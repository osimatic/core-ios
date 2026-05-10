import UIKit

/**
 * Created by Miraan on 15/10/2017
 */
public class CalendarDateRangePickerHeaderView: UICollectionReusableView {

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
        label.font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
    }
    
}
