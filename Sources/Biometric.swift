import LocalAuthentication

public class Biometric {

    public static func authenticate(reason: String, onResult: @escaping (_ status: String, _ method: String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            let code = (error as? LAError)?.code
            let status: String
            if code == .biometryNotAvailable { status = "hardware_missing" }
            else if code == .biometryNotEnrolled || code == .passcodeNotSet { status = "not_enrolled" }
            else { status = "unavailable" }
            DispatchQueue.main.async { onResult(status, nil) }
            return
        }

        let method: String
        switch context.biometryType {
        case .touchID: method = "fingerprint"
        case .faceID: method = "face"
        default: method = "biometric"
        }

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authError in
            DispatchQueue.main.async {
                if success {
                    onResult("success", method)
                    return
                }
                if let laError = authError as? LAError {
                    switch laError.code {
                    case .userCancel, .appCancel, .systemCancel: onResult("cancelled", nil)
                    default: onResult("error", nil)
                    }
                } else {
                    onResult("error", nil)
                }
            }
        }
    }
}