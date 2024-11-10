Given

```
CrashRepro (iOS app) -> Polling (Module)
```

where CrashRepro contains

```
// SomePollingService.swift

final class SomePollingService {}
```

```
// SomePollingService+PollingService.swift

import Polling

extension SomePollingService: PollingService {}
```

```
// ViewController.swift

import UIKit
import Polling

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let somePollingService = SomePollingService()
        print(somePollingService)

        let pollingServiceWrapper = PollingServiceWrapper(pollingService: somePollingService)
        print(pollingServiceWrapper)

        view.backgroundColor = .red
    }
}
```

and Polling contains

```
// PollingService.swift

import Foundation

public protocol PollingService {}

public final class PollingServiceWrapper<Service: PollingService> {
    public init(pollingService: Service, debounceInterval: TimeInterval = 0.5) {
        print(pollingService)
        print(debounceInterval)
    }
}
```

and `-ObjC` flag is disabled and `alwayslink` is `False`, when i run `bazelisk run //:CrashRepro` (`make bazel_run_debug`), then the app DOES NOT crash, while when i run `bazelisk run --swiftcopt=-Osize //:CrashRepro` (`make bazel_run_debug_o_size`), then the app DOES crash and generates the following crash report

```
...
Thread 0 Crashed::  Dispatch queue: com.apple.main-thread
0   CrashRepro                    	       0x10256dba4 PollingServiceWrapper.init(pollingService:debounceInterval:) + 84
1   CrashRepro                    	       0x10256d75c ViewController.viewDidLoad() + 200
2   CrashRepro                    	       0x10256d8a0 @objc ViewController.viewDidLoad() + 32
3   UIKitCore                     	       0x12b5d669c -[UIViewController _sendViewDidLoadWithAppearanceProxyObjectTaggingEnabled] + 80
4   UIKitCore                     	       0x12b5db238 -[UIViewController loadViewIfRequired] + 908
5   UIKitCore                     	       0x12b5db4e0 -[UIViewController view] + 20
6   UIKitCore                     	       0x12bd7ba08 -[UIWindow addRootViewControllerViewIfPossible] + 132
7   UIKitCore                     	       0x12bd7b43c -[UIWindow _updateLayerOrderingAndSetLayerHidden:actionBlock:] + 168
8   UIKitCore                     	       0x12bd7c288 -[UIWindow _setHidden:forced:] + 228
9   UIKitCore                     	       0x12bd8b344 -[UIWindow _mainQueue_makeKeyAndVisible] + 36
10  CrashRepro                    	       0x10256cf14 AppDelegate.application(_:didFinishLaunchingWithOptions:) + 276
11  CrashRepro                    	       0x10256cfa8 @objc AppDelegate.application(_:didFinishLaunchingWithOptions:) + 116
...
```

When i apply the following patch (`git apply make_bazel_always_crash.patch`)

```
diff --git a/CrashRepro/ViewController.swift b/CrashRepro/ViewController.swift
index b5ce4be..53ab636 100644
--- a/CrashRepro/ViewController.swift
+++ b/CrashRepro/ViewController.swift
@@ -8,7 +8,7 @@ class ViewController: UIViewController {
         let somePollingService = SomePollingService()
         print(somePollingService)
 
-        let pollingServiceWrapper = PollingServiceWrapper(pollingService: somePollingService)
+        let pollingServiceWrapper = PollingServiceWrapper(pollingService: somePollingService, debounceInterval: 0.5)
         print(pollingServiceWrapper)
 
         view.backgroundColor = .red
```

and run either `bazelisk run //:CrashRepro` (`make bazel_run_debug`) or `bazelisk run --swiftcopt=-Osize //:CrashRepro` (`make bazel_run_debug_o_size`), then the app DOES crash in either case and generates the same crash report as before.

This behaviour is consistent for both iOS simulator and iOS device (run either `make bazel_generate_xcode_proj_debug` or `make bazel_generate_xcode_proj_debug_o_size` to generate Xcode project using [rules_xcodeproj](https://github.com/MobileNativeFoundation/rules_xcodeproj) to run the app on iOS device).

As a comparison, when i build and run the app on either iOS simulator or iOS device, in either Debug or Release config, with or without the afore mentioned patch from "vanilla" Xcode project, the app DOES NOT crash (run either `make xcodebuild_run_debug_o_size` or `make xcodebuild_run_release_o_size` to run on iOS simulator, or open `CrashRepro.xcworkspace` and run manually).

