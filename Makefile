clean:
	rm -fdr bazel-xcodeproj/*
	bazelisk clean

crash: clean
	bazelisk run --swiftcopt=-Osize //:CrashRepro

no_crash: clean
	bazelisk run //:CrashRepro

xcode_crash: clean
	bazelisk run  --@rules_xcodeproj//xcodeproj:extra_common_flags='--swiftcopt=-Osize' //:CrashRepro_xcodeproj && xed bazel-xcodeproj/CrashRepro.xcodeproj

xcode_no_crash: clean
	bazelisk run //:CrashRepro_xcodeproj && xed bazel-xcodeproj/CrashRepro.xcodeproj