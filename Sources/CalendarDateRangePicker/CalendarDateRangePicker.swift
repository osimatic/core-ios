import Foundation
import UIKit

class CalendarDateRangePicker {
	static func getViewController(delegate: CalendarDateRangePickerViewControllerDelegate, selectedStartDate: Date? = nil, selectedEndDate: Date? = nil, selectedColor: UIColor? = nil) -> CalendarDateRangePickerViewController {
		let dateRangePickerViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout());
		dateRangePickerViewController.delegate = delegate;
		
		dateRangePickerViewController.allowSelectSingleDate = true;
		dateRangePickerViewController.minimumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date());
		dateRangePickerViewController.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date());
		dateRangePickerViewController.selectedStartDate = selectedStartDate;
		dateRangePickerViewController.selectedEndDate = selectedEndDate;
		dateRangePickerViewController.focusOnDate = selectedStartDate;
		
		if let selectedColor = selectedColor {
			dateRangePickerViewController.selectedColor = selectedColor;
		}
		dateRangePickerViewController.titleText = String.localize("selectDateRangeTitle");
		dateRangePickerViewController.cancelNavigationButton = String.localize("cancel");
		dateRangePickerViewController.doneNavigationButton = String.localize("ok");
		
		return dateRangePickerViewController;
	}
}
