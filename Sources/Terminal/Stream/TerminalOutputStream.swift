// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation

public protocol TerminalOutputStream {
  func write(_ string: String)
}

final class StandardOutputStream: TextOutputStream, TerminalOutputStream {
  private var stream: UnsafeMutablePointer<FILE>

  init(stream: UnsafeMutablePointer<FILE>) {
    self.stream = stream
  }

  func write(_ string: String) {
    fputs(string, stream)
  }
}
