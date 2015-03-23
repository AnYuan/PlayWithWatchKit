//
//  OnDeviceCacheHelper.swift
//  SousChef
//
//  Created by Jack Wu on 2014-12-11.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import WatchKit

public class OnDeviceCacheHelper {
  
  public func addImageToCache(image:UIImage, name:String) {
    // Add an image to the cache
    let device = WKInterfaceDevice.currentDevice()
    
    while (device.addCachedImage(image, name: name) == false) {
      let removedImage = removeRandomImageFromCache()
      if !removedImage {
        device.removeAllCachedImages()
        device.addCachedImage(image, name: name)
        break
      }
    }
  }
  
  public func cacheContainsImageNamed(name:String) -> Bool {
    return contains(cachedImages.keys, name)
  }
  
  private func removeRandomImageFromCache() -> Bool {
    let cachedImageNames = cachedImages.keys
    if let randomImageName = cachedImageNames.first {
      WKInterfaceDevice.currentDevice().removeCachedImageWithName(randomImageName)
      return true
    }
    return false
  }
  
  private var cachedImages: [String : NSNumber] = {
    return WKInterfaceDevice.currentDevice().cachedImages as [String : NSNumber]
  }()

}