//
//  MeatTemperature.swift
//  MeatCooker
//
//  Created by Anyuan on 15/3/16.
//  Copyright (c) 2015年 Ray Wenderlich. All rights reserved.
//

import Foundation

enum MeatTemperature: Int {
    case Rare = 0, MediumRare, Medium, WellDone
    
    var stringValue: String {
        let temperatures = ["Rare", "Medium Rare", "Medium", "Well Done"]
        return temperatures[self.rawValue]
    }
    
    var timeModifier: Double {
        let modifiers = [0.5, 0.75, 1.0, 1.5]
        return modifiers[self.rawValue]
    }
}