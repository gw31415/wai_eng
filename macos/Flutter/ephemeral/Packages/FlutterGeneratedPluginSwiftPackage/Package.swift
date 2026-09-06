// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .macOS("12.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "appkit_ui_element_colors", path: "../.packages/appkit_ui_element_colors-1.0.1"),
        .package(name: "dynamic_color", path: "../.packages/dynamic_color-1.8.1"),
        .package(name: "macos_ui", path: "../.packages/macos_ui-2.2.0"),
        .package(name: "macos_window_utils", path: "../.packages/macos_window_utils-1.9.1"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-9.0.1"),
        .package(name: "path_provider_foundation", path: "../.packages/path_provider_foundation-2.4.2"),
        .package(name: "share_plus", path: "../.packages/share_plus-12.0.2"),
        .package(name: "sqflite_darwin", path: "../.packages/sqflite_darwin-2.4.2"),
        .package(name: "url_launcher_macos", path: "../.packages/url_launcher_macos-3.2.3"),
        .package(name: "wakelock_plus", path: "../.packages/wakelock_plus-1.4.0"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "appkit-ui-element-colors", package: "appkit_ui_element_colors"),
                .product(name: "dynamic-color", package: "dynamic_color"),
                .product(name: "macos-ui", package: "macos_ui"),
                .product(name: "macos-window-utils", package: "macos_window_utils"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "url-launcher-macos", package: "url_launcher_macos"),
                .product(name: "wakelock-plus", package: "wakelock_plus"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
