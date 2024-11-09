load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_apple//apple:apple.bzl", "local_provisioning_profile")
load("@rules_xcodeproj//xcodeproj:defs.bzl", "xcode_provisioning_profile")
load("@build_bazel_rules_apple//apple:versioning.bzl", "apple_bundle_version")
load("@rules_xcodeproj//xcodeproj:defs.bzl", "xcodeproj", "top_level_target")

_BUNDLE_ID = "restermans.com.CrashRepro"
_PROFILE_NAME = "iOS Team Provisioning Profile: restermans.com.CrashRepro"
_TEAM_ID = "YAK5CL5GTN"

swift_library(
    name = "Polling_swift_library",
    module_name = "Polling",
    srcs = glob(["Polling/*.swift"]),
)

swift_library(
    name = "CrashRepro_swift_library",
    module_name = "CrashRepro",
    srcs = glob(["CrashRepro/*.swift"]),
    deps = [":Polling_swift_library"],
)

local_provisioning_profile(
    name = "CrashRepro_local_provisioning_profile",
    profile_name = _PROFILE_NAME,
    team_id = _TEAM_ID,
)

xcode_provisioning_profile(
    name = "CrashRepro_xcode_provisioning_profile",
    managed_by_xcode = True,
    provisioning_profile = ":CrashRepro_local_provisioning_profile",
)

apple_bundle_version(
    name = "CrashRepro_apple_bundle_version",
    build_version = "1.0",
)

ios_application(
    name = "CrashRepro",
    bundle_name = "CrashRepro",
    app_icons = glob(["Assets.xcassets/**"]),
    bundle_id = _BUNDLE_ID,
    families = ["iphone"],
    infoplists = ["CrashRepro/Info.plist"],
    minimum_os_version = "17.0",
    deps = [":CrashRepro_swift_library"],
    resources = glob(["CrashRepro/*.lproj/**"]),
    provisioning_profile = ":CrashRepro_xcode_provisioning_profile",
    version = ":CrashRepro_apple_bundle_version",
    visibility = ["//visibility:public"],
    features = ["-objc_link_flag"],
)

xcodeproj(
    name = "CrashRepro_xcodeproj",
    install_directory = package_name() + "bazel-xcodeproj",
    project_name = "CrashRepro",
    top_level_targets = [
        top_level_target(
            ":CrashRepro",
            target_environments = [
                "device",
                "simulator",
            ],
        ),
    ],
    focused_targets = [
        ":CrashRepro_swift_library",
        ":CrashRepro",
        ":Polling_swift_library",
    ],
)