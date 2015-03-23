//
//  ViewController.swift
//  ArcGenerator
//
//  Created by Jack Wu on 2014-12-09.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let generator = ArcGenerator()
    let width = 10
    let radius = 60
    let gap = 2
    
    var animation = ArcAnimation.progressArcAnimation()
    animation.totalFrames = 100
    animation.name = "progressRed"
    
    animation.initialArc = Arc(radius: radius,
      lineWidth: width, padding: 0,
      startAngle: 3.0 * M_PI / 2.0, endAngle: 3.0 * M_PI / 2.0,
      clockwise: true, color: UIColor.magentaColor())
    animation.initialArc.emptyArcColor =
      UIColor.magentaColor().colorWithAlphaComponent(0.3)
    animation.initialArc.lineWidth = width
    
    generator.generateArcAnimationFrames(animation)
    
    animation = ArcAnimation.progressArcAnimation()
    animation.totalFrames = 100
    animation.name = "progressCyan"
    animation.initialArc = Arc(radius: radius - (width + gap),
      lineWidth: width, padding: width + gap,
      startAngle: 3.0 * M_PI / 2.0, endAngle: 3.0 * M_PI / 2.0,
      clockwise: true, color: UIColor.cyanColor())
    animation.initialArc.emptyArcColor =
      UIColor.cyanColor().colorWithAlphaComponent(0.3)
    generator.generateArcAnimationFrames(animation)
    
    animation = ArcAnimation.progressArcAnimation()
    animation.totalFrames = 100
    animation.name = "progressGreen"
    animation.initialArc = Arc(radius: radius - (width + gap) * 2,
      lineWidth: width, padding: (width + gap) * 2,
      startAngle: 3.0 * M_PI / 2.0, endAngle: 3.0 * M_PI / 2.0,
      clockwise: true, color: UIColor.greenColor())
    animation.initialArc.emptyArcColor =
      UIColor.greenColor().colorWithAlphaComponent(0.3)
    generator.generateArcAnimationFrames(animation)
  }
  
}

