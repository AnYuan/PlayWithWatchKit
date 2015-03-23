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
    
    let animation = ArcAnimation.progressArcAnimation()
    animation.name = "progress"
    animation.initialArc.color = UIColor.magentaColor()
    animation.initialArc.emptyArcColor = UIColor.magentaColor().colorWithAlphaComponent(0.3)
    generator.generateArcAnimationFrames(animation)
  }
  
}

