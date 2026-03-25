import Foundation
import UIKit

class Checkbox: UIControl {

	let checkedView: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		view.image = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate)
		view.tintColor = .white
		return view
	}()

	var isChecked: Bool = false {
		didSet {
			updateState()
		}
	}

	var hitRadiusOffset: CGFloat = 10

	var checkedViewInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5) {
		didSet {
			layoutIfNeeded()
		}
	}

	var checkedBackgroundColor: UIColor = #colorLiteral(red: 0.1450980392, green: 0.3450980392, blue: 0.5098039216, alpha: 1) {
		didSet {
			backgroundColor = isChecked ? checkedBackgroundColor : uncheckedBackgroundColor
		}
	}

	var uncheckedBackgroundColor: UIColor = .white {
		didSet {
			backgroundColor = isChecked ? checkedBackgroundColor : uncheckedBackgroundColor
		}
	}

	var checkedImage: UIImage? = UIImage(systemName: "checkmark") {
		didSet {
			checkedView.image = checkedImage?.withRenderingMode(.alwaysTemplate)
		}
	}

	var checkedBorderColor: UIColor = .black {
		didSet {
			layer.borderColor = isChecked ? checkedBorderColor.cgColor : uncheckedBorderColor.cgColor
		}
	}

	var uncheckedBorderColor: UIColor = .black {
		didSet {
			layer.borderColor = isChecked ? checkedBorderColor.cgColor : uncheckedBorderColor.cgColor
		}
	}

	var imageTint: UIColor? = .white {
		didSet {
			checkedView.tintColor = imageTint
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	func setup() {
		backgroundColor = uncheckedBackgroundColor
		layer.borderColor = uncheckedBorderColor.cgColor
		layer.borderWidth = 1
		layer.cornerRadius = 4
		addSubview(checkedView)
	}

	func updateState() {
		backgroundColor = isChecked ? checkedBackgroundColor : uncheckedBackgroundColor
		layer.borderColor = isChecked ? checkedBorderColor.cgColor : uncheckedBorderColor.cgColor
		checkedView.isHidden = !isChecked
	}

	//MARK: - handle touches
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		sendActions(for: .valueChanged)
		isChecked.toggle()
	}

	//MARK: - Increase hit area
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		return bounds.inset(by: UIEdgeInsets(top: -hitRadiusOffset, left: -hitRadiusOffset, bottom: -hitRadiusOffset, right: -hitRadiusOffset)).contains(point)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		checkedView.frame = CGRect(
			x: checkedViewInsets.left,
			y: checkedViewInsets.top,
			width: frame.width - checkedViewInsets.left - checkedViewInsets.right,
			height: frame.height - checkedViewInsets.top - checkedViewInsets.bottom
		)
	}
	
}
