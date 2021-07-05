import Foundation

public protocol TerminalView {
    associatedtype Body: TerminalView
    var body: Body { get }
}
