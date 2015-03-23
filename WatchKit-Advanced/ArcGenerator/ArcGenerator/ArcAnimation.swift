//
//  ArcAnimation.swift
//  ArcGenerator
//
//  Created by Jack Wu on 2014-12-12.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit

// Defines how to animate a arc
public class ArcAnimation {
  // MARK: Meta
  public var name: String
  public var scale:Int = 2 // Should not need changing (until new watches :])
  public var totalFrames: Int
  
  public var initialArc: Arc
  public var animationStep: ((arc: Arc, frame: Int, totalFrames: Int) -> Arc)
  
  init(name: String, totalFrames: Int, initialArc:Arc, animationStep:((arc: Arc, frame: Int, totalFrames: Int) -> Arc)) {
    self.name = name
    self.totalFrames = totalFrames
    self.initialArc = initialArc
    
    self.animationStep = animationStep
  }
}

// MARK: Pre-set Animations
// You can start with these and customize the parameters to quickly create new animations
extension ArcAnimation {
  
  // Standard progress arc
  public class func progressArcAnimation() -> ArcAnimation {
    let initialArc = Arc(radius: 50, lineWidth: 10, padding: 0, startAngle: 3.0*M_PI/2.0, endAngle: 3.0*M_PI/2.0, clockwise: true, color: UIColor.whiteColor())
    
    let animation = ArcAnimation(name: "arc", totalFrames: 360, initialArc: initialArc) { arc, frame, totalFrames in
      var length = Double(frame+1)/Double(totalFrames) * 2 * M_PI * Double(arc.radius)
      if length < Double(arc.lineWidth) {
        length = Double(arc.lineWidth)/2.0
      }
      arc.endAngle = length / Double(arc.radius) + arc.startAngle
      return arc
    }
    
    return animation
  }
  
  public class func spinningArcAnimation() -> ArcAnimation {
    let length = 0.8 * 2 * M_PI // length is 80% of a circle
    
    let initialArc = Arc(radius: 50, lineWidth: 10, padding: 0, startAngle: 0, endAngle: length, clockwise: true, color: UIColor.whiteColor())
    
    
    let animation = ArcAnimation(name: "arc", totalFrames: 360, initialArc: initialArc) { arc, frame, totalFrames in
      arc.startAngle = Double(frame)/Double(totalFrames-1) * 2 * M_PI
      arc.endAngle = arc.startAngle + length
      return arc
    }
    
    return animation
  }
}
