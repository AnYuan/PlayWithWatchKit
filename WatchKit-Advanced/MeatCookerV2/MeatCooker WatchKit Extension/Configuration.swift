//
//  Configuration.swift
//  MeatCooker
//
//  Created by Jack Wu on 2015-01-19.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

public class Configuration: NSObject {
    var ounces = 16
    var cookTemp = MeatTemperature.Medium
    var usingMetric = false
    var timerRunning = false
    
    override init() {
        super.init()
    }
}

// MARK: Constants
extension Configuration {
    public struct Constants {
        public static let AppGroup = "group.com.baidu.lebo.documents"
        public static let Identifier = "timerConfiguration"
    }
    
    public struct Keys {
        static let ounces = "ounces"
        static let cookTemp = "cookTemp"
        static let timerRunning = "timerRunning"
        static let usingMetric = "usingMetric"
    }
    
    public class func savePath () -> String {
        let fileManager = NSFileManager()
        let appGroupPath: String = fileManager.containerURLForSecurityApplicationGroupIdentifier(Constants.AppGroup)!.path!
        let path = appGroupPath.stringByAppendingPathComponent(Constants.Identifier)
        return path
    }
}

// MARK: Dictonary Representation
extension Configuration {
    public func dictionaryRep () -> [NSObject: AnyObject] {
        return [
            Keys.ounces : NSNumber(integer: ounces),
            Keys.cookTemp : NSNumber(integer: cookTemp.rawValue),
            Keys.timerRunning : NSNumber(bool: timerRunning),
            Keys.usingMetric : NSNumber(bool: usingMetric),
        ]
    }
    
    public convenience init(dictionaryRep: [NSObject: AnyObject]) {
        self.init()
        ounces = (dictionaryRep[Keys.ounces] as NSNumber).integerValue
        cookTemp = MeatTemperature(rawValue: (dictionaryRep[Keys.cookTemp] as NSNumber).integerValue)!
        timerRunning = (dictionaryRep[Keys.timerRunning] as NSNumber).boolValue
        usingMetric = (dictionaryRep[Keys.usingMetric] as NSNumber).boolValue
    }
}