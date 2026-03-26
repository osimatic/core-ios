import Foundation
import UIKit

//https://stackoverflow.com/questions/29117759/how-to-create-radio-buttons-and-checkbox-in-swift-ios
//https://ashokraju.medium.com/programmatic-easy-custom-radiobutton-for-ios-swift-5-9f22db12d4ab

protocol UIRadioButtonDelegate {
	func onRadioButtonSelected(_ sender: UIRadioButton);
}

class UIRadioButtonGroup {
	var buttons: [UIRadioButton] = [];
	//var onSelect: ((UIRadioButton) -> Void)?;
	
	static func setGroup(_ buttons: [UIRadioButton], onSelect: ((UIRadioButton) -> Void)? = nil, defaultSelectedRadioButton: UIRadioButton? = nil) {
		for button in buttons {
			button.groupBouttons = buttons;
			button.onSelect = onSelect;
		}
		
		if let defaultSelectedRadioButton = defaultSelectedRadioButton {
			defaultSelectedRadioButton.setSelected();
		}
	}
	
	init (_ buttons: [UIRadioButton], onSelect: @escaping (UIRadioButton) -> Void) {
		self.buttons = buttons;
		
		for button in self.buttons {
			button.onSelect = onSelect;
			button.group = self;
		}
	}
	
	func didSelect(_ onSelect: @escaping (UIRadioButton) -> Void) {
		for button in self.buttons {
			button.onSelect = onSelect;
		}
	}
}

class UIRadioButton: UIButton {
	var groupBouttons: [UIRadioButton]? = nil;
	var group: UIRadioButtonGroup?;
	var delegate: UIRadioButtonDelegate?;
	var onSelect: ((UIRadioButton) -> Void)?;
	var stringTag: String?;
	
	convenience init(frame: CGRect, label: String, delegate: UIRadioButtonDelegate) {
		self.init(frame: frame, label: label);
		self.delegate = delegate;
	}
	
	convenience init(frame: CGRect, label: String) {
		self.init(frame: frame);
		self.setTitle(label, for: UIControl.State.normal);
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		if (!self.allTargets.contains(self)) {
			super.addTarget(self, action: #selector(onClick), for: UIControl.Event.touchUpInside);
		}
		
		self.initStyle();
	}
	
	func initStyle() {
		self.setTitleColor(UIColor.darkGray, for: UIControl.State.normal);
		self.titleLabel!.font = UIFont.systemFont(ofSize: 16);
		self.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left;
		self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0);
		
		self.setImage(UIImage(named: "radiobutton_checked"), for: UIControl.State.selected);
		self.setImage(UIImage(named: "radiobutton_unchecked"), for: UIControl.State.normal);
	}
	
	override func awakeFromNib() {
		super.awakeFromNib();

		if (!self.allTargets.contains(self)) {
			super.addTarget(self, action: #selector(onClick), for: UIControl.Event.touchUpInside);
		}

		self.initStyle();
	}

	override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
		// 'self' should be the first target
		if (!self.allTargets.contains(self)) {
			super.addTarget(self, action: #selector(onClick), for: UIControl.Event.touchUpInside);
		}
		super.addTarget(target, action:action, for:controlEvents);
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder);
		//fatalError("init(coder:) has not been implemented")
	}
	
	func setSelected(onSelect: Bool = true) {
		var allGroupButtons: [UIRadioButton] = self.groupBouttons ?? [];
		if let group = self.group {
			for rb in group.buttons where !allGroupButtons.contains(rb) {
				allGroupButtons.append(rb);
			}
		}

		for rb in allGroupButtons {
			if (rb != self) {
				rb.isSelected = false;
			}
		}

		self.isSelected = true;

		if let onSelectCallback = self.onSelect, onSelect {
			onSelectCallback(self);
		}
	}
	
	func setGroupButtons(_ buttons: [UIRadioButton]) {
		self.groupBouttons = buttons;
		for rb in buttons {
			rb.groupBouttons = buttons;
		}
	}
	
	@objc func onClick(sender: UIRadioButton) {
		if sender != self {
			return;
		}

		self.setSelected(onSelect: false);

		if let delegate = sender.delegate {
			delegate.onRadioButtonSelected(sender);
		}

		if let onSelect = sender.onSelect {
			onSelect(sender);
		}
	}
}
