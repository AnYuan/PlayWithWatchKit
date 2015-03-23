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
    let animation = ArcAnimation.spinningArcAnimation()
    animation.name = "spinning"
    generator.generateArcAnimationFrames(animation)
    
    let animation2 = ArcAnimation.progressArcAnimation()
    animation2.name = "progress"
    generator.generateArcAnimationFrames(animation2)
  }
  
}

