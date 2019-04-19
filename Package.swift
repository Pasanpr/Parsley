// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Parsley",
    products: [
        .library(name: "ParsleyCore", targets: ["ParsleyCore"]),
        .library(name: "Syllablast", targets: ["Syllablast"]),
        .library(name: "SwiftMark", targets: ["SwiftMark"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/johnsundell/files", from: "3.1.0"),
        .package(url: "https://github.com/kylef/Commander", from: "0.8.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "Parsley", dependencies: ["ParsleyCore"]),
        .target(name: "ParsleyCore", dependencies: ["Syllablast", "Files", "Commander"]),
        .target(name: "Syllablast", dependencies: ["SwiftMark"]),
        .target(name: "SwiftMark", dependencies: ["Yams"]),
        .testTarget(name: "ParsleyCoreTests", dependencies: ["ParsleyCore"]),
        .testTarget(name: "ParsleyTests", dependencies: ["Parsley"]),
        .testTarget(name: "SyllablastTests", dependencies: ["Syllablast"]),
        .testTarget(name: "SwiftMarkTests", dependencies: ["SwiftMark"]),
    ]
)
