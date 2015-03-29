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
  let fileManager = NSFileManager.defaultManager()
  var groceryListQuery = NSMetadataQuery()
  
  override func willActivate() {
    super.willActivate()
    
    if let currentToken = fileManager.ubiquityIdentityToken {
      println("iCloud access with ID \(currentToken)")
      queryGroceryListCloudContainer()
    } else {
      println("No iCloud access")
      setupGroceryListGroupDoc()
    }
  }
  
  override func handleUserActivity(userInfo: [NSObject: AnyObject]!) {
    println("Received a Handoff payload: \(userInfo)")
    
    if let version = userInfo[kHandoffVersionKey] as? String {
      if version == kHandoffVersionNumber {
        if let nextItem = userInfo[kGlanceHandoffNextItemKey] as? String {
          self.pushControllerWithName("GroceryController", context: nextItem)
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
  
  // MARK: - iCloud
  func createNewGroceryListDoc() {
    let newGroceryListDoc = GroceryList(fileURL: GroceryListConfig.url)
    newGroceryListDoc.saveToURL(newGroceryListDoc.fileURL, forSaveOperation: UIDocumentSaveOperation.ForCreating, completionHandler: { success in
      if success {
        println("createNewGroceryListDoc: success")
      } else {
        println("createNewGroceryListDoc: failed")
      }
    })
  }
  
  func setupGroceryListGroupDoc() {
    GroceryListConfig.url = GroceryListConfig.groupURL
    // check for existing doc; create one if none exists
    if !fileManager.fileExistsAtPath(
      GroceryListConfig.url.path!) {
        println("setupGroceryListGroupDoc: create empty group doc")
        createNewGroceryListDoc()
    }
  }
  
  func setupGroceryListCloudDoc(query: NSMetadataQuery) {
    if query.resultCount > 0 {
      // construct cloudURL from metadata
      let item: NSMetadataItem = query.resultAtIndex(0)
        as NSMetadataItem
      let groceryListCloudURL =
      (item.valueForAttribute(NSMetadataItemURLKey) as NSURL)
      GroceryListConfig.cloudURL = groceryListCloudURL
      GroceryListConfig.url = GroceryListConfig.cloudURL
      
      if fileManager.fileExistsAtPath(
        GroceryListConfig.groupURL.path!) {
          // remove cloud doc and move group doc to cloud container
          fileManager.removeItemAtURL(groceryListCloudURL, error: nil)
          moveGroupDocToCloud()
      }
      
    } else {
      // construct cloudURL from URLForUbiquityContainerID
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        if let iCloudContainerURL =
          self.fileManager.URLForUbiquityContainerIdentifier(
            GroceryListConfig.iCloudID)
        {
          println("setupGroceryListCloudDoc: new cloud doc")
          let groceryListCloudURL = iCloudContainerURL.URLByAppendingPathComponent("Documents").URLByAppendingPathComponent(GroceryListConfig.filename)
          GroceryListConfig.cloudURL = groceryListCloudURL
          GroceryListConfig.url = GroceryListConfig.cloudURL
          
          if self.fileManager.fileExistsAtPath(GroceryListConfig.groupURL.path!) {
            println("setupGroceryListCloudDoc: moving group doc to cloud")
            self.moveGroupDocToCloud()
          } else {
            println("setupGroceryListCloudDoc: creating empty cloud doc")
            self.createNewGroceryListDoc()
          }
        }
      }
    }
  }
  
  func queryGroceryListCloudContainer() {
    groceryListQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
    groceryListQuery.predicate = NSPredicate(format: "(%K = %@)", argumentArray: [NSMetadataItemFSNameKey, GroceryListConfig.filename])
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "metadataQueryDidFinishGathering:", name: NSMetadataQueryDidFinishGatheringNotification, object: groceryListQuery)
    groceryListQuery.startQuery()
  }
  
  @objc private func metadataQueryDidFinishGathering(notification: NSNotification) {
    groceryListQuery.disableUpdates()
    groceryListQuery.stopQuery()
    NSNotificationCenter.defaultCenter().removeObserver(self,
      name: NSMetadataQueryDidFinishGatheringNotification,
      object: groceryListQuery)
    setupGroceryListCloudDoc(groceryListQuery)
  }
  
  func moveGroupDocToCloud() {
    let defaultQueue =
    dispatch_get_global_queue(
      DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    dispatch_async(defaultQueue) {
      let success = self.fileManager.setUbiquitous(true,
        itemAtURL: GroceryListConfig.groupURL, destinationURL:
        GroceryListConfig.cloudURL, error: nil)
      if success {
        println("moveGroupDocToCloud: moved doc to cloud")
        // open and sync cloud doc to save group doc, in case user
        // doesn't update cloud doc before losing cloud access
        let groceryList = GroceryList(fileURL:
          GroceryListConfig.cloudURL)
        groceryList.openWithCompletionHandler { success in
          if success {
            println("moveGroupDocToCloud: opened groceryList")
            groceryList.sync()
          } else {
            println("moveGroupDocToCloud: open groceryList failed")
          }
        }
      }
      return
    }
  }
  
}
