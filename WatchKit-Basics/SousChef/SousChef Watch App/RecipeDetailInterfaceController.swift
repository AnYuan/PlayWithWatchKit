//
//  RecipeDetailInterfaceController.swift
//  SousChef
//
//  Created by Anyuan on 15/3/16.
//  Copyright (c) 2015年 Ray Wenderlich. All rights reserved.
//

import WatchKit

class RecipeDetailInterfaceController: WKInterfaceController {
  @IBOutlet weak var nameLabel: WKInterfaceLabel!
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    if let name = context as? String {
      nameLabel.setText(name)
    }
  }
}
