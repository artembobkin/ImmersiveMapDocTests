// Compares the centre of two 1000x500 screenshots. Identical settings differ by about 0.006.
// Usage: compare_images a.png b.png
import AppKit

func load(_ p: String) -> NSBitmapImageRep { NSBitmapImageRep(data: try! Data(contentsOf: URL(fileURLWithPath: p)))! }
let a = load(CommandLine.arguments[1]), b = load(CommandLine.arguments[2])
var total = 0.0, n = 0.0
for y in stride(from: 110, to: 440, by: 3) {
    for x in stride(from: 400, to: 600, by: 3) {
        let p = a.colorAt(x: x, y: y)!.usingColorSpace(.deviceRGB)!, q = b.colorAt(x: x, y: y)!.usingColorSpace(.deviceRGB)!
        total += abs(p.redComponent - q.redComponent) + abs(p.greenComponent - q.greenComponent) + abs(p.blueComponent - q.blueComponent)
        n += 1
    }
}
print("mean difference:", total / n / 3)
