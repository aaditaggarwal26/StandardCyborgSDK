// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Eigen",
    products: [
        .library(name: "Eigen", targets: ["Eigen"]),
    ],
    targets: [
        .target(
            name: "Eigen",
            path: "include",
            // exclude: ["src"],
            publicHeadersPath: "."
        ),
    ],
    cxxLanguageStandard: .cxx17
)
