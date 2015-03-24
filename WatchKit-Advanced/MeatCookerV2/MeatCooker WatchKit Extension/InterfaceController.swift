//
//  InterfaceController.swift
//  MeatCooker WatchKit Extension
//
//  Created by Ryan Nystrom on 12/14/14.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

  @IBOutlet weak var timer: WKInterfaceTimer!
  @IBOutlet weak var weightLabel: WKInterfaceLabel!
  @IBOutlet weak var cookLabel: WKInterfaceLabel!
  @IBOutlet weak var timerButton: WKInterfaceButton!

  @IBOutlet weak var metricSwitch: WKInterfaceSwitch!
  @IBOutlet weak var cookSlider: WKInterfaceSlider!
  
  var configuration = Configuration()

  private let phoneConfigurationIdentifier = "timerConfigurationPhone"
  private let watchConfigurationIdentifier = "timerConfigurationWatch"

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    registerForNotifications()
    loadConfiguration()
  }
}

// MARK: - Notificaitons
extension InterfaceController {
  func registerForNotifications() {
    
  }
}

// MARK: - Configuration
extension InterfaceController {
  private func loadConfiguration() {
    configuration = Configuration()
    displayConfiguration()
  }

  private func configurationUpdated() {
    displayConfiguration()
  }
  
  func displayConfiguration() {
    var weight = configuration.ounces
    var unit = "oz"

    if configuration.usingMetric {
      let grams = Double(configuration.ounces) * 28.3495
      weight = Int(grams)
      unit = "gm"
    }

    cookLabel.setText(configuration.cookTemp.stringValue)
    weightLabel.setText("Weight: \(weight) \(unit)")
    cookSlider.setValue(Float(configuration.cookTemp.rawValue))
    metricSwitch.setOn(configuration.usingMetric)

    if configuration.timerRunning {
      startTimer()
      timerButton.setTitle("Stop Timer")
    } else {
      stopTimer()
      timerButton.setTitle("Start Timer")
    }
  }
}

// Mark: - Timer
extension InterfaceController {
  func startTimer() {
    let time = cookTimeForOunces(configuration.ounces, cookTemp: configuration.cookTemp)
    timer.setDate(NSDate(timeIntervalSinceNow: time))
    timer.start()
  }
  
  func stopTimer() {
    timer.stop()
  }
  
  func cookTimeForOunces(ounces: Int, cookTemp: MeatTemperature) -> NSTimeInterval {
    let baseTime: NSTimeInterval = 47 * 60
    let baseWeight = 16
    let weightModifier: Double = Double(ounces) / Double(baseWeight)
    let tempModifier = cookTemp.timeModifier
    
    return baseTime * weightModifier * tempModifier
  }
}

// MARK: - Actions
extension InterfaceController {
  @IBAction func onMinusButton() {
    configuration.ounces--
    configurationUpdated()
  }

  @IBAction func onPlusButton() {
    configuration.ounces++
    configurationUpdated()
  }

  @IBAction func onTempChange(value: Float) {
    if let temp = MeatTemperature(rawValue: Int(value)) {
      configuration.cookTemp = temp
      configurationUpdated()
    }
  }

  @IBAction func onTimerButton() {
    configuration.timerRunning = !configuration.timerRunning
    configurationUpdated()
  }

  @IBAction func onMetricChanged(value: Bool) {
    configuration.usingMetric = value
    configurationUpdated()
  }

}
