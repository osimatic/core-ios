import Foundation
import UIKit

public class DurationPickerPopoverView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
	public var hourPicker: UIPickerView!;
	public var minutePicker: UIPickerView!;
	public var secondPicker: UIPickerView!;

	public var hours: [Int] = Array(0...23);
	public var minutes: [Int] = Array(0...59);
	public var seconds: [Int] = Array(0...59);

	public var onChange: (Int) -> Void = { value in };

	public init() {
		super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 200));
		
		self.backgroundColor = .white;
		
		// Create and configure the UIPickerViews
		hourPicker = UIPickerView();
		minutePicker = UIPickerView();
		secondPicker = UIPickerView();
		
		hourPicker.dataSource = self;
		hourPicker.delegate = self;
		minutePicker.dataSource = self;
		minutePicker.delegate = self;
		secondPicker.dataSource = self;
		secondPicker.delegate = self;
		
		// Add the UIPickerViews to the container view
		self.addSubview(hourPicker);
		self.addSubview(minutePicker);
		self.addSubview(secondPicker);
		
		// Position the UIPickerViews within the container view as needed
		hourPicker.frame = CGRect(x: 0, y: 0, width: 100, height: 200);
		minutePicker.frame = CGRect(x: 100, y: 0, width: 100, height: 200);
		secondPicker.frame = CGRect(x: 200, y: 0, width: 120, height: 200);
		
		// Create a popover controller for the UIPickerViews
		//let pickerViewPopover = UIPopoverController(contentViewController: createPickerContainerView());
		
		// Set the size for the popover (adjust to your needs)
		//self.contentSize = CGSize(width: 320, height: 200);
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// Function to set the UIPickerView selections based on a duration in seconds
	public func setPickersForDuration(_ durationInSeconds: Int) {
		let hours = durationInSeconds / 3600;
		let remainingSeconds = durationInSeconds % 3600;
		let minutes = remainingSeconds / 60;
		let seconds = remainingSeconds % 60;
		
		hourPicker.selectRow(hours, inComponent: 0, animated: false);
		minutePicker.selectRow(minutes, inComponent: 0, animated: false);
		secondPicker.selectRow(seconds, inComponent: 0, animated: false);
	}
	
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1;
	}

	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == hourPicker {
			return hours.count;
		} else if pickerView == minutePicker {
			return minutes.count;
		} else if pickerView == secondPicker {
			return seconds.count;
		}
		return 0;
	}

	public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView == hourPicker {
			return String(hours[row]);
		} else if pickerView == minutePicker {
			return String(minutes[row]);
		} else if pickerView == secondPicker {
			return String(seconds[row]);
		}
		return "";
	}

	public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let selectedHours = hours[hourPicker.selectedRow(inComponent: 0)];
		let selectedMinutes = minutes[minutePicker.selectedRow(inComponent: 0)];
		let selectedSeconds = seconds[secondPicker.selectedRow(inComponent: 0)];

		let duration = (selectedHours*3600) + (selectedMinutes*60) + selectedSeconds;
		
		//let duration = String(format: "%02d:%02d:%02d", selectedHours, selectedMinutes, selectedSeconds);
		//durationTextField.text = duration
		self.onChange(duration);
	}
}
