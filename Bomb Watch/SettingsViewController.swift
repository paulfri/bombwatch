//
//  SettingsViewController.swift
//  Bomb Watch
//
//  Created by Paul Friedman on 7/1/14.
//  Copyright (c) 2014 Laika Cosmonautics. All rights reserved.
//

import Foundation

enum VideoQuality: Int {
  case Mobile, Low, High, HD
}

class SettingsViewController: BombWatchTableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

  let qualityOptions = ["Mobile", "Low", "High", "HD"]
  
  @IBOutlet var qualityPicker: UIPickerView
  @IBOutlet var qualityLabel: UILabel
  
  @IBAction func doneTapped(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  // UIPickerViewDelegate
  func pickerView(pickerView: UIPickerView!, rowHeightForComponent component: Int) -> CGFloat {
    return 30.0
  }

  func pickerView(pickerView: UIPickerView!, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString! {
    let attributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    
    return NSAttributedString(string: qualityOptions[row], attributes: attributes)
  }
  
  func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
    
    if pickerView == qualityPicker {
      BWSettings.setDefaultQuality(row)
      qualityLabel.text = "asdf"
      //      qualityLabel.text = pickerView(pickerView, attributedTitleForRow: row, forComponent: component).string
    }
  }
  
  // UIPickerViewDataSource
  func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
    return qualityOptions.count
  }

}