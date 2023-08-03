//
//  PDFDocument+.swift
//  yahtml2pdf
//
//  Created by Anton Leuski on 8/1/23.
//

import Foundation
import PDFKit

// streamline some operations
extension PDFDocument {
  var pages: [PDFPage?] {
    (0..<pageCount).map { index in page(at: index) }
  }

  func insert(_ pages: [PDFPage], at index: Int) {
    pages.reversed().forEach { page in
      insert(page, at: index)
    }
  }

  func insert(_ pages: [PDFPage?], at index: Int) {
    insert(pages.compactMap { $0 }, at: index)
  }
}

enum PDFError: LocalizedError {
  case failedToRead(URL)
  case failedToWrite(URL)
}

// make sure we throw if the pdf fails to load or save.
extension PDFDocument {
  static func document(at url: URL) throws -> PDFDocument {
    guard let document = PDFDocument(url: url)
    else { throw PDFError.failedToRead(url) }
    return document
  }

  func write(to url: URL, atomically: Bool) throws {
    if atomically {
      let tmpURL = URL.temporaryDirectory
        .appendingPathComponent(url.lastPathComponent)
      guard self.write(to: tmpURL)
      else { throw PDFError.failedToWrite(tmpURL) }
      try FileManager.default.moveItem(at: tmpURL, to: url)
    } else {
      guard self.write(to: url)
      else { throw PDFError.failedToWrite(url) }
    }
  }
}

extension PDFDocument {
  /// compute the TOC entries for each h tag described in the argument.
  /// the result is a TOC tree.
  func toc(headings: [Heading]) -> TOCEntry? {
    // we need a page for the root element
    guard let firstPage = page(at: 0) else { return nil }

    let headingIndices = Dictionary(
      headings.enumerated()
        .map { index, header in (header.identifier, index) }) { old, _ in old }

    var entries = [String: (TOCEntry, Int)]()

    pages.enumerated().forEach { pageIndex, page in
      guard let page = page else { return }

      let annotations = page.ourAnnotations

      annotations.forEach { annotation, id in
        let bounds = annotation.bounds
        page.removeAnnotation(annotation)
        guard let headerIndex = headingIndices[id] else { return }
        entries[id] = (.init(
          heading: headings[headerIndex],
          pageIndex: pageIndex,
          page: page,
          // left side of the page and 1/2 inch above the text
          point: .init(x: 0, y: bounds.maxY + 36)), headerIndex)
      }
    }

    var stack = [TOCEntry]()
    stack.append(TOCEntry(heading: .init(content: "Root"), page: firstPage))

    entries.values
      .sorted { lhs, rhs in lhs.1 < rhs.1 }
      .map { pair in pair.0 }
      .forEach { entry in
        while true {
          guard let current = stack.last else { return }
          if current.heading.level >= entry.heading.level {
            stack.removeLast()
          }
          if current.heading.level <= entry.heading.level {
            stack.last?.items.append(entry)
            stack.append(entry)
            return
          }
        }
      }

    return stack.first
  }
}

extension PDFPage {
  /// return a list of the annotations that contain our dummy links.
  /// For each such annotation also return the payload string from the
  /// url.
  var ourAnnotations: [(PDFAnnotation, String)] {
    annotations.compactMap { annotation in
      guard
        let url = annotation.url,
        url.absoluteString.hasPrefix(dummyURLPrefix)
      else { return nil }
      return (
        annotation, String(url.absoluteString.dropFirst(dummyURLPrefix.count)))
    }
  }
}
