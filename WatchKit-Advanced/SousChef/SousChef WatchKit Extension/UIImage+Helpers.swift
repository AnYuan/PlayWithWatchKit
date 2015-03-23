//
//  UIImage+Overlays.swift
//  SousChef
//
//  Created by Jack Wu on 2014-12-08.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit
import Foundation

extension UIImage {
  
  func imageWithOverlayedColor(color:UIColor) -> UIImage {
    UIGraphicsBeginImageContext(size)
    self.drawAtPoint(CGPoint.zeroPoint)
    color.setFill()
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0,y: 0,width: size.width,height: size.height))
    let overlayedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return overlayedImage
  }
  
  func resizedImageWithSize(newSize: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(newSize, false,
    0)
    drawInRect(CGRect(origin: CGPointZero, size: newSize))
    let scaledImage =
    UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return scaledImage
  }
  
  func resizedImageWithAspectRatioInsideRect(boundingRect: CGRect) -> UIImage {
      return resizedImageWithSize(sizeWithAspectRatioInsideRect(size, boundingRect: boundingRect))
  }
  
  private func sizeWithAspectRatioInsideRect(aspectRatio: CGSize,
    boundingRect: CGRect) -> CGSize  {
    let widthRatio = boundingRect.size.width / aspectRatio.width;
    let heightRatio =
    boundingRect.size.height / aspectRatio.height;
    let ratio = min(widthRatio, heightRatio)
    let transform = CGAffineTransformMakeScale(ratio, ratio)
    return CGSizeApplyAffineTransform(aspectRatio, transform)
  }

}