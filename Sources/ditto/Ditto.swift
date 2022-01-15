//
//  File.swift
//
//
//  Created by Luis Padron on 1/16/22.
//

import Foundation
import System
import Terminal

@main
struct Ditto {
  static func main() async throws {
    let trm = Terminal.default

    trm.writeln("Ditto!")
    trm.writeln("Is interactive: \(isatty(FileHandle.standardInput.fileDescriptor) == 1)")

    trm.writeln("What is your name?")
    let name = trm.read()
    trm.writeln("Ditto! \(name ?? "?")")
    exit(0)
  }
}
