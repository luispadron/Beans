// MIT License
// Copyright (c) 2021
// For more information: https://opensource.org/licenses/MIT

import Terminal
import System
import Foundation

let terminal = Terminal.default
let arguments = ProcessInfo.processInfo.arguments.map { $0.lowercased() }

if arguments.contains("basic") {
    basic()
}
if arguments.contains("system") {
    system()
}

// MARK: - Basic

func basic() {
    terminal.write(
        """
        Hello, welcome to the TerminalKit examples!
        In the following examples we'll walk through using most of the API available in TerminalKit.


        """
    )

    // MARK: - Writing

    terminal.write("~~~~ \("Writing to the terminal", foreground: .cyan1) ~~~~\n")
    terminal.write(
        """
        This message is written to the current process' stdout stream.
        You can write to this stream using 'Terminal.write'


        """
    )
    terminal.write(error:
        """
        On the other hand, this message is written to the current process' stderr stream.
        You can write error messages & warnings to this stream using 'Terminal.write(error:)'


        """
    )
    terminal.write(
        """
        TerminalKit also ships with 'Terminal.Text' type that allows modifying the output of the string via ANSI codes.
        For example, \("this string is red", foreground: .red) and \("this string is green", foreground: .green).
        You can choose to call 'Terminal.write' with an initialized 'Terminal.Text' and any styling you'd like.
        There are also custom interpolation methods that allow stying specific parts of a string.
        For example: '\\(someString, foreground: .red)'


        """
    )


    waitForEnter()

    // MARK: - Reading

    terminal.write("~~~~ \("Reading from the terminal", foreground: .cyan1) ~~~~\n")
    terminal.write(
        """
        To read input from a user in the terminal you can use 'Terminal.read'
        This function allows supplying a conversion function so that you can convert the read string (if any) to any type you want.
        Let's test this out now!


        """
    )

    terminal.write("What is your name: ")
    // Reading input is a "failable" operation, as such, it always returns `Optional<T>`.
    var name = terminal.read() ?? "Unknown"
    name = name.isEmpty ? "Unknown" : name
    terminal.write("Welcome \(name, foreground: .cyan1) to TerminalKit!\n")
}

// MARK: - System

func system() {
    terminal.write("TODO")
}


// MARK: - Helpers

func waitForEnter() {
    terminal.write("Press ENTER to continue\n")
    _ = terminal.read()
}
