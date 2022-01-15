// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

extension Terminal {
  public struct TextStyle {
    var foregroundColor: ANSIColor?
    var backgroundColor: ANSIColor?

    static let `default` = TextStyle(foregroundColor: nil, backgroundColor: nil)
  }
}
