// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation
import XCTest

@testable import Terminal

final class TerminalTests: XCTestCase {
    func test_REMOVE_ME() {
        let terminal = Terminal.default
        terminal.write("Some output!\n")
        terminal.write(error: "Some error!\n")
    }

    func test_write_should_writeStringToOutputStream() {
        let outputStream = MockTerminalOutputStream()
        let terminal = Terminal(
            outputStream: outputStream,
            errorOutputStream: FailingTerminalOutputStream(),
            inputStream: MockTerminalInputStream()
        )

        terminal.write("Hello, world!")
        terminal.write("This includes a newline\n")
        terminal.write("😎 cool")

        XCTAssertEqual(outputStream.output, [
            "Hello, world!",
            "This includes a newline\n",
            "😎 cool",
        ])
    }

    func test_writeError_should_writeStringToErrorOutputStream() {
        let errorOutputStream = MockTerminalOutputStream()
        let terminal = Terminal(
            outputStream: FailingTerminalOutputStream(),
            errorOutputStream: errorOutputStream,
            inputStream: MockTerminalInputStream()
        )

        terminal.write(error: "This is an error!")
        terminal.write(error: "This error includes a newline\n")
        terminal.write(error: "💥")

        XCTAssertEqual(errorOutputStream.output, [
            "This is an error!",
            "This error includes a newline\n",
            "💥",
        ])
    }
}
