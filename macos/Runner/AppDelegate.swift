import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

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
    case "printTemplate":
      guard
        let args = call.arguments as? [String: Any],
        let printerName = args["printerName"] as? String,
        let templateMap = args["template"] as? [String: Any]
      else {
        result(
          FlutterError(
            code: "bad_args",
            message: "Missing printerName or template",
            details: nil
          )
        )
        return
      }

      do {
        let template = try MacOSPrintTemplate(map: templateMap)
        try printTemplate(template, printerName: printerName)
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
    case "printImage":
      result(
        FlutterError(
          code: "deprecated_path",
          message: "Image-based macOS printing is disabled for this printer path. Use template printing instead.",
          details: nil
        )
      )
      return
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func printTemplate(_ template: MacOSPrintTemplate, printerName: String) throws {
    guard let printer = NSPrinter(name: printerName) else {
      throw NSError(
        domain: "MacOSNativePrinterBridge",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Printer '\(printerName)' not found in macOS."]
      )
    }

    let pageWidthPoints = mmToPoints(58.0)
    let pageHeightPoints = mmToPoints(102.0)
    let pageSize = NSSize(width: pageWidthPoints, height: pageHeightPoints)

    let printInfo = NSPrintInfo.shared.copy() as! NSPrintInfo
    printInfo.printer = printer
    printInfo.paperSize = pageSize
    printInfo.topMargin = 0
    printInfo.bottomMargin = 0
    printInfo.leftMargin = 0
    printInfo.rightMargin = 0
    printInfo.horizontalPagination = .fit
    printInfo.verticalPagination = .fit
    printInfo.isHorizontallyCentered = false
    printInfo.isVerticallyCentered = false
    printInfo.orientation = .portrait

    let printView = NativeTemplatePrintView(frame: NSRect(origin: .zero, size: pageSize), template: template)
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

struct MacOSPrintTemplate {
  let customerName: String
  let pageName: String
  let phoneLines: [String]
  let locationLines: [String]
  let selectedOption: String
  let totalPrice: String
  let currency: String
  let guestServiceChecked: Bool
  let virakChecked: Bool
  let jtChecked: Bool
  let otherChecked: Bool

  init(map: [String: Any]) throws {
    func string(_ key: String) -> String { map[key] as? String ?? "" }
    func bool(_ key: String) -> Bool { map[key] as? Bool ?? false }
    func strings(_ key: String) -> [String] { map[key] as? [String] ?? [] }

    customerName = string("customerName")
    pageName = string("pageName")
    phoneLines = strings("phoneLines")
    locationLines = strings("locationLines")
    selectedOption = string("selectedOption")
    totalPrice = string("totalPrice")
    currency = string("currency")
    guestServiceChecked = bool("guestServiceChecked")
    virakChecked = bool("virakChecked")
    jtChecked = bool("jtChecked")
    otherChecked = bool("otherChecked")
  }

  var amountText: String {
    let value = totalPrice.isEmpty ? selectedOption : totalPrice
    return "\(currency)\(value)"
  }

  var serviceText: String {
    var values: [String] = []
    if guestServiceChecked { values.append("Guest") }
    if virakChecked { values.append("Virak") }
    if jtChecked { values.append("J&T") }
    if otherChecked { values.append("Other") }
    return values.isEmpty ? "-" : values.joined(separator: " • ")
  }

  var shouldShowShopHeader: Bool {
    shopDisplayName != nil
  }

  var shopDisplayName: String? {
    let normalized = customerName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if normalized.isEmpty || normalized == "shop" || normalized == "r99" || normalized == "key_r99" {
      return "R99"
    }
    if normalized == "r99-ii" || normalized == "r99 ii" || normalized == "r99 2" || normalized == "key_r99_ii" {
      return "R99-II"
    }
    return nil
  }
}

final class NativeTemplatePrintView: NSView {
  private let template: MacOSPrintTemplate
  private let accentColor = NSColor.black
  private(set) var neededPageHeight: CGFloat = 0

  init(frame frameRect: NSRect, template: MacOSPrintTemplate) {
    self.template = template
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
    NSGraphicsContext.current?.imageInterpolation = .none

    let outerTop: CGFloat = 1
    let outerSideInset: CGFloat = 1
    let outerWidth = bounds.width - (outerSideInset * 2)
    let minOuterHeight: CGFloat = 40

    var y = outerTop + 8
    let contentX = outerSideInset + 6
    let contentWidth = outerWidth - 12

    if template.shouldShowShopHeader {
      y = drawPageHeader(
        title: "ឈ្មោះផេកៈ \(template.shopDisplayName ?? "R99")",
        y: y,
        width: contentWidth,
        x: contentX
      )
      y = drawSenderPhoneHeader(
        title: "លេខទូរស័ព្ទអ្នកផ្ញើរ ឬ វេរលុយ",
        phone: "097 71 56 486",
        y: y + 2,
        width: contentWidth,
        x: contentX
      )
      y += 4
    }

    y = drawSection(
      iconName: "person.fill",
      title: "ឈ្មោះអតិថិជន",
      lines: [template.pageName.isEmpty ? "-" : template.pageName],
      y: y,
      topMargin: 2,
      bottomMargin: -8,
      titleBoxGap: 2,
      minBoxHeight: 22,
      titleFont: khmerFont(size: 11, weight: .bold),
      bodyFont: NSFont.boldSystemFont(ofSize: 12.5),
      contentX: contentX,
      contentWidth: contentWidth
    )

    y = drawSection(
      iconName: "phone.fill",
      title: "លេខទូរស័ព្ទអ្នកទទួល",
      lines: template.phoneLines.isEmpty ? ["-"] : template.phoneLines,
      y: y + 2,
      topMargin: 4,
      bottomMargin: -6, // -8
      titleBoxGap: 2,
      minBoxHeight: 16,
      titleFont: khmerFont(size: 11, weight: .bold),
      bodyFont: NSFont.boldSystemFont(ofSize: 11),
      contentX: contentX,
      contentWidth: contentWidth
    )

    y = drawSection(
      iconName: "mappin.circle.fill",
      title: "ទីតាំង",
      lines: template.locationLines.isEmpty ? ["-"] : template.locationLines,
      y: y,
      topMargin: 4,
      bottomMargin: -8,
      titleBoxGap: 2,
      minBoxHeight: 10,
      titleFont: khmerFont(size: 11, weight: .bold),
      bodyFont: khmerFont(size: 8.8, weight: .bold),
      contentX: contentX,
      contentWidth: contentWidth
    )

    let amountRect = NSRect(x: contentX, y: y + 4, width: contentWidth, height: 22)
    drawRoundedBox(amountRect)
    drawLeadingIcon("truck.box.fill", rect: NSRect(x: amountRect.minX + 8, y: amountRect.minY + 8, width: 12, height: 12))
   
    _ = drawText(
      "សេវាដឹក",
      rect: NSRect(x: amountRect.minX + 23, y: amountRect.minY + 8, width: 60, height: 10),
      font: khmerFont(size: 10.2, weight: .bold)
    )
    _ = drawText(
      "តម្លៃ: \(template.amountText)",
      rect: NSRect(x: amountRect.minX + 84, y: amountRect.minY + 8, width: amountRect.width - 84, height: 15),
      font: khmerFont(size: 9.8, weight: .bold),
      alignment: .right
    )
    y = amountRect.maxY + 3

    let chipGap: CGFloat = 6
    let chipWidth = (contentWidth - chipGap * 2) / 3
    let chips = [
      (label: "សេវាខាងភ្ញៀវ", selected: template.guestServiceChecked),
      (label: "VAT", selected: template.virakChecked),
      (label: "J&T", selected: template.jtChecked),
    ]
    let chipLabelFont = khmerFont(size: 8.5, weight: .bold)
    let chipLabelWidth = chipWidth - 26
    let rawChipLabelHeight = chips.map { textHeight($0.label, width: chipLabelWidth, font: chipLabelFont) }.max() ?? 12
    let chipHeight = max(22, rawChipLabelHeight + 10)

    for (index, chip) in chips.enumerated() {
      let chipRect = NSRect(
        x: contentX + CGFloat(index) * (chipWidth + chipGap),
        y: y,
        width: chipWidth,
        height: chipHeight
      )
      drawCheckboxChip(
        rect: chipRect,
        label: chip.label,
        selected: chip.selected
      )
    }
    y += chipHeight + 3

    let footerFont = khmerFont(size: 9.2, weight: .bold)
    let footerText = "សូមអរគុណសម្រាប់ការគាំទ្រ"
    let footerHeight = textHeight(footerText, width: contentWidth, font: footerFont) + 2
    let borderBottomPadding: CGFloat = 10
    _ = drawText(
      footerText,
      rect: NSRect(x: contentX, y: y, width: contentWidth, height: footerHeight),
      font: footerFont,
      alignment: .center
    )
    let contentBottom = y + footerHeight

    let outerHeight = max(minOuterHeight, contentBottom - outerTop + borderBottomPadding)
    neededPageHeight = outerTop * 2 + outerHeight
    let outerRect = NSRect(
      x: outerSideInset,
      y: outerTop,
      width: outerWidth,
      height: outerHeight
    )
    let outerPath = NSBezierPath(roundedRect: outerRect, xRadius: 12, yRadius: 12)
    outerPath.lineWidth = 1.2
    accentColor.setStroke()
    outerPath.stroke()
  }

  private func drawSection(
    iconName: String,
    title: String,
    lines: [String],
    y: CGFloat,
    topMargin: CGFloat = 4,
    bottomMargin: CGFloat = -8,
    titleBoxGap: CGFloat = 2,
    minBoxHeight: CGFloat,
    titleFont: NSFont,
    bodyFont: NSFont,
    contentX: CGFloat,
    contentWidth: CGFloat
  ) -> CGFloat {
    let startY = y + topMargin
    drawLeadingIcon(
      iconName,
      rect: NSRect(x: contentX, y: startY + 1, width: 13, height: 13)
    )

    let titleRectHeight: CGFloat = 13
    _ = drawText(
      title,
      rect: NSRect(x: contentX + 18, y: startY, width: contentWidth - 18, height: titleRectHeight),
      font: titleFont
    )
    var currentY = startY + titleRectHeight + titleBoxGap

    for line in lines {
      let innerWidth = contentWidth - 16
      let measuredHeight = textHeight(
        line,
        width: innerWidth,
        font: bodyFont
      )
      let boxHeight = max(minBoxHeight, measuredHeight + 5)
      let lineRect = NSRect(x: contentX, y: currentY, width: contentWidth, height: boxHeight)
      drawRoundedBox(lineRect)
      _ = drawText(
        line,
        rect: lineRect.insetBy(dx: 8, dy: 2),
        font: bodyFont
      )
      currentY = lineRect.maxY + 1
    }

    return currentY + bottomMargin
  }

  private func drawRoundedBox(_ rect: NSRect) {
    let path = NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8)
    NSColor.white.setFill()
    path.fill()
    NSColor(calibratedWhite: 0.72, alpha: 1).setStroke()
    path.lineWidth = 0.5
    path.stroke()
  }

  private func drawPageHeader(
    title: String,
    y: CGFloat,
    width: CGFloat,
    x: CGFloat
  ) -> CGFloat {
    let font = khmerFont(size: 11.5, weight: .bold)
    let titleSize = attributedTextSize(title, font: font)
    let titleWidth = titleSize.width
    let iconSize: CGFloat = 14
    let gap: CGFloat = 5
    let totalWidth = iconSize + gap + titleWidth
    let startX = max(x + 4, x + (width - totalWidth) / 2)
    let titleRect = NSRect(
      x: startX + iconSize + gap,
      y: y - 1,
      width: min(titleWidth + 8, width - iconSize - gap - 8),
      height: max(18, titleSize.height)
    )
    let iconY = titleRect.minY + ((titleRect.height - iconSize) / 2) + 2

    drawLeadingIcon(
      "facebook",
      rect: NSRect(x: startX, y: iconY, width: iconSize, height: iconSize)
    )
    return drawText(
      title,
      rect: titleRect,
      font: font
    )
  }

  private func drawSenderPhoneHeader(
    title: String,
    phone: String,
    y: CGFloat,
    width: CGFloat,
    x: CGFloat
  ) -> CGFloat {
    let titleFont = khmerFont(size: 10.6, weight: .bold)
    let phoneFont = NSFont.boldSystemFont(ofSize: 12.2)
    let iconSize: CGFloat = 13
    let gap: CGFloat = 5

    let titleWidth = attributedTextSize(title, font: titleFont).width
    let totalWidth = iconSize + gap + titleWidth
    let startX = max(x + 2, x + (width - totalWidth) / 2)

    drawLeadingIcon(
      "phone.fill",
      rect: NSRect(x: startX, y: y + 2, width: iconSize, height: iconSize)
    )
    let titleBottom = drawText(
      title,
      rect: NSRect(
        x: startX + iconSize + gap,
        y: y,
        width: width - iconSize - gap - 4,
        height: 16
      ),
      font: titleFont
    )
    let phoneBottom = drawText(
      phone,
      rect: NSRect(
        x: x,
        y: titleBottom + 1,
        width: width,
        height: 18
      ),
      font: phoneFont,
      alignment: .center
    )
    return phoneBottom
  }

  private func drawCheckboxChip(
    rect: NSRect,
    label: String,
    selected: Bool
  ) {
    drawRoundedBox(rect)

    let checkSize: CGFloat = 12
    let checkRect = NSRect(
      x: rect.minX + 5,
      y: rect.minY + (rect.height - checkSize) / 2,
      width: checkSize,
      height: checkSize
    )
    let checkPath = NSBezierPath(roundedRect: checkRect, xRadius: 2, yRadius: 2)
    accentColor.setStroke()
    checkPath.lineWidth = 1
    checkPath.stroke()

    if selected {
      _ = drawText(
        "✓",
        rect: checkRect.offsetBy(dx: 0, dy: -1),
        font: NSFont.boldSystemFont(ofSize: 11),
        alignment: .center
      )
    }

    let labelFont = khmerFont(size: 8.5, weight: .bold)
    let labelH = max(checkSize, textHeight(label, width: rect.width - 26, font: labelFont))
    let labelY = rect.minY + (rect.height - labelH) / 2
    _ = drawText(
      label,
      rect: NSRect(x: rect.minX + 21, y: labelY, width: rect.width - 26, height: labelH),
      font: labelFont,
      alignment: .center
    )
  }

  private func drawLeadingIcon(_ iconName: String, rect: NSRect) {
    if let assetImage = iconAssetImage(for: iconName) {
      drawAssetIcon(assetImage, in: rect, rotateHalfTurn: shouldRotateAssetIcon(iconName))
    }
  }

  @discardableResult
  private func drawText(
    _ text: String,
    rect: NSRect,
    font: NSFont,
    alignment: NSTextAlignment = .left
  ) -> CGFloat {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byWordWrapping

    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: NSColor.black,
      .paragraphStyle: paragraph
    ]

    let attributed = NSAttributedString(string: text, attributes: attributes)
    attributed.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading])

    let textBounds = attributed.boundingRect(
      with: NSSize(width: rect.width, height: .greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin, .usesFontLeading]
    )
    return rect.minY + ceil(textBounds.height)
  }

  private func textHeight(
    _ text: String,
    width: CGFloat,
    font: NSFont
  ) -> CGFloat {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .left
    paragraph.lineBreakMode = .byWordWrapping

    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .paragraphStyle: paragraph
    ]

    let attributed = NSAttributedString(string: text, attributes: attributes)
    let textBounds = attributed.boundingRect(
      with: NSSize(width: width, height: .greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin, .usesFontLeading]
    )
    return ceil(textBounds.height)
  }

  private func textSize(_ text: String, font: NSFont) -> NSSize {
    let attributes: [NSAttributedString.Key: Any] = [.font: font]
    return (text as NSString).size(withAttributes: attributes)
  }

  private func attributedTextSize(_ text: String, font: NSFont) -> NSSize {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .left
    paragraph.lineBreakMode = .byWordWrapping

    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .paragraphStyle: paragraph
    ]

    let attributed = NSAttributedString(string: text, attributes: attributes)
    let textBounds = attributed.boundingRect(
      with: NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin, .usesFontLeading]
    )
    return NSSize(width: ceil(textBounds.width), height: ceil(textBounds.height))
  }

  private func khmerFont(size: CGFloat, weight: NSFont.Weight) -> NSFont {
    if let font = NSFont(name: "Khmer MN", size: size) {
      return font
    }
    if let font = NSFont(name: "Khmer Sangam MN", size: size) {
      return font
    }
    return NSFont.systemFont(ofSize: size, weight: weight)
  }

  private func drawAssetIcon(_ image: NSImage, in rect: NSRect, rotateHalfTurn: Bool = false) {
    if rotateHalfTurn {
      NSGraphicsContext.saveGraphicsState()
      var transform = CGAffineTransform.identity
      transform = transform.translatedBy(x: rect.midX, y: rect.midY)
      transform = transform.rotated(by: .pi)
      transform = transform.translatedBy(x: -rect.midX, y: -rect.midY)
      NSGraphicsContext.current?.cgContext.concatenate(transform)
    }

    image.draw(
      in: rect,
      from: .zero,
      operation: .sourceOver,
      fraction: 1,
      respectFlipped: true,
      hints: nil
    )

    if rotateHalfTurn {
      NSGraphicsContext.restoreGraphicsState()
    }
  }

  private func shouldRotateAssetIcon(_ iconName: String) -> Bool {
    switch iconName {
    case "person.fill", "mappin.circle.fill", "truck.box.fill":
      return false
    default:
      return false
    }
  }

  private func iconAssetImage(for iconName: String) -> NSImage? {
    for relativePath in assetRelativePaths(for: iconName) {
      for baseURL in flutterAssetsBaseURLs() {
        let url = baseURL.appendingPathComponent(relativePath)
        if FileManager.default.fileExists(atPath: url.path),
           let image = NSImage(contentsOf: url) {
          return image
        }
      }
    }
    return nil
  }

  private func assetRelativePaths(for iconName: String) -> [String] {
    switch iconName {
    case "facebook":
      return [
        "assets/pngs/facebook-svgrepo-com.png",
      ]
    case "person.fill":
      return [
        "assets/pngs/person-svgrepo-com.png",
      ]
    case "mappin.circle.fill":
      return [
        "assets/pngs/location-pin-svgrepo-com.png",
      ]
    case "truck.box.fill":
      return [
        "assets/pngs/truck-speed-svgrepo-com.png",
      ]
    case "phone.fill":
      return [
         "assets/pngs/phone-call-answer-svgrepo-com.png",
      ]
    default:
      return []
    }
  }

  private func flutterAssetsBaseURLs() -> [URL] {
    var urls: [URL] = []

    if let resourceURL = Bundle.main.resourceURL {
      urls.append(resourceURL.appendingPathComponent("flutter_assets"))
    }

    if let frameworksURL = Bundle.main.privateFrameworksURL {
      urls.append(
        frameworksURL
          .appendingPathComponent("App.framework")
          .appendingPathComponent("Resources")
          .appendingPathComponent("flutter_assets")
      )
    }

    let bundleURL = Bundle.main.bundleURL
    urls.append(
      bundleURL
        .appendingPathComponent("Contents")
        .appendingPathComponent("Frameworks")
        .appendingPathComponent("App.framework")
        .appendingPathComponent("Resources")
        .appendingPathComponent("flutter_assets")
    )

    var seen: Set<String> = []
    return urls.filter { seen.insert($0.path).inserted }
  }

}
