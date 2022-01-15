//
//  File.swift
//
//
//  Created by Luis Padron on 11/2/21.
//

import XCTest

@testable import Path

final class PathValidationErrorTests: XCTestCase {
  func test_startsWithTilde() {
    XCTAssertEqual(
      PathValidationError.startsWithTilde("~").errorDescription,
      "The string: ~ starts with illegal character: ~"
    )
    XCTAssertEqual(
      PathValidationError.startsWithTilde("~").failureReason,
      "The home directory (~) alias is not expanded automatically and is illegal as an absolute path."
    )
    XCTAssertEqual(
      PathValidationError.startsWithTilde("~").recoverySuggestion,
      "Expand the home directory (~) path manually"
    )
  }

  func test_invalidAbsolutePath() {
    XCTAssertEqual(
      PathValidationError.invalidAbsolutePath("?").errorDescription,
      "The string ? is not a valid absolute path on the file system"
    )
    XCTAssertEqual(
      PathValidationError.invalidAbsolutePath("?").failureReason,
      "The string ? failed to validate as a valid absolute path"
    )
    XCTAssertEqual(
      PathValidationError.invalidAbsolutePath("?").recoverySuggestion,
      "Ensure the string ? represents a valid absolute path on the current file system"
    )
  }

  func test_invalidRelativePath() {
    XCTAssertEqual(
      PathValidationError.invalidRelativePath("?").errorDescription,
      "The string ? is not a valid relative path on the file system"
    )
    XCTAssertEqual(
      PathValidationError.invalidRelativePath("?").failureReason,
      "The string ? failed to validate as a valid relative path"
    )
    XCTAssertEqual(
      PathValidationError.invalidRelativePath("?").recoverySuggestion,
      "Ensure the string ? represents a valid relative path on the current file system"
    )
  }
}
