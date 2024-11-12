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
        .package(path: "../deps/PoissonRecon"),
    ],
    targets: [
        .target(
            name: "StandardCyborgFusion",
            dependencies: [
                "json", "scsdk", "PoissonRecon", "ZipArchive"
            ],
            path: "Sources/StandardCyborgFusion",
            resources: [
                .process("Models/SCEarLandmarking.mlmodel"),
                .process("Models/SCEarTrackingModel.mlmodel"),
                .process("Models/SCFootTrackingModel.mlmodel"),
            ],
            publicHeadersPath: "include",
            // cSettings: [
            //     .define("DEBUG", .when(configuration: .debug)),
            //     .headerSearchPath("Algorithm"),
            //     .headerSearchPath("DataStructures"),
            //     .headerSearchPath("Helpers"),
            //     .headerSearchPath("IO"),
            //     .headerSearchPath("MetalDepthProcessor"),
            //     // .unsafeFlags(["-stdlib=libc++"]),
            // ],
            cxxSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("STD_LIB_FLAG"),
                .headerSearchPath("Algorithm"),
                .headerSearchPath("DataStructures"),
                .headerSearchPath("Helpers"),
                .headerSearchPath("IO"),
                .headerSearchPath("MetalDepthProcessor"),
                // .unsafeFlags(["-stdlib=libc++"]),
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
    cxxLanguageStandard: .cxx11
)
