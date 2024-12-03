import Flutter
import UIKit

public class ImpektDeeparPlugin: NSObject, FlutterPlugin {
    
    var streamSprint : StreamSprint!
    private var methodChannel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "impekt_deepar", binaryMessenger: registrar.messenger())
        let instance = ImpektDeeparPlugin(flutterMethodChannel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(flutterMethodChannel : FlutterMethodChannel) {
        self.methodChannel = flutterMethodChannel
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkLiveness":
            if let params = call.arguments as? [String: Any] {
                if let key = params["key"] as? String {
                    print("Starting deepAR")
                    streamSprint = StreamSprint(licenseKey: key)
                    streamSprint.delegate = self
                }
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
}


extension ImpektDeeparPlugin : StreamSprintDelegate {
    public func frameAvailable(_ sampleBufferImageData: Data) {
        methodChannel?.invokeMethod("updateCameraFrame", arguments: sampleBufferImageData)
    }
}
