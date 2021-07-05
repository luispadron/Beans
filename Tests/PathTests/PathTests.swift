// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import XCTest

@testable import Path

final class PathTests: XCTestCase {
    func test_init_pathString() {
        let p1 = Path("/")
        let p2 = Path("/path/to/dir")
        let p3 = Path("/../a")
        let p4 = Path("/path/to/a/b/../c")
        let p5 = Path("/path/to/a/b/c/..")

        XCTAssertEqual(p1.string, "/")
        XCTAssertEqual(p2.string, "/path/to/dir")
        XCTAssertEqual(p3.string, "/a")
        XCTAssertEqual(p4.string, "/path/to/a/c")
        XCTAssertEqual(p5.string, "/path/to/a/b")
    }

    func test_init_validating() throws {
        // Valid paths
        XCTAssertNoThrow(try Path(validating: "/"))
        XCTAssertNoThrow(try Path(validating: "/path/to/dir"))
        XCTAssertNoThrow(try Path(validating: "/../a"))
        XCTAssertNoThrow(try Path(validating: "/path/to/a/b/../c"))
        XCTAssertNoThrow(try Path(validating: "/path/to/a/b/c/.."))

        // Invalid paths
        try XCTAssertPathValidationError(when: Path(validating: ""))
        try XCTAssertPathValidationError(when: Path(validating: "~"))
        try XCTAssertPathValidationError(when: Path(validating: "~/path"))
        try XCTAssertPathValidationError(when: Path(validating: "path"))
        try XCTAssertPathValidationError(when: Path(validating: "../path"))
    }

    func test_init_relativeTo() {
        let p1 = Path("Sources", relativeTo: .root)
        let p2 = Path("Tests", relativeTo: Path("/path/to/repo"))
        let p3 = Path("/path/to/repo", relativeTo: Path("/path/to/another/repo"))
        let p4 = Path("../Tests", relativeTo: Path("/path/to/repo/Sources"))

        XCTAssertEqual(p1.string, "/Sources")
        XCTAssertEqual(p2.string, "/path/to/repo/Tests")
        XCTAssertEqual(p3.string, "/path/to/repo")
        XCTAssertEqual(p4.string, "/path/to/repo/Tests")
    }

    func test_init_relativeToValidating() throws {
        try XCTAssertNoThrow(Path(validating: "Sources", relativeTo: .root))
        try XCTAssertNoThrow(Path(validating: "Tests", relativeTo: Path("/path/to/repo")))
        try XCTAssertNoThrow(Path(validating: "/path/to/repo", relativeTo: Path("/path/to/another/repo")))
        try XCTAssertNoThrow(Path(validating: "../Tests", relativeTo: Path("/path/to/repo/Sources")))
        try XCTAssertPathValidationError(when: Path(validating: "~", relativeTo: .root))
    }

    func test_internal_init() throws {
        let _path = UNIXPath(string: "/path/to/a")
        let path = Path(_path: _path)
        XCTAssertEqual(path.string, "/path/to/a")
    }

    func test_url() {
        XCTAssertEqual(Path("/").url, URL(fileURLWithPath: "/"))
        XCTAssertEqual(Path("/.").url, URL(fileURLWithPath: "/"))
        XCTAssertEqual(Path("/path/to/dir").url, URL(fileURLWithPath: "/path/to/dir"))
        XCTAssertEqual(Path("/path/to/dir/..").url, URL(fileURLWithPath: "/path/to"))
        XCTAssertEqual(Path("/path/to/another/../dir").url, URL(fileURLWithPath: "/path/to/dir"))
    }

    func test_basename() {
        XCTAssertEqual(Path("/").basename, "/")
        XCTAssertEqual(Path("/path/to/file.swift").basename, "file.swift")
        XCTAssertEqual(Path("/path/to/dir").basename, "dir")
        XCTAssertEqual(Path("/path/to/tar.gz.zip").basename, "tar.gz.zip")
    }

    func test_components() {
        XCTAssertEqual(Path("/").components, ["/"])
        XCTAssertEqual(Path("/path/to/a").components, ["/", "path", "to", "a"])
    }

    func test_parent() {
        let p1 = Path("/")
        let p2 = Path("/path/to/a")
        let p3 = Path("/path/to/c/../b")

        XCTAssertEqual(p1.parent(), .root)
        XCTAssertEqual(p1.parent(depth: 2), .root)
        XCTAssertEqual(p1.parent(depth: 100), .root)
        XCTAssertEqual(p2.parent(), Path("/path/to"))
        XCTAssertEqual(p3.parent(depth: 2), Path("/path"))
    }

    func test_hasExtension() throws {
        XCTAssertTrue(try XCTUnwrap(Path("/path/to/file.swift")).hasExtension("swift"))
        XCTAssertFalse(try XCTUnwrap(Path("/path/to/file.swift")).hasExtension(".swift"))
        XCTAssertFalse(try XCTUnwrap(Path("/path/to/file.swift")).hasExtension("..swift"))
        XCTAssertTrue(try XCTUnwrap(Path("/path/to/file.tar.gz")).hasExtension("gz"))
        XCTAssertFalse(try XCTUnwrap(Path("/path/to/file.tar.gz")).hasExtension(".gz"))
        XCTAssertFalse(try XCTUnwrap(Path("/path/to/file/swift")).hasExtension("swift"))
        XCTAssertFalse(try XCTUnwrap(Path("/path/to/file/swift")).hasExtension(".swift"))
    }

    func test_appending() {
        let path = Path.root
        let p1 = path.appending("path")
        let p2 = p1.appending("to", "file.swift")
        let p3 = p1.appending("..", "otherPath")

        XCTAssertEqual(p1.string, "/path")
        XCTAssertEqual(p2.string, "/path/to/file.swift")
        XCTAssertEqual(p3.string, "/otherPath")
    }
}

private func XCTAssertPathValidationError<T>(
    when expression: @autoclosure @escaping () throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line
) throws {
    XCTAssertThrowsError(try expression()) { error in
        XCTAssertTrue(error is PathValidationError)
    }
}
