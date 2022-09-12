//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import WebRTC

class VideoCapturer {
    
    private var videoCapturer: RTCVideoCapturer
    private var videoOptions: VideoOptions
    
    init(videoSource: RTCVideoSource, videoOptions: VideoOptions) {
        self.videoOptions = videoOptions
        #if targetEnvironment(simulator)
        videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
        videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif
    }
    
    func setCameraPosition(_ cameraPosition: AVCaptureDevice.Position) {
        guard let videoCapturer = videoCapturer as? RTCCameraVideoCapturer else { return }
        
        let devices = RTCCameraVideoCapturer.captureDevices()
        
        guard let device = devices.first(where: { $0.position == cameraPosition }) ?? devices.first else {
            log.error("No camera video capture devices available")
            return
        }

        let formats = RTCCameraVideoCapturer.supportedFormats(for: device)
        let sortedFormats = formats.map {
            (format: $0, dimensions: CMVideoFormatDescriptionGetDimensions($0.formatDescription))
        }
        .sorted { $0.dimensions.area < $1.dimensions.area }

        var selectedFormat = sortedFormats.first

        if let preferredFormat = videoOptions.preferredFormat,
           let foundFormat = sortedFormats.first(where: { $0.format == preferredFormat }) {
            selectedFormat = foundFormat
        } else {
            selectedFormat = sortedFormats.first(where: { $0.dimensions.area >= videoOptions.preferredDimensions.area })
        }

        guard let selectedFormat = selectedFormat, let fpsRange = selectedFormat.format.fpsRange() else {
            log.error("Unable to resolve format")
            return
        }

        var selectedFps = videoOptions.preferredFps

        if !fpsRange.contains(selectedFps) {
            log.warning("requested fps: \(videoOptions.preferredFps) not available: \(fpsRange) and will be clamped")
            selectedFps = selectedFps.clamped(to: fpsRange)
        }

        videoCapturer.startCapture(
            with: device,
            format: selectedFormat.format,
            fps: selectedFps
        )
    }
}

extension CMVideoDimensions {
    
    public static var full = CMVideoDimensions(width: 1280, height: 720)
    public static var half = CMVideoDimensions(width: 640, height: 480)
    public static var quarter = CMVideoDimensions(width: 480, height: 360)
    
    var area: Int32 {
        width * height
    }
}

extension AVCaptureDevice.Format {

    // computes a ClosedRange of supported FPSs for this format
    func fpsRange() -> ClosedRange<Int>? {
        videoSupportedFrameRateRanges
            .map { $0.toRange() }
            .reduce(into: nil as ClosedRange<Int>?) { result, current in
                guard let previous = result else {
                    result = current
                    return
                }

                // merge previous element
                result = merge(range: previous, with: current)
            }
    }
}

extension AVFrameRateRange {

    // convert to a ClosedRange
    func toRange() -> ClosedRange<Int> {
        Int(minFrameRate)...Int(maxFrameRate)
    }
}

internal func merge<T>(
    range range1: ClosedRange<T>,
    with range2: ClosedRange<T>
) -> ClosedRange<T> where T: Comparable {
    min(range1.lowerBound, range2.lowerBound)...max(range1.upperBound, range2.upperBound)
}

extension Comparable {

    // clamp a value within the range
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}