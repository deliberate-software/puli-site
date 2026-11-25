// lesson-composite.swift: one image from several screenshots of the same window, for How Lessons Work.
//
//   swift tools/lesson-composite.swift bands <out.png> <shot.png>...
//       Side by side, each shot showing its own vertical band of the window, left to right, so the window reads as one:
//       Themes' colors across it, or Suggestions' before and after.
//   swift tools/lesson-composite.swift grid <out.png> <x> <y> <w> <h> <shot.png>...
//       The same region (in pixels) of each shot, two to a row (or COLS=n), with a gap between: Typography's note in
//       each, or, with the whole window as the region and COLS=3, Themes' windows, light above and dark below.
//
// The shots are window captures of one size (screencapture -o -l), so the bands line up.
import AppKit

let a = CommandLine.arguments
let mode = a[1], out = URL(fileURLWithPath: a[2])
func load(_ p: String) -> CGImage {
  let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: p) as CFURL, nil)!
  return CGImageSourceCreateImageAtIndex(src, 0, nil)!
}
func context(_ w: Int, _ h: Int) -> CGContext {
  CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
}
func write(_ ctx: CGContext) {
  let dest = CGImageDestinationCreateWithURL(out as CFURL, "public.png" as CFString, 1, nil)!
  CGImageDestinationAddImage(dest, ctx.makeImage()!, nil); CGImageDestinationFinalize(dest)
}

if mode == "bands" {
  let shots = a[3...].map(load), w = shots[0].width, h = shots[0].height
  let ctx = context(w, h)
  for (i, shot) in shots.enumerated() {
    // Each band, from its own shot; CGContext's y runs up, but the band spans the whole height, so only x matters.
    let x0 = w * i / shots.count, x1 = w * (i + 1) / shots.count
    ctx.saveGState(); ctx.clip(to: CGRect(x: x0, y: 0, width: x1 - x0, height: h))
    ctx.draw(shot, in: CGRect(x: 0, y: 0, width: w, height: h)); ctx.restoreGState()
  }
  write(ctx)
} else {
  let x = Int(a[3])!, y = Int(a[4])!, cw = Int(a[5])!, ch = Int(a[6])!
  let cols = Int(ProcessInfo.processInfo.environment["COLS"] ?? "2")!
  let shots = a[7...].map(load), gap = 24, rows = (shots.count + cols - 1) / cols
  let ctx = context(cols * cw + (cols - 1) * gap, rows * ch + (rows - 1) * gap)
  for (i, shot) in shots.enumerated() {
    let crop = shot.cropping(to: CGRect(x: x, y: y, width: cw, height: ch))!
    let col = i % cols, row = i / cols
    ctx.draw(crop, in: CGRect(x: col * (cw + gap), y: ctx.height - (row + 1) * ch - row * gap, width: cw, height: ch))
  }
  write(ctx)
}
print("wrote", out.path)
