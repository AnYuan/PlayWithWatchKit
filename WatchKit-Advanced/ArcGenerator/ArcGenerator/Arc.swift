//
//  Arc.swift
//  ArcGenerator
//
//  Created by Jack Wu on 2014-12-12.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit

public class Arc {
  // MARK: Appearance
  
  // Constant
  public let clockwise: Bool
  public let padding: Int
  public let radius: Int // From center to farthest point
  
  // Animatable
  public var lineWidth: Int
  public var startAngle: Double // 0 is rightmost, defaults to 3π/2, which is top
  public var endAngle: Double // 0 is rightmost, defaults to 3π/2, which is top
  
  public var color: UIColor
  
  // MARK: Computed
  public var size: CGSize {
    let width = 2 * (radius + padding)
    return CGSize(width: width, height: width)
  }
  
  public var center: CGPoint {
    return CGPoint(x: radius + padding, y: radius + padding)
  }
  
  public var compensatedRadius: Double {
    return Double(radius) - Double(lineWidth)/2
  }
  
  // MARK: Init
  public init(radius: Int = 50,
    lineWidth: Int = 6,
    padding: Int = 0,
    startAngle: Double = 3.0*M_PI/2.0,
    endAngle: Double = M_PI,
    clockwise: Bool = true,
    color: UIColor = UIColor.whiteColor()
    ) {
      self.radius = radius
      self.lineWidth = lineWidth
      self.padding = padding
      self.startAngle = startAngle
      self.endAngle = endAngle
      self.clockwise = clockwise
      self.color = color
  }
  
  // MARK: Drawing
  public func stroke() {
    color.setStroke()
    bezierPath().stroke()
  }
  
  public func bezierPath() -> UIBezierPath {
    let path = UIBezierPath(arcCenter: center, radius: CGFloat(compensatedRadius), startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: clockwise)
    
    path.lineWidth = CGFloat(lineWidth)
    path.lineCapStyle = kCGLineCapRound
    
    return path
  }
}