// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "SpreadsheetView",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
    products: [
        .library(name: "SpreadsheetView", targets: ["SpreadsheetView"]),
        .library(name: "Spreadsheet", targets: ["Spreadsheet"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SpreadsheetView",
            dependencies: [],
            path: "Framework/Sources"
        ),
        .target(
            name: "Spreadsheet",
            dependencies: ["SpreadsheetView"]
        ),
//        .testTarget(
//            name: "SpreadsheetViewTests",
//            dependencies: ["SpreadsheetView"]),
    ]
)
