//
//  Measurement+Argument.swift
//  yahtml2pdf
//
//  Created by Anton Leuski on 8/1/23.
//

import Foundation
import ArgumentParser

/// Supports parsing of the measurement units in the arguments.
/// We can handle points, mm, cm, and inches.
extension Measurement: ExpressibleByArgument
where UnitType == UnitLength
{
  public init?(argument: String) {
    guard
      let match = argument
        .firstMatch(of: #/([-+\d\.]+)(\s*(\w+))?/#),
      let value = Double(match.1)
    else { return nil }

    guard let unit = match.3 else {
      self = .init(value: value / 72.0, unit: .inches)
      return
    }

    for dimension in [UnitLength.inches, .centimeters, .millimeters, .points]
    where dimension.symbol == unit {
      self = .init(value: value, unit: dimension)
      return
    }

    return nil
  }
}

extension UnitLength {
  static var points: UnitLength {
    .init(
      symbol: "pt",
      converter: UnitConverterLinear(coefficient: 0.000352777777778))
  }
}
