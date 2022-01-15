// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

extension Path {
  /// The root path, representing the root directory in the file system.
  public static let root: Self = Path(_path: .init(string: "/"))

  /// The path to the `/usr` directory.
  public static let usr: Self = Path.root.appending("usr")

  /// The path to the `/usr/bin` directory.
  public static let bin: Self = Path.usr.appending("bin")

  /// The path to the `/usr/local` directory
  public static let local: Self = Path.usr.appending("local")

  /// The path to the `/usr/local/bin` directory
  public static let localBin: Self = Path.local.appending("bin")
}
