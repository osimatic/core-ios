import Foundation
import UIKit

class DurationPickerPopover {
	static func show(viewController: UIViewController, durationTextField: UITextField,  durationInSeconds: Int? = nil) {
		let durationPickerPopoverView = DurationPickerPopoverView();
		if let durationInSeconds = durationInSeconds {
			durationPickerPopoverView.setPickersForDuration(durationInSeconds);
		}
		
		let popoverViewController = UIViewController();
		popoverViewController.view.addSubview(durationPickerPopoverView);
		
		let popoverController = UIPopoverPresentationController(presentedViewController: popoverViewController, presenting: viewController);
		popoverController.sourceView = durationTextField;
		popoverController.sourceRect = durationTextField.bounds;
		popoverController.permittedArrowDirections = .any;
		viewController.present(popoverViewController, animated: true, completion: nil);
	}
}
