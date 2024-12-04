# DeepAR for iOS

Build rich Augmented Reality experiences for iPhone, iPad and Mac.

## Overview

DeepAR is an augmented reality SDK used to integrate advanced,
Snapchat-like face lenses in iOS, Android and Web apps.

DeepAR iOS framework supports:
- Face filters and masks.
- Glasses virtual try on.
- Background replacement.
- Background blur.
- AR mini-games.

## Support

- iOS and iPad, minimum target version 12.4.
- MacOS, minimum target version 10.15.

DeepAR is available as xcframework for:
- iPhone.
- iPhone simulator for x86_64 ARCH (arm64 support coming soon).
- Mac for x86_64 ARCH (arm64 support coming soon).

DeepAR can be used in both Swift and ObjC projects.

## Documentation

- Visit official DeepAR docs for iOS SDK [here](https://docs.deepar.ai/deepar-sdk/platforms/ios/overview).
- See the official example [here](https://github.com/DeepARSDK/quickstart-ios-swift).

## Install

DeepAR is available as xcframework 
through [CocoaPods](https://cocoapods.org/), [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)
and can be downloaded directly from [DeepAR Developer Portal](https://developer.deepar.ai/downloads).

### Swift Packages

Add [swift package](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) to your Xcode project
from this GitHub URL: 
```text
https://github.com/DeepARSDK/swift-deepar
```

### CocoaPods

To install DeepAR via CocoaPods, add this to your Podfile:
```ruby
pod 'DeepAR'
```

If the `pod install` command fails, you may need to run `pod install --repo-update`.
This is because the CocoaPods repos sometimes need a lot of time to sync.

### Direct download

1. Download the iOS package from [DeepAR Developer Portal](https://developer.deepar.ai/downloads) and unzip.
2. With your project open in Xcode, select your **Target**. Under **General** tab, find **Frameworks, Libraries, and Embedded Content** and then click the `+` button.
3. Click `Add Other...` and then `Add files...` button.
4. Select the `DeepAR.xcframework` from the unzipped directory and click `Open`.

## License key

In order to use the DeepAR SDK you need to set up a license key for your ios app on [developer.deepar.ai](https://developer.deepar.ai).
1. Create an account: https://developer.deepar.ai/signup.
2. Create a project: https://developer.deepar.ai/projects.
3. Add a ios app to the project. Note that you need to specify the bundle id of your app app.

## Getting started

Import DeepAR.
```swift
import DeepAR
```

Create DeepAR object and set your license key.
```swift
var deepAR = DeepAR()
deepAR.setLicenseKey("your_license_key_here")
```

Add delegate for the DeepAR object to be notified of async events.
```swift
deepAR.delegate = ...
```

Create CameraController object:
```swift
var cameraController = CameraController(deepAR: deepAR)
```

Get the `UIView` that will display the camera preview and AR filters.
Add it to your view hierarchy.
```swift
let arView = self.deepAR.createARView(withFrame: ...)
mainView.addSubview(arView)
```

Start the camera controller
```swift
cameraController.startCamera(withAudio: true)
```

Wait for the `didInitialize` delegate to be called.

## Switch effects

AR filters are represented by effect files in DeepAR. You can load them to preview the effect.

Places you can get DeepAR effects:
- Download a free filter pack: https://docs.deepar.ai/deepar-sdk/filters#free-effects-pack-content.
- Visit DeepAR asset store: https://www.store.deepar.ai/
- Create your own filters with [DeepAR Studio](https://www.deepar.ai/creator-studio).

Call `switchEffect` method to load an AR filter from a file.
File can be placed in the app bundle or fetched from network and saved to device.
```swift
deepAR.switchEffect(withSlot: "effect", path: path)
```

## Background blur

Blur the background with blur strength 5.
```swift
deepAR.backgroundBlur(true, strength: 5)
```

## Background replacement

Also known as background removal or greenscreen effect.

```swift
deepAR.backgroundReplacement(true, image: UIImage(named: "sunny_beach.png"))
```

## License

Please see: https://developer.deepar.ai/customer-agreement
