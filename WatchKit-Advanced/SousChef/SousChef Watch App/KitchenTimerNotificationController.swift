//
//  KitchenTimerNotificationController.swift
//  SousChef
//
//  Created by Anyuan on 15/3/22.
//  Copyright (c) 2015年 Ray Wenderlich. All rights reserved.
//

import WatchKit

class KitchenTimerNotificationController: WKUserNotificationInterfaceController {
  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  @IBOutlet weak var messageLabel: WKInterfaceLabel!
  
  override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: (WKUserNotificationInterfaceType) -> Void) {
    if let userInfo = localNotification.userInfo {
      processNotificationWithUserInfo(userInfo, withCompletion: completionHandler)
    }
  }
  
  override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: (WKUserNotificationInterfaceType) -> Void) {
      processNotificationWithUserInfo(remoteNotification, withCompletion: completionHandler)
  }
  
  func processNotificationWithUserInfo(userInfo: [NSObject: AnyObject],
    withCompletion completionHandler:(WKUserNotificationInterfaceType) -> Void) {
      
      messageLabel.setHidden(true)
      if let message = userInfo["message"] as? String {
        messageLabel.setHidden(false)
        messageLabel.setText(message)
      }
      
      titleLabel.setHidden(true)
      if let title = userInfo["title"] as? String {
        titleLabel.setHidden(false)
        titleLabel.setText(title)
      }
      // By Specifying Custom for the type, you're telling
      // WatchKit that you wang it to use your custom long look interface
      // instead of the static interface. Specifying *Default* would load the static interface
      completionHandler(.Custom)
  }
}
