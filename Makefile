clean:
	rm -fdr .bazel-xcodeproj/* .xcodebuild/*
	bazelisk clean

bazel_run_debug: clean
	bazelisk run //:CrashRepro

bazel_run_debug_o_size: clean
	bazelisk run --swiftcopt=-Osize //:CrashRepro

bazel_generate_xcode_proj_debug: clean
	bazelisk run //:CrashRepro_xcodeproj && xed .bazel-xcodeproj/CrashRepro.xcodeproj

bazel_generate_xcode_proj_debug_o_size: clean
	bazelisk run  --@rules_xcodeproj//xcodeproj:extra_common_flags='--swiftcopt=-Osize' //:CrashRepro_xcodeproj && xed .bazel-xcodeproj/CrashRepro.xcodeproj

xcodebuild_run_debug_o_size: clean create_simulator
	xcodebuild -workspace CrashRepro.xcworkspace -scheme CrashRepro -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15 Pro Max (CrashRepro),OS=latest' -xcconfig Base.xcconfig clean build install DSTROOT=.xcodebuild
	$(MAKE) simctl_launch_app

xcodebuild_run_release_o_size: clean create_simulator
	xcodebuild -workspace CrashRepro.xcworkspace -scheme CrashRepro -configuration Release -destination 'platform=iOS Simulator,name=iPhone 15 Pro Max (CrashRepro),OS=latest' -xcconfig Base.xcconfig clean build install DSTROOT=.xcodebuild
	$(MAKE) simctl_launch_app

simctl_launch_app:
	xcrun simctl list devices available | grep 'iPhone 15 Pro Max (CrashRepro)' | grep -q '(Booted)' || xcrun simctl boot 'iPhone 15 Pro Max (CrashRepro)'
	xcrun simctl install 'iPhone 15 Pro Max (CrashRepro)' .xcodebuild/Applications/CrashRepro.app
	xcrun simctl launch 'iPhone 15 Pro Max (CrashRepro)' com.restermans.CrashRepro

create_simulator:
	xcrun simctl list devices available | grep -q 'iPhone 15 Pro Max (CrashRepro)' || xcrun simctl create 'iPhone 15 Pro Max (CrashRepro)' 'iPhone 15 Pro Max'