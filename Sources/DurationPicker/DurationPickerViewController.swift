import Foundation
import UIKit

class DurationPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
	var onChange: ((Int) -> Void)? = nil;

	var hourPicker: UIPickerView!;
	var minutePicker: UIPickerView!;
	var secondPicker: UIPickerView!;

	var hours: [Int] = Array(0...23);
	var minutes: [Int] = Array(0...59);
	var seconds: [Int] = Array(0...59);

	private var pendingInitialDuration: Int? = nil;

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .white;

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
		self.view.addSubview(hourPicker);
		self.view.addSubview(minutePicker);
		self.view.addSubview(secondPicker);

		// Position the UIPickerViews within the container view as needed
		hourPicker.frame = CGRect(x: 0, y: 0, width: 100, height: 200);
		minutePicker.frame = CGRect(x: 100, y: 0, width: 100, height: 200);
		secondPicker.frame = CGRect(x: 200, y: 0, width: 120, height: 200);

		if let pending = pendingInitialDuration {
			applyDuration(pending);
			pendingInitialDuration = nil;
		}
	}

	// Function to set the UIPickerView selections based on a duration in seconds
	func setPickersForDuration(_ durationInSeconds: Int) {
		guard isViewLoaded else {
			pendingInitialDuration = durationInSeconds;
			return;
		}
		applyDuration(durationInSeconds);
	}

	private func applyDuration(_ durationInSeconds: Int) {
		let hours = durationInSeconds / 3600;
		let remainingSeconds = durationInSeconds % 3600;
		let minutes = remainingSeconds / 60;
		let seconds = remainingSeconds % 60;

		hourPicker.selectRow(hours, inComponent: 0, animated: false);
		minutePicker.selectRow(minutes, inComponent: 0, animated: false);
		secondPicker.selectRow(seconds, inComponent: 0, animated: false);
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1;
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == hourPicker {
			return hours.count;
		} else if pickerView == minutePicker {
			return minutes.count;
		} else if pickerView == secondPicker {
			return seconds.count;
		}
		return 0;
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView == hourPicker {
			return String(hours[row]);
		} else if pickerView == minutePicker {
			return String(minutes[row]);
		} else if pickerView == secondPicker {
			return String(seconds[row]);
		}
		return "";
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let selectedHours = hours[hourPicker.selectedRow(inComponent: 0)];
		let selectedMinutes = minutes[minutePicker.selectedRow(inComponent: 0)];
		let selectedSeconds = seconds[secondPicker.selectedRow(inComponent: 0)];

		let duration = (selectedHours*3600) + (selectedMinutes*60) + selectedSeconds;
		
		//let duration = String(format: "%02d:%02d:%02d", selectedHours, selectedMinutes, selectedSeconds);
		//durationTextField.text = duration
		if let onChange = self.onChange {
			onChange(duration);
		}
		
		
		self.dismiss(animated: true)
	}
}
