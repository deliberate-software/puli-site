// promo-card.swift: draws the promotional film's end card (1920×1080), the link-preview image's layout (og-image.swift)
// at 16:9, with "Coming soon to the Mac App Store." under the lede.
//
//   swift tools/promo-card.swift . <app icon, 1024px> out.png
//
// Run from the site's folder. The icon is Puli's macOS app icon at 1024px (icon_512x512@2x.png in its AppIcon set), drawn
// whole, so its own shape and margins come with it. Laid out in points on a 1200×675 page, drawn at 1.6x.
import AppKit
import CoreText
let root = CommandLine.arguments[1], iconPath = CommandLine.arguments[2], out = CommandLine.arguments[3]
for f in ["tools/fonts/IBMPlexSerif-Light.otf", "tools/fonts/InstrumentSans.ttf"] {
  CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: root + "/" + f) as CFURL, .process, nil) }
let W = 1200, H = 675, k: CGFloat = 1.6
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(CGFloat(W) * k), pixelsHigh: Int(CGFloat(H) * k), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = NSSize(width: W, height: H)
NSGraphicsContext.saveGraphicsState()
let ctx = NSGraphicsContext(bitmapImageRep: rep)!; NSGraphicsContext.current = ctx; ctx.imageInterpolation = .high
func hex(_ h: Int, _ a: CGFloat = 1) -> NSColor { NSColor(srgbRed: CGFloat((h >> 16) & 255) / 255, green: CGFloat((h >> 8) & 255) / 255, blue: CGFloat(h & 255) / 255, alpha: a) }
func img(_ p: String) -> NSImage { NSImage(contentsOf: URL(fileURLWithPath: root + "/tools/art/" + p))! }
func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSRect { NSRect(x: x, y: CGFloat(H) - y - h, width: w, height: h) }
func place(_ p: String, x: CGFloat, bottom: CGFloat, width: CGFloat, flip: Bool = false) {
  let i = img(p); let h = width * i.size.height / i.size.width
  let r = rect(x, CGFloat(H) - bottom - h, width, h)
  if flip { NSGraphicsContext.saveGraphicsState(); let t = NSAffineTransform(); t.translateX(by: r.midX, yBy: 0); t.scaleX(by: -1, yBy: 1); t.translateX(by: -r.midX, yBy: 0); t.concat() }
  i.draw(in: r, from: .zero, operation: .sourceOver, fraction: 1)
  if flip { NSGraphicsContext.restoreGraphicsState() }
}
let bg = hex(0xCFE1DD)
bg.setFill(); NSRect(x: 0, y: 0, width: W, height: H).fill()

// the flock, far off, and the meadow in front: exactly as in the link-preview image, anchored to the bottom edge
let pasture = img("pasture/pasture-grazing.png")
let pScale = CGFloat(W) / pasture.size.width, pH = pasture.size.height * pScale, strip: CGFloat = 170
pasture.draw(in: rect(0, CGFloat(H) - 277 * pScale, CGFloat(W), pH), from: .zero, operation: .sourceOver, fraction: 1)
bg.setFill(); rect(0, 0, CGFloat(W), CGFloat(H) - strip).fill()
NSGradient(starting: bg, ending: bg.withAlphaComponent(0))!.draw(in: rect(0, CGFloat(H) - strip, CGFloat(W), strip * 0.45), angle: -90)
NSGradient(starting: bg, ending: bg.withAlphaComponent(0))!.draw(in: rect(0, CGFloat(H) - strip, 180, strip), angle: 0)
NSGradient(starting: bg, ending: bg.withAlphaComponent(0))!.draw(in: rect(CGFloat(W) - 180, CGFloat(H) - strip, 180, strip), angle: 180)
place("meadow/grass-flat-8.png", x: -16, bottom: 0, width: 118)
place("meadow/poppies-flat-4.png", x: 64, bottom: 0, width: 132)
let pupX: CGFloat = 212, pupW: CGFloat = 140, pk = pupW / 190
NSGraphicsContext.saveGraphicsState()
let shadow = NSBezierPath(ovalIn: rect(pupX, CGFloat(H) - 4 - 12, pupW * 0.87, 12))
NSGradient(colors: [hex(0x173F3C, 0.30), hex(0x173F3C, 0.12), hex(0x173F3C, 0)], atLocations: [0, 0.6, 1], colorSpace: .sRGB)!.draw(in: shadow, relativeCenterPosition: .zero)
NSGraphicsContext.restoreGraphicsState()
place("pack/pack-herding.png", x: pupX, bottom: 0, width: pupW)
place("meadow/grass-flat-5.png", x: pupX + 2 * pk, bottom: 0, width: 42 * pk)
place("meadow/grass-flat-1.png", x: pupX + 32 * pk, bottom: 0, width: 38 * pk, flip: true)
place("meadow/grass-flat-2.png", x: pupX + 62 * pk, bottom: 0, width: 28 * pk)
place("meadow/grass-flat-5.png", x: 370, bottom: 0, width: 46)
place("meadow/grass-flat-2.png", x: 430, bottom: 0, width: 60)
place("meadow/poppies-flat-3.png", x: 520, bottom: 0, width: 100)
place("meadow/grass-flat-1.png", x: 660, bottom: 0, width: 54)
place("meadow/poppies-flat-5.png", x: 760, bottom: 0, width: 112)
place("meadow/grass-flat-10.png", x: 905, bottom: 0, width: 42)
place("meadow/poppies-flat-6.png", x: 975, bottom: 0, width: 132)
place("meadow/grass-flat-8.png", x: 1104, bottom: 0, width: 110, flip: true)

// the words: the link-preview image's five lines, with "Coming soon to the Mac App Store." between the lede and the byline
let bold = NSFont(name: "InstrumentSans-Regular_Bold", size: 34)!
let light = NSFont(name: "InstrumentSans-Regular", size: 34)!
let caps = NSFont(name: "InstrumentSans-Regular_Medium", size: 15)!
let serif = NSFont(name: "IBMPlexSerif-Light", size: 54)!
let sans = NSFont(name: "InstrumentSans-Regular", size: 25)!
let medium = NSFont(name: "InstrumentSans-Regular_Medium", size: 25)!
typealias Run = (String, NSFont, NSColor, CGFloat)
func attr(_ parts: [Run]) -> NSAttributedString {
  let a = NSMutableAttributedString(); for (s, f, c, k) in parts { a.append(NSAttributedString(string: s, attributes: [.font: f, .foregroundColor: c, .kern: k])) }; return a }
func line(_ parts: [Run], x: CGFloat, baseline: CGFloat) { attr(parts).draw(at: NSPoint(x: x, y: CGFloat(H) - baseline + parts[0].1.descender)) }
let ink = hex(0x1F2023), muted = hex(0x44514E), amber = hex(0x8A4B08)
let L1: [Run] = [("Puli", bold, ink, -0.45), (" for Mac", light, ink, -0.45)]
let L2: [Run] = [("Herd your thoughts.", serif, ink, -1.4)]
let L3: [Run] = [("Your notes on people, projects, and promises,", sans, muted, 0)]
let L4: [Run] = [("filed for you, for free, forever.", sans, muted, 0)]
let L5: [Run] = [("Coming soon to the Mac App Store.", medium, ink, 0)]
let L6: [Run] = [("DELIBERATE SOFTWARE  \u{2219}  MADE ON PURPOSE", caps, amber, 2.4)]
let lines = [L1, L2, L3, L4, L5, L6]
let offs: [CGFloat] = [0, 2, 4, 4, 4, 4]
// baselines relative to the first: the link-preview image's spacing, plus the new line, set apart from the lede like the byline
let rel: [CGFloat] = [0, 59, 109, 145, 199, 245]
let textW = zip(lines, offs).map { attr($0.0).size().width + $0.1 }.max()!
let iconSize: CGFloat = 290, gap: CGFloat = 64
let margin = (CGFloat(W) - iconSize - gap - textW) / 2
// the group sits centered in the space above the meadow, as in the link-preview image: the text block's middle (the
// cap top of the first line to the last baseline) lines up with the icon's middle
let capTop = bold.capHeight, blockH = rel.last! + capTop
let centerY: CGFloat = 280
let base0 = centerY - blockH / 2 + capTop
let iconX = margin, iconY = centerY - iconSize / 2
let tx = margin + iconSize + gap

// the app icon: the macOS icon drawn whole, its shape (824 of 1024) sized to iconSize, casting the same soft shadow
let icon = NSImage(contentsOf: URL(fileURLWithPath: iconPath))!
let full = iconSize * 1024 / 824, inset = (full - iconSize) / 2
NSGraphicsContext.saveGraphicsState()
let sh = NSShadow(); sh.shadowColor = hex(0x173F3C, 0.30); sh.shadowOffset = NSSize(width: 0, height: -12); sh.shadowBlurRadius = 28; sh.set()
icon.draw(in: rect(iconX - inset, iconY - inset, full, full), from: .zero, operation: .sourceOver, fraction: 1)
NSGraphicsContext.restoreGraphicsState()

func inkLeft(_ parts: [Run]) -> CGFloat { CTLineGetImageBounds(CTLineCreateWithAttributedString(attr(parts)), nil).origin.x }
let nudge = (inkLeft(L2) + 2) - inkLeft(L1) + 1
for (i, l) in lines.enumerated() { line(l, x: tx + (i == 0 ? nudge : offs[i]), baseline: base0 + rel[i]) }
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("wrote", out, rep.pixelsWide, rep.pixelsHigh, "margin", margin)
