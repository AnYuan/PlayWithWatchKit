//
//  InterfaceController.swift
//  FitnessArcs WatchKit Extension
//
//  Created by Jack Wu on 2014-12-23.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

  @IBOutlet weak var redGroup: WKInterfaceGroup!
  @IBOutlet weak var cyanGroup: WKInterfaceGroup!
  @IBOutlet weak var greenGroup: WKInterfaceGroup!

  @IBOutlet weak var redLabel: WKInterfaceLabel!
  @IBOutlet weak var cyanLabel: WKInterfaceLabel!
  @IBOutlet weak var greenLabel: WKInterfaceLabel!


  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    // Configure interface objects here.

  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

}
