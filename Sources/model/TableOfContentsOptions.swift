//
//  TableOfContentsOptions.swift
//  
//
//  Created by Anton Leuski on 8/3/23.
//

import Foundation
import ArgumentParser

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

  @Option(help: .init("""
    The HTML heading tags to include into the Table of Contents.  \
    A comma seprated list of heading levels. \
    Default value provided.
    """, valueName: "list of numbers"))
  var tocHeadings: String = "1,2,3"

  @Option(help: .init("""
    The depth of the Table of Contents. The effect is different from the \
    allowed headings list. For example, if your document has
      <h1>...</h1>
      <h3>Heading 3</h3>
    and you set the depth to 2, \
    'Heading 3' will be included in the table. If, on the other hand, you have
      <h1>...</h1>
      <h2>...</h2>
      <h3>Heading 3</h3>
    here, there is an h2 tag between <h1> \
    and <h3>, -- 'Heading 3' will not be included in the table. \
    Default value provided.
    """, valueName: "depth"))
  var tocDepth: Int = 6

  @Flag(help: .init("""
    Generate the document outline in the final PDF. The table of Contents is \
    a part of the document itself. The outline is the navigation menu in the \
    PDF.
    """))
  var outline: Bool = false

  @Option(help: .init("""
    The HTML heading tags to include into the Table of Contents.  \
    A comma seprated list of heading levels. \
    Default value provided.
    """, valueName: "list of numbers"))
  var outlineHeadings: String = "1,2,3"

  @Option(help: .init("""
    The depth of the outline. The effect is different from the \
    allowed headings list. For example, if your document has
      <h1>...</h1>
      <h3>Heading 3</h3>
    and you set the depth to 2, \
    'Heading 3' will be included in the outline. If, on the other hand, you have
      <h1>...</h1>
      <h2>...</h2>
      <h3>Heading 3</h3>
    here, there is an h2 tag between <h1> \
    and <h3>, -- 'Heading 3' will not be included in the outline. \
    Default value provided.
    """, valueName: "depth"))
  var outlineDepth: Int = 6
}
