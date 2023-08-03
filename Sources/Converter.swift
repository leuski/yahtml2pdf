//
//  Converter.swift
//  yahtml2pdf
//
//  Created by Anton Leuski on 7/31/23.
//

import Foundation
import ArgumentParser
import WebKit
import Combine
import PDFKit

let dummyURLPrefix = "http://dummy/#"

struct TableOfContentsOptions: ParsableArguments {
  @Flag(help: .init("""
    Generate Table of Content and insert it in front of the document.
    """))
  var toc: Bool = false

  @Option(help: .init("""
    The path where to store the TOC xml file. Normally we do not save \
    the xml file but convert it into HTML. This might be useful for \
    debugging the XSL stylesheet. If omitted, no file is saved. \
    Optional.
    """, valueName: "path to store TOC XML file"))
  var dumpToc: String?

  @Option(help: .init("""
    The path to a custom xsl stylesheet for creating the Table of Content. \
    Optional.
    """, valueName: "path to xsl stylesheet"))
  var xslStyleSheet: String?

  @Option(help: .init("""
    The path for the CSS style sheet to include with the table of contents \
    Optional.
    """, valueName: "path to style sheet"))
  var tocUserStyleSheet: String?

  @Option(help: .init("""
    The language for the table of contents.  \
    Default value provided.
    """, valueName: "language code"))
  var tocLanguage: String = "en"

  @Option(help: .init("""
    The title for the table of contents.  \
    Default value provided.
    """, valueName: "string"))
  var tocTitle: String = "Table of Contents"

  @Flag(help: .init("""
    Generate the document outline in the final PDF. The table of Contents is \
    a part of the document itself. The outline is the navigation menu in the \
    PDF.
    """))
  var outline: Bool = false
}

struct PageOptions: ParsableArguments {
  @Option(help: .init("""
    Left page margin. Can be specified in points (pt), inches (in), \
    millimeters (mm), or centimeters (cm). Default value provided.
    """, valueName: "length value"))
  var marginLeft: Measurement<UnitLength> = .init(value: 1, unit: .inches)

  @Option(help: .init("""
    Right page margin. Can be specified in points (pt), inches (in), \
    millimeters (mm), or centimeters (cm). Default value provided.
    """, valueName: "length value"))
  var marginRight: Measurement<UnitLength> = .init(value: 1, unit: .inches)

  @Option(help: .init("""
    Top page margin. Can be specified in points (pt), inches (in), \
    millimeters (mm), or centimeters (cm). Default value provided.
    """, valueName: "length value"))
  var marginTop: Measurement<UnitLength> = .init(value: 1, unit: .inches)

  @Option(help: .init("""
    Bottom page margin. Can be specified in points (pt), inches (in), \
    millimeters (mm), or centimeters (cm). Default value provided.
    """, valueName: "length value"))
  var marginBottom: Measurement<UnitLength> = .init(value: 1, unit: .inches)

  @Option(help: .init("""
    Paper width. Can be specified in points (pt), inches (in), \
    millimeters (mm), or centimeters (cm). You must supply either both \
    paper-width and paper-height values or neither. If you provide only \
    one of them, it will be ignored. If both are omitted, the default \
    paper size "\(NSPrintInfo().localizedPaperName ?? "n/a")" will be used. \
    Optional.
    """, valueName: "length value"))
  var paperWidth: Measurement<UnitLength>?

  @Option(help: .init("""
    Paper height. Can be specified in points (pt), inches (in), \
    millimeters (mm), or centimeters (cm). Optional.
    """, valueName: "length value"))
  var paperHeight: Measurement<UnitLength>?
}

@main
struct Converter: ParsableCommand {

  static var configuration = CommandConfiguration(
    commandName: "yahtml2pdf",
    abstract: """
      Converts an HTML file into a PDF using WebKit. Supports generating \
      the table of contents and including a cover page.
      """)

  @Argument(help: .init("""
    The path to the source HTML file.
    """))
  var inputPath: String

  @Argument(help: .init("""
    The path to the final PDF file.
    """))
  var outputPath: String

  @OptionGroup(title: "Table of Contents")
  var tocOptions: TableOfContentsOptions

  @Option(help: .init("""
    The path to the cover page html file if a cover page is required. \
    Optional.
    """, valueName: "path to the cover page html"))
  var cover: String?

  @OptionGroup(title: "Page Options")
  var pageOptions: PageOptions

  @Flag(help: .init(
    "Keep temporary files around for debugging", visibility: .private))
  var keepTmpFiles: Bool = false

  func run() throws {
    let inputURL = inputPath.filePathURL
    let outputURL = outputPath.filePathURL

    // write into a temporary PDF file
    let tmpOutputURL = URL.temporaryDirectory
      .appendingPathComponent(outputURL.lastPathComponent)

    if tocOptions.toc || tocOptions.outline {
      // if either TOC or outline are requested, we need to collect header
      // tag page placement. We insert a dummy anchor tags next to each
      // h tag, then examine the resulting PDF to find the tag page placement
      // and remove the dummy anchors
      //
      // insert anchors first.
      let (tmpURL, headers) = try insertHeaderMarkers(input: inputURL)
      defer {
        if !keepTmpFiles {
          try? FileManager.default.removeItem(at: tmpURL)
        }
      }
      // print the pages
      try Printer(command: self).run(input: tmpURL, output: tmpOutputURL)
      // make the TOC and outline
      try makeOutline(
        source: inputURL.deletingLastPathComponent(),
        pdf: tmpOutputURL,
        headers: headers)
    } else {
      // just print the pages to PDF
      try Printer(command: self).run(input: inputURL, output: tmpOutputURL)
    }

    if let cover = cover {
      // if we need a cover page, print it into PDF
      let coverOutputURL = URL.temporaryDirectory
        .appendingPathComponent(UUID().uuidString + ".pdf")
      try Printer(command: self).run(
        input: cover.filePathURL, output: coverOutputURL)
      // and insert into the temporary document
      try insertCover(coverOutputURL, into: tmpOutputURL)
    }

    // finally move the temporary file into the final location.
    try? FileManager.default.removeItem(at: outputURL)
    try FileManager.default.moveItem(at: tmpOutputURL, to: outputURL)
  }

  func insertHeaderMarkers(input inputURL: URL) throws -> (URL, [Header]) {
    // take the existing html and modify the h tags.
    let tmpURL = inputURL.deletingLastPathComponent()
      .appendingPathComponent("al.tmp.html")
    let (html, headers) = tagHeaders(in: try String(contentsOf: inputURL))
    try html.write(to: tmpURL, atomically: true, encoding: .utf8)
    return (tmpURL, headers)
  }

  func insertCover(_ cover: URL, into content: URL) throws {
    let document = try PDFDocument.document(at: content)
    let cover = try PDFDocument.document(at: cover)
    document.insert(cover.pages, at: 0)
    try document.write(to: content, atomically: false)
  }
  
}

extension Converter {

  func makeTOC(
    source sourceURL: URL,
    document: PDFDocument,
    entryRoot: TOCEntry) throws
  {
    // make the xml document for the outline
    // it has a link for every TOC entry, the links are dummy URLs
    // with the page inde and page location, we need this so we can
    // extract it out of the PDF later.
    let tocXML = entryRoot.tocXMLDocument

    if let tocURL = tocOptions.dumpToc?.filePathURL {
      try tocXML
        .xmlData(options: [
          .nodePrettyPrint,
          .nodeCompactEmptyElement,
          .documentTidyXML,
          .documentIncludeContentTypeDeclaration])
        .write(to: tocURL)
    }

    // convert the outline xml into html
    let tocHTML: XMLDocument?
    var arguments = [String: String]()
    arguments["style-sheet"] = tocOptions.tocUserStyleSheet?.xsltParameter
    arguments["lang"] = tocOptions.tocLanguage.xsltParameter
    arguments["title"] = tocOptions.tocTitle.xsltParameter
    if let xsltURL = tocOptions.xslStyleSheet?.filePathURL {
      tocHTML = try tocXML.documentByApplyingXSLT(
        at: xsltURL, arguments: arguments)
    } else {
      tocHTML = try tocXML.documentByApplyingXSLT(
        defaultTocXsl, arguments: arguments)
    }

    // save the html in the source directory so we can use
    // other files, e.g., stylesheet if we want to
    let tocURL = sourceURL.appendingPathComponent("al.toc.html")
    try tocHTML?
      .xmlData(options: [
        .nodePrettyPrint,
        .documentTidyHTML,
        .documentIncludeContentTypeDeclaration])
      .write(to: tocURL)
    defer {
      if !keepTmpFiles {
        try? FileManager.default.removeItem(at: tocURL)
      }
    }

    // print TOC html into pdf
    let tocPDF = tocURL.deletingPathExtension().appendingPathExtension("pdf")
    try Printer(command: self).run(input: tocURL, output: tocPDF)
    defer {
      if !keepTmpFiles {
        try? FileManager.default.removeItem(at: tocPDF)
      }
    }

    // load the TOC pdf and replace dummy anchors with the corresponding
    // PDF links to the page the content document
    let tocDocument = try PDFDocument.document(at: tocPDF)
    tocDocument.pages.forEach { page in
      guard let page = page else { return }

      page.ourAnnotations.forEach { annotation, fragment in
        guard
          let storedDestination = PageDestination(fragment: fragment),
          let page = document.page(at: storedDestination.page)
        else { return }

        let destination = PDFDestination(
          page: page, at: storedDestination.point)

        annotation.action = PDFActionGoTo(destination: destination)
      }
    }

    // now insert the TOC pages into the original document.
    document.insert(tocDocument.pages, at: 0)
  }

  func makeOutline(
    source sourceURL: URL, pdf inputURL: URL, headers: [Header]) throws
  {
    let document = try PDFDocument.document(at: inputURL)

    // extract the TOC hierarchy
    guard let entryRoot = document.toc(headers: headers)
    else { return }

    if tocOptions.outline {
      // make the outline
      document.outlineRoot = entryRoot.outlineItem
    }

    if tocOptions.toc {
      // make the TOC
      try makeTOC(source: sourceURL, document: document, entryRoot: entryRoot)
    }

    // save the changes
    try document.write(to: inputURL, atomically: false)
  }
}
