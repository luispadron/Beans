// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation

extension Path: CustomStringConvertible {
  public var description: String {
    string
  }
}

extension Path: CustomDebugStringConvertible {
  public var debugDescription: String {
    "<Path: \"\(string)\">"
  }
}
