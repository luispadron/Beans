// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

#if canImport(Darwin)
import Darwin
import Foundation

/// The standard streams for a process.
public struct StandardStream {
    /// The `stdout` output stream for the current process.
    static let output = StandardOutputStream(stream: stdout)

    /// The `stderr` output stream for the current process.
    static let error = StandardOutputStream(stream: stderr)

    /// The `stdin` input stream for the current process.
    static let input = StandardInputStream()
}
#endif
