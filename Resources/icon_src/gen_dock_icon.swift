import AppKit
import Foundation

// 复刻主窗口左上角 Header 图标：深灰圆角方块 + 白色 SF Symbol "keyboard"
// Design.accent = Color(white: 0.30)；Header 方块圆角 radiusSm=10，符号 font 22 占方块一半高。

let S: CGFloat = 1024
let size = NSSize(width: S, height: S)
let image = NSImage(size: size)
image.lockFocus()
let ctx = NSGraphicsContext.current!
ctx.shouldAntialias = true
ctx.imageInterpolation = .high

// 深灰圆角方块（与 Header 同色、同圆角比例 10/44 ≈ 0.227）
let gray = NSColor(white: 0.30, alpha: 1.0)
let corner = S * (10.0 / 44.0)
let path = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size), xRadius: corner, yRadius: corner)
gray.setFill()
path.fill()

// 顶部细微高光，呼应 Liquid Glass 质感
let gloss = NSBezierPath(roundedRect: NSRect(x: 0, y: S * 0.62, width: S, height: S * 0.38),
                         xRadius: corner, yRadius: corner)
NSColor.white.withAlphaComponent(0.06).setFill()
gloss.fill()

// 白色 keyboard 符号（点阵大小 ≈ 方块一半，对应 Header 22/44）
if let base = NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil),
   let sym = base.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: S * 0.5, weight: .medium)) {
    let symSize = sym.size
    let whiteSym = NSImage(size: symSize)
    whiteSym.lockFocus()
    let g = NSGraphicsContext.current!.cgContext
    g.setFillColor(NSColor.white.cgColor)
    g.fill(CGRect(origin: .zero, size: symSize))
    sym.draw(in: NSRect(origin: .zero, size: symSize),
             from: NSRect.zero, operation: NSCompositingOperation.destinationIn, fraction: 1.0)
    whiteSym.unlockFocus()

    let drawRect = NSRect(x: (S - symSize.width) / 2,
                          y: (S - symSize.height) / 2,
                          width: symSize.width,
                          height: symSize.height)
    whiteSym.draw(in: drawRect)
} else {
    fputs("WARN: keyboard symbol unavailable\n", stderr)
}

image.unlockFocus()

if let tiff = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiff),
   let png = bitmap.representation(using: .png, properties: [:]) {
    let out = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("Resources/icon_src/keyboard_deepgray.png")
    try png.write(to: out)
    print("saved -> \(out.path)")
} else {
    fputs("FAILED to encode PNG\n", stderr)
    exit(1)
}
