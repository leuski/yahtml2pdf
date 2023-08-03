//
//  PageOptions.swift
//  
//
//  Created by Anton Leuski on 8/3/23.
//

import Foundation
import WebKit
import ArgumentParser

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
