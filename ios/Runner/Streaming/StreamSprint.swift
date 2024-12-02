//
//  StreamSprint.swift
//  Runner
//
//  Created by Jahan on 03/12/2024.
//

import UIKit
import DeepAR

protocol StreamSprintDelegate : AnyObject {
    func frameAvailable(_ sampleBufferImageData: Data)
}

class StreamSprint : NSObject {
        
    // MARK: - Constant properties -
    let sharedResourceQueue = DispatchQueue(label: "com.ktc.mytest", qos: .userInitiated, attributes: .concurrent)
    
    // MARK: - Private properties -
    private var cameraController: CameraController!
    private var deepAR: DeepAR!
    public var delegate : StreamSprintDelegate?

    init(licenseKey : String, height : Int = 1080, width : Int = 720) {
        super.init()
        setupDeepARAndCamera(licenseKey: licenseKey, height: height, width: width)
    }
    
    private func setupDeepARAndCamera(licenseKey : String,height : Int, width : Int) {
        
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        let backgroundQueue = DispatchQueue(label: "com.ktc.mytest",
                                            qos: .default)
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            sharedResourceAccess { [weak self] in
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
                dispatchSemaphore.signal()
            }
            
            _ = dispatchSemaphore.wait(timeout: DispatchTime.distantFuture)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
            }
        }
    }
    
    private func sharedResourceAccess(_ accessBlock: @escaping () -> Void) {
        sharedResourceQueue.async(flags: .barrier) {
            accessBlock()
        }
    }
    
    public func applyEffect(effect : Effects) {
        if let effectPath = Bundle.main.path(forResource: effect.rawValue, ofType: "deepar") {
            deepAR.switchEffect(withSlot: "effect", path: effectPath)
        }else {
            deepAR.switchEffect(withSlot: "effect", path: nil)
        }
    }
    
    public func shutDown(){
        deepAR.shutdown()
        cameraController.stopCamera()
        cameraController.stopAudio()
        deepAR = nil
        cameraController = nil
    }
}

extension StreamSprint : DeepARDelegate {
    
    func cvImageBufferToData(pixelBuffer: CVImageBuffer) -> Data? {
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        let context = CIContext()
        // Create CGImage from CIImage
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage.pngData()
        }
        return nil
    }
    
    func frameAvailable(_ sampleBuffer: CMSampleBuffer!) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        if let imageData = cvImageBufferToData(pixelBuffer: pixelBuffer) {
            if let del = delegate {
                del.frameAvailable(imageData)
            }
        }
    }
    
    func didInitialize() {
        if (deepAR.videoRecordingWarmupEnabled) {
            DispatchQueue.main.async { [self] in
                let width: Int32 = Int32(deepAR.renderingResolution.width)
                let height: Int32 =  Int32(deepAR.renderingResolution.height)
                deepAR.startVideoRecording(withOutputWidth: width, outputHeight: height)
            }
        }
    }
    
    func didFinishShutdown (){}
    
    func faceVisiblityDidChange(_ faceVisible: Bool) {}
    
    func didFinishPreparingForVideoRecording() {}
    
    func didStartVideoRecording() {}
    
    func didFinishVideoRecording(_ videoFilePath: String!) {}
    
    func recordingFailedWithError(_ error: Error!) {}
    
    func didTakeScreenshot(_ screenshot: UIImage!) {}
    
}
