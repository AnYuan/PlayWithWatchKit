/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import WatchKit
import SousChefKit

class RecipeIngredientsInterfaceController: WKInterfaceController {
  var recipe: Recipe?
  let groceryList = GroceryList(fileURL: GroceryListConfig.url)

  @IBOutlet weak var table: WKInterfaceTable!
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    recipe = context as? Recipe

    // 1
    if let ingredients = recipe?.ingredients {
      // 2
      table.setNumberOfRows(
        ingredients.count, withRowType: "IngredientRow")

      for (index, ingredient) in enumerate(ingredients) {
        // 3
        let controller = table.rowControllerAtIndex(index) as
        IngredientRowController
        // 4
        controller.nameLabel.setText(
          ingredient.name.capitalizedString)
        controller.measurementLabel.setText(ingredient.quantity)
      }
    }
  }

  @IBAction func onAddToGrocery() {
    groceryList.openWithCompletionHandler {
      success in
      if success {
        println("RecipeIngredientsIC: opened groceryList")
        self.addToGrocery()
      } else {
        println("RecipeIngredientsIC: opened groceryList failed")
      }
    }
  }
  
  func addToGrocery() {
    if let items = self.recipe?.ingredients {
      for item in items {
        groceryList.addItemToList(item)
      }
      groceryList.sync()
    }
  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }

  override func didDeactivate() {
    super.didDeactivate()
    groceryList.closeWithCompletionHandler(nil)
  }

}
