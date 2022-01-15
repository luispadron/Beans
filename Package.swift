// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "TerminalKit",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .library(
      name: "Terminal",
      targets: ["Terminal"]
    ),
    .library(
      name: "System",
      targets: ["System"]
    ),
    .library(
      name: "Path",
      targets: ["Path"]
    ),
    .executable(
      name: "examples",
      targets: ["examples"]
    ),
    .executable(
      name: "ditto",
      targets: ["ditto"]
    ),
  ],
  dependencies: [],
  targets: [
    .executableTarget(
      name: "examples",
      dependencies: [
        "Terminal",
        "System",
      ]
    ),
    .executableTarget(
      name: "ditto",
      dependencies: [
        "Terminal",
        "System",
      ]
    ),
    .target(
      name: "TerminalUI",
      dependencies: []
    ),
    .target(
      name: "Terminal",
      dependencies: []
    ),
    .testTarget(
      name: "TerminalTests",
      dependencies: ["Terminal"]
    ),
    .target(
      name: "System",
      dependencies: []
    ),
    .target(
      name: "Path",
      dependencies: []
    ),
    .testTarget(
      name: "PathTests",
      dependencies: ["Path"]
    ),
  ]
)
