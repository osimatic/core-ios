import Foundation
import UIKit

protocol UICheckboxDelegate {
	func onCheckboxSelected(_ sender: UICheckbox);
}

class UICheckbox: UIButton {
	var delegate: UICheckboxDelegate?;
	var onSelect: ((UIButton) -> Void)?;
	var stringTag: String?;
	
	convenience init(frame: CGRect, label: String, delegate: UICheckboxDelegate) {
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
		
		self.setImage(UIImage(named: "checkbox_checked"), for: UIControl.State.selected);
		self.setImage(UIImage(named: "checkbox_unchecked"), for: UIControl.State.normal);
	}
	
	func initCheckbox(_ title: String, _ action: ((UIButton) -> Void)? = nil, isChecked: Bool = false) {
		self.setTitle(title, for: .normal);
		self.onSelect = action;
		self.isSelected = isChecked;
	}
	
	override func awakeFromNib() {
		super.awakeFromNib();
		
		if (!self.allTargets.contains(self)) {
			super.addTarget(self, action: #selector(onClick), for: UIControl.Event.touchUpInside);
		}
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
	
	func setSelected() {
		self.isSelected = !self.isSelected;
	}
	
	@objc func onClick(sender: UICheckbox) {
		//NSLog("onClick");
		if sender != self {
			return;
		}
		
		self.setSelected();
		
		if let delegate = sender.delegate {
			delegate.onCheckboxSelected(sender);
		}
		
		if let onSelect = sender.onSelect {
			onSelect(sender);
		}
	}
}
