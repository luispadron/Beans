// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Foundation

public struct Terminal {
    public static let `default` = Terminal(
        outputStream: StandardStream.output,
        errorOutputStream: StandardStream.error,
        inputStream: StandardStream.input
    )

    private let outputStream: TerminalOutputStream
    private let errorOutputStream: TerminalOutputStream
    private let inputStream: TerminalInputStream

    public init(
        outputStream: TerminalOutputStream,
        errorOutputStream: TerminalOutputStream,
        inputStream: TerminalInputStream
    ) {
        self.outputStream = outputStream
        self.errorOutputStream = errorOutputStream
        self.inputStream = inputStream
    }

    public func write(_ text: Text) {
        outputStream.write(text.build())
    }

    public func write(error text: Text) {
        errorOutputStream.write(text.build())
    }

    public func read<T>(_ converting: (String) -> T?) -> T? {
        inputStream.read(strippingNewLine: true, converting)
    }
}

public extension Terminal {
    func read<T: LosslessStringConvertible>() -> T? {
        read(T.init)
    }
    
    func read() -> String? {
        read(String.init)
    }
}
