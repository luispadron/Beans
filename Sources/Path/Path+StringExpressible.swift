import Foundation

extension Path: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    self._path = .init(normalizingAbsolutePath: stringLiteral)
  }
}

extension DefaultStringInterpolation {
  public mutating func appendInterpolation(path value: String) {
    appendLiteral(Path(value).string)
  }
}
