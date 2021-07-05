import Foundation

/// Describes the way in which a path is invalid.
public enum PathValidationError: LocalizedError {
    case startsWithTilde(String)
    case invalidAbsolutePath(String)
    case invalidRelativePath(String)

    public var errorDescription: String? {
        switch self {
        case let .startsWithTilde(path):
            return "The string: \(path) starts with illegal character: ~"
        case let .invalidAbsolutePath(path):
            return "The string \(path) is not a valid absolute path on the file system"
        case let .invalidRelativePath(path):
            return "The string \(path) is not a valid relative path on the file system"
        }
    }

    public var failureReason: String? {
        switch self {
        case .startsWithTilde:
            return "The home directory (~) alias is not expanded automatically and is illegal as an absolute path."
        case let .invalidAbsolutePath(path):
            return "The string \(path) failed to validate as a valid absolute path"
        case let .invalidRelativePath(path):
            return "The string \(path) failed to validate as a valid relative path"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .startsWithTilde:
            return "Expand the home directory (~) path manually"
        case let .invalidAbsolutePath(path):
            return "Ensure the string \(path) represents a valid absolute path on the current file system"
        case let .invalidRelativePath(path):
            return "Ensure the string \(path) represents a valid relative path on the current file system"
        }
    }
}

