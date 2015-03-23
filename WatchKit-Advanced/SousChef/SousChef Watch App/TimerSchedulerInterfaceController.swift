//
//  TimerSchedulerInterfaceController.swift
//  SousChef
//
//  Created by Anyuan on 15/3/22.
//  Copyright (c) 2015年 Ray Wenderlich. All rights reserved.
//

import WatchKit
import SousChefKit

class TimerSchedulerData {
  let recipe: Recipe
  let stepInstruction: String
  let timer: Int
  
  init(recipe: Recipe, stepInstruction: String, timer: Int) {
    self.recipe = recipe
    self.stepInstruction = stepInstruction
    self.timer = timer
  }
}


class TimerSchedulerInterfaceController: WKInterfaceController {
  @IBOutlet weak var messageLabel: WKInterfaceLabel!
  
  var recipe: Recipe!
  var stepInstruction: String!
  var timer: Int!
  
  override func awakeWithContext(context: AnyObject?) {
    if let timerSchedulerData = context as? TimerSchedulerData {
      recipe = timerSchedulerData.recipe
      stepInstruction = timerSchedulerData.stepInstruction
      timer = timerSchedulerData.timer
      messageLabel.setText("Start \(timer) minute timer?")
    }
  }
  
  @IBAction func startButtonTapped() {
    let userInfo: [NSObject : AnyObject] = [
      "category" : "timer",
      "timer" : timer,
      "message" : "Timer: \(stepInstruction)",
      "title" : recipe.name
    ]
    WKInterfaceController.openParentApplication(userInfo, reply: { (userInfo:[NSObject: AnyObject]!, error: NSError!) -> Void in
      self.dismissController()
    })
  }
  
  @IBAction func cancelButtonTapped() {
    dismissController()
  }
}