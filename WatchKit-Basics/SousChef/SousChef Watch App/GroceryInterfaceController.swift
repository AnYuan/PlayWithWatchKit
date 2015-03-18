//
//  GroceryInterfaceController.swift
//  SousChef
//
//  Created by Anyuan on 15/3/18.
//  Copyright (c) 2015年 Ray Wenderlich. All rights reserved.
//

import WatchKit
import Foundation
import SousChefKit


class GroceryInterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    
    let groceryList = GroceryList(useSample: true)
    lazy var flatList: [FlatGroceryItem] = {
        return self.groceryList.flattenedGroceries()
    }()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        updateTable()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateTable() {
        table.setRowTypes(flatList.map({ $0.id}))
        
        for i in 0..<table.numberOfRows {
            let controller: AnyObject! = table.rowControllerAtIndex(i)
            let context = flatList[i]
            
            if let row = controller as? GroceryTypeRowController {
                let type = context.item as String
                row.textLabel.setText(type)
                row.image.setImageNamed(type.lowercaseString)
            } else if let row = controller as? GroceryRowController {
                let item = context.item as Ingredient
                row.textLabel.setText(item.name.capitalizedString)
                row.measurementLabel.setText(item.quantity)
                
                let quantity = groceryList.quantityForItem(item)
                let quantityText = quantity > 1 ? "x\(quantity)":""
                row.quantityLabel.setText(quantityText)
            }
        }
    }

}
