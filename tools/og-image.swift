// og-image.swift: draws the site's link-preview image, assets/images/og-image.png (1200×630).
//
//   swift tools/og-image.swift . assets/images/og-image.png
//
// Run from the site's folder. It uses the site's own fonts (assets/fonts) and art (tools/art: the originals the site's AVIFs are drawn from): the app icon,
// "Puli for Mac", "Herd your thoughts.", a two-line lede and a byline, centered as a group with equal margins, over the
// painted meadow and three sheep along the bottom. Change the words in L1–L5 below; the layout follows their widths.
import AppKit
import CoreText
// Drawn at 2x for crispness, then scaled down.
let root = CommandLine.arguments[1], out = CommandLine.arguments[2]
for f in ["tools/fonts/IBMPlexSerif-Light.otf", "tools/fonts/InstrumentSans.ttf"] {
  CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: root + "/" + f) as CFURL, .process, nil) }
let W = 1200, H = 630, k = 2
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W * k, pixelsHigh: H * k, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = NSSize(width: W, height: H)
NSGraphicsContext.saveGraphicsState()
let ctx = NSGraphicsContext(bitmapImageRep: rep)!; NSGraphicsContext.current = ctx; ctx.imageInterpolation = .high
func hex(_ h: Int, _ a: CGFloat = 1) -> NSColor { NSColor(srgbRed: CGFloat((h >> 16) & 255) / 255, green: CGFloat((h >> 8) & 255) / 255, blue: CGFloat(h & 255) / 255, alpha: a) }
func img(_ p: String) -> NSImage { NSImage(contentsOf: URL(fileURLWithPath: root + "/tools/art/" + p))! }
// top-left coordinates
func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSRect { NSRect(x: x, y: CGFloat(H) - y - h, width: w, height: h) }
func place(_ p: String, x: CGFloat, bottom: CGFloat, width: CGFloat, flip: Bool = false) {
  let i = img(p); let h = width * i.size.height / i.size.width
  let r = rect(x, CGFloat(H) - bottom - h, width, h)
  if flip { NSGraphicsContext.saveGraphicsState(); let t = NSAffineTransform(); t.translateX(by: r.midX, yBy: 0); t.scaleX(by: -1, yBy: 1); t.translateX(by: -r.midX, yBy: 0); t.concat() }
  i.draw(in: r, from: .zero, operation: .sourceOver, fraction: 1)
  if flip { NSGraphicsContext.restoreGraphicsState() }
}
hex(0xCFE1DD).setFill(); NSRect(x: 0, y: 0, width: W, height: H).fill()

// the meadow along the bottom: smaller grass and poppies, so three sheep can stand among them at the site's scale
place("meadow/grass-flat-8.png", x: -16, bottom: 0, width: 118)
place("meadow/poppies-flat-4.png", x: 70, bottom: 0, width: 138)
place("flock/flock-grazing-right.png", x: 186, bottom: 4, width: 152)
place("meadow/grass-flat-1.png", x: 196, bottom: 0, width: 66, flip: true)
place("meadow/grass-flat-5.png", x: 296, bottom: 0, width: 54)
place("meadow/grass-flat-2.png", x: 340, bottom: 0, width: 64)
place("meadow/poppies-flat-3.png", x: 404, bottom: 0, width: 104)
place("flock/flock-lying.png", x: 516, bottom: 3, width: 150)
place("meadow/grass-flat-5.png", x: 500, bottom: 0, width: 50, flip: true)
place("meadow/grass-flat-1.png", x: 630, bottom: 0, width: 56)
place("meadow/poppies-flat-5.png", x: 690, bottom: 0, width: 118)
place("flock/flock-standing-left.png", x: 820, bottom: 5, width: 150)
place("meadow/grass-flat-2.png", x: 812, bottom: 0, width: 62, flip: true)
place("meadow/grass-flat-10.png", x: 936, bottom: 0, width: 44)
place("meadow/poppies-flat-6.png", x: 980, bottom: 0, width: 134)
place("meadow/grass-flat-8.png", x: 1104, bottom: 0, width: 110, flip: true)

// the words, centered on the icon: the name first and largest, as the menu bar sets it, then the headline, then a line
let bold = NSFont(name: "InstrumentSans-Regular_Bold", size: 34)!
let light = NSFont(name: "InstrumentSans-Regular", size: 34)!
let caps = NSFont(name: "InstrumentSans-Regular_Medium", size: 15)!
let serif = NSFont(name: "IBMPlexSerif-Light", size: 54)!
let sans = NSFont(name: "InstrumentSans-Regular", size: 25)!
func line(_ parts: [(String, NSFont, NSColor, CGFloat)], x: CGFloat, baseline: CGFloat) {
  let a = NSMutableAttributedString()
  for (s, f, c, k) in parts { a.append(NSAttributedString(string: s, attributes: [.font: f, .foregroundColor: c, .kern: k])) }
  a.draw(at: NSPoint(x: x, y: CGFloat(H) - baseline + parts[0].1.descender))
}
// lay out icon and text as one group, centered: equal margins left of the icon and right of the widest line
func attr(_ parts: [(String, NSFont, NSColor, CGFloat)]) -> NSAttributedString {
  let a = NSMutableAttributedString(); for (s, f, c, k) in parts { a.append(NSAttributedString(string: s, attributes: [.font: f, .foregroundColor: c, .kern: k])) }; return a }
let ink = hex(0x1F2023), muted = hex(0x44514E)
let L1 = [("Puli", bold, ink, CGFloat(-0.45)), (" for Mac", light, ink, CGFloat(-0.45))]
let L2 = [("Herd your thoughts.", serif, ink, CGFloat(-1.4))]
let L3 = [("Your notes on people, projects, and promises,", sans, muted, CGFloat(0))]
let L4 = [("filed for you, for free, forever.", sans, muted, CGFloat(0))]
let L5 = [("DELIBERATE SOFTWARE  \u{2219}  MADE ON PURPOSE", caps, hex(0x8A4B08), CGFloat(2.4))]
let offs: [CGFloat] = [0, 2, 4, 4, 4]
let textW = zip([L1, L2, L3, L4, L5], offs).map { attr($0.0).size().width + $0.1 }.max()!
let iconSize: CGFloat = 290, gap: CGFloat = 64
let margin = (CGFloat(W) - iconSize - gap - textW) / 2
let iconX = margin, iconY: CGFloat = 256 - iconSize / 2
let tx = margin + iconSize + gap
print("margin", margin, "text width", textW)
// the app icon: rounded, with a soft shadow
let ir = rect(iconX, iconY, iconSize, iconSize)
let path = NSBezierPath(roundedRect: ir, xRadius: iconSize * 0.2237, yRadius: iconSize * 0.2237)
NSGraphicsContext.saveGraphicsState()
let sh = NSShadow(); sh.shadowColor = hex(0x173F3C, 0.30); sh.shadowOffset = NSSize(width: 0, height: -12); sh.shadowBlurRadius = 28; sh.set()
hex(0x25716E).setFill(); path.fill()
NSGraphicsContext.restoreGraphicsState()
NSGraphicsContext.saveGraphicsState(); path.addClip()
img("puli-icon-square-400.png").draw(in: ir, from: .zero, operation: .sourceOver, fraction: 1)
NSGraphicsContext.restoreGraphicsState()

// optical alignment (Alan, Nov 19): the serif H's stem starts a few pixels in from its own edge, so "Puli" moves in to meet it
func inkLeft(_ parts: [(String, NSFont, NSColor, CGFloat)]) -> CGFloat {
  let l = CTLineCreateWithAttributedString(attr(parts)); return CTLineGetImageBounds(l, nil).origin.x }
let nudge = (inkLeft(L2) + 2) - inkLeft(L1) + 1   // + 1: a little into the serif, where the eye reads the letter starting
print("ink left: Puli", inkLeft(L1), "H", inkLeft(L2), "nudge", nudge)
line(L1, x: tx + nudge, baseline: 173)
line(L2, x: tx + 2, baseline: 232)
line(L3, x: tx + 4, baseline: 282)
line(L4, x: tx + 4, baseline: 318)
line(L5, x: tx + 4, baseline: 364)
NSGraphicsContext.restoreGraphicsState()

// down to 1200×630
let final = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState(); let c2 = NSGraphicsContext(bitmapImageRep: final)!; NSGraphicsContext.current = c2; c2.imageInterpolation = .high
rep.draw(in: NSRect(x: 0, y: 0, width: W, height: H)); NSGraphicsContext.restoreGraphicsState()
try! final.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("wrote", out)
