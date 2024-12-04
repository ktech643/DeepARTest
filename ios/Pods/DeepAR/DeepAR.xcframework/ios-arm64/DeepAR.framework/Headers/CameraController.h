/**
 * @file CameraController.h
 * Contains the @link CameraController @endlink helper class that controls the camera device.
 * @copyright Copyright (c) 2021 DeepAR.ai
 */

#import <AVFoundation/AVFoundation.h>
#import "DeepAR.h"

/**
 * Helper class that wraps [AVFoundation](https://developer.apple.com/documentation/avfoundation)
 * to handle camera-related logic like starting camera preview, choosing resolution, front or back camera, and video orientation for DeepAR.
 *
 * Example of usage:
 *
 * **ObjC**
 * ```objc
 * self.cameraController = [[CameraController alloc]
 *                          initWithDeepAR:self.deepAR];
 * [self.cameraController startCamera];
 * ```
 *
 * **Swift**
 * ```swift
 * cameraController = CameraController(deepAR:self.deepAR)
 * cameraController.startCamera()
 * ```
 */
@interface CameraController : NSObject

/**
 * The ``DeepAR/DeepAR`` instance.
 *
 * > Important: This property should be set only once after the `CameraController` instance is created. See ``init``.
 */
@property (nonatomic, weak) DeepAR* deepAR;

/**
 * The currently selected camera.
 *
 * Options:
 * - [`AVCaptureDevicePositionBack`](https://developer.apple.com/documentation/avfoundation/avcapturedeviceposition/avcapturedevicepositionback)
 * - [`AVCaptureDevicePositionFront`](https://developer.apple.com/documentation/avfoundation/avcapturedeviceposition/avcapturedevicepositionfront)
 *
 * > Important: Changing this parameter in real-time causes the preview to switch to the given camera device.
 */
@property (nonatomic, assign) AVCaptureDevicePosition position;

/**
 * Represents camera resolution currently used.
 *
 * Can be changed in real-time.
 */
@property (nonatomic, strong) AVCaptureSessionPreset preset;

/**
 * Represents currently used video orientation.
 *
 * Should be called with right orientation when the device rotates.
 */
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

/**
 * Initializes a new `CameraController` instance.
 *
 * > Tip: Better use ``init(deepAR:)`` instead.
 *
 * Example of initialization:
 *
 * **ObjC**
 * ```objc
 * self.cameraController = [[CameraController alloc] init];
 * self.cameraController.deepAR = self.deepAR;
 * [self.cameraController startCamera]; 
 * ```
 *
 * **Swift**
 * ```swift
 * cameraController = CameraController()
 * cameraController.deepAR = self.deepAR
 * cameraController.startCamera()
 * ```
 */
- (instancetype)init;

/**
 * Initializes a new `CameraController` instance.
 *
 * Example of initialization:
 *
 * **ObjC**
 * ```objc
 * self.cameraController = [[CameraController alloc]
 *                          initWithDeepAR:self.deepAR];
 * [self.cameraController startCamera];
 * ```
 *
 * **Swift**
 * ```swift
 * cameraController = CameraController(deepAR:self.deepAR)
 * cameraController.startCamera()
 * ```
 */
- (instancetype)initWithDeepAR:(DeepAR*)deepAR;

/**
 * Checks camera permissions.
 *
 * This will promt the user to give the camera permission if the app does not have it.
 */
- (void)checkCameraPermission;

/**
 * Checks microphone permissions.
 *
 * This will promt the user to give the microphone permission if the app does not have it.
 */
- (void)checkMicrophonePermission;

/**
 * Starts camera preview.
 *
 * Checks camera permissions and asks if none has been given.
 */
- (void)startCamera;

/**
 * Starts camera preview. Allows to start microphone as well.
 *
 * Checks camera permissions and asks if none has been given. Additionally, checks for microphone permissions if specified.
 *
 * > Important: Must be called if ``DeepAR/DeepAR/startVideoRecordingWithOutputWidth:outputHeight:subframe:videoCompressionProperties:recordAudio:`` has been called with `recordAudio` parameter set to `true`.
 *
 * - Parameter audio: If set to true, camera won't need to reinitialize when starting video recording.
 */
- (void)startCameraWithAudio:(BOOL)audio;

/**
 * Stops camera preview.
 */
- (void)stopCamera;

/**
 * Starts capturing audio samples.
 *
 * Checks permissions and asks if none has been given.
 *
 * > Important: Must be called if ``DeepAR/DeepAR/startVideoRecordingWithOutputWidth:outputHeight:subframe:videoCompressionProperties:recordAudio:`` has been called with `recordAudio` parameter set to `true`.
 */
- (void)startAudio;

/**
 * Stops capturing audio samples.
 */
- (void)stopAudio;

@end
