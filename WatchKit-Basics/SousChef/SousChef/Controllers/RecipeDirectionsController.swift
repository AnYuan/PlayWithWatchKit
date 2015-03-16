//
//  RecipeDirectionsController.swift
//  SousChef
//
//  Created by Ryan Nystrom on 11/24/14.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit
import SousChefKit

class RecipeDirectionsController: UITableViewController {

  var recipe: Recipe!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.rowHeight = UITableViewAutomaticDimension
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }

  // MARK: Actions

  func promptToStartTimerForStepIndex(stepIndex: Int) {
    let alert = UIAlertController(title: "Start a Timer", message: "Would you like to start a timer for \(recipe.timers[stepIndex]) minutes?", preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Start Timer", style: .Default, handler: { _ in
      self.startTimerForStepIndex(stepIndex)
    }))
    presentViewController(alert, animated: true, completion: nil)
  }

  func startTimerForStepIndex(stepIndex: Int) {

    let userInfo: [NSObject : AnyObject] = [
      "category" : "timer",
      "timer" : recipe.timers[stepIndex],
      "message" : "Timer: \(recipe.steps[stepIndex])",
      "title" : recipe.name
    ]
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    appDelegate.scheduleTimerNotificationWithUserInfo(userInfo)
  }

  // MARK: UITableViewDataSource

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = recipe.steps.count
    return count > 0 ? count : 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("RecipeStepsCell", forIndexPath: indexPath) as UITableViewCell
    let step = recipe.steps[indexPath.row]
    cell.textLabel?.text = "\(indexPath.row+1). \(step)"
    return cell
  }

  // MARK: UITableViewDelegate

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let timer = recipe.timers[indexPath.row]
    if timer > 0 {
      promptToStartTimerForStepIndex(indexPath.row)
    }
  }
}
