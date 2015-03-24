//
//  ViewController.swift
//  MeatCooker
//
//  Created by Ryan Nystrom on 12/14/14.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
  @IBOutlet weak var timerButton: UIButton!
  
  @IBOutlet weak var weightLabel: UILabel!
  @IBOutlet weak var cookLabel: UILabel!

  @IBOutlet weak var cookStepper: UIStepper!
  @IBOutlet weak var metricSwitch: UISwitch!
  
  var configuration: Configuration = Configuration()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    registerForNotifications()
    loadConfiguration()
  }
}

// MARK: - Notificaitons
extension ViewController {
  func registerForNotifications() {
    
  }
}

// MARK: - Configuration
extension ViewController {
  private func loadConfiguration() {
    configuration = Configuration()
    displayConfiguration()
  }
  
  private func configurationUpdated() {
    displayConfiguration()
  }

  private func displayConfiguration() {
    var weight = configuration.ounces
    var unit = "oz"
    
    if configuration.usingMetric {
      let grams = Double(configuration.ounces) * 28.3495
      weight = Int(grams)
      unit = "gm"
    }
    
    cookLabel.text = configuration.cookTemp.stringValue
    weightLabel.text = "Weight: \(weight) \(unit)"
    cookStepper.value = Double(configuration.cookTemp.rawValue)
    metricSwitch.on = configuration.usingMetric
    
    if configuration.timerRunning {
      timerButton.setTitle("Stop Timer", forState: .Normal)
    } else {
      timerButton.setTitle("Start Timer", forState: .Normal)
    }
  }
}

// MARK: - Actions
extension ViewController {
  @IBAction func onTimerButton(sender: AnyObject) {
    configuration.timerRunning = !configuration.timerRunning
    configurationUpdated()
  }

  @IBAction func onPlusButton(sender: AnyObject) {
    configuration.ounces++
    configurationUpdated()

  }
  
  @IBAction func onMinusButton(sender: AnyObject) {
    configuration.ounces--
    configurationUpdated()

  }
  
  @IBAction func onStepperChanged(sender: UIStepper) {
    configuration.cookTemp = MeatTemperature(rawValue: Int(sender.value))!
    configurationUpdated()
}
  
  @IBAction func onSwitchChanged(sender: UISwitch) {
    configuration.usingMetric = sender.on
    configurationUpdated()
 }
}

