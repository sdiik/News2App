#if WEB_AUTH_PLATFORM
    import Foundation

    /// Keeps track of the current Auth Transaction.
    class TransactionStore {
        static let shared = TransactionStore()

        private(set) var current: AuthTransaction?

        func resume(_ url: URL) -> Bool {
            let isResumed = current?.resume(url) ?? false
            clear()
            return isResumed
        }

        func store(_ transaction: AuthTransaction) {
            current = transaction
        }

        func cancel() {
            current?.cancel()
            clear()
        }

        func clear() {
            current = nil
        }
    }
#endif
