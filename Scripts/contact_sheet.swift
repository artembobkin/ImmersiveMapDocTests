import AppKit
// Usage: contact_sheet out.png dir name1 name2 ... (two columns, labelled)
let a = CommandLine.arguments; let out = a[1], dir = a[2], names = Array(a[3...])
let cw = 780.0, ch = 390.0, lab = 26.0
let rows = (names.count + 1) / 2
let W = Int(cw * 2), H = Int((ch + lab) * Double(rows))
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor.white.setFill(); NSRect(x: 0, y: 0, width: W, height: H).fill()
for (i, n) in names.enumerated() {
  let r = i / 2, c = i % 2
  let y = Double(H) - (ch + lab) * Double(r + 1), x = cw * Double(c)
  (n as NSString).draw(at: NSPoint(x: x + 6, y: y + ch + 2), withAttributes: [.font: NSFont.boldSystemFont(ofSize: 18), .foregroundColor: NSColor.black])
  if let im = NSImage(contentsOfFile: "\(dir)/\(n).png") { im.draw(in: NSRect(x: x, y: y, width: cw, height: ch)) }
}
NSGraphicsContext.current = nil
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
