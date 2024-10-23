// swift-tools-version:5.0
import PackageDescription
let package = Package(
    name: "RoomPlan2DViewer",
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        .target(
        name: "RoomPlan2DViewer",
        dependencies: ["ZIPFoundation"]),
    ]
)
