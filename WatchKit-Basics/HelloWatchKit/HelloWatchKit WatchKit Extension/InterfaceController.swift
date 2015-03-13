//
//  InterfaceController.swift
//  HelloWatchKit WatchKit Extension
//
//  Created by Anyuan on 15/3/13.
//  Copyright (c) 2015年 Baidu Inc. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var label: WKInterfaceLabel!
    
    let people = ["😄", "😙", "😔", "😣", "😕", "👯", "💁"]
    let nature = ["🐣", "🍀", "🌺", "🌴", "⛅️", "🐋", "🐺"]
    let objects = ["🎁", "⏳", "🍎", "🎵", "💰", "⌚️"]
    let places = ["✈️", "♨️", "🎭", "🚲", "🎢"]
    let symbols = ["🔁", "🔀", "⏩", "⏪", "🆒"]
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
//        label.setText("👋, 🍎 ⌚️❗️")
        
        // 1
        let peopleIndex = Int(arc4random_uniform(UInt32(people.count)))
        let natureIndex = Int(arc4random_uniform(UInt32(nature.count)))
        let objectsIndex = Int(arc4random_uniform(UInt32(objects.count)))
        let placesIndex = Int(arc4random_uniform(UInt32(places.count)))
        let symbolsIndex = Int(arc4random_uniform(UInt32(symbols.count)))
        
        // 2
        label.setText("\(people[peopleIndex])\(nature[natureIndex])\(objects[objectsIndex])\(places[placesIndex])\(symbols[symbolsIndex])")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
