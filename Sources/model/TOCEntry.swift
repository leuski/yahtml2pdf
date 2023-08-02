//
//  TOCEntry.swift
//  yahtml2pdf
//
//  Created by Anton Leuski on 8/1/23.
//

import Foundation
import PDFKit

/// An entry in the document table of content.
final class Entry: CustomStringConvertible {
  let header: Header
  let pageIndex: Int
  let page: PDFPage
  let point: NSPoint
  var items: [Entry]

  internal init(
    header: Header,
    pageIndex: Int = 0,
    page: PDFPage,
    point: NSPoint = .zero,
    items: [Entry] = [])
  {
    self.header = header
    self.pageIndex = pageIndex
    self.page = page
    self.point = point
    self.items = items
  }

  var description: String {
    "\(header.identifier) \(header.level) { " + items.description + " } "
  }

}

extension Entry {
  var outlineItem: PDFOutline {
    let item = PDFOutline()
    item.label = header.content
    item.destination = PDFDestination(page: page, at: point)
    items.enumerated().forEach { index, entry in
      item.insertChild(entry.outlineItem, at: index)
    }
    return item
  }
}

extension Entry {
  var serializedDestination: String? {
    PageDestination(page: pageIndex, point: point).fragment
  }

  var tocXMLElement: XMLElement {
    let element = XMLElement(name: "item")
    element.addAttribute(name: "title", value: header.content)
    element.addAttribute(name: "page", value: String(pageIndex+1))
    serializedDestination.map { link in
      element.addAttribute(
        name: "link", value: dummyURLPrefix + link)
    }
    element.setChildren(items.map { item in item.tocXMLElement })
    return element
  }

  var tocXMLDocument: XMLDocument {
    let document = XMLDocument(
      rootElement: .init(
        name: "outline", uri: "http://wkhtmltopdf.org/outline"))
    XMLNode.namespace(value: "http://wkhtmltopdf.org/outline")
      .map { node in document.rootElement()?.addNamespace(node) }
    document.characterEncoding = "UTF-8"
    document.version = "1.0"
    document.rootElement()?.addChild(tocXMLElement)
    return document
  }
}
