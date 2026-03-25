import Foundation;
import UIKit;

extension UIView {
	func showLoader(contentView: UIView? = nil) {
		self.showLoader(contentView: contentView, submitButton: nil);
	}
	func showLoader(submitButton: UIButton? = nil) {
		self.showLoader(contentView: nil, submitButton: submitButton);
	}
	func showLoader(contentView: UIView? = nil, submitButton: UIButton? = nil) {
		DispatchQueue.main.async {
			if let contentView = contentView {
				contentView.isHidden = true;
			}
			if let submitButton = submitButton {
				submitButton.isEnabled = false;
			}
			
			let blurLoader = BlurLoader(frame: self.frame);
			self.addSubview(blurLoader);
		};
	}

	func hideLoader(contentView: UIView? = nil) {
		self.hideLoader(contentView: contentView, submitButton: nil);
	}
	func hideLoader(submitButton: UIButton? = nil) {
		self.hideLoader(contentView: nil, submitButton: submitButton);
	}
	func hideLoader(contentView: UIView? = nil, submitButton: UIButton? = nil) {
		DispatchQueue.main.async {
			if let contentView = contentView {
				contentView.isHidden = false;
			}
			if let submitButton = submitButton {
				submitButton.isEnabled = true;
			}
			
			if let blurLoader = self.subviews.first(where: { $0 is BlurLoader }) {
				blurLoader.removeFromSuperview();
			}
		};
	}
}

class BlurLoader: UIView {
	var blurEffectView: UIVisualEffectView?;

	override init(frame: CGRect) {
		let blurEffect = UIBlurEffect(style: .light); // original : .dark
		let blurEffectView = UIVisualEffectView(effect: blurEffect);
		blurEffectView.frame = frame;
		blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
		self.blurEffectView = blurEffectView;
		super.init(frame: frame);
		addSubview(blurEffectView);
		addLoader();
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented");
	}

	private func addLoader() {
		guard let blurEffectView = blurEffectView else { return };
		//let activityIndicator = UIActivityIndicatorView(style: .whiteLarge);
		let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large);
		activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50);
		blurEffectView.contentView.addSubview(activityIndicator);
		activityIndicator.center = blurEffectView.contentView.center;
		activityIndicator.startAnimating();
	}
}

/*
class Loader {
	var alertLoader: UIAlertController;
	
	static let loader = Loader();
	
	init() {
		alertLoader = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert);

		let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50));
		loadingIndicator.hidesWhenStopped = true;
		loadingIndicator.style = UIActivityIndicatorView.Style.gray;
		loadingIndicator.startAnimating();

		self.alertLoader.view.addSubview(loadingIndicator);
	}
	
	static func show(viewController: UIViewController) -> Void {
		viewController.present(loader.alertLoader, animated: true, completion: nil);
	}
	
	static func hide() -> Void {
		loader.alertLoader.dismiss(animated: false, completion: nil);
	}
}
*/
