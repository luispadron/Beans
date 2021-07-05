// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation
import XCTest

@testable import Path

final class PathStringExpressibleTests: XCTestCase {
    func test_expressible() {
        let p1: Path = "/path/to/a"
        let p2: Path = "/"

        XCTAssertEqual(p1.string, "/path/to/a")
        XCTAssertEqual(p2.string, "/")
    }

    func test_interpolation() {
        let p1: String = "\(path: "/path/to/a")"
        XCTAssertEqual(p1, "/path/to/a")
    }
}
