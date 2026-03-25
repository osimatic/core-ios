import Foundation
import UIKit

/*
 * Utility class for displaying UIAlertController-based modal alerts.
 */
class Alert {

	/*
	 * Displays an alert with a message.
	 * Optionally pops the navigation stack after the user dismisses it.
	 *
	 * @param message        The message to display.
	 * @param viewController The view controller from which to present the alert.
	 * @param goBack         If true, pops the current view controller after dismissal.
	 * @param hideLoader     If true, hides any active loader before showing the alert.
	 */
	static func display(message: String, viewController: UIViewController?, goBack: Bool = false, hideLoader: Bool = true) {
		Alert.display(title: nil, message: message, viewController: viewController, onCompletion: {
			if (goBack) {
				NSLog("go back");
				viewController?.navigationController?.popViewController(animated: true);
				//self.navigationController?.popToRootViewController(animated: true);
				//self.dismiss(animated: false, completion: nil);
			}
		}, hideLoader: hideLoader);
	}

	/*
	 * Displays an alert with a title and message.
	 * Optionally pops the navigation stack after dismissal.
	 */
	static func display(title: String?, message: String, viewController: UIViewController?, goBack: Bool = false, hideLoader: Bool = true) {
		Alert.display(title: title, message: message, viewController: viewController, onCompletion: {
			if (goBack) {
				NSLog("go back");
				viewController?.navigationController?.popViewController(animated: true);
			}
		}, hideLoader: hideLoader);
	}

	/*
	 * Displays an alert then performs a segue transition after the user dismisses it.
	 */
	static func display(message: String, identifierRedirectSegue: String?, viewController: UIViewController?, hideLoader: Bool = true) {
		Alert.display(title: nil, message: message, identifierRedirectSegue: identifierRedirectSegue, viewController: viewController, hideLoader: hideLoader);
	}
	static func display(title: String?, message: String, identifierRedirectSegue: String?, viewController: UIViewController?, hideLoader: Bool = true) {
		Alert.display(title: title, message: message, viewController: viewController, onCompletion: {
			if (identifierRedirectSegue != nil) {
				NSLog("performSegue");
				viewController?.performSegue(withIdentifier: identifierRedirectSegue!, sender: self);
			}
		}, hideLoader: hideLoader);
	}

	/*
	 * Displays an alert then executes a completion callback after the user dismisses it.
	 */
	static func display(message: String, viewController: UIViewController?, onCompletion:@escaping ()->(), hideLoader: Bool = true) {
		Alert.display(title: nil, message: message, viewController: viewController, onCompletion: onCompletion, hideLoader: hideLoader);
	}
	static func display(title: String?, message: String, viewController: UIViewController?, onCompletion:@escaping ()->(), hideLoader: Bool = true) {
		guard let viewController = viewController else { return; }

		if (hideLoader) {
			viewController.view.hideLoader(); // Hide loader
		}

		DispatchQueue.main.async {
			let alert = UIAlertController(title:title, message:message, preferredStyle:UIAlertController.Style.alert);

			alert.addAction(UIAlertAction(title:String.localize("ok"), style:UIAlertAction.Style.default, handler: {action in
					onCompletion();
				}
			));
			viewController.present(alert, animated: true, completion: nil);
		};
	}

}

/*
 * Utility class for displaying brief auto-dismissing toast-style alerts.
 */
class Toast {

	/*
	 * Displays a toast message. Optionally pops the navigation stack after it is dismissed.
	 */
	static func display(message: String, viewController: UIViewController, goBack: Bool = false) {
		Toast.display(message: message, viewController: viewController, onCompletion: {
			if (goBack) {
				NSLog("goBack");
				viewController.navigationController?.popViewController(animated: true);
			}
		});
	}

	/*
	 * Displays a toast message then performs a segue transition after it is dismissed.
	 */
	static func display(message: String, identifierRedirectSegue: String?, viewController: UIViewController) {
		Toast.display(message: message, viewController: viewController, onCompletion: {
			if let identifierRedirectSegue = identifierRedirectSegue {
				NSLog("performSegue");
				viewController.performSegue(withIdentifier: identifierRedirectSegue, sender: viewController);
			}
		});
	}

	/*
	 * Displays a toast message for 2 seconds then executes a completion callback.
	 */
	static func display(message: String, viewController: UIViewController, onCompletion:@escaping ()->()) {
		DispatchQueue.main.async {
			let toast = UIAlertController(title:nil, message:message, preferredStyle:UIAlertController.Style.alert);
			viewController.present(toast, animated: true, completion: nil);

			delay(2) {
				toast.dismiss(animated: true) {
					onCompletion();
				}
			};
		};
	}

}