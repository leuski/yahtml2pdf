//
//  Header.swift
//  yahtml2pdf
//
//  Created by Anton Leuski on 8/1/23.
//

import Foundation

/// an html header element that has an id attribute
struct Header: CustomStringConvertible {
  internal init(level: Int = 0, identifier: String = "", content: String = "") {
    self.level = level
    self.identifier = identifier
    self.content = content
  }

  let level: Int
  let identifier: String
  let content: String

  var description: String {
    "\(identifier) \(level) \(content)"
  }
}

/// Given an html document tag every h tag with a dummy anchor.
func tagHeaders(in html: String) -> (String, [Header]) {
  var headers = [Header]()

  let taggedHTML = html.replacing(#/<[Hh](.)(.*?)>(.*?)</[Hh].>/#) { match in
    let level = match.1
    let content = match.3
    let id: String
    let attributes = String(match.2)

    if let existingID = attributes.firstMatch(of: /id="(.*?)"/)?.1 {
      id = String(existingID)
    } else {
      id = "__al_tmp_\(headers.count)"
    }

    headers.append(.init(
      level: Int(level) ?? 1,
      identifier: id,
      content: String(content)))

    // rewrite the h tag so it has the dummy anchor
    return """
          <h\(level)\(attributes)>\(content)\
          <a href="\(dummyURLPrefix)\(id)">&nbsp;</a>
          </h\(level)>
          """
  }
  
  return (taggedHTML, headers)
}

