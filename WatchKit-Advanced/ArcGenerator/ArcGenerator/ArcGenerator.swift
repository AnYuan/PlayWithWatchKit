//
//  ArcGenerator.swift
//  ArcGenerator
//
//  Created by Jack Wu on 2014-12-09.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit
import Darwin

let WatchSize38mm = CGSize(width: 136, height: 170)
let WatchSize42mm = CGSize(width: 156, height: 195)

public class ArcGenerator: NSObject {
  
  // MARK: Frame Generation
  public func generateArcAnimationFrames(arcAnimation:ArcAnimation) {
    prepareFolderForArcsNamed(arcAnimation.name)
    
    UIGraphicsBeginImageContextWithOptions(arcAnimation.initialArc.size, false, CGFloat(arcAnimation.scale))
    let context = UIGraphicsGetCurrentContext()
    
    // Set up context
    CGContextSetShouldAntialias(context, true)
    CGContextSetAllowsAntialiasing(context, true)
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
    
    var currentArc = arcAnimation.initialArc
    for i in 0..<arcAnimation.totalFrames {
      currentArc = arcAnimation.animationStep(arc: currentArc, frame: i, totalFrames: arcAnimation.totalFrames)
      currentArc.stroke()
      saveFrameToDisk(UIGraphicsGetImageFromCurrentImageContext(), name: arcAnimation.name, index: i)
      CGContextClearRect(UIGraphicsGetCurrentContext(), CGRect(origin: CGPointZero, size: arcAnimation.initialArc.size))
    }
    UIGraphicsEndImageContext()
    
    println("Done generating frames \"\(arcAnimation.name)\" to path:")
    println(documentsPath.stringByAppendingPathComponent(arcAnimation.name))
  }
  
  // MARK: Private
  private func saveFrameToDisk(frame: UIImage, name: String, index: Int) {
    let filename = name + String(index) + "@2x.png"
    let filePath = documentsPath.stringByAppendingPathComponent(name).stringByAppendingPathComponent(filename)
    UIImagePNGRepresentation(frame).writeToFile(filePath, atomically: true)
  }
  
  private func prepareFolderForArcsNamed(name: String) {
    let path = documentsPath.stringByAppendingPathComponent(name)
    NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
    NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
  }
  
  private let documentsPath: String = {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    return paths.first as String
    }()
  
}
