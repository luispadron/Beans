// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation

/// A `Path` is **always** an absolute path to some item on a file system.
///
/// `Path`s are simple representations of a file system item, `Path` just provides a way of representing an absolute path in a uniform way.
/// They do not guarantee anything about the item that the path represents.
///
/// ## Creating paths
///
/// `Path`s are initialized with a `String` which is checked for any invalid characters and validated to ensure the path actually
/// represents an absolute path on the current file system.
///
/// `Path`s have several initializers which can be used to either `throw` an error if validation fails or assume correct paths.
/// In either case, the initializer must perform some validation to ensure the given path is a valid absolute path on the current file system, as such,
/// creating a `Path` is always fail-able.
///
/// ## Examples
///
/// ```
/// let root = Path.root
/// let git: Path = "/usr/bin/git"
/// let sources = Path("/path/to/sources")
///
/// do {
///     let git = try Path(validating: "/usr/bin/git")
/// } catch {
///     print("Error validating path")
/// }
/// ```
public struct Path: Hashable {
    let _path: UNIXPath

    // MARK: - Initializers

    /// Initializes a `Path` with the given `String` representing an absolute path on a file system.
    ///
    /// Normalizes the given path if needed.
    /// Note: `pathString` must be an absolute path, i.e `~/path/to/file` is not valid.
    public init(_ pathString: String) {
        self._path = UNIXPath(normalizingAbsolutePath: pathString)
    }

    /// Initializes a `Path` with the given `String` representing an absolute path on a file system.
    ///
    /// If the given string is not a valid absolute path, throws a `PathError`.
    public init(validating pathString: String) throws {
        _path = try UNIXPath(validatingAbsolutePath: pathString)
    }

    /// Creates a `Path` from the given relative `pathString` relative to the given `path`.
    ///
    /// If `pathString` is an absolute path, then `relativeTo` is ignored and `pathString` is returned.
    ///
    /// Example: 
    /// ```
    /// let r1 = Path("Sources/File", relativeTo: Path("/MyProject")) // -> /MyProject/Sources/File
    /// let r2 = Path("/Absolute", relativeTo: "/Absolute2") // -> /Absolute
    /// ```
    public init(_ pathString: String, relativeTo path: Path) {
        if pathString.hasPrefix("/") {
            self._path = UNIXPath(normalizingAbsolutePath: pathString)
        } else {
            let relativePath = UNIXPath(normalizingRelativePath: pathString)
            self._path = path._path.appending(relativePath: relativePath)
        }
    }

    /// Creates a `Path` from the given relative `pathString` relative to the given `path`.
    ///
    /// If `pathString` is an absolute path, then `relativeTo` is ignored and `pathString` is returned.
    /// Validates that `pathString` is a relative path on the file system.
    ///
    /// Example: 
    /// ```
    /// let r1 = Path("Sources/File", relativeTo: Path("/MyProject")) // -> /MyProject/Sources/File
    /// let r2 = Path("/Absolute", relativeTo: "/Absolute2") // -> /Absolute
    /// ```
    public init(validating pathString: String, relativeTo path: Path) throws {
        if pathString.hasPrefix("/") {
            self._path = try UNIXPath(validatingAbsolutePath: pathString)
        } else {
            let relativePath = try UNIXPath(validatingRelativePath: pathString)
            self._path = path._path.appending(relativePath: relativePath)
        }
    }

    /// Initializer for internal representation of `Path`.
    init(_path: UNIXPath) {
        self._path = _path
    }

    // MARK: - API

    /// The `Path` represented as a `String`.
    public var string: String {
        _path.string
    }

    /// The `Path` represented as a `URL`.
    public var url: URL {
        URL(fileURLWithPath: string)
    }

    /// The base name of a `Path` is the last component in the `Path`.
    ///
    /// ## Examples
    ///
    /// ```
    /// Path("/path/to/file.swift").basename // -> "file.swift"
    /// Path("/path/to/dir").basename // -> "dir"
    /// ```
    public var basename: String {
        _path.basename
    }

    /// Returns the path components.
    ///
    /// Components are separated by "/" path character.
    /// Note that the root path ("/") is itself a component.
    ///
    /// ## Examples
    ///
    /// ```
    /// Path("/usr/bin/git").components // -> ["/", "usr", "bin", "git"]
    /// Path("/").components // -> ["/"]
    /// ```
    public var components: [String] {
        _path.components
    }

    /// Returns the `depth` parent from the given current `Path`.
    ///
    /// This operation will always result in a valid `Path` being returned, even
    /// if `depth` is greater than the number of total components because
    /// the parent of `/`  is `/`.
    ///
    /// ## Examples
    ///
    /// ```
    /// Path("/usr/bin/git").parent() // -> "/usr/bin"
    /// Path("/").parent(depth: 2) // -> "/"
    /// ```
    public func parent(depth: Int = 1) -> Self {
        let parent = (0..<depth).reduce(_path) { path, _ in
            path.parentDirectory
        }
        return Path(_path: parent)
    }

    /// Returns whether the `Path` has the given path extension.
    ///
    /// A path extension here is anything following the last '.'.
    ///
    /// ## Examples
    ///
    /// ```
    /// Path("/path/to/file.swift").hasExtension("swift") // -> true
    /// Path("/path/to/file.tar.gz").hasExtension("gz) // -> true
    /// Path("/path/to/swift").hasExtension("swift") // -> false
    /// ```
    ///
    /// - Parameter extension: The file extension to check the path for.
    /// - Returns: Whether or not the `Path` has the given extension.
    public func hasExtension(_ extension: String) -> Bool {
        guard let suffix = _path.suffix(withDot: false) else { return false }
        return suffix == `extension`
    }

    /// Appends a path component and returns the result as a new `Path`.
    ///
    /// Path components should not contain any path separators, they should be single
    /// components that make up a path.
    ///
    /// ## Examples
    ///
    /// ```
    /// Path.root.appending("usr", "bin") // -> "/usr/bin"
    /// Path("/usr/local/bin").appending("brew") // -> "/usr/local/bin/brew"
    /// ```
    ///
    /// - Parameter components: The singular components to add to the `Path`.
    /// - Returns: A new `Path` with the given `components` appended.
    public func appending(_ components: String...) -> Self {
        Self(_path: components.reduce(_path) { $0.appending(component: $1) })
    }
}
