//
//  String+.swift
//  yahtml2pdf
//
//  Created by Anton Leuski on 8/1/23.
//

import Foundation

extension String {
  var filePathURL: URL {
    URL(fileURLWithPath: self)
  }

  var xsltParameter: String {
    "'\(self)'"
  }
}
