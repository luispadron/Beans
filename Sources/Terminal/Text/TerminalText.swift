// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation

public extension Terminal {
    struct Text {
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

public extension Terminal.Text {
    func styled(with style: Terminal.TextStyle) -> Self {
        var text = self
        text.style = style
        return text
    }

    func foreground(color: ANSIColor) -> Self {
        var text = self
        text.style.foregroundColor = color
        return text
    }

    func background(color: ANSIColor) -> Self {
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

extension Terminal.Text: LosslessStringConvertible { }

extension Terminal.Text: ExpressibleByStringInterpolation { }

public extension DefaultStringInterpolation {
    mutating func appendInterpolation(
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

private extension String {
    mutating func applyStyle(code: String) {
        var string = replacingOccurrences(of: ANSICode.reset, with: ANSICode.reset + code)
        string = code + string + ANSICode.reset
        self = string
    }
}
