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

@main
@objc class AppDelegate: FlutterAppDelegate {
        
    private var methodChannel: FlutterMethodChannel?
    var deepAR: DeepAR!
    var cameraController: CameraController!
    var arView: UIView!
    private var effectIndex: Int = 2
    private var effectPaths: [String?] {
        return Effects.allCases.map { $0.rawValue.path }
    }
    
    private func appltEffect(index : Int) {
        var path: String?
        effectIndex = index
        path = effectPaths[effectIndex]
        deepAR.switchEffect(withSlot: "effect", path: path)
    }
    let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "ViewController") as! ViewController
    
    var isLoadView = false
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
                        if self.isLoadView == false {
                            vc.methodChannel = self.methodChannel
                            isLoadView = true
                            vc.loadView()
                            vc.viewDidLoad()
                        }else {
                            
                        }
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
    
    private func checkLiveness(data: [String: Any]) {
        guard let imageWidth = data["width"] as? Int, let imageHeight = data["height"] as? Int else { return }
        
       // Initialize Liveness over here
        
        guard let flutterData = data["platforms"] as? FlutterStandardTypedData,
              let bytesPerRow = data["bytesPerRow"] as? Int else {
            return
        }
        
        guard let image = createUIImageFromRawData(data: flutterData.data,
                                                   imageWidth: imageWidth,
                                                   imageHeight: imageHeight,
                                                   bytes: bytesPerRow) else {
            return
        }
        // Feed image into liveness
        print(image)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            methodChannel?.invokeMethod("updateCameraFrame", arguments: imageData)
        }
    }
   
    // Group of util to convert image
    private func bytesToPixelBuffer(width: Int, height: Int, baseAddress: UnsafeMutableRawPointer, bytesPerRow: Int) -> CVBuffer? {
        var dstPixelBuffer: CVBuffer?
        CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, baseAddress, bytesPerRow,
                                     nil, nil, nil, &dstPixelBuffer)
        return dstPixelBuffer ?? nil
    }
    
    private func createImage(from pixelBuffer: CVPixelBuffer) -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        return cgImage
    }
    
    private func createUIImageFromRawData(data: Data, imageWidth: Int, imageHeight: Int, bytes: Int) -> UIImage? {
        data.withUnsafeBytes { rawBufferPointer in
            let rawPtr = rawBufferPointer.baseAddress!
            let address = UnsafeMutableRawPointer(mutating:rawPtr)
            guard let pxBuffer = bytesToPixelBuffer(width: imageWidth, height: imageHeight, baseAddress: address, bytesPerRow: bytes), let copyImage = pxBuffer.copy() , let cgiImage = createImage(from: pxBuffer) else {
                return nil
            }
            
            return UIImage(cgImage: cgiImage)
        }
    }
    
}


extension AppDelegate: DeepARDelegate {
    func didFinishPreparingForVideoRecording() {}
    
    func didStartVideoRecording() {}
    
    func frameAvailable(_ sampleBuffer: CMSampleBuffer!) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("*** NO BUFFER ERROR")
            return
        }
        
        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        if let imageData = cvImageBufferToData(pixelBuffer: pixelBuffer) {
            methodChannel?.invokeMethod("updateCameraFrame", arguments: imageData)
        }
    }
//    func frameAvailable(_ sampleBuffer: CMSampleBuffer!) {
//        
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            print("*** NO BUFFER ERROR")
//            return
//        }
//
//        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
//        
//        if let imageData = cvImageBufferToData(pixelBuffer: pixelBuffer) {
//            methodChannel?.invokeMethod("updateCameraFrame", arguments: imageData)
//        }
//        
//    }
    
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
    
    func didFinishVideoRecording(_ videoFilePath: String!) {
        
    }
    
    func recordingFailedWithError(_ error: Error!) {
        print(error.localizedDescription)
    }
    
    func didTakeScreenshot(_ screenshot: UIImage!) {
        if let imageData = screenshot.jpegData(compressionQuality: 0.8) {
            methodChannel?.invokeMethod("updateCameraFrame", arguments: imageData)
        }
    }
    
    func didInitialize() {
        print("Init Deep AR")
    }
    
    func faceVisiblityDidChange(_ faceVisible: Bool) {
        print("Init Deep AR",faceVisible)
    }
}
