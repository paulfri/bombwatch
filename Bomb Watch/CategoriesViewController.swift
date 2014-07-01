//
//  CategoriesViewController.swift
//  Bomb Watch
//
//  Created by Paul Friedman on 6/29/14.
//  Copyright (c) 2014 Laika Cosmonautics. All rights reserved.
//

import UIKit

class CategoriesViewController: BombWatchTableViewController {
  
  let cellIdentifier = "CategoryCell"

  let sectionTitles = ["Featured", "Endurance Run", "Other"]
  let featuredCategories = ["Latest", "Quick Looks", "Features", "Events", "Trailers"]
  let enduranceRuns = ["Persona 4", "The Matrix Online", "Deadly Premonition", "Chrono Trigger"]
  let otherCategories = ["TANG", "Reviews", "Subscriber"]

  override func viewWillAppear(animated: Bool) {
    tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow(), animated: animated)
    super.viewWillAppear(animated)
  }
  
  // TODO (possibly) break out the data source to a separate class
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
    // TODO: list view controller should take an enum as its category
    if let destination = segue.destinationViewController as? BWListViewController {
      if let theSegue = segue {
        if let theIdentifier = segue.identifier {
          if segue.identifier == "videoListSegue" {
            let selectedCell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow())
            destination.category = selectedCell.textLabel.text
          }
        }
      }
    }
  }
  
}