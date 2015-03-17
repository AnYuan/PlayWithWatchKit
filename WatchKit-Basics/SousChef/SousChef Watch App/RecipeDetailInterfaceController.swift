//
//  RecipeDetailInterfaceController.swift
//  SousChef
//
//  Created by Anyuan on 15/3/16.
//  Copyright (c) 2015年 Ray Wenderlich. All rights reserved.
//

import WatchKit
import SousChefKit

class RecipeDetailInterfaceController: WKInterfaceController {
  @IBOutlet weak var nameLabel: WKInterfaceLabel!
  var recipe: Recipe?
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    recipe = context as? Recipe
    
    nameLabel.setText(recipe?.name)
  }
  
  override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
    return recipe
  }
}
