//
//  SettingsViewController.swift
//  Bomb Watch
//
//  Created by Paul Friedman on 7/1/14.
//  Copyright (c) 2014 Laika Cosmonautics. All rights reserved.
//

import Foundation

class SettingsViewController: BombWatchTableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
  
  let defaultQualityOptions = ["Mobile", "Low", "High", "HD"]
  
  @IBAction func doneTapped(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  // UIPickerViewDelegate
  func pickerView(pickerView: UIPickerView!, rowHeightForComponent component: Int) -> CGFloat {
    return 30.0
  }

  // UIPickerViewDataSource
  func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
    return defaultQualityOptions.count
  }
  
//  #pragma mark - UIPickerViewDelegate protocol methods
//    
//  - (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
//  {
//  return 30.0;
//  }
//  
//  - (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//  {
//  if (pickerView == self.defaultQualityPicker) {
//  [BWSettings setDefaultQuality:row];
//  
//  self.defaultQualityLabel.text = [[self pickerView:pickerView attributedTitleForRow:row forComponent:component] string];
//  }
//  }
//  
//  #pragma mark - UIPickerViewDataSource protocol methods
//    
//  - (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
//  {
//  return 1;
//  }
//  
//  - (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
//  {
//  if (pickerView == self.defaultQualityPicker) {
//  return self.defaultQualityOptions.count;
//  }
//  
//  return 0;
//  }
//  
//  - (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
//  {
//  return [[NSAttributedString alloc] initWithString:self.defaultQualityOptions[row]
//  attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
//  }
  
}