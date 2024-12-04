import Flutter
import UIKit
import VideoToolbox

public class impektDeeparPlugin: NSObject, FlutterPlugin {
    
    var streamSprint : StreamSprint!
    private var methodChannel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "impekt_deepar", binaryMessenger: registrar.messenger())
        let instance = impektDeeparPlugin(flutterMethodChannel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(flutterMethodChannel : FlutterMethodChannel) {
        self.methodChannel = flutterMethodChannel
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            if let params = call.arguments as? [String: Any] {
                if let key = params["key"] as? String {
                    streamSprint = StreamSprint(licenseKey: key)
                    streamSprint.delegate = self
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        case "sendFrameForProcess":
            if let data = call.arguments as? [String: Any] {
                self.checkLiveness(data: data)
            } else {
                result(FlutterMethodNotImplemented)
            }
        case "changeEffect":
            if let effectData = call.arguments as? [String: Any] {
                if let effectName = effectData["effect"] as? String {
                    streamSprint.applyEffect(effect: Effects.init(rawValue: effectName)!)
                }
            }
        case "disposeCamera":
            if let _ = call.arguments as? [String : Any] {
                
            }
            streamSprint.dispose()
            streamSprint = nil
        default:
            result(FlutterMethodNotImplemented)
        }
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
        if let streamSprint = streamSprint {
            streamSprint.processImage(image: image)
        }
        // Feed image into liveness
    }
    
    private func createUIImageFromRawData(data: Data, imageWidth: Int, imageHeight: Int, bytes: Int) -> UIImage? {
        data.withUnsafeBytes { rawBufferPointer in
            let rawPtr = rawBufferPointer.baseAddress!
            let address = UnsafeMutableRawPointer(mutating:rawPtr)
            guard let pxBuffer = bytesToPixelBuffer(width: imageWidth, height: imageHeight, baseAddress: address, bytesPerRow: bytes), let _ = pxBuffer.copy() , let cgiImage = createImage(from: pxBuffer) else {
                return nil
            }
            
            return UIImage(cgImage: cgiImage)
        }
    }
    
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
    
}


extension impektDeeparPlugin : StreamSprintDelegate {
    public func frameAvailable(_ sampleBufferImageData: Data) {
        methodChannel?.invokeMethod("receiveProcessedFrame", arguments: sampleBufferImageData)
    }
}
