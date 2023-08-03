//
//  TOCEntry.swift
//  yahtml2pdf
//
//  Created by Anton Leuski on 8/1/23.
//

import Foundation
import PDFKit

/// An entry in the document table of content.
final class TOCEntry: CustomStringConvertible {
  let heading: Heading
  let pageIndex: Int
  let page: PDFPage
  let point: NSPoint
  var items: [TOCEntry]

  internal init(
    heading: Heading,
    pageIndex: Int = 0,
    page: PDFPage,
    point: NSPoint = .zero,
    items: [TOCEntry] = [])
  {
    self.heading = heading
    self.pageIndex = pageIndex
    self.page = page
    self.point = point
    self.items = items
  }

  var description: String {
    "\(heading.identifier) \(heading.level) { " + items.description + " } "
  }

}

struct TOCTreeFilter {
  let allowedLevels: Set<Int>
  let maximumDepth: Int

  init(allowedLevels: Set<Int>, maximumDepth: Int) {
    self.allowedLevels = allowedLevels
    self.maximumDepth = maximumDepth
  }

  init(levels: String, maximumDepth: Int) {
    self.init(
      allowedLevels: Set(levels
        .split(separator: ",")
        .compactMap { string in Int(string) }),
      maximumDepth: maximumDepth)
  }

  func acceptable(_ entry: TOCEntry, at depth: Int) -> Bool {
    allowedLevels.contains(entry.heading.level) && depth <= maximumDepth
  }
}

extension TOCEntry {
  func outlineItem(
    filter: TOCTreeFilter,
    depth: Int = 0) -> PDFOutline
  {
    let item = PDFOutline()
    item.label = heading.content
    item.destination = PDFDestination(page: page, at: point)
    items.forEach { entry in
      guard filter.acceptable(entry, at: depth+1) else { return }
      item.insertChild(
        entry.outlineItem(filter: filter, depth: depth+1),
        at: item.numberOfChildren)
    }
    return item
  }
}

let tocXMLNamespaceURI = "https://github.com/leuski/yahtml2pdf"

extension TOCEntry {
  var serializedDestination: String? {
    PageDestination(page: pageIndex, point: point).fragment
  }

  func tocXMLElement(
    filter: TOCTreeFilter,
    depth: Int = 0) -> XMLElement
  {
    let element = XMLElement(name: "item", uri: tocXMLNamespaceURI)
    element.addAttribute(name: "title", value: heading.content)
    element.addAttribute(name: "page", value: String(pageIndex+1))
    serializedDestination.map { link in
      element.addAttribute(
        name: "link", value: dummyURLPrefix + link)
    }
    element.setChildren(items.compactMap {
      entry in
      guard filter.acceptable(entry, at: depth+1) else { return nil }
      return entry.tocXMLElement(filter: filter, depth: depth+1)
    })
    return element
  }

  func tocXMLDocument(filter: TOCTreeFilter) -> XMLDocument {
    let document = XMLDocument(
      rootElement: .init(name: "outline", uri: tocXMLNamespaceURI))
    XMLNode.namespace(value: tocXMLNamespaceURI)
      .map { node in document.rootElement()?.addNamespace(node) }
    document.characterEncoding = "UTF-8"
    document.version = "1.0"
    document.rootElement()?.addChild(tocXMLElement(filter: filter))
    return document
  }
}
