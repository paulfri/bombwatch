//
//  BombWatchTableViewController.swift
//  Bomb Watch
//
//  Created by Paul Friedman on 7/1/14.
//  Copyright (c) 2014 Laika Cosmonautics. All rights reserved.
//

import Foundation

class BombWatchTableViewController: UITableViewController {
  
  // generic stuff to move to a superclass later
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addTableHeader()
    tableView.backgroundColor = UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1);
    tableView.separatorColor = UIColor.grayColor()
  }
  
  func addTableHeader() {
    let header = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, 45))
    tableView.tableHeaderView = header
    
    let bomb = UIImageView(image: UIImage(named: "BombTableHeader"))
    bomb.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    header.addSubview(bomb)
    header.sendSubviewToBack(bomb)
    
    // Hides the bomb behind the navigation bar
    tableView.contentInset = UIEdgeInsetsMake(-bomb.bounds.size.height, 0, 0, 0)
    
    // Centers the bomb in the header view, in all device orientations
    let views = ["bomb": bomb, "header": header]
    let constraintsX = NSLayoutConstraint.constraintsWithVisualFormat("V:[header]-(<=1)-[bomb]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
    let constraintsY = NSLayoutConstraint.constraintsWithVisualFormat("H:[header]-(<=1)-[bomb]", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
    
    tableView.tableHeaderView.addConstraints(constraintsX)
    tableView.tableHeaderView.addConstraints(constraintsY)
  }
  
  override func tableView(tableView: UITableView!, willDisplayHeaderView view: UIView!, forSection section: Int) {
    if let header = view as? UITableViewHeaderFooterView {
      header.textLabel.textColor = UIColor.lightGrayColor()
    }
  }
  
  override func tableView(tableView: UITableView!, willDisplayFooterView view: UIView!, forSection section: Int) {
    if let footer = view as? UITableViewHeaderFooterView {
      footer.textLabel.textColor = UIColor.lightGrayColor()
    }
  }
  
}