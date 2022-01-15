// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation

public protocol TerminalInputStream {
  func read<T>(strippingNewLine: Bool, _ mapping: (String) -> T?) -> T?
}

public final class StandardInputStream: TerminalInputStream {
  public func read<T>(strippingNewLine: Bool, _ mapping: (String) -> T?) -> T? {
    guard let line = readLine(strippingNewline: strippingNewLine) else { return nil }
    return mapping(line)
  }
}

extension StandardInputStream {
  func read<T>(strippingNewLine: Bool) -> T? where T: LosslessStringConvertible {
    read(strippingNewLine: strippingNewLine, T.init)
  }
}
