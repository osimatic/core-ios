import Foundation
import UIKit

/*
class RadioButtonOld : UIButton {
	
	// Outlet collection of links to other buttons in the group.
	@IBOutlet var groupButtons: [RadioButton]!;

	// Currently selected radio button in the group.
	// If there are multiple buttons selected then it returns the first one.
	//var selectedButton: RadioButton;
	
	var _sharedLinks: [NSValue]? = nil;
	var stringTag: String? = nil;
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		if (!self.allTargets.contains(self)) {
			super.addTarget(self, action: #selector(onTouchUpInside), for: UIControl.Event.touchUpInside);
		}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder);
		//fatalError("init(coder:) has not been implemented")
	}
	
	override func awakeFromNib() {
		super.awakeFromNib();
		
		if (!self.allTargets.contains(self)) {
			super.addTarget(self, action: #selector(onTouchUpInside), for: UIControl.Event.touchUpInside);
		}
	}

	override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
		// 'self' should be the first target
		if (!self.allTargets.contains(self)) {
			super.addTarget(self, action: #selector(onTouchUpInside), for: UIControl.Event.touchUpInside);
		}
		super.addTarget(target, action:action, for:controlEvents);
	}

	@objc func onTouchUpInside() {
		self.setSelected(selected: true, distinct:true, sendControlEvent:true);
	}

	func setGroupButtons(buttons: [RadioButton]) {
		if (_sharedLinks == nil) {
			for rb in buttons {
				if (rb._sharedLinks != nil) {
					_sharedLinks = rb._sharedLinks;
					break;
				}
			}
			if (_sharedLinks == nil) {
				//_sharedLinks = [Any?](repeating: nil, count: buttons.count+1);
				_sharedLinks = [];
				//[[NSMutableArray alloc] initWithCapacity:[buttons count]+1];
			}
		}

		func btnExistsInList(_ list: [NSValue], _ rb: RadioButton) -> Bool {
			for v in list {
				if ((v.nonretainedObjectValue as! RadioButton) == rb) {
					return true;
				}
			}
			return false;
		}

		if (!btnExistsInList(_sharedLinks!, self)) {
			_sharedLinks?.append(NSValue(nonretainedObject: self));
		}

		for rb in buttons {
			if (rb._sharedLinks != _sharedLinks) {
				if (rb._sharedLinks == nil) {
					rb._sharedLinks = _sharedLinks;
				}
				else {
					for v in rb._sharedLinks ?? [] {
						let vrb = v.nonretainedObjectValue as! RadioButton;
						if (!btnExistsInList(_sharedLinks ?? [], vrb)) {
							_sharedLinks?.append(v);
							vrb._sharedLinks = _sharedLinks;
						}
					}
				}
			}
			if (!btnExistsInList(_sharedLinks!, rb)) {
				_sharedLinks?.append(NSValue(nonretainedObject: rb));
			}
		}
	}

	func getGroupButtons() -> [RadioButton]? {
		if (_sharedLinks!.count > 0) {
			var buttons: [RadioButton] = [];
			//NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:[_sharedLinks count]];
			for v in _sharedLinks ?? [] {
				buttons.append(v.nonretainedObjectValue as! RadioButton);
			}
			return buttons;
		}
		return nil;
	}

	func getSelectedButton() -> RadioButton? {
		if (self.isSelected) {
			return self;
		}
		else {
			for v in _sharedLinks ?? [] {
				let rb = v.nonretainedObjectValue as! RadioButton;
				if (rb.isSelected) {
					return rb;
				}
			}
		}
		return nil;
	}

	func setSelected(selected: Bool) {
		self.setSelected(selected: selected, distinct:true, sendControlEvent:false);
	}

	func setButtonSelected(selected: Bool, sendControlEvent: Bool) {
		let valueChanged = (self.isSelected != selected);
		self.setSelected(selected: selected); // super. dans fichier original
		if (valueChanged && sendControlEvent) {
			self.sendActions(for: UIControl.Event.valueChanged);
		}
	}

	func setSelected(selected: Bool, distinct:Bool, sendControlEvent:Bool) {
		self.setButtonSelected(selected:selected, sendControlEvent:sendControlEvent);

		if (distinct && (selected || _sharedLinks?.count == 2)) {
			let selected = !selected;
			for v in _sharedLinks ?? [] {
				let rb = v.nonretainedObjectValue as! RadioButton;
				if (rb != self) {
					rb.setButtonSelected(selected:selected, sendControlEvent:sendControlEvent);
				}
			}
		}
	}

	func deselectAllButtons() {
		for v in _sharedLinks ?? [] {
			let rb = v.nonretainedObjectValue as! RadioButton;
			rb.setButtonSelected(selected: false, sendControlEvent:false);
		}
	}


	func setTitle(title: String) {
		super.setTitle("  "+title, for:UIControl.State.normal);
		//[super setTitle];
	}

	func setSelectedWithTag(tag: Int) {
		if (self.tag == tag) {
			self.setSelected(selected:true, distinct:true, sendControlEvent:false);
		}
		else {
			for v in _sharedLinks ?? [] {
				let rb = v.nonretainedObjectValue as! RadioButton;
				if (rb.tag == tag) {
					rb.setSelected(selected: true, distinct:true, sendControlEvent:false);
					break;
				}
			}
		}
	}

	func dealloc() {
		for v in _sharedLinks ?? [] {
			let rb = v.nonretainedObjectValue as! RadioButton;
			if (rb == self) {
				if let index = _sharedLinks?.firstIndex(of: v) {
					_sharedLinks?.remove(at: index)
				}
				//_sharedLinks?.removeObject(identicalTo: v);
				break;
			}
		}
	}


}
*/
