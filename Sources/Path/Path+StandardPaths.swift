// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

public extension Path {
    /// The root path, representing the root directory in the file system.
    static let root: Self = Path(_path: .init(string: "/"))

    /// The path to the `/usr` directory.
    static let usr: Self = Path.root.appending("usr")

    /// The path to the `/usr/bin` directory.
    static let bin: Self = Path.usr.appending("bin")

    /// The path to the `/usr/local` directory
    static let local: Self = Path.usr.appending("local")

    /// The path to the `/usr/local/bin` directory
    static let localBin: Self = Path.local.appending("bin")
}
