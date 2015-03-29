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

import WatchKit
import SousChefKit

class InitialInterfaceController: WKInterfaceController {
  
  //iCloud
  let fileManager = NSFileManager.defaultManager()

  override func willActivate() {
    super.willActivate()
    setupGroceryListGroupDoc()
  }
  
  //handoff
  override func handleUserActivity(userInfo: [NSObject : AnyObject]?) {
    println("Received a handoff payload: \(userInfo)")
    if let userInfo = userInfo {
      if let version = userInfo[kHandoffVersionKey] as? String {
        if version == kHandoffVersionNumber {
          if let nextItem = userInfo[kGlanceHandoffNextItemKey] as? String {
            self.pushControllerWithName("GroceryController", context: nextItem)
          }
        }
      }
    }
  }
  
  let recipeStore = RecipeStore()
  
  override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
    if let userInfo = localNotification.userInfo {
      processActionWithIdentifier(identifier, withUserInfo: userInfo)
    }
  }
  
  override func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject: AnyObject]) {
    processActionWithIdentifier(identifier, withUserInfo: remoteNotification)
  }
  
  func processActionWithIdentifier(identifier: String?, withUserInfo userInfo: [NSObject : AnyObject]) {
    if identifier == "viewDirectionsButtonAction" {
      if let title = userInfo["title"] as? String {
        let matchingRecipes = recipeStore.recipes.filter({$0.name == title})
        pushControllerWithName("RecipeDirections", context: matchingRecipes[0])
      }
    }
  }

  //MARK: iClound
  func createNewGroceryListDoc() {
    let newGroceryListDoc = GroceryList(fileURL: GroceryListConfig.url)
    newGroceryListDoc.saveToURL(newGroceryListDoc.fileURL, forSaveOperation: UIDocumentSaveOperation.ForCreating, completionHandler: {
      success in
      if success {
        println("create new grocery list doc: success")
      } else {
        println("create new grocery list doc: failed")
      }
    })
  }
  
  func setupGroceryListGroupDoc() {
    GroceryListConfig.url = GroceryListConfig.groupURL
    //check for existing doc; create one if none exists
    if !fileManager.fileExistsAtPath(GroceryListConfig.url.path!) {
      println("setupGroceryListGroupDoc: create empty group doc")
      createNewGroceryListDoc()
    }
  }
  
}
