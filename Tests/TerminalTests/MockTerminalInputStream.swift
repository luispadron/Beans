// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Terminal

final class MockTerminalInputStream: TerminalInputStream {
  private var readStub: (() -> Any)?
  func read<T>(strippingNewLine: Bool, _ mapping: (String) -> T?) -> T? {
    readStub?() as? T
  }
}
