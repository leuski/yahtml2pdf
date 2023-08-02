//
//  PageDestination.swift
//  yahtml2pdf
//
//  Created by Anton Leuski on 8/1/23.
//

import Foundation

/// Codable PDFDestination. Stores a page index and a point. Can be converted
/// to and from a URL fragment
struct PageDestination: Codable {
  let page: Int
  let point: NSPoint

  var fragment: String? {
    try? JSONEncoder().encode(self).base64EncodedString()
      .addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
  }

  init?(fragment: String) {
    let value = fragment.removingPercentEncoding.flatMap { string in
      Data(base64Encoded: string).flatMap { data in
        try? JSONDecoder().decode(Self.self, from: data)
      }
    }
    guard let value = value else { return nil }
    self = value
  }

  internal init(page: Int, point: NSPoint) {
    self.page = page
    self.point = point
  }
}
