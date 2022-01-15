import Foundation

public struct SystemResult: Equatable, Sendable {
  public enum Status: Equatable, Sendable {
    case exit(Int)
    case signal(Int)
  }

  public struct Output: Equatable, Sendable {
    public var out: String?
    public var err: String?
  }

  public var status: Status?
  public var output: Output
}

public actor System {
  public var process: Process

  public var stdin: FileHandle.AsyncBytes {
    (process.standardInput as! Pipe).fileHandleForReading.bytes
  }

  public var stdout: FileHandle.AsyncBytes {
    (process.standardOutput as! Pipe).fileHandleForReading.bytes
  }

  public var stderr: FileHandle.AsyncBytes {
    (process.standardError as! Pipe).fileHandleForReading.bytes
  }

  public init(
    path: String
  ) {
    let stdin = Pipe()
    let stdout = Pipe()
    let stderr = Pipe()
    let process = Process()
    process.standardInput = FileHandle.standardInput
    process.standardOutput = stdout
    process.standardError = stderr
    process.executableURL = URL(fileURLWithPath: path)
    self.process = process
  }

  public func result(
    for arguments: [String]
  ) async throws -> SystemResult {
    return try await _run(arguments: arguments)
  }

  private func _run(arguments: [String]) async throws -> SystemResult {
    process.arguments = arguments
    try process.run()

    async let stdoutput = reading(handle: (process.standardOutput as! Pipe).fileHandleForReading)
    async let stderrput = reading(handle: (process.standardError as! Pipe).fileHandleForReading)

    for try await input in FileHandle.standardInput.bytes {
      try (process.standardInput as! Pipe).fileHandleForWriting.write(contentsOf: [input])
    }

    process.waitUntilExit()

    let status = Int(process.terminationStatus)
    let reason = process.terminationReason
    let output = SystemResult.Output(
      out: try await stdoutput,
      err: try await stderrput
    )

    switch reason {
    case .exit:
      return .init(status: .exit(status), output: output)
    case .uncaughtSignal:
      return .init(status: .signal(status), output: output)
    @unknown default:
      return .init(status: .exit(-1), output: .init())
    }
  }

  private func reading(handle: FileHandle) async throws -> String? {
    var output: String?
    for try await bytes in handle.bytes where !Task.isCancelled {
      guard let str = String(data: Data([bytes]), encoding: .utf8) else {
        break
      }
      output = (output ?? "") + str
    }
    return output
  }
}
