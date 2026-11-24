// promo-film.swift: the promotional film. The herding film plays through, its last moment on the empty gate dissolves
// into the end card (promo-card.swift), and the card holds.
//
//   swift tools/promo-film.swift <film.mp4> <card.png> <out.mp4> [dissolve seconds = 1] [hold seconds = 5]
//
// Writes H.264 at the film's own size (1920×1080 from Alan's export) and frame rate, about 12 Mbps, video only.
import AVFoundation
import CoreImage
let a = CommandLine.arguments
let film = AVURLAsset(url: URL(fileURLWithPath: a[1]))
let card = CIImage(contentsOf: URL(fileURLWithPath: a[2]))!
let out = URL(fileURLWithPath: a[3]); try? FileManager.default.removeItem(at: out)
let dissolve = a.count > 4 ? Double(a[4])! : 1.0, hold = a.count > 5 ? Double(a[5])! : 5.0
let sem = DispatchSemaphore(value: 0)
Task {
  do {
    let track = try await film.loadTracks(withMediaType: .video)[0]
    let size = try await track.load(.naturalSize), fps = Double(try await track.load(.nominalFrameRate))
    let dur = try await film.load(.duration).seconds
    let reader = try AVAssetReader(asset: film)
    let rOut = AVAssetReaderTrackOutput(track: track, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
    reader.add(rOut); reader.startReading()
    let writer = try AVAssetWriter(outputURL: out, fileType: .mp4)
    let wIn = AVAssetWriterInput(mediaType: .video, outputSettings: [
      AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: Int(size.width), AVVideoHeightKey: Int(size.height),
      AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 12_000_000, AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel],
      AVVideoColorPropertiesKey: [AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2, AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2, AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2]])
    wIn.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: wIn, sourcePixelBufferAttributes: [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, kCVPixelBufferWidthKey as String: Int(size.width), kCVPixelBufferHeightKey as String: Int(size.height)])
    writer.add(wIn); writer.startWriting(); writer.startSession(atSourceTime: .zero)
    let ci = CIContext(options: [.workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!])
    let cardFit = card.transformed(by: CGAffineTransform(scaleX: size.width / card.extent.width, y: size.height / card.extent.height))
    func write(_ image: CIImage, _ t: CMTime) {
      while !wIn.isReadyForMoreMediaData { usleep(2000) }
      var pb: CVPixelBuffer?; CVPixelBufferPoolCreatePixelBuffer(nil, adaptor.pixelBufferPool!, &pb)
      ci.render(image, to: pb!, bounds: CGRect(origin: .zero, size: size), colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
      adaptor.append(pb!, withPresentationTime: t)
    }
    // the film, with the card dissolving in over its last `dissolve` seconds (smoothstep, so it eases in and out)
    var last = CMTime.zero, n = 0
    while let sb = rOut.copyNextSampleBuffer(), let px = CMSampleBufferGetImageBuffer(sb) {
      let t = CMSampleBufferGetPresentationTimeStamp(sb)
      var frame = CIImage(cvPixelBuffer: px)
      let into = (t.seconds - (dur - dissolve)) / dissolve
      if into > 0 {
        let x = min(1, into), e = x * x * (3 - 2 * x)
        frame = CIFilter(name: "CIDissolveTransition", parameters: [kCIInputImageKey: frame, kCIInputTargetImageKey: cardFit, kCIInputTimeKey: e])!.outputImage!
      }
      write(frame, t); last = t; n += 1
    }
    // then the card alone
    let step = CMTime(value: 1001, timescale: CMTimeScale((fps * 1001).rounded()))
    var t = last + step
    for _ in 0..<Int((hold * fps).rounded()) { write(cardFit, t); t = t + step; n += 1 }
    wIn.markAsFinished(); await writer.finishWriting()
    print("frames", n, "seconds", t.seconds, writer.status == .completed ? "ok" : "failed \(String(describing: writer.error))")
  } catch { print("error", error) }
  sem.signal()
}
sem.wait()
