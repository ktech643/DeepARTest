import UIKit
import Flutter
import VideoToolbox
import DeepAR

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

enum Effects: String, CaseIterable {
    case viking_helmet = "viking_helmet.deepar"
    case MakeupLook = "MakeupLook.deepar"
    case Split_View_Look = "Split_View_Look.deepar"
    case Emotions_Exaggerator = "Emotions_Exaggerator.deepar"
    case Emotion_Meter = "Emotion_Meter.deepar"
    case Stallone = "Stallone.deepar"
    case flower_face = "flower_face.deepar"
    case galaxy_background = "galaxy_background.deepar"
    case Humanoid = "Humanoid.deepar"
    case Neon_Devil_Horns = "Neon_Devil_Horns.deepar"
    case Ping_Pong = "Ping_Pong.deepar"
    case Pixel_Hearts = "Pixel_Hearts.deepar"
    case Snail = "Snail.deepar"
    case Hope = "Hope.deepar"
    case Vendetta_Mask = "Vendetta_Mask.deepar"
    case Fire_Effect = "Fire_Effect.deepar"
    case burning_effect = "burning_effect.deepar"
    case Elephant_Trunk = "Elephant_Trunk.deepar"
}

@main
@objc class AppDelegate: FlutterAppDelegate {
        
    private var methodChannel: FlutterMethodChannel?
        
    private var deepAR: DeepAR!
    
    // This class handles camera interaction. Start/stop feed, check permissions etc. You can use it or you
    // can provide your own implementation
    private var cameraController: CameraController!
    
    // MARK: - Private properties -

    private var effectIndex: Int = 0
    private var effectPaths: [String?] {
        return Effects.allCases.map { $0.rawValue.path }
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        if let controller = window?.rootViewController as? FlutterViewController {
            
            let channel = FlutterMethodChannel(
                name: "SendForProcess",
                binaryMessenger: controller.binaryMessenger)
            
            channel.setMethodCallHandler({ [weak self] (
                call: FlutterMethodCall,
                result: @escaping FlutterResult) -> Void in
                guard let self = self else { return }
                switch call.method {
                case "checkLiveness":
                    if let data = call.arguments as? [String: Any] {
                        setupDeepARAndCamera()
                      //  self?.checkLiveness(data: data)
                       // self?.deepAR.takeScreenshot()
                    } else {
                        result(FlutterMethodNotImplemented)
                    }
                default:
                    result(FlutterMethodNotImplemented)
                }
            })
            methodChannel = FlutterMethodChannel(name: "SendForProcess", binaryMessenger: controller.binaryMessenger)

                 
        }
        
        
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupDeepARAndCamera() {
        
        self.deepAR = DeepAR()
        self.deepAR.delegate = self
        self.deepAR.setLicenseKey("8e2d8c59efc7a141b49c2422c0dfedbcf6cacc0e0b540779f45d928ad54718f68ccbd8fd41ac5fb7")
        deepAR.changeLiveMode(false)
        deepAR.initializeOffscreen(withWidth: 720, height: 1080)
        cameraController = CameraController()
        cameraController.deepAR = self.deepAR
        self.deepAR.videoRecordingWarmupEnabled = false;

        cameraController.startCamera(withAudio: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
                guard let self = self else { return }
            didLoadNextFilter()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
                guard let self = self else { return }
            didLoadNextFilter()
        })
    }
   
    func didLoadPrevFilter() {
        var path: String?
        effectIndex = (effectIndex - 1 < 0) ? (effectPaths.count - 1) : (effectIndex - 1)
        path = effectPaths[effectIndex]
        deepAR.switchEffect(withSlot: "effect", path: path)
    }
    
    func didLoadNextFilter() {
        var path: String?
        effectIndex = (effectIndex + 1 > effectPaths.count - 1) ? 0 : (effectIndex + 1)
        path = effectPaths[effectIndex]
        deepAR.switchEffect(withSlot: "effect", path: path)
    }
}

extension AppDelegate : DeepARDelegate {
    
    func cvImageBufferToData(pixelBuffer: CVImageBuffer, compressionQuality: CGFloat = 0.8) -> Data? {
        // 1. Lock the pixel buffer for thread-safe access.
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        
        // 2. Create a CIImage from the pixel buffer.
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // 3. Create a CIContext for rendering.
        let context = CIContext()
        
        // 4. Render the CIImage to a CGImage.
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
            return nil
        }
        
        // 5. Unlock the pixel buffer.
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        
        // 6. Create a UIImage from the CGImage.
        let image = UIImage(cgImage: cgImage)
        
        // 7. Compress the UIImage to JPEG or PNG data.
        return image.jpegData(compressionQuality: compressionQuality)
        // For PNG format, use this instead:
        // return image.pngData()
    }
    
    func frameAvailable(_ sampleBuffer: CMSampleBuffer!) {
        print("My Buffer:",sampleBuffer ?? "")
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("*** NO BUFFER ERROR")
            return
        }
        let image = cvImageBufferToData(pixelBuffer: pixelBuffer)
        if let imageData = cvImageBufferToData(pixelBuffer: pixelBuffer) {
            methodChannel?.invokeMethod("updateCameraFrame", arguments: imageData)
        }
    }
    func didFinishPreparingForVideoRecording() {
        NSLog("didFinishPreparingForVideoRecording!!!!!")
    }
    
    func didStartVideoRecording() {
        NSLog("didStartVideoRecording!!!!!")
    }
    
    func didFinishVideoRecording(_ videoFilePath: String!) {
        
        NSLog("didFinishVideoRecording!!!!!")

    }
    
    func recordingFailedWithError(_ error: Error!) {}
    
    func didTakeScreenshot(_ screenshot: UIImage!) {
        
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
    
    
    func didFinishShutdown (){
        NSLog("didFinishShutdown!!!!!")
    }
    
    func faceVisiblityDidChange(_ faceVisible: Bool) {}
}


extension String {
    var path: String? {
        return Bundle.main.path(forResource: self, ofType: nil)
    }
}
