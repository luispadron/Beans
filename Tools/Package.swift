// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "Tools",
  platforms: [.macOS(.v12)],
  dependencies: [
    .package(
      name: "swift-format",
      url: "https://github.com/apple/swift-format",
      .upToNextMajor(from: "0.50500.0")
    )
  ],
  targets: [
    .target(
      name: "Tools",
      path: "",
      exclude: [
        "swift-format"
      ]
    )
  ]
)
