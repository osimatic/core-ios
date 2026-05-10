import UIKit

/**
 * Created by Miraan on 15/10/2017
 */
public class CalendarDateRangePickerCell: UICollectionViewCell {
	
	private let defaultTextColor = UIColor.darkGray
	private let highlightedColor = UIColor(white: 0.9, alpha: 1.0)
	private let disabledColor = UIColor.lightGray
	
	public var selectedColor: UIColor!

	public var date: Date?
	public var selectedView: UIView?
	public var halfBackgroundView: UIView?
	public var roundHighlightView: UIView?

	public var label: UILabel!
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		initLabel()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initLabel()
	}

	func initLabel() {
		label = UILabel(frame: bounds)
		label.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
		label.font = UIFont(name: "HelveticaNeue", size: 15.0)
		label.textColor = UIColor.darkGray
		label.textAlignment = NSTextAlignment.center
		self.addSubview(label)
	}
	
	public func reset() {
		self.backgroundColor = UIColor.clear
		label.textColor = defaultTextColor
		label.backgroundColor = UIColor.clear
		if selectedView != nil {
			selectedView?.removeFromSuperview()
			selectedView = nil
		}
		if halfBackgroundView != nil {
			halfBackgroundView?.removeFromSuperview()
			halfBackgroundView = nil
		}
		if roundHighlightView != nil {
			roundHighlightView?.removeFromSuperview()
			roundHighlightView = nil
		}
	}
	
	public func select() {
		let width = self.frame.size.width
		let height = self.frame.size.height
		selectedView = UIView(frame: CGRect(x: (width - height) / 2, y: 0, width: height, height: height))
		selectedView?.backgroundColor = selectedColor
		selectedView?.layer.cornerRadius = height / 2
		self.addSubview(selectedView!)
		self.sendSubviewToBack(selectedView!)
		
		label.textColor = UIColor.white
	}
	
	public func highlightRight() {
		// This is used instead of highlight() when we need to highlight cell with a rounded edge on the left
		let width = self.frame.size.width
		let height = self.frame.size.height
		halfBackgroundView = UIView(frame: CGRect(x: width / 2, y: 0, width: width / 2, height: height))
		halfBackgroundView?.backgroundColor = highlightedColor
		self.addSubview(halfBackgroundView!)
		self.sendSubviewToBack(halfBackgroundView!)
		
		addRoundHighlightView()
	}
	
	public func highlightLeft() {
		// This is used instead of highlight() when we need to highlight the cell with a rounded edge on the right
		let width = self.frame.size.width
		let height = self.frame.size.height
		halfBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: width / 2, height: height))
		halfBackgroundView?.backgroundColor = highlightedColor
		self.addSubview(halfBackgroundView!)
		self.sendSubviewToBack(halfBackgroundView!)
		
		addRoundHighlightView()
	}
	
	func addRoundHighlightView() {
		let width = self.frame.size.width
		let height = self.frame.size.height
		roundHighlightView = UIView(frame: CGRect(x: (width - height) / 2, y: 0, width: height, height: height))
		roundHighlightView?.backgroundColor = highlightedColor
		roundHighlightView?.layer.cornerRadius = height / 2
		self.addSubview(roundHighlightView!)
		self.sendSubviewToBack(roundHighlightView!)
	}
	
	public func highlight() {
		self.backgroundColor = highlightedColor
	}
	
	public func disable() {
		label.textColor = disabledColor
	}
	
}
