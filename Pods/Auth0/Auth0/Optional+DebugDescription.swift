import Foundation

extension Optional {
    var debugDescription: String {
        switch self {
        case .none: return "nil"
        case let .some(value): return String(describing: value)
        }
    }
}
