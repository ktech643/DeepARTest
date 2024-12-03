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
    private var cameraController: CameraController!
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
                deepAR.initializeOffscreen(withWidth: width, height: height)
                cameraController = CameraController()
                cameraController.deepAR = self.deepAR
                deepAR.videoRecordingWarmupEnabled = false;
                cameraController.startCamera(withAudio: true)
            }
        }
    }
    
    public func applyEffect(effect : Effects) {
        if let effectPath = Bundle.main.path(forResource: effect.rawValue, ofType: "deepar") {
            deepAR.switchEffect(withSlot: "effect", path: effectPath)
        }else {
            deepAR.switchEffect(withSlot: "effect", path: nil)
        }
    }
    
    deinit{
        dispose()
    }
    
    public func dispose(){
        cameraController?.stopAudio()
        cameraController?.stopCamera()
        cameraController = nil
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
    
}
