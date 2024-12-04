/**
 * @file DeepAR.h
 * Conatins the main DeepAR classes, structures and enumerations.
 * @copyright Copyright (c) 2021 DeepAR.ai
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include <TargetConditionals.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <Cocoa/Cocoa.h>
#endif

/**
 * Represents data structure containing all the information available about the detected face.
 *
 * > Important: The face data is available only when some face filter is loaded.
 */
typedef struct {
    /**
     * Determines whether the face is detected or not.
     */
    bool detected;
    /**
     * The X, Y and Z translation values of the face in the scene.
     */
    float translation[3];
    /**
     * The pitch, yaw and roll rotation values in euler angles (degrees) of the face in the scene.
     */
    float rotation[3];
    /**
     * Translation and rotation in matrix form (D3D style, column-major order).
     */
    float poseMatrix[16];
    /**
     * Detected 68 face feature points in 3D space (X, Y, Z).
     */
    float landmarks[68 * 3];
    /**
     * Detected face feature points in 2D screen space coordinates (X, Y).
     *
     * Usually more precise than 3D points but no estimation for Z translation.
     */
    float landmarks2d[68 * 3]; // TODO: *3 is definitely a typo; fix and test
    /**
     * A rectangle containing the face in screen coordinates (X, Y, Width, Height).
     */
    float faceRect[4];
    /**
     * Estimated emotions for the face.
     *
     * > Important: The emotions values are valid only when some emotion detection filter is loaded.
     *
     * Each emotion has a value in [0.0, 1.0] range. The 1.0 value means 100% detected emotion.
     *
     * We differentiate 5 different emotions:
     * - Index 0 is neutral
     * - Index 1 is happiness
     * - Index 2 is surprise
     * - Index 3 is sadness
     * - Index 4 is anger
     */
    float emotions[5];
    /**
     * The array of action units.
     *
     * > Warning: This property currently contains garbage values and it should not be used.
     */
    float actionUnits[63]; // TODO: discover more
    /**
     * The number of ``actionUnits``.
     */
    int numberOfActionUnits; // TODO: discover more
} FaceData;

/**
 * Structure containing face data for up to 4 detected faces.
 */
typedef struct {
    /**
     * Array of face data for up to 4 detected faces.
     */
    FaceData faceData[4];
} MultiFaceData;

/**
 * The video (and audio) recording configuration.
 */
typedef struct {
    /**
     * The output video width.
     */
    NSInteger outputWidth;
    /**
     * The output video height.
     */
    NSInteger outputHeight;
    /**
     * The sub rectangle of the view  that you want to record in normalized coordinates (0.0 - 1.0).
     */
    CGRect subframe;
    /**
     *Video compression properties.
     *
     * A dictionary used as the value for the key [`AVVideoCompressionPropertiesKey`](https://developer.apple.com/documentation/avfoundation/avvideocompressionpropertieskey).
     */
    CFDictionaryRef videoCompressionProperties;
    /**
     * Determine whether audio is recorded or not.
     */
    BOOL recordAudio;
} RecordingConfig;

/**
 * A four-dimensional float vector.
 */
typedef struct {
    /**
     * X value.
     */
    float x;
    /**
     * Y value.
     */
    float y;
    /**
     * Z value.
     */
    float z;
    /**
     * W value.
     */
    float w;
} Vector4;

/**
 * A three-dimensional float vector.
 */
typedef struct {    
    /**
     * X value.
     */
    float x;
    /**
     * Y value.
     */
    float y;
    /**
     * Z value.
     */
    float z;
} Vector3;

/**
 * Output color format.
 */
typedef NS_ENUM(NSInteger, OutputFormat)
{
    /**
     * Undefined format.
     */
    Undefined, // 0
    /**
     * Red, green, blue and alpha format.
     */
    RGBA,      // 1
    /**
     * Blue, green, red and alpha format.
     */
    BGRA,      // 2
    /**
     * Alpha, red, green and blue format.
     */
    ARGB,      // 3
    /**
     * Alpha, blue, green and red format.
     */
    ABGR,      // 4
    /**
     * Number of formats.
     */
    COUNT
};

/**
 * DeepAR error types.
 */
typedef NS_ENUM(NSInteger, ARErrorType) {
    /**
     * DeepAR debug type.
     */
    DEEPAR_ERROR_TYPE_DEBUG,
    /**
     * DeepAR info type.
     */
    DEEPAR_ERROR_TYPE_INFO,
    /**
     * DeepAR warning type.
     */
    DEEPAR_ERROR_TYPE_WARNING,
    /**
     * DeepAR error type.
     */
    DEEPAR_ERROR_TYPE_ERROR
};

/**
 * Possible types of an occurred touch.
 */
typedef NS_ENUM(NSInteger, TouchType) {
    /**
     * Touch type that implies that a touch was started.
     */
    START,
    /**
     * Touch type that implies that a previously started touch changed.
     */
    MOVE,
    /**
     * Touch type that implies that a previously started touch ended.
     */
    END
};

/**
 * Possible variable types.
 */
typedef NS_ENUM(NSInteger, VarType) {
    /**
     * Bool variable type.
     */
    BOOLEAN = 0,
    /**
     * Integer variable type.
     */
    INT = 1,
    /**
     * Double variable type.
     */
    DOUBLE = 2,
    /**
     * String variable type.
     */
    STRING = 3
};

/**
 * Possible types for tone mapping
 */
typedef NS_ENUM(NSInteger, ToneMapping) {
    LINEAR = 1,
    REINHARD = 2,
    CINEON = 3,
    ACES = 4,
    AGX = 5,
    NEUTRAL = 6
};


#if TARGET_OS_OSX
/**
 * Possible types of logging.
 */
typedef NS_ENUM(NSInteger, LogType) {
    /**
     * Info logging type.
     */
    INFO = 1,
    /**
     * Warning logging type.
     */
    WARNING = 2,
    /**
     * Error loging type.
     */
    ERROR = 3
};

@interface LogEntry : NSObject

@property NSString* message;
@property LogType type;

@end
#endif


/**
 * Contains information about the current location and status of the started touch.
 */
typedef struct {
    /**
     * Value of the x coordinate of the current touch location.
     */
    CGFloat x;
    /**
     * Value of the y coordinate of the current touch location.
     */
    CGFloat y;
    /**
     * The status, i.e., touch type, of the touch.
     */
    TouchType type;
} TouchInfo;

/**
 * Properties related to face tracking initialization.
 *
 * Pass to ``DeepAR/DeepAR/setFaceTrackingInitParameters:``.
 */
typedef struct {
    /**
     * Engine will initialize face tracking as soon as possible if true.
     * Else it will initialize when face tracking when it is needed. Eg. when loading effect that uses face tracking.
     */
    bool initializeEngineWithFaceTracking;

    /**
     * If true, face tracking will be initialized synchronously and will be blocking DeepAR rendering.
     * Else it will initialize in background thread and not block rendering.
     */
    bool initializeFaceTrackingSynchronously;
} FaceTrackingInitParameters;

/**
 * A delegate that is used to notify events from DeepAR to the consumer of the DeepAR SDK.
 *
 * It is set on ``DeepAR/DeepAR/delegate``
 */
@protocol DeepARDelegate <NSObject>

// We must put @optional before every delagate method because DocC otherwise marks them as required.
// This issue has been fixed in DocC (see: https://github.com/apple/swift-docc/issues/182), but is not yet part of Xcode.
@optional

#if TARGET_OS_IOS
/**
 * Called when DeepAR has finished taking a screenshot.
 *
 * - Parameter screenshot: The taken screenshot.
 */
- (void)didTakeScreenshot:(UIImage*)screenshot;
#elif TARGET_OS_OSX
/**
 * Called when DeepAR has finished taking a screenshot.
 *
 * - Parameter screenshot: The taken screenshot.
 */
- (void)didTakeScreenshot:(NSImage*)screenshot;
#endif

@optional

/**
 * Called when the DeepAR engine initialization is complete.
 */
- (void)didInitialize;

@optional

/**
 * Called when DeepAR detects a new face or loses a face that has been tracked.
 *
 * - Parameter faceVisible: True if face is visible in the scene, false otherwise..
 */
- (void)faceVisiblityDidChange:(BOOL)faceVisible;

@optional

/**
 * Called when a new processed frame is available.
 *
 * > Important: To start receiving this delegate method call ``DeepAR/DeepAR/startCaptureWithOutputWidth:outputHeight:subframe:``.
 *
 * - Parameter sampleBuffer: New frame.
 */
- (void)frameAvailable:(CMSampleBufferRef)sampleBuffer;

@optional

/**
 * Called on each frame where at least one face data is detected.
 *
 * > Important: In order for this delegate to be invoked, the face tracking in DeepAR needs to be working. This is usually started with loading some face filter.
 *
 * - Parameter faceData: The face data.
 */
- (void)faceTracked:(MultiFaceData)faceData;

@optional

/**
 * Whenever a face is detected or lost from the scene this method is called.
 *
 * - Parameter facesVisible: The number of currently detected faces in the frame.
 */
- (void)numberOfFacesVisibleChanged:(NSInteger)facesVisible;

@optional

/**
 * DeepAR has successfully shut down after the method shutdown call.
 *
 * This is called after ``DeepAR/DeepAR/shutdown``.
 */
- (void)didFinishShutdown;

@optional

/**
 * Called when the tracked image changes visibility.
 *
 * > Warning: This delegate is not being used at all.
 *
 * - Parameter gameObjectName: The name of the node in the filter file to which the image is associated.
 * - Parameter imageVisible: True if image is visible, false otherwise..
 */
- (void)imageVisibilityChanged:(NSString*)gameObjectName imageVisible:(BOOL)imageVisible; // TODO: explore further

@optional

/**
 * Called when the effect is fully switched (loaded) and ready for preview.
 *
 * This delegate is called after call to ``DeepAR/DeepAR/switchEffectWithSlot:path:`` and other `switchEffect` methods.
 *
 * - Parameter slot: The slot name of the loaded effect.
 */
- (void)didSwitchEffect:(NSString*)slot;

@optional

/**
 * Called when the conditions have been met for the animation to transition to the next state (e.g. mouth open, emotion detected etc.).
 *
 * - Parameter state: The state name.
 */
- (void)animationTransitionedToState:(NSString*)state;

@optional

/**
 * Called when DeepAR has started video recording.
 *
 * Called after the call to ``DeepAR/DeepAR/startVideoRecordingWithOutputWidth:outputHeight:`` and other `startVideoRecording` methods.
 */
- (void)didStartVideoRecording;

@optional

/**
 * Called when the video recording preparation is finished.
 */
- (void)didFinishPreparingForVideoRecording;

@optional

/**
 * Called when the video recording is finished.
 *
 * Called after the call to ``DeepAR/DeepAR/finishVideoRecording``.
 *
 * - Parameter videoFilePath: The video file path.
 */
- (void)didFinishVideoRecording:(NSString*)videoFilePath;

@optional

/**
 * Called when an error has occurred during video recording.
 *
 * - Parameter error: The video recording error.
 */
- (void)recordingFailedWithError:(NSError*)error;

@optional

/**
 * Called when an error has occurred within DeepAR SDK.
 *
 * - Parameter code: Error type.
 * - Parameter error: Error message.
 */
- (void)onErrorWithCode:(ARErrorType)code error:(NSString*)error;

@end

/**
 * Main class for interacting with DeepAR engine.
 *
 */
@interface DeepAR : NSObject

/**
 * The object which implements ``DeepARDelegate`` protocol to listen for async events coming from DeepAR.
 */
@property (nonatomic, weak) id<DeepARDelegate> delegate;

/**
 * Indicates if computer vision components have been initialized during the initialization process.
 */
@property (nonatomic, readonly) BOOL visionInitialized;

/**
 * Indicates if DeepAR rendering components have been initialized during the initialization process.
 */
@property (nonatomic, readonly) BOOL renderingInitialized;

/**
 * Indicates if at least one face is detected in the current frame.
 */
@property (nonatomic, readonly) BOOL faceVisible;

/**
 * Rendering resolution with which the DeepAR has been initialized.
 */
@property (nonatomic, readonly) CGSize renderingResolution;

/**
 * If enabled, this removes the lag that occures when starting to record first video with DeepAR.
 *
 * If set to true, ``startVideoRecordingWithOutputWidth:outputHeight:`` and other video recording methods work
 * to allow the video recording to be started immediately during runtime
 *
 * To use video recodring warmup follow these steps
 * 1. Set videoRecordingWarmupEnabled = true after calling `DeepAR()`
 * ```swift
 * override func viewDidLoad() {
 *  self.deepAR = DeepAR()
 *  self.deepAR.videoRecordingWarmupEnabled = true
 * }
 * ```
 * 2. After DeepAR is initialized (``DeepARDelegate/didInitialize``)
 * call ``startVideoRecordingWithOutputWidth:outputHeight:`` or any other video recording methods with desired parameters.
 * Only needs to be called once.
 * ```swift
 * func didInitialize {
 *     self.deepAR.startVideoRecording(withOutputWidth:outputWidth, outputHeight:outputHeight, subframe:screenRect)
 * }
 *  ```
 * 3. Wait for ``DeepARDelegate/didFinishPreparingForVideoRecording`` delegate method to enable recording.
 * 4. Call ``resumeVideoRecording``.
 * 5. Call ``finishVideoRecording``. This will automatically start preparing for the next recording session with the parameters set in ``startVideoRecordingWithOutputWidth:outputHeight:``.
 * 6. Wait for ``DeepARDelegate/didFinishVideoRecording:`` delegate method and repeat the resumeVideoRecording step as needed
 */
@property (nonatomic, assign) BOOL videoRecordingWarmupEnabled;

/**
 * The audio compression settings.
 */
@property (nonatomic, strong) NSDictionary* audioCompressionSettings;

/**
 * The DeepAR SDK version number.
 *
 * - Returns: DeepAR SDK version number string.
 */
+ (NSString*) sdkVersion;

/**
 * Set the license key for your app.
 *
 * The license key is generated on the DeepAR Developer portal. Here are steps on how to generate a license key:
 * 1. Log in/Sign up to [DeepAR Developer Portal](https://developer.deepar.ai/).
 * 2. Create a new project and in that project create an iOS app.
 * 3. In the create app dialog enter your app name and bundle id that your app is using. Bundle id must match the one you are using in your app, otherwise, the license check will fail. Read more about iOS bundle id [here](https://developer.apple.com/documentation/appstoreconnectapi/bundle_ids).
 * 4. Copy the newly generated license key as a parameter in this method.
 *
 * > Important:  You must call this method before you call the ``createARViewWithFrame:`` or any other initialization methods.
 *
 * - Parameter key: The license key.
 */
- (void)setLicenseKey:(NSString*)key;

#if TARGET_OS_IOS
/**
 * Initialize DeepAR with a [CAEAGLLayer](https://developer.apple.com/documentation/quartzcore/caeagllayer) as rendering target.
 *
 * > Tip: Consider using ``createARViewWithFrame:`` which will create the `UIView` for you.
 *
 * - Parameter width: The rendering width.
 * - Parameter height: The rendering height.
 * - Parameter window: Destination layer where the DeepAR engine will render the frames.
 */
- (void)initializeWithWidth:(NSInteger)width height:(NSInteger)height window:(CAEAGLLayer*)window;
#elif TARGET_OS_OSX
/**
 * Initialize DeepAR with a [NSOpenGLContext](https://developer.apple.com/documentation/appkit/nsopenglcontext) as rendering target.
 *
 * > Tip: Consider using ``initializeViewWithFrame:`` which will create the `NSView` for you.
 *
 * - Parameter width: The rendering width.
 * - Parameter height: The rendering height.
 * - Parameter context: OpenGL context where the DeepAR engine will render the frames.
 */
- (void)initializeWithWidth:(NSInteger)width height:(NSInteger)height context:(NSOpenGLContext*)context;
#endif

/**
 * Initialize DeepAR in vision-only mode.
 *
 * Vision-only mode doesn't do any rendering and/or camera preview. It is used just to get the ML tracking information from DeepAR..
 */
- (void)initialize;

/**
 * Starts the engine initialization for rendering in off-screen mode.
 *
 *  Frames will be produced in ``DeepARDelegate/frameAvailable:`` delegate method.
 *
 * - Parameter width: The rendering width.
 * - Parameter height: The rendering height.
 */
- (void)initializeOffscreenWithWidth:(NSInteger)width height:(NSInteger)height;

#if TARGET_OS_IOS
/**
 * Initialize DeepAR and render the AR preview in the `UIView`.
 *
 * - Parameter frame: The view dimensions.
 * - Returns: The `UIView` where the DeepAR frames will be rendered.
 */
- (UIView*)createARViewWithFrame:(CGRect)frame;
#elif TARGET_OS_OSX
/**
 * Initialize DeepAR and render the AR preview in the `NSView`.
 *
 * - Parameter frame: The view dimensions.
 * - Returns: The `NSView` where the DeepAR frames will be rendered.
 */
- (NSView*)initializeViewWithFrame:(NSRect)frame;
#endif

/**
 * Indicates if DeepAR has been initialized in the vision-only mode or not.
 *
 * - Returns: Indication if the vision-only mode is active.
 */
- (BOOL)isVisionOnly;

/**
 * Changes the output resolution of the processed frames.
 *
 * > Note: Can be called any time.
 *
 * - Parameter width: The output resolution width.
 * - Parameter height: The output resolution height.
 */
- (void)setRenderingResolutionWithWidth:(NSInteger)width height:(NSInteger)height;

/**
 * Shuts down the DeepAR engine.
 *
 * > Warning: Reinitialization of a new DeepAR instance which has not been properly shut down can cause crashes and memory leaks. Usually, it is done in view controller `dealloc` method.
 */
- (void)shutdown;

#if TARGET_OS_IOS
/**
 * Switch DeepAR rendering to `UIView`.
 *
 * - Parameter frame: The frame size.
 * - Returns: The new `UIView` in which DeepAR will render with a given frame size.
 */
- (UIView*)switchToRenderingToViewWithFrame:(CGRect)frame;
#elif TARGET_OS_OSX
/**
 * Switch DeepAR rendering to `NSView`.
 *
 * - Parameter frame: The frame size.
 * - Returns: The new `NSView` in which DeepAR will render with a given frame size.
 */
- (NSView*)switchToRenderingToViewWithFrame:(CGRect)frame;
#endif

/**
 * Starts rendering in the off-screen buffer.
 *
 * Frames will be produced in ``DeepARDelegate/frameAvailable:`` delegate method.
 *
 * - Parameter width: The buffer width.
 * - Parameter height: The buffer height.
 */
- (void)switchToRenderingOffscreenWithWidth:(NSInteger)width height:(NSInteger)height;

/**
 * An optimization method and it allows the user to indicate the DeepAR in which mode it should operate.
 *
 * If called with true value, DeepAR will expect a continuous flow of new frames and it will optimize its inner processes for such workload.
 * An example of this is the typical use case of processing the frames from the camera stream.
 * If called with false it will optimize for preserving resources and memory by pausing the rendering after each processed frame.
 * A typical use case for this is when the user needs to process just one image. In that case, the user will feed the image to DeepAR by calling ``processFrame:mirror:``
 * or similar method, and DeepAR would process it and stop rendering until a new frame is received. If we did so when the DeepAR is in live mode,
 * it would process the same frame over and over again without ever stopping the rendering process, thus wasting processing time.
 *
 * - Parameter liveMode: Enable or disable live mode.
 */
- (void)changeLiveMode:(BOOL)liveMode;

/**
 * Resumes the rendering if it was previously paused, otherwise doesn't do anything.
 */
- (void)resume;

/**
 * Pauses the rendering.
 *
 * This method will not release any resources and should be used only for temporary pause (e.g. user goes to the next screen).
 * Use the``shutdown`` method to stop the engine and to release the resources.
 */
- (void)pause;

/**
 * Feed frame to DeepAR for processing.
 *
 * - Parameter imageBuffer: The input image data that needs processing.
 * - Parameter mirror: Indicates whether the image should be flipped vertically before processing (front/back camera).
 */
- (void)processFrame:(CVPixelBufferRef)imageBuffer mirror:(BOOL)mirror;

/**
 * Feed frame to DeepAR for processing.
 *
 * - Parameter imageBuffer: The input image data that needs processing.
 * - Parameter mirror: Indicates whether the image should be flipped vertically before processing (front/back camera).
 * - Parameter timestamp: The frame timestamp.
 */
- (void)processFrame:(CVPixelBufferRef)imageBuffer mirror:(BOOL)mirror timestamp:(CMTimeValue)timestamp;

/**
 * Feed frame to DeepAR for processing.
 *
 * Outputs the result in the `outputBuffer` parameter.
 * Requires frame capturing to be started (user must call ``startCaptureWithOutputWidth:outputHeight:subframe:`` beforehand).
 *
 * - Parameter imageBuffer: The input image data that needs processing.
 * - Parameter outputBuffer: The output image buffer.
 * - Parameter mirror: Indicates whether the image should be flipped vertically before processing (front/back camera).
 */
- (void)processFrameAndReturn:(CVPixelBufferRef)imageBuffer outputBuffer:(CVPixelBufferRef)outputBuffer mirror:(BOOL)mirror;

/**
 * Enqueue camera frame for processing by DeepAR.
 *
 * - Parameter sampleBuffer: The sample buffer.
 * - Parameter mirror: Indicates whether the image should be flipped vertically before processing (front/back camera).
 */
- (void)enqueueCameraFrame:(CMSampleBufferRef)sampleBuffer mirror:(BOOL)mirror;

/**
 * Enqueue an audio sample to the DeepAR engine.
 *
 * Used in video recording when user wants to record audio too. Audio samples will be processed only
 * if the ``startVideoRecordingWithOutputWidth:outputHeight:subframe:videoCompressionProperties:recordAudio:``
 * method has been called with `recordAudio` parameter set to true.
 *
 * - Parameter sampleBuffer: The sample buffer.
 */
- (void)enqueueAudioSample:(CMSampleBufferRef)sampleBuffer;

/**
 * Sets the video recording file output name.
 *
 * The argument is file name only, no extension. The file extension .mov will be appended automatically. Defalut value is *"export"*.
 *
 * - Parameter outputName: Output file name without the extension.
 */
- (void)setVideoRecordingOutputName:(NSString*)outputName;

/**
 * Changes the output path for all video recordings during runtime after it is called.
 *
 * The argument is path only, no name. The defalut value is the AppData Documents folder.
 *
 * Example:
 * ```objc
 * [self.deepAR setVideoRecordingOutputPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
 * ```
 *
 * - Parameter outputPath: Output video file path.
 */
- (void)setVideoRecordingOutputPath:(NSString*)outputPath;

/**
 * Starts video recording of the AR preview with the given resolution.
 *
 * - Parameter outputWidth: The output width.
 * - Parameter outputHeight: The output height.
 */
- (void)startVideoRecordingWithOutputWidth:(int)outputWidth outputHeight:(int)outputHeight;

/**
 * Starts video recording of the AR preview with the given resolution.
 *
 * - Parameter outputWidth: The output width.
 * - Parameter outputHeight: The output height.
 * - Parameter subframe: Defines the sub rectangle of the AR preview that you want to record in normalized coordinates (0.0 - 1.0).
 */
- (void)startVideoRecordingWithOutputWidth:(int)outputWidth outputHeight:(int)outputHeight subframe:(CGRect)subframe;

/**
 * Starts video recording of the AR preview with the given resolution.
 *
 * - Parameter outputWidth: The output width.
 * - Parameter outputHeight: The output height.
 * - Parameter subframe: Defines the sub rectangle of the AR preview that you want to record in normalized coordinates (0.0 - 1.0).
 * - Parameter videoCompressionProperties: A dictionary used as the value for the key [`AVVideoCompressionPropertiesKey`](https://developer.apple.com/documentation/avfoundation/avvideocompressionpropertieskey). Read more about video compression options in the official docs [here](https://developer.apple.com/documentation/avfoundation/avvideocompressionpropertieskey).
 */
- (void)startVideoRecordingWithOutputWidth:(int)outputWidth outputHeight:(int)outputHeight subframe:(CGRect)subframe videoCompressionProperties:(NSDictionary*)videoCompressionProperties;

/**
 * Starts video recording of the AR preview with given resolution.
 *
 * - Parameter outputWidth: The output width.
 * - Parameter outputHeight: The output height.
 * - Parameter subframe: Defines the sub rectangle of the AR preview that you want to record in normalized coordinates (0.0 - 1.0).
 * - Parameter videoCompressionProperties: A dictionary used as the value for the key [`AVVideoCompressionPropertiesKey`](https://developer.apple.com/documentation/avfoundation/avvideocompressionpropertieskey). Read more about video compression options in the official docs [here](https://developer.apple.com/documentation/avfoundation/avvideocompressionpropertieskey).
 * - Parameter recordAudio: Determines weather the audio is recorded. If DeepAR preview is paired with ``DeepAR/CameraController`` this will work out of the box. Otherwise, if set to true the recording will wait until you call ``enqueueAudioSample:``. When DeepAR is ready to receive audio samples it will publish `NSNotification` with key `deepar_start_audio`. You can subscribe to this notification and start feeding audio samples once you receive it.
 */
- (void)startVideoRecordingWithOutputWidth:(int)outputWidth outputHeight:(int)outputHeight subframe:(CGRect)subframe videoCompressionProperties:(NSDictionary*)videoCompressionProperties recordAudio:(BOOL)recordAudio;

/**
 * Load a DeepAR effect file for AR preview.
 *
 * Example of loading 2 effects in the same scene:
 * ```objc
 * [self.deepAR switchEffectWithSlot:@"mask" path:"flowers"];
 * [self.deepAR switchEffectWithSlot:@"filter" path:"tv80"];
 * ```
 *
 * - Parameter slot: Specifies a namespace for the effect in the scene. In each slot, there can be only one effect. If you load another effect in the same slot the previous one will be removed and replaced with a new effect.
 * - Parameter path: Path to a file located in the app bundle or anywhere in the filesystem where the app has access to. Value `nil` will remove the effect from the scene. For example, one can download the filters from online locations and save them in the Documents directory.
 */
- (void)switchEffectWithSlot:(NSString*)slot path:(NSString*)path;

/**
 * Load a DeepAR effect file for AR preview.
 *
 * Example:
 * ```objc
 * // apply flowers effect to the first face
 * [self.deepAR switchEffectWithSlot:@"mask_f0" path:"flowers" face:0];
 * // apply beard effect to the second face
 * [self.deepAR switchEffectWithSlot:@"mask_f1" path:"beard" face:1];
 * // replace the effect on the first face with the lion
 * [self.deepAR switchEffectWithSlot:@"mask_f0" path:"lion" face:0];
 * // remove the beard effect from the second face
 * [self.deepAR switchEffectWithSlot:@"mask_f1" path:nil face:1];
 * ```
 *
 * - Parameter slot: Specifies a namespace for the effect in the scene. In each slot, there can be only one effect. If you load another effect in the same slot the previous one will be removed and replaced with a new effect.
 * - Parameter path: Path to a file located in the app bundle or anywhere in the filesystem where the app has access to. Value `nil` will remove the effect from the scene. For example, one can download the filters from online locations and save them in the Documents directory.
 * - Parameter face: Indicates on which face to apply the effect. DeepAR offers tracking up to 4 faces, so valid values for this parameter are 0, 1, 2, and 3. For example, if you call this method with face value 2, the effect will be only applied to the third detected face in the scene. If you want to set an effect on a different face make sure to also use a different value for the slot parameter to avoid removing the previously added effect.
 *
 */
- (void)switchEffectWithSlot:(NSString*)slot path:(NSString*)path face:(NSInteger)face;

/**
 * Load a DeepAR effect file for AR preview.
 *
 * - Parameter slot: Specifies a namespace for the effect in the scene. In each slot, there can be only one effect. If you load another effect in the same slot the previous one will be removed and replaced with a new effect.
 * - Parameter path: Path to a file located in the app bundle or anywhere in the filesystem where the app has access to. Value `nil` will remove the effect from the scene. For example, one can download the filters from online locations and save them in the Documents directory.
 * - Parameter face: Indicates on which face to apply the effect. DeepAR offers tracking up to 4 faces, so valid values for this parameter are 0, 1, 2, and 3. For example, if you call this method with face value 2, the effect will be only applied to the third detected face in the scene. If you want to set an effect on a different face make sure to also use a different value for the slot parameter to avoid removing the previously added effect.
 * - Parameter targetGameObject: Indicates a node in the currently loaded scene/effect into which the new effect will be loaded. By default, effects are loaded in the root node object.
 */
- (void)switchEffectWithSlot:(NSString*)slot path:(NSString*)path face:(NSInteger)face targetGameObject:(NSString*)targetGameObject;

/**
 * Load a DeepAR effect file for AR preview.
 *
 * - Parameter slot: Specifies a namespace for the effect in the scene. In each slot, there can be only one effect. If you load another effect in the same slot the previous one will be removed and replaced with a new effect.
 * - Parameter data: The contents of the file.
 */
- (void)switchEffectWithSlot:(NSString*)slot data:(NSData*)data;

/**
 * Load a DeepAR effect file for AR preview.
 *
 * - Parameter slot: Specifies a namespace for the effect in the scene. In each slot, there can be only one effect. If you load another effect in the same slot the previous one will be removed and replaced with a new effect.
 * - Parameter data: The contents of the file.
 * - Parameter face: Iindicates on which face to apply the effect. DeepAR offers tracking up to 4 faces, so valid values for this parameter are 0, 1, 2, and 3. For example, if you call this method with face value 2, the effect will be only applied to the third detected face in the scene. If you want to set an effect on a different face make sure to also use a different value for the slot parameter to avoid removing the previously added effect.
 */
- (void)switchEffectWithSlot:(NSString*)slot data:(NSData*)data face:(NSInteger)face;

/**
 * Produces a image of the current AR preview.
 *
 * The image is produced in ``DeepARDelegate/didTakeScreenshot:`` delegate method.
 */
- (void)takeScreenshot;

/**
 * Finishes the video recording.
 *
 * The video is produced in ``DeepARDelegate/didFinishVideoRecording:`` delegate method.
 */
- (void)finishVideoRecording;

/**
 * Pauses video recording if it has been started beforehand.
 */
- (void)pauseVideoRecording;

/**
 * Resumes video recording after it has been paused.
 */
- (void)resumeVideoRecording;

/**
 * Enables or disables audio pitch processing for video recording.
 *
 * - Parameter enabled: Enable or disable audio processing.
 */
- (void)enableAudioProcessing:(BOOL)enabled;

/**
 * Sets the pitch change amount.
 *
 * Negative values will make the recorded audio lower in pitch and positive values will make it higher in pitch.
 * Must call ``enableAudioProcessing:`` to enable the pitch processing beforehand.
 *
 *- Parameter sts: The pitch change amount.
 */
- (void)setAudioProcessingSemitone:(float)sts;

/**
 * Starts capturing the AR preview frames in the image buffer.
 *
 * Images are produced in the ``DeepARDelegate/frameAvailable:`` delegate method.
 *
 * - Parameter outputWidth: The width of the processed frames.
 * - Parameter outputHeight: The height of the processed frames.
 * - Parameter subframe: The subrectangle of AR preview which will be outputted. This means that the output frame in ``DeepARDelegate/frameAvailable:`` does not need to be the same size and/or position as the one rendered to the AR preview.
 */
- (void)startCaptureWithOutputWidth:(NSInteger)outputWidth outputHeight:(NSInteger)outputHeight subframe:(CGRect)subframe;

/**
 * Starts capturing the AR preview frames in the image buffer.
 *
 * Images are produced in the ``DeepARDelegate/frameAvailable:`` delegate method.
 *
 * - Parameter outputHeight: The height of the processed frames.
 * - Parameter subframe: The subrectangle of AR preview which will be outputted. This means that the output frame in ``DeepARDelegate/frameAvailable:`` does not need to be the same size and/or position as the one rendered to the AR preview.
 * - Parameter outputFormat: Pixel format of the captured images.
 */
- (void)startCaptureWithOutputWidthAndFormat:(NSInteger)outputWidth outputHeight:(NSInteger)outputHeight subframe:(CGRect)subframe outputImageFormat:(OutputFormat)outputFormat;

/**
 * Stops capturing the AR preview frames in the image buffer.
 *
 * Images are no longer produced in the ``DeepARDelegate/frameAvailable:`` delegate method.
 */
- (void)stopCapture;

/**
 * Fire named trigger of an fbx animation set on the currently loaded effect.
 *
 * To learn more about fbx and image sequence animations on DeepAR please read our article [here](https://docs.deepar.ai/deepar-studio/studio-explained/animations-and-sounds/animation-controller#animation-state-transitions).
 *
 *- Parameter trigger: The trigger name.
 */
- (void)fireTrigger:(NSString*)trigger;

/**
 * Informs DeepAR that a touch occured.
 */
- (void)touchOccurred:(TouchInfo)touchInfo;

/**
 * Display performance  stats on screen.
 *
 * - Parameter enabled: Enable performance stats.
 */
- (void)showStats:(BOOL) enabled;

/**
 * Enable or disable global physics simulation.
 *
 * - Parameter enabled: Enable global physics simulation.
 */
- (void)simulatePhysics:(BOOL) enabled;

/**
 * Display physics colliders preview on screen.
 *
 * - Parameter enabled: Enable physics colliders preview.
 */
- (void)showColliders:(BOOL) enabled;

/**
 * Mutes or un-mutes all the sounds that are currently playing from the loaded effects.
 *
 * - Parameter muteSound: True if you want to mute all the sounds.
 */
- (void)muteSound:(BOOL) muteSound;

/**
 * Sets tone mapping exposure
 *
 * Sets tone mapping exposure. Value passed here will override value specified within an effect file.
 * - Parameter exposure: exposure value
 */
- (void)setExposure:(float) exposure;

/**
 * Sets environment map intensity
 *
 * Sets environment map intensity. Value passed here will override value specified within an effect file.
 *
 * - Parameter environmentMapIntensity: environment map intensity
 */
- (void)setEnvironmentMapIntensity:(float) envMapIntensity;

/**
 * Sets tone mapping
 *
 * Sets tone mapping. Value passed here will override value specified within an effect file.
 * See here for more details about tone mapping functions: https://modelviewer.dev/examples/tone-mapping
 * - Parameter toneMapping: tone mapping function
 */
- (void)setToneMapping:(ToneMapping) toneMapping;

/**
 * Toggles bloom postprocessing.
 */
- (void)setBloomEnabled:(BOOL) enable;

/**
 * Sets bloom threshold parameter.
 *
 * Value passed here overrides the one specified within an effect file.
 * - Parameter threshold bloom threshold
 */
- (void)setBloomThreshold:(float) threshold;

/**
 * Sets bloom strength parameter.
 *
 * Value passed here overrides the one specified within an effect file.
 * - Parameter strength bloom strength
 */
- (void)setBloomStrength:(float) strength;

/**
 * Sets bloom radius parameter.
 *
 * Value passed here overrides the one specified within an effect file.
 * - Parameter radius bloom radius
 */
- (void)setBloomRadius:(float) radius;

#if TARGET_OS_IOS
/**
 * Enable background replacement (also known as background removal, or green screen effect).
 *
 * - Parameter enable: Indicates whether to enable or disable the background replacement effect.
 * - Parameter image: Image to be used as the background.
 */
- (void)backgroundReplacement:(BOOL) enable image:(UIImage*) image;

/**
 * Sets a new environment map
 *
 * Sets a new environment map that will be used for rendering materials with new PBR glTF shader.
 * If an effect file using the new PBR glTF shader is currently active, function changes the environment map to the one provided.
 * Otherwise, it is going to override the one passed in with the effect file.
 *
 * - Parameter image: image to be used as an environment map.
 */
- (void)setEnvironmentMap:(UIImage*) image;

/**
 * Sets new environment map that will be used for rendering materials with diamond shader.
 *
 * Overrides environment map specified within an effect file.
 * - Parameter image Path to fetch or ArrayBuffer with an image.
 */
- (void)setDiamondEnvironmentMap:(UIImage*) image;

#elif TARGET_OS_OSX
/**
 * Enable background replacement (also known as background removal, or green screen effect).
 *
 * - Parameter enable: Indicates whether to enable or disable the background replacement effect.
 * - Parameter image: Image to be used as the background.
 */
- (void)backgroundReplacement:(BOOL) enable image:(NSImage*) image;

/**
 * Sets a new environment map
 *
 * Sets a new environment map that will be used for rendering materials with new PBR glTF shader.
 * If an effect file using the new PBR glTF shader is currently active, function changes the environment map to the one provided.
 * Otherwise, it is going to override the one passed in with the effect file.
 *
 * - Parameter image: image to be used as an environment map.
 */
- (void)setEnvironmentMap:(NSImage*) image;

/**
 * Sets new environment map that will be used for rendering materials with diamond shader.
 *
 * Overrides environment map specified within an effect file.
 * - Parameter image Path to fetch or ArrayBuffer with an image.
 */
- (void)setDiamondEnvironmentMap:(NSImage*) image;

#endif

/**
 * Enables background blur.
 *
 * Video calling use case usually provides users with the option to blur the bacground.
 *
 * - Parameter enable: Indicates whether to enable or disable the background blur effect.
 * - Parameter strength: Blur strength. Number ranging from 1-10.
 */
- (void)backgroundBlur:(BOOL) enable strength:(NSInteger) strength;

/**
 * This method allows the user to change face detection sensitivity.
 *
 * - Parameter sensitivity: Ranges from 0 to 3, where 0 is the fastest but might not recognize smaller (further away) faces, and 3 is the slowest but will find smaller faces. By default, this parameter is set to 1.
 */
- (void)setFaceDetectionSensitivity:(NSInteger)sensitivity;

/**
 * Changes a node or component float parameter.
 *
 * For more details about changeParameter API read our article [here](https://docs.deepar.ai/deepar-sdk/tutorials/change-parameter).
 *
 * - Parameter gameObject: The name of the node. If multiple nodes share the same name, only the first one will be affected.
 * - Parameter component: The name of the component. If the name of the component is null or an empty string, the node itself will be affected.
 * - Parameter parameter: The name of the parameter.
 * - Parameter value: New parameter value.
 */
- (void)changeParameter:(NSString*)gameObject component:(NSString*)component parameter:(NSString*)parameter floatValue:(float)value;

/**
 * Changes a node or component 4D vector parameter.
 *
 * For more details about changeParameter API read our article [here](https://docs.deepar.ai/deepar-sdk/tutorials/change-parameter).
 *
 * - Parameter gameObject: The name of the node. If multiple nodes share the same name, only the first one will be affected.
 * - Parameter component: The name of the component. If the name of the component is null or an empty string, the node itself will be affected.
 * - Parameter parameter: The name of the parameter.
 * - Parameter value: New parameter value.
 */
- (void)changeParameter:(NSString*)gameObject component:(NSString*)component parameter:(NSString*)parameter vectorValue:(Vector4)value;

/**
 * Changes a node or component 3D vector parameter.
 *
 * For more details about changeParameter API read our article [here](https://docs.deepar.ai/deepar-sdk/tutorials/change-parameter).
 *
 * - Parameter gameObject: The name of the node. If multiple nodes share the same name, only the first one will be affected.
 * - Parameter component: The name of the component. If the name of the component is null or an empty string, the node itself will be affected.
 * - Parameter parameter: The name of the parameter.
 * - Parameter value: New parameter value.
 */
- (void)changeParameter:(NSString*)gameObject component:(NSString*)component parameter:(NSString*)parameter vector3Value:(Vector3)value;

/**
 * Changes a node or component boolean parameter.
 *
 * For more details about changeParameter API read our article [here](https://docs.deepar.ai/deepar-sdk/tutorials/change-parameter).
 *
 * - Parameter gameObject: The name of the node. If multiple nodes share the same name, only the first one will be affected.
 * - Parameter component: The name of the component. If the name of the component is null or an empty string, the node itself will be affected.
 * - Parameter parameter: The name of the parameter.
 * - Parameter value: New parameter value.
 */
- (void)changeParameter:(NSString*)gameObject component:(NSString*)component parameter:(NSString*)parameter boolValue:(BOOL)value;

#if TARGET_OS_IOS
/**
 * Changes a node or component image parameter.
 *
 * For more details about changeParameter API read our article [here](https://docs.deepar.ai/deepar-sdk/tutorials/change-parameter).
 *
 * - Parameter gameObject: The name of the node. If multiple nodes share the same name, only the first one will be affected.
 * - Parameter component: The name of the component. If the name of the component is null or an empty string, the node itself will be affected.
 * - Parameter parameter: The name of the parameter.
 * - Parameter image: New image parameter.
 */
- (void)changeParameter:(NSString*)gameObject component:(NSString*)component parameter:(NSString*)parameter image:(UIImage*)image;
#elif TARGET_OS_OSX
/**
 * Changes a node or component image parameter.
 *
 * For more details about changeParameter API read our article [here](https://docs.deepar.ai/deepar-sdk/tutorials/change-parameter).
 *
 * - Parameter gameObject: The name of the node. If multiple nodes share the same name, only the first one will be affected.
 * - Parameter component: The name of the component. If the name of the component is null or an empty string, the node itself will be affected.
 * - Parameter parameter: The name of the parameter.
 * - Parameter image: New image parameter.
 */
- (void)changeParameter:(NSString*)gameObject component:(NSString*)component parameter:(NSString*)parameter image:(NSImage*)image;
#endif

/**
 * Changes a node or component string parameter.
 *
 * For more details about changeParameter API read our article [here](https://docs.deepar.ai/deepar-sdk/tutorials/change-parameter).
 *
 * - Parameter gameObject: The name of the node. If multiple nodes share the same name, only the first one will be affected.
 * - Parameter component: The name of the component. If the name of the component is null or an empty string, the node itself will be affected.
 * - Parameter parameter: The name of the parameter.
 * - Parameter value: New parameter value.
 */
- (void)changeParameter:(NSString*)gameObject component:(NSString*)component parameter:(NSString*)parameter stringValue:(NSString*)value;


/**
 * Moves the selected game object from its current position in a tree and sets it as a direct child of a target game object.
 *
 * This is equivalent to moving around a node in the node hierarchy in the DeepAR Studio.
 *
 * - Parameter selectedGameObjectName: Node to move.
 * - Parameter targetGameObjectName: New node parent.
 */
- (void)moveGameObject:(NSString*)selectedGameObjectName targetGameObjectname:(NSString*)targetGameObjectName;

/**
 * Starts recording profiling stats by writing them to a CSV-formatted stream.
 */
- (void)startProfiling;

/**
 * Stops recording profiling stats and sends the recorded CSV to the stat export server.
 */
- (void)stopProfiling;

#if TARGET_OS_OSX
- (BOOL)pushConsoleLog:(NSString*)message type:(LogType)type;

- (NSMutableArray*)getConsoleLogs;
#endif

/**
 * Set parameters that will determine how the face tracking is initialized.
 *
 * > Important: This function must be called before DeepAR engine initializes. Call it before calling ``createARViewWithFrame:`` or ``initializeOffscreenWithWidth:height:``.
 *
 * - Parameter params: The parameters. See ``FaceTrackingInitParameters``.
 */
- (void)setFaceTrackingInitParameters:(FaceTrackingInitParameters)params;

/**
 * Check if variable with the given name is already created in the specified effect.
 *
 * - Parameter name: The variable name.
 * - Parameter slot: The slot of the effect in which to search the variable.
 * - Returns: True if variable is already created, false otherwise.
 */
- (bool)hasVar:(NSString*)name slot:(NSString*) slot;

/**
 * Check if variable with the given name is already created in at least one effect.
 *
 * - Parameter name: The variable name.
 * - Returns: True if variable is already created, false otherwise.
 */
- (bool)hasVar:(NSString*)name;

/**
 * Get the type of the variable with the given name in the specified effect.
 *
 * - Parameter name: The variable name.
 * - Parameter slot: The slot of the effect in which to search the variable.
 * - Returns: Variable type. Supported types are: boolean, int, double and string.
 * - Throws: `NSException` if the variable with the specified name does not exist.
 */
- (VarType)getVarType:(NSString*)name slot:(NSString*) slot;

/**
 * Get the type of the variable with the given name.
 *
 * The variable is searched in all effects.
 *
 * - Parameter name: The variable name.
 * - Returns: Variable type. Supported types are: boolean, int, double and string.
 * - Throws: `NSException` if the variable with the specified name does not exist.
 */
- (VarType)getVarType:(NSString*)name;

/**
 * Get boolean variable with the given name.
 *
 * - Parameter name: The variable name.
 * - Parameter slot: The slot of the effect in which to search the variable.
 * - Returns: Boolean value of the variable with the specified name.
 * - Throws: `NSException` if the variable with the specified name does not exist or is not of the bool type.
 */
- (bool)getBoolVar:(NSString*)name slot:(NSString*) slot;

/**
 * Get boolean variable with the given name.
 *
 * The variable is searched in all effects
 *
 * - Parameter name: The variable name.
 * - Returns: Boolean value of the variable with the specified name.
 * - Throws: `NSException` if the variable with the specified name does not exist or is not of the bool type.
 */
- (bool)getBoolVar:(NSString*)name;

/**
 * Get integer variable with the given name.
 *
 * - Parameter name: The variable name.
 * - Parameter slot: The slot of the effect in which to search the variable.
 * - Returns: Int value of the variable with the specified name.
 * - Throws: `NSException` if the variable with the specified name does not exist or is not of the int type.
 */
- (int)getIntVar:(NSString*)name slot:(NSString*) slot;

/**
 * Get integer variable with the given name.
 *
 * The variable is searched in all effects.
 *
 * - Parameter name: The variable name.
 * - Returns: Int value of the variable with the specified name.
 * - Throws: `NSException` if the variable with the specified name does not exist or is not of the int type.
 */
- (int)getIntVar:(NSString*)name;

/**
 * Get double variable with the given name.
 *
 * - Parameter name: The variable name.
 * - Parameter slot: The slot of the effect in which to search the variable.
 * - Returns: Double value of the variable with the specified name.
 * - Throws: `NSException` if the variable with the specified name does not exist or is not of the double type.
 */
- (double)getDoubleVar:(NSString*)name slot:(NSString*) slot;

/**
 * Get double variable with the given name.
 *
 * The variable is searched in all effects.
 *
 * - Parameter name: The variable name.
 * - Returns: Double value of the variable with the specified name.
 * - Throws: `NSException` if the variable with the specified name does not exist or is not of the double type.
 */
- (double)getDoubleVar:(NSString*)name;

/**
 * Get string variable with the given name.
 *
 * - Parameter name: The variable name.
 * - Parameter slot: The slot of the effect in which to search the variable.
 * - Returns: String value of the variable with the specified name.
 * - Throws: `NSException` if the variable with the specified name does not exist or is not of the string type.
 */
- (NSString*)getStringVar:(NSString*)name slot:(NSString*) slot;

/**
 * Get string variable with the given name.
 *
 * The variable is searched in all effects.
 *
 * - Parameter name: The variable name.
 * - Returns: String value of the variable with the specified name.
 * - Throws: `NSException` if the variable with the specified name does not exist or is not of the string type.
 */
- (NSString*)getStringVar:(NSString*)name;

/**
 * Set the boolean variable wih the given name.
 *
 * - Parameter name: The variable name.
 * - Parameter slot: The slot of the effect in which to search the variable.
 * - Parameter value: Value to be set.
 * - Returns: True if the variable is created. False if the variable with the given name already exists and the new value is set.
 */
- (bool)setBoolVar:(NSString*)name value:(bool)value slot:(NSString*) slot;

/**
 * Set the boolean variable with the given name.
 *
 * The variable is set globally, for all effects.
 *
 * - Parameter name: The variable name.
 * - Parameter value: Value to be set.
 * - Returns: True if the variable is created. False if the variable with the given name already exists and the new value is set.
 */
- (bool)setBoolVar:(NSString*)name value:(bool)value;

/**
 * Set the int variable wih the given name.
 *
 * - Parameter name: The variable name.
 * - Parameter slot: The slot of the effect in which to search the variable.
 * - Parameter value: Value to be set.
 * - Returns: True if the variable is created. False if the variable with the given name already exists and the new value is set.
 */
- (bool)setIntVar:(NSString*)name value:(int)value slot:(NSString*) slot;

/**
 * Set the int variable with the given name.
 *
 * The variable is set globally, for all effects.
 *
 * - Parameter name: The variable name.
 * - Parameter value: Value to be set.
 * - Returns: True if the variable is created. False if the variable with the given name already exists and the new value is set.
 */
- (bool)setIntVar:(NSString*)name value:(int)value;

/**
 * Set the double variable wih the given name.
 *
 * - Parameter name: The variable name.
 * - Parameter slot: The slot of the effect in which to search the variable.
 * - Parameter value: Value to be set.
 * - Returns: True if the variable is created. False if the variable with the given name already exists and the new value is set.
 */
- (bool)setDoubleVar:(NSString*)name value:(double)value slot:(NSString*) slot;

/**
 * Set the double variable with the given name.
 *
 * The variable is set globally, for all effects.
 *
 * - Parameter name: The variable name.
 * - Parameter value: Value to be set.
 * - Returns: True if the variable is created. False if the variable with the given name already exists and the new value is set.
 */
- (bool)setDoubleVar:(NSString*)name value:(double)value;

/**
 * Set the string variable wih the given name.
 *
 * - Parameter name: The variable name.
 * - Parameter slot: The slot of the effect in which to search the variable.
 * - Parameter value: Value to be set.
 * - Returns: True if the variable is created. False if the variable with the given name already exists and the new value is set.
 */
- (bool)setStringVar:(NSString*)name value:(NSString*)value slot:(NSString*) slot;

/**
 * Set the string variable with the given name.
 *
 * The variable is set globally, for all effects.
 *
 * - Parameter name: The variable name.
 * - Parameter value: Value to be set.
 * - Returns: True if the variable is created. False if the variable with the given name already exists and the new value is set.
 */
- (bool)setStringVar:(NSString*)name value:(NSString*)value;

/**
 * Delete the variable with the given name.
 *
 * - Parameter name: The variable name.
 * - Parameter slot: The slot of the effect in which to search the variable.
 * - Returns: True if variable is deleted, false otherwise.
 */
- (bool)deleteVar:(NSString*)name slot:(NSString*) slot;

/**
 * Delete the variable with the given name.
 *
 * The variable is searched in all effects.
 *
 * - Parameter name: The variable name.
 * - Returns: True if variable is deleted, false otherwise.
 */
- (bool)deleteVar:(NSString*)name;

/**
 * Clear all variables or variables from the specified effect.
 *
 * - Parameter slot: The ID of the effect in which to search the variable.
 * - Returns: True if one or more variables are deleted, false otherwise.
 */
- (bool)clearVars:(NSString*)slot;

/**
 * Clear all variables.
 *
 * - Returns: True if one or more variables are deleted, false otherwise.
 */
- (bool)clearVars;

@end
