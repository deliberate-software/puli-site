// avif.swift: writes an image as AVIF, scaled down to a maximum width, with its transparency kept.
//   swift tools/avif.swift <in.png> <out.avif> <max width> [quality 0–1, default 0.6]
// The site's decorative art and icons are drawn with this, from the originals in tools/art/ (Nov 20).
import AppKit
import ImageIO

let a = CommandLine.arguments
guard a.count >= 4, let maxW = Int(a[3]) else { print("usage: avif <in> <out.avif> <max width> [quality]"); exit(1) }
let quality = a.count > 4 ? Double(a[4])! : 0.6
let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: a[1]) as CFURL, nil)!
let img = CGImageSourceCreateImageAtIndex(src, 0, nil)!
// Both sides even: Chrome decodes some AVIFs with an odd side as wholly transparent (a 2122×937 one did, Nov 24),
// so the last odd row or column, if any, is left out.
let w0 = min(maxW, img.width), h0 = Int((Double(img.height) * Double(w0) / Double(img.width)).rounded())
let w = w0 - w0 % 2, h = h0 - h0 % 2
let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.interpolationQuality = .high
ctx.draw(img, in: CGRect(x: 0, y: 0, width: w0, height: h0))   // drawn whole, bottom-left; an odd top row or right column falls off
let out = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: a[2]) as CFURL, "public.avif" as CFString, 1, nil)!
CGImageDestinationAddImage(dest, out, [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary)
guard CGImageDestinationFinalize(dest) else { print("failed: \(a[2])"); exit(1) }
let size = (try? FileManager.default.attributesOfItem(atPath: a[2])[.size] as? Int) ?? 0
print("\(a[2]) \(w)x\(h) \(size / 1024) KB")
