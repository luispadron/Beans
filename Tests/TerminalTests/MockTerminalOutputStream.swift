// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation
import Terminal
import XCTest

final class MockTerminalOutputStream: TerminalOutputStream {
    private(set) var output = [String]()

    func write(_ string: String) {
        output.append(string)
    }
}

final class FailingTerminalOutputStream: TerminalOutputStream {
    func write(_ string: String) {
        XCTFail("Attempted to write to a `FailingTerminalOutputStream`")
    }
}
