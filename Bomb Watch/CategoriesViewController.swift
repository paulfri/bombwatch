//
//  CategoriesViewController.swift
//  Bomb Watch
//
//  Created by Paul Friedman on 6/29/14.
//  Copyright (c) 2014 Laika Cosmonautics. All rights reserved.
//

import UIKit

class CategoriesViewController: UITableViewController {
  
  let cellIdentifier = "CategoryCell"

  let sectionTitles = ["Featured", "Endurance Run", "Other"]
  let featuredCategories = ["Latest", "Quick Looks", "Features", "Events", "Trailers"]
  let enduranceRuns = ["Persona 4", "The Matrix Online", "Deadly Premonition", "Chrono Trigger"]
  let otherCategories = ["TANG", "Reviews", "Subscriber"]

  override func viewWillAppear(animated: Bool) {
    tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow(), animated: animated)
    super.viewWillAppear(animated)
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
    return 3
  }
  
  override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return featuredCategories.count
    } else if section == 1 {
      return enduranceRuns.count
    } else if section == 2 {
      return otherCategories.count
    }
    
    return 0
  }
  
  override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
    return sectionTitles[section]
  }

  override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
    let section = indexPath.section

    if section == 0 {
      cell.textLabel.text = featuredCategories[indexPath.row];
    } else if section == 1 {
      cell.textLabel.text = enduranceRuns[indexPath.row];
    } else if section == 2 {
      cell.textLabel.text = otherCategories[indexPath.row];
    }

    return cell
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    //
  }

  
  
  // generic stuff to move to a superclass later
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addTableHeader()

//    tableView.backgroundColor = kBWGiantBombCharcoalColor;
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