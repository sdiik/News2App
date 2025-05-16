#if WEB_AUTH_PLATFORM
    import Foundation
    import LocalAuthentication

    struct BioAuthentication {
        private let authContext: LAContext
        private let evaluationPolicy: LAPolicy

        let title: String
        var fallbackTitle: String? {
            get { return authContext.localizedFallbackTitle }
            set { authContext.localizedFallbackTitle = newValue }
        }

        var cancelTitle: String? {
            get { return authContext.localizedCancelTitle }
            set { authContext.localizedCancelTitle = newValue }
        }

        var available: Bool {
            return authContext.canEvaluatePolicy(evaluationPolicy, error: nil)
        }

        init(authContext: LAContext, evaluationPolicy: LAPolicy, title: String, cancelTitle: String? = nil, fallbackTitle: String? = nil) {
            self.authContext = authContext
            self.evaluationPolicy = evaluationPolicy
            self.title = title
            self.cancelTitle = cancelTitle
            self.fallbackTitle = fallbackTitle
        }

        func validateBiometric(callback: @escaping (Error?) -> Void) {
            authContext.evaluatePolicy(evaluationPolicy, localizedReason: title) {
                guard $1 == nil else { return callback($1) }
                callback($0 ? nil : LAError(LAError.authenticationFailed))
            }
        }
    }
#endif
