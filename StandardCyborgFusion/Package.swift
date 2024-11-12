// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "StandardCyborgFusion",
    platforms: [
        .iOS(.v13), .macOS(.v11)
    ],
    products: [
        .library(
            name: "StandardCyborgFusion",
            targets: ["StandardCyborgFusion"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nlohmann/json.git", from: "3.11.3"),
        .package(url: "https://github.com/ZipArchive/ZipArchive.git", from: "2.6.0"),
        .package(path: "../scsdk"),
        .package(path: "../deps/libigl"),
        .package(path: "../deps/PoissonRecon"),
    ],
    targets: [
        .target(
            name: "StandardCyborgFusion",
            dependencies: [
                "json",
                "libigl",
                "scsdk",
                "PoissonRecon",
                "ZipArchive",
            ],
            path: "Sources/StandardCyborgFusion",
            // resources: [
            //     .process("Models/SCEarLandmarking.mlmodel"),
            //     .process("Models/SCEarTrackingModel.mlmodel"),
            //     .process("Models/SCFootTrackingModel.mlmodel"),
            // ],
            publicHeadersPath: "include",
            cxxSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("STD_LIB_FLAG"),
                .define("OBJC_OLD_DISPATCH_PROTOTYPES", to: "1"),
                .unsafeFlags(["-fobjc-arc"]),
                .headerSearchPath("Algorithm"),
                .headerSearchPath("DataStructures"),
                .headerSearchPath("EarLandmarking"),
                .headerSearchPath("Helpers"),
                .headerSearchPath("IO"),
                .headerSearchPath("MetalDepthProcessor"),
                .headerSearchPath("Private"),
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("Metal")
            ]
        ),
        // .testTarget(
        //     name: "StandardCyborgFusionTests",
        //     dependencies: ["StandardCyborgFusion"],
        //     cSettings: [
        //         // .headerSearchPath("Include"),
        //         .define("DEBUG", .when(configuration: .debug)),
        //     ],
        //     cxxSettings: [
        //         // .headerSearchPath("Include"),
        //         .define("DEBUG", .when(configuration: .debug)),
        //     ]
        // )
    ],
    cxxLanguageStandard: .cxx17
)
