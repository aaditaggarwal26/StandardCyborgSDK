// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "PoissonRecon",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(name: "PoissonRecon", targets: ["PoissonRecon"]),
    ],
    targets: [
        .target(
            name: "PoissonRecon",
            path: "Sources",
            publicHeadersPath: "include",
            cxxSettings: [
                .define("STD_LIB_FLAG"),
            ]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
