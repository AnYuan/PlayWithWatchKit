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

class RecipesInterfaceController: WKInterfaceController {

  @IBOutlet weak var table: WKInterfaceTable!
  let recipeStore = RecipeStore()

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    // 1
    let recipes = recipeStore.recipes
    // 2
    table.setNumberOfRows(recipes.count,
      withRowType: "RecipeRowType")

    // 3
    for (index, recipe) in enumerate(recipes) {
      // 4
      let controller = table.rowControllerAtIndex(index)
        as RecipeRowController
      // 5
      controller.textLabel.setText(recipe.name)
      // 6
      controller.ingredientsLabel.setText(
        "\(recipe.ingredients.count) ingredients")
    }
  }

  override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
    return recipeStore.recipes[rowIndex]
  }

}
