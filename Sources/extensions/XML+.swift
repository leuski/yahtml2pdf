//
//  XML+.swift
//  yahtml2pdf
//
//  Created by Anton Leuski on 8/1/23.
//

import Foundation

extension XMLElement {
  func addAttribute(name: String, value: String) {
    guard let node = XMLNode
      .attribute(withName: name, stringValue: value) as? XMLNode
    else { return }
    addAttribute(node)
  }
}

extension XMLNode {
  static func namespace(name: String = "", value: String) -> XMLNode? {
    namespace(withName: name, stringValue: value) as? XMLNode
  }
}

extension XMLDocument {
  func documentByApplyingXSLT(
    at url: URL, arguments: [String: String]? = nil) throws -> XMLDocument?
  {
    try objectByApplyingXSLT(at: url, arguments: arguments) as? XMLDocument
  }

  func documentByApplyingXSLT(
    _ string: String, arguments: [String: String]? = nil) throws -> XMLDocument?
  {
    try object(
      byApplyingXSLTString: string, arguments: arguments) as? XMLDocument
  }
}
