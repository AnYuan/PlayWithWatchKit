//
//  GlanceController.swift
//  SousChef
//
//  Created by Anyuan on 15/3/22.
//  Copyright (c) 2015年 Ray Wenderlich. All rights reserved.
//

import WatchKit
import SousChefKit

class GlanceController: WKInterfaceController {
  
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var upNextLabel: WKInterfaceLabel!
    @IBOutlet weak var onDeckLabel: WKInterfaceLabel!
  
  var upNextItem: Ingredient?
  var onDeckItem: Ingredient?
  
  let groceryList = GroceryList().flattenedGroceries()
  
  var purchasedItemsCount = Int()
  var totalItemsCount = Int()
  
  override func willActivate() {
    super.willActivate()
    
    totalItemsCount = 0
    purchasedItemsCount = 0
    for context in groceryList {
      if let item = context.item as? Ingredient {
        totalItemsCount++
        if item.purchased {
          purchasedItemsCount++
        } else {
          if upNextItem != nil && onDeckItem == nil {
            onDeckItem = item
          } else if upNextItem == nil {
            upNextItem = item
          }
        }
      }
    }
    
    statusLabel.setText("\(purchasedItemsCount)/\(totalItemsCount)")
    
    upNextLabel.setText(upNextItem?.name)
    onDeckLabel.setText(onDeckItem?.name)
    
    //broadcasting the user activity
    if let upNextItem = upNextItem {
      updateUserActivity(kGlanceHandoffActivityName, userInfo: [kHandoffVersionKey : kHandoffVersionNumber, kGlanceHandoffNextItemKey: upNextItem.name], webpageURL: nil)
    }
  }
  
  override func didDeactivate() {
    super.didDeactivate()
    //stop broadcasting the user activity
    invalidateUserActivity()
  }
}
