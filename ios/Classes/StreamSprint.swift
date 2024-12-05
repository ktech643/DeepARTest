//
//  StreamSprint.swift
//  Runner
//
//  Created by Jahan on 03/12/2024.
//

import UIKit
import DeepAR

// MARK: - Enum For Change Effect
public enum Effects: String, CaseIterable {
    case none = "None"
    case viking_helmet = "viking_helmet"
    case MakeupLook = "MakeupLook"
    case Split_View_Look = "Split_View_Look"
    case Emotions_Exaggerator = "Emotions_Exaggerator"
    case Emotion_Meter = "Emotion_Meter"
    case Stallone = "Stallone"
    case flower_face = "flower_face"
    case galaxy_background = "galaxy_background"
    case Humanoid = "Humanoid"
    case Neon_Devil_Horns = "Neon_Devil_Horns"
    case Ping_Pong = "Ping_Pong"
    case Pixel_Hearts = "Pixel_Hearts"
    case Snail = "Snail"
    case Hope = "Hope"
    case Vendetta_Mask = "Vendetta_Mask"
    case Fire_Effect = "Fire_Effect"
    case burning_effect = "burning_effect"
    case Elephant_Trunk = "Elephant_Trunk"
}

// MARK: - Delegate for handle state
public protocol StreamSprintDelegate : AnyObject {
    func frameAvailable(_ sampleBufferImageData: Data)
}

// MARK: - Main Class
public class StreamSprint : NSObject , DeepARDelegate {
    
    // MARK: - Private properties -
    private var deepAR: DeepAR!
    public var delegate : StreamSprintDelegate?
    
    // MARK: - Functions
    public init(licenseKey : String, height : Int = 1080, width : Int = 720) {
        super.init()
        setupDeepARAndCamera(licenseKey: licenseKey, height: height, width: width)
    }
    
    private func setupDeepARAndCamera(licenseKey : String,height : Int, width : Int) {
        DispatchQueue.global(qos: .userInitiated).async {  [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                deepAR = DeepAR()
                deepAR.delegate = self
                deepAR.setLicenseKey(licenseKey)
                deepAR.changeLiveMode(false)
                deepAR.enableAudioProcessing(false)
                deepAR.initializeOffscreen(withWidth: width, height: height)
            }
        }
    }
    
    public func applyEffect(effect : Effects) {
        let bundle = Bundle(for: StreamSprint.self)
        if let resourceBundle = Bundle(url: bundle.url(forResource: "effects", withExtension: "bundle")!) {
            if let effectFilePath = resourceBundle.path(forResource: "\(effect.rawValue).deepar", ofType: nil) {
                deepAR?.switchEffect(withSlot: "effect", path: effectFilePath)
            } else {
                deepAR?.switchEffect(withSlot: "effect", path: nil)
            }
        }
       
//        if let effectPath = bundle.path(forResource: effect.rawValue, ofType: "deepar") {
//            deepAR?.switchEffect(withSlot: "effect", path: effectPath)
//        }else {
//            deepAR?.switchEffect(withSlot: "effect", path: nil)
//        }
    }
    
    deinit{
        dispose()
    }
    
    public func processImage(image : UIImage) {
        if let pixelBuffer = convertUIImageToCVPixelBuffer(image: image) {
            let timestamp = CMTimeValue(20) // 1/30th of a second
            deepAR?.processFrame(pixelBuffer, mirror: false, timestamp: timestamp)
        }
    }
    
    public func dispose(){
        deepAR?.shutdown()
        deepAR?.delegate = nil
        deepAR = nil
    }
    
    private func cvImageBufferToData(pixelBuffer: CVImageBuffer) -> Data? {
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        let context = CIContext()
        // Create CGImage from CIImage
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage.jpegData(compressionQuality: 0.5)
        }
        return nil
    }
    
    public func frameAvailable(_ sampleBuffer: CMSampleBuffer!) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        if let imageData = cvImageBufferToData(pixelBuffer: pixelBuffer) {
            if let del = delegate {
                del.frameAvailable(imageData)
            }
        }
    }
    
    private func convertUIImageToCVPixelBuffer(image: UIImage) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        )
        
        guard let ctx = context else {
            CVPixelBufferUnlockBaseAddress(buffer, [])
            return nil
        }
        
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
    
}
