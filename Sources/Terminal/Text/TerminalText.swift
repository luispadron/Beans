// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation

extension Terminal {
  public struct Text {
    private var string: String
    private var style: TextStyle = .default

    public init(_ string: String) {
      self.string = string
    }

    func build() -> String {
      var string = self.string

      if let foregroundColor = style.foregroundColor {
        string.applyStyle(code: foregroundColor.foregroundCode)
      }
      if let backgroundColor = style.backgroundColor {
        string.applyStyle(code: backgroundColor.backgroundCode)
      }

      return string
    }
  }
}

// MARK: - Modifiers

extension Terminal.Text {
  public func styled(with style: Terminal.TextStyle) -> Self {
    var text = self
    text.style = style
    return text
  }

  public func foreground(color: ANSIColor) -> Self {
    var text = self
    text.style.foregroundColor = color
    return text
  }

  public func background(color: ANSIColor) -> Self {
    var text = self
    text.style.backgroundColor = color
    return text
  }
}

// MARK: - String conversions

extension Terminal.Text: CustomStringConvertible {
  public var description: String { build() }
}

extension Terminal.Text: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self.init(value)
  }
}

extension Terminal.Text: LosslessStringConvertible {}

extension Terminal.Text: ExpressibleByStringInterpolation {}

extension DefaultStringInterpolation {
  public mutating func appendInterpolation(
    _ input: String,
    foreground: ANSIColor? = nil,
    background: ANSIColor? = nil
  ) {
    let style = Terminal.TextStyle(
      foregroundColor: foreground,
      backgroundColor: background
    )
    appendInterpolation(Terminal.Text(input).styled(with: style))
  }
}

// MARK: - Helpers

extension String {
  fileprivate mutating func applyStyle(code: String) {
    var string = replacingOccurrences(of: ANSICode.reset, with: ANSICode.reset + code)
    string = code + string + ANSICode.reset
    self = string
  }
}
