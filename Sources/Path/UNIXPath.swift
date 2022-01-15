// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation

// The code in this file may include changes made by the authors of TerminalKit.
// It is part of the Swift project and originally created by the team at Apple.
// Taken from: https://github.com/apple/swift-tools-support-core and modified to for this project.

/*
 This source file is part of the Swift.org open source project
 Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

struct UNIXPath: Hashable {
  let string: String
  private static let root = UNIXPath(string: "/")

  var dirname: String {
    #if os(Windows)
      let fsr: UnsafePointer<Int8> = string.fileSystemRepresentation
      defer { fsr.deallocate() }

      let path = String(cString: fsr)
      return path.withCString(encodedAs: UTF16.self) {
        let data = UnsafeMutablePointer(mutating: $0)
        PathCchRemoveFileSpec(data, path.count)
        return String(decodingCString: data, as: UTF16.self)
      }
    #else
      // FIXME: This method seems too complicated; it should be simplified,
      //        if possible, and certainly optimized (using UTF8View).
      // Find the last path separator.
      guard let idx = string.lastIndex(of: "/") else {
        // No path separators, so the directory name is `.`.
        return "."
      }
      // Check if it's the only one in the string.
      if idx == string.startIndex {
        // Just one path separator, so the directory name is `/`.
        return "/"
      }
      // Otherwise, it's the string up to (but not including) the last path
      // separator.
      return String(string.prefix(upTo: idx))
    #endif
  }

  var basename: String {
    #if os(Windows)
      let path: String = string
      return path.withCString(encodedAs: UTF16.self) {
        PathStripPathW(UnsafeMutablePointer(mutating: $0))
        return String(decodingCString: $0, as: UTF16.self)
      }
    #else
      // FIXME: This method seems too complicated; it should be simplified,
      //        if possible, and certainly optimized (using UTF8View).
      // Check for a special case of the root directory.
      if string.only == "/" {
        // Root directory, so the basename is a single path separator (the
        // root directory is special in this regard).
        return "/"
      }
      // Find the last path separator.
      guard let idx = string.lastIndex(of: "/") else {
        // No path separators, so the basename is the whole string.
        return string
      }
      // Otherwise, it's the string from (but not including) the last path
      // separator.
      return String(string.suffix(from: string.index(after: idx)))
    #endif
  }

  // FIXME: We should investigate if it would be more efficient to instead
  // return a path component iterator that does all its work lazily, moving
  // from one path separator to the next on-demand.
  //
  var components: [String] {
    #if os(Windows)
      return string.components(separatedBy: "\\").filter { !$0.isEmpty }
    #else
      // FIXME: This isn't particularly efficient; needs optimization, and
      // in fact, it might well be best to return a custom iterator so we
      // don't have to allocate everything up-front.  It would be backed by
      // the path string and just return a slice at a time.
      let components = string.split(separator: "/").filter { !$0.isEmpty }

      if string.hasPrefix("/") {
        return ["/"] + components.map(String.init)
      } else {
        return components.map(String.init)
      }
    #endif
  }

  var parentDirectory: UNIXPath {
    self == .root ? self : Self(string: dirname)
  }

  init(string: String) {
    self.string = string
  }

  init(normalizingAbsolutePath path: String) {
    #if os(Windows)
      var buffer = [WCHAR](repeating: 0, count: Int(MAX_PATH + 1))
      _ = path.withCString(encodedAs: UTF16.self) {
        PathCanonicalizeW(&buffer, $0)
      }
      self.init(string: String(decodingCString: buffer, as: UTF16.self))
    #else
      precondition(
        path.first == "/", "Failure normalizing \(path), absolute paths should start with '/'")

      // At this point we expect to have a path separator as first character.
      assert(path.first == "/")
      // Fast path.
      if !mayNeedNormalization(absolute: path) {
        self.init(string: path)
      }

      // Split the character array into parts, folding components as we go.
      // As we do so, we count the number of characters we'll end up with in
      // the normalized string representation.
      var parts: [String] = []
      var capacity = 0
      for part in path.split(separator: "/") {
        switch part.count {
        case 0:
          // Ignore empty path components.
          continue
        case 1 where part.first == ".":
          // Ignore `.` path components.
          continue
        case 2 where part.first == "." && part.last == ".":
          // If there's a previous part, drop it; otherwise, do nothing.
          if let prev = parts.last {
            parts.removeLast()
            capacity -= prev.count
          }
        default:
          // Any other component gets appended.
          parts.append(String(part))
          capacity += part.count
        }
      }
      capacity += max(parts.count, 1)

      // Create an output buffer using the capacity we've calculated.
      // FIXME: Determine the most efficient way to reassemble a string.
      var result = ""
      result.reserveCapacity(capacity)

      // Put the normalized parts back together again.
      var iter = parts.makeIterator()
      result.append("/")
      if let first = iter.next() {
        result.append(contentsOf: first)
        while let next = iter.next() {
          result.append("/")
          result.append(contentsOf: next)
        }
      }

      // Sanity-check the result (including the capacity we reserved).
      assert(!result.isEmpty, "unexpected empty string")
      assert(
        result.count == capacity,
        "count: " + "\(result.count), cap: \(capacity)"
      )

      // Use the result as our stored string.
      self.init(string: result)
    #endif
  }

  init(normalizingRelativePath path: String) {
    #if os(Windows)
      var buffer = [WCHAR](repeating: 0, count: Int(MAX_PATH + 1))
      _ = path.replacingOccurrences(of: "/", with: "\\").withCString(encodedAs: UTF16.self) {
        PathCanonicalizeW(&buffer, $0)
      }
      self.init(string: String(decodingCString: buffer, as: UTF16.self))
    #else
      precondition(path.first != "/")

      // FIXME: Here we should also keep track of whether anything actually has
      // to be changed in the string, and if not, just return the existing one.
      // Split the character array into parts, folding components as we go.
      // As we do so, we count the number of characters we'll end up with in
      // the normalized string representation.
      var parts: [String] = []
      var capacity = 0
      for part in path.split(separator: "/") {
        switch part.count {
        case 0:
          // Ignore empty path components.
          continue
        case 1 where part.first == ".":
          // Ignore `.` path components.
          continue
        case 2 where part.first == "." && part.last == ".":
          // If at beginning, fall through to treat the `..` literally.
          guard let prev = parts.last else {
            fallthrough
          }
          // If previous component is anything other than `..`, drop it.
          if !(prev.count == 2 && prev.first == "." && prev.last == ".") {
            parts.removeLast()
            capacity -= prev.count
            continue
          }
          // Otherwise, fall through to treat the `..` literally.
          fallthrough
        default:
          // Any other component gets appended.
          parts.append(String(part))
          capacity += part.count
        }
      }
      capacity += max(parts.count - 1, 0)

      // Create an output buffer using the capacity we've calculated.
      // FIXME: Determine the most efficient way to reassemble a string.
      var result = ""
      result.reserveCapacity(capacity)

      // Put the normalized parts back together again.
      var iter = parts.makeIterator()
      if let first = iter.next() {
        result.append(contentsOf: first)
        while let next = iter.next() {
          result.append("/")
          result.append(contentsOf: next)
        }
      }

      // Sanity-check the result (including the capacity we reserved).
      assert(
        result.count == capacity,
        "count: " + "\(result.count), cap: \(capacity)"
      )

      // If the result is empty, return `.`, otherwise we return it as a string.
      self.init(string: result.isEmpty ? "." : result)
    #endif
  }

  init(validatingAbsolutePath path: String) throws {
    #if os(Windows)
      let fsr: UnsafePointer<Int8> = path.fileSystemRepresentation
      defer { fsr.deallocate() }

      let realpath = String(cString: fsr)
      if !UNIXPath.isAbsolutePath(realpath) {
        throw PathValidationError.invalidAbsolutePath(path)
      }
      self.init(normalizingAbsolutePath: path)
    #else
      switch path.first {
      case "/":
        self.init(normalizingAbsolutePath: path)
      case "~":
        throw PathValidationError.startsWithTilde(path)
      default:
        throw PathValidationError.invalidAbsolutePath(path)
      }
    #endif
  }

  init(validatingRelativePath path: String) throws {
    #if os(Windows)
      let fsr: UnsafePointer<Int8> = path.fileSystemRepresentation
      defer { fsr.deallocate() }

      let realpath = String(cString: fsr)
      if UNIXPath.isAbsolutePath(realpath) {
        throw PathValidationError.invalidRelativePath(path)
      }
      self.init(normalizingRelativePath: path)
    #else
      switch path.first {
      case "/",
        "~":
        throw PathValidationError.invalidRelativePath(path)
      default:
        self.init(normalizingRelativePath: path)
      }
    #endif
  }

  func suffix(withDot: Bool) -> String? {
    #if os(Windows)
      return string.withCString(encodedAs: UTF16.self) {
        if let pointer = PathFindExtensionW($0) {
          let substring = String(decodingCString: pointer, as: UTF16.self)
          guard substring.length > 0 else { return nil }
          return withDot ? substring : String(substring.dropFirst(1))
        }
        return nil
      }
    #else
      // FIXME: This method seems too complicated; it should be simplified,
      //        if possible, and certainly optimized (using UTF8View).
      // Find the last path separator, if any.
      let sIdx = string.lastIndex(of: "/")
      // Find the start of the basename.
      let bIdx = (sIdx != nil) ? string.index(after: sIdx!) : string.startIndex
      // Find the last `.` (if any), starting from the second character of
      // the basename (a leading `.` does not make the whole path component
      // a suffix).
      let fIdx = string.index(bIdx, offsetBy: 1, limitedBy: string.endIndex) ?? string.startIndex
      if let idx = string[fIdx...].lastIndex(of: ".") {
        // Unless it's just a `.` at the end, we have found a suffix.
        if string.distance(from: idx, to: string.endIndex) > 1 {
          let fromIndex = withDot ? idx : string.index(idx, offsetBy: 1)
          return String(string.suffix(from: fromIndex))
        } else {
          return nil
        }
      }
      // If we get this far, there is no suffix.
      return nil
    #endif
  }

  func appending(component name: String) -> UNIXPath {
    #if os(Windows)
      var result: PWSTR?
      _ = string.withCString(encodedAs: UTF16.self) { root in
        name.withCString(encodedAs: UTF16.self) { path in
          PathAllocCombine(root, path, ULONG(PATHCCH_ALLOW_LONG_PATHS.rawValue), &result)
        }
      }
      defer { LocalFree(result) }
      return PathImpl(string: String(decodingCString: result!, as: UTF16.self))
    #else
      assert(!name.contains("/"), "\(name) is invalid path component")

      // Handle pseudo paths.
      switch name {
      case "",
        ".":
        return self
      case "..":
        return parentDirectory
      default:
        break
      }

      if self == Self.root {
        return Self(string: "/" + name)
      } else {
        return Self(string: string + "/" + name)
      }
    #endif
  }

  func appending(relativePath: UNIXPath) -> UNIXPath {
    #if os(Windows)
      var result: PWSTR?
      _ = string.withCString(encodedAs: UTF16.self) { root in
        relativePath.string.withCString(encodedAs: UTF16.self) { path in
          PathAllocCombine(root, path, ULONG(PATHCCH_ALLOW_LONG_PATHS.rawValue), &result)
        }
      }
      defer { LocalFree(result) }
      return PathImpl(string: String(decodingCString: result!, as: UTF16.self))
    #else
      // Both paths are already normalized.  The only case in which we have
      // to renormalize their concatenation is if the relative path starts
      // with a `..` path component.
      var newPathString = string
      if self != .root {
        newPathString.append("/")
      }

      let relativePathString = relativePath.string
      newPathString.append(relativePathString)

      // If the relative string starts with `.` or `..`, we need to normalize
      // the resulting string.
      // FIXME: We can actually optimize that case, since we know that the
      // normalization of a relative path can leave `..` path components at
      // the beginning of the path only.
      if relativePathString.hasPrefix(".") {
        if newPathString.hasPrefix("/") {
          return Self(normalizingAbsolutePath: newPathString)
        } else {
          return Self(normalizingRelativePath: newPathString)
        }
      } else {
        return Self(string: newPathString)
      }
    #endif
  }
}

extension Collection {
  /// Returns the only element of the collection or nil.
  fileprivate var only: Element? {
    count == 1 ? self[startIndex] : nil
  }
}

// FIXME: We should consider whether to merge the two `normalize()` functions.
// The argument for doing so is that some of the code is repeated; the argument
// against doing so is that some of the details are different, and since any
// given path is either absolute or relative, it's wasteful to keep checking
// for whether it's relative or absolute.  Possibly we can do both by clever
// use of generics that abstract away the differences.

/// Fast check for if a string might need normalization.
/// This assumes that paths containing dotfiles are rare:
private func mayNeedNormalization(absolute string: String) -> Bool {
  var last = UInt8(ascii: "0")
  for c in string.utf8 {
    switch c {
    case UInt8(ascii: "/") where last == UInt8(ascii: "/"):
      return true
    case UInt8(ascii: ".") where last == UInt8(ascii: "/"):
      return true
    default:
      break
    }
    last = c
  }
  if last == UInt8(ascii: "/") {
    return true
  }
  return false
}
