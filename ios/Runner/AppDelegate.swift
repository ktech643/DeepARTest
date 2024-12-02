//
//  Constants.swift
//  Runner
//
//  Created by Jahan on 03/12/2024.
//

import UIKit
import Flutter
import VideoToolbox

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    // MARK: - Constant properties -
    private var methodChannel: FlutterMethodChannel?
    var streamSprint : StreamSprint!
    let key = "8e2d8c59efc7a141b49c2422c0dfedbcf6cacc0e0b540779f45d928ad54718f68ccbd8fd41ac5fb7"
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
                    if let _ = call.arguments as? [String: Any] {
                        streamSprint = StreamSprint(licenseKey: key)
                        streamSprint.delegate = self
                    } else {
                        result(FlutterMethodNotImplemented)
                    }
                case "changeEffect":
                    if let effectData = call.arguments as? [String: Any] {
                        if let effectName = effectData["effect"] as? String {
                            streamSprint.applyEffect(effect: Effects.init(rawValue: effectName)!)
                        }
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
    
    func closeStream(){
        streamSprint.dispose()
        streamSprint = nil
    }
    
}

extension AppDelegate : StreamSprintDelegate {
    func frameAvailable(_ sampleBufferImageData: Data) {
        methodChannel?.invokeMethod("updateCameraFrame", arguments: sampleBufferImageData)
    }
}
