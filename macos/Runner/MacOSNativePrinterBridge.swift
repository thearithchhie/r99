import AppKit
import Cocoa
import FlutterMacOS

final class MacOSNativePrinterBridge: NSObject {
  static let channelName = "r99/macos_native_printer"

  static func register(with flutterViewController: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    let instance = MacOSNativePrinterBridge()
    channel.setMethodCallHandler { call, result in
      instance.handle(call: call, result: result)
    }
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "listPrinters":
      result(NSPrinter.printerNames.sorted())
    case "printImage":
      guard
        let args = call.arguments as? [String: Any],
        let printerName = args["printerName"] as? String,
        let imageBytes = (args["imageBytes"] as? FlutterStandardTypedData)?.data
      else {
        result(
          FlutterError(
            code: "bad_args",
            message: "Missing printerName or imageBytes",
            details: nil
          )
        )
        return
      }

      do {
        try printImage(data: imageBytes, printerName: printerName)
        result(nil)
      } catch {
        result(
          FlutterError(
            code: "print_failed",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func printImage(data: Data, printerName: String) throws {
    guard let printer = NSPrinter(name: printerName) else {
      throw NSError(
        domain: "MacOSNativePrinterBridge",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Printer '\(printerName)' not found in macOS."]
      )
    }

    guard let image = NSImage(data: data) else {
      throw NSError(
        domain: "MacOSNativePrinterBridge",
        code: 2,
        userInfo: [NSLocalizedDescriptionKey: "Unable to decode preview image."]
      )
    }

    let pageWidthPoints = mmToPoints(58.0)
    let imageAspectRatio = image.size.width > 0 ? image.size.height / image.size.width : 1.0
    let pageHeightPoints = max(pageWidthPoints * imageAspectRatio, mmToPoints(80.0))
    let pageSize = NSSize(width: pageWidthPoints, height: pageHeightPoints)

    let printInfo = NSPrintInfo.shared.copy() as! NSPrintInfo
    printInfo.printer = printer
    printInfo.paperSize = pageSize
    printInfo.topMargin = 0
    printInfo.bottomMargin = 0
    printInfo.leftMargin = 0
    printInfo.rightMargin = 0
    printInfo.horizontalPagination = .fitPagination
    printInfo.verticalPagination = .fitPagination
    printInfo.isHorizontallyCentered = false
    printInfo.isVerticallyCentered = false
    printInfo.orientation = .portrait

    let printView = ReceiptPrintView(frame: NSRect(origin: .zero, size: pageSize), image: image)
    let operation = NSPrintOperation(view: printView, printInfo: printInfo)
    operation.showsPrintPanel = false
    operation.showsProgressPanel = false

    if !operation.run() {
      throw NSError(
        domain: "MacOSNativePrinterBridge",
        code: 3,
        userInfo: [NSLocalizedDescriptionKey: "macOS print operation failed."]
      )
    }
  }

  private func mmToPoints(_ value: CGFloat) -> CGFloat {
    value / 25.4 * 72.0
  }
}

final class ReceiptPrintView: NSView {
  private let image: NSImage

  init(frame frameRect: NSRect, image: NSImage) {
    self.image = image
    super.init(frame: frameRect)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var isFlipped: Bool {
    true
  }

  override func draw(_ dirtyRect: NSRect) {
    NSColor.white.setFill()
    bounds.fill()

    let imageSize = image.size
    guard imageSize.width > 0, imageSize.height > 0 else { return }

    let scale = min(bounds.width / imageSize.width, bounds.height / imageSize.height)
    let targetSize = NSSize(width: imageSize.width * scale, height: imageSize.height * scale)
    let targetRect = NSRect(
      x: 0,
      y: 0,
      width: targetSize.width,
      height: targetSize.height
    )

    image.draw(
      in: targetRect,
      from: NSRect(origin: .zero, size: imageSize),
      operation: .sourceOver,
      fraction: 1.0
    )
  }
}
