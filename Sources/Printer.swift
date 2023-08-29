//
//  Printer.swift
//  yahtml2pdf
//
//  Created by Anton Leuski on 8/1/23.
//

import Foundation
import WebKit
import Combine

/// Uses WKWebView machinery to load an HTML file with styles and images
/// and print the content into a PDF file. This is using the printing
/// process, so the Print media CSS instructions are applied and the
/// final PDF is correctly paginated.
final class Printer: NSObject, @unchecked Sendable {
  internal init(command: Converter) {
    self.command = command
  }

  let command: Converter
  var observers = Set<AnyCancellable>()
  var shouldKeepRunning = true

  @MainActor
  func printView(_ webView: WKWebView, to outputURL: URL) {
    let printInfo = NSPrintInfo(dictionary: [
      .jobDisposition: NSPrintInfo.JobDisposition.save,
      .jobSavingURL: outputURL,
      .detailedErrorReporting: true
    ])

    printInfo.horizontalPagination = .automatic
    printInfo.verticalPagination = .automatic
    printInfo.isVerticallyCentered = false
    printInfo.isHorizontallyCentered = false

    let command = self.command.pageOptions
    
    if
      let width = command.paperWidth?.converted(to: .points).value,
      let height = command.paperHeight?.converted(to: .points).value
    {
      printInfo.paperSize = .init(width: width, height: height)
    }

    printInfo.leftMargin = command.marginLeft.converted(to: .points).value
    printInfo.rightMargin = command.marginRight.converted(to: .points).value
    printInfo.topMargin = command.marginTop.converted(to: .points).value
    printInfo.bottomMargin = command.marginBottom.converted(to: .points).value

    let operation = webView.printOperation(with: printInfo)
    operation.view?.frame = .init(
      origin: .zero, size: .init(width: 500, height: 1000))
    operation.showsPrintPanel = false
    operation.showsProgressPanel = false

    operation.runModal(
      for: NSWindow(),
      delegate: self,
      didRun: #selector(
        printOperationDidRun(printOperation:success:contextInfo:)),
      contextInfo: nil)
  }

  @objc func printOperationDidRun(
    printOperation: NSPrintOperation,
    success: Bool,
    contextInfo: UnsafeMutableRawPointer?)
  {
    shouldKeepRunning = false
  }

  @MainActor
  private func _run(input inputURL: URL, output outputURL: URL) {
    let config = WKWebViewConfiguration()
    let webView = WKWebView(
      frame: .init(origin: .zero, size: .init(width: 500, height: 1000)),
      configuration: config)

    webView.loadFileURL(inputURL, allowingReadAccessTo: "/".filePathURL)
    webView.publisher(for: \.isLoading)
      .receive(on: RunLoop.main)
      .sink { value in
        if !value {
          self.printView(webView, to: outputURL)
        }
      }
      .store(in: &observers)
  }

  func run(input inputURL: URL, output outputURL: URL) throws {

    Task { @MainActor in
      self._run(input: inputURL, output: outputURL)
    }

    let theRL = RunLoop.current
    while
      shouldKeepRunning
        && theRL.run(mode: .default, before: .distantFuture) {}
  }
}
