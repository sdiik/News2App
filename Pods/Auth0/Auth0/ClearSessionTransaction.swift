#if WEB_AUTH_PLATFORM
    import Foundation

    class ClearSessionTransaction: NSObject, AuthTransaction {
        private(set) var userAgent: WebAuthUserAgent?

        init(userAgent: WebAuthUserAgent) {
            self.userAgent = userAgent
            super.init()
        }

        func cancel() {
            // The user agent can handle the error
            finishUserAgent(with: .failure(WebAuthError(code: .userCancelled)))
        }

        func resume(_: URL) -> Bool {
            // The user agent can close itself
            finishUserAgent(with: .success(()))
            return true
        }

        private func finishUserAgent(with result: WebAuthResult<Void>) {
            userAgent?.finish(with: result)
            userAgent = nil
        }
    }
#endif
