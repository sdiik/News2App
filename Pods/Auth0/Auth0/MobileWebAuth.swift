#if os(iOS)
    import AuthenticationServices
    import UIKit

    extension UIApplication {
        static func shared() -> UIApplication? {
            return UIApplication.perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue() as? UIApplication
        }
    }

    @available(iOS 13.0, *)
    extension ASUserAgent: ASWebAuthenticationPresentationContextProviding {
        func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
            return UIApplication.shared()?.windows.filter { $0.isKeyWindow }.last ?? ASPresentationAnchor()
        }
    }
#endif
