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

import UIKit
import SousChefKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let recipeStore = RecipeStore()
  let fileManager = NSFileManager.defaultManager()
  var groceryListQuery = NSMetadataQuery()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    configureAppearance()
    registerUserNotificationSettings()
    
    updateRecipesController()
    
    //checking for ubiquityIdentityToken is the quickest and easiest way
    //to determine whether iCloud is available.
    //If the user switches to another iCloud account, the token changes
    if let currentToken = fileManager.ubiquityIdentityToken {
      println("iCloud access with ID \(currentToken)")
      queryGroceryListCloudContainer()
    } else {
      println("No iCloud access")
      setupGroceryListGroupDoc()
    }
    return true
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    updateRecipesController()
  }
  
  func application(application: UIApplication!, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]!, reply: (([NSObject : AnyObject]!) -> Void)!) {
    
    if let category = userInfo["category"] as? String {
      
      //checks the user's notification settings. If the user has disabled notifications, there's no point in scheduling 
      //the kitchen timer since it won't be visible. It also checks if it's the timer category. Then the method calls
      //scheduleTimerNotificationWithUserInfo, which simply schedules the local notification.
      if ((application.currentUserNotificationSettings().types & UIUserNotificationType.Alert) != nil) && category == "timer"
      {
        scheduleTimerNotificationWithUserInfo(userInfo)
        
        if (reply != nil) {
          reply(nil)
        }
      }
      
    } else {
      let kGroceryUpdateRequest = "com.baidu.update-recipes"
      if let updateRecipesRequest = userInfo[kGroceryUpdateRequest] as? Bool {
        updateRecipesWithRemoteServerWithCompletionBlock({ (Void) -> Void in
          reply(nil)
        })
      }
    }
  }
  
  // MARK: - Appearance

  func configureAppearance() {
    let navBarAppearance = UINavigationBar.appearance()
    navBarAppearance.titleTextAttributes = [
      NSForegroundColorAttributeName: Theme.navTextColor,
      NSFontAttributeName: Theme.navFont!
    ]
    navBarAppearance.barTintColor = Theme.baseColor
    navBarAppearance.tintColor = Theme.navTextColor

    let tabBarAppearance = UITabBar.appearance()
    tabBarAppearance.tintColor = Theme.baseColor
  }
  
  // MARK: - Notification Setup
  
  func registerUserNotificationSettings() {
    let viewDirectionsAction = UIMutableUserNotificationAction()
    viewDirectionsAction.identifier = "viewDirectionsButtonAction"
    viewDirectionsAction.title = "View Directions"
    viewDirectionsAction.activationMode = .Foreground
    viewDirectionsAction.authenticationRequired = false
    
    let viewRecipeAction = UIMutableUserNotificationAction()
    viewRecipeAction.identifier = "viewRecipeButtonAction"
    viewRecipeAction.title = "View Recipe"
    viewRecipeAction.activationMode = .Foreground
    viewRecipeAction.authenticationRequired = false
    
    let timerCategory = UIMutableUserNotificationCategory()
    timerCategory.identifier = "timer"
    timerCategory.setActions([viewDirectionsAction], forContext: .Default)
    
    let newRecipeCategory = UIMutableUserNotificationCategory()
    newRecipeCategory.identifier = "new_recipe"
    newRecipeCategory.setActions([viewRecipeAction], forContext: .Default)
    
    let categories = NSSet(array: [timerCategory, newRecipeCategory])
    
    let settings = UIUserNotificationSettings(forTypes: .Alert | .Sound, categories: categories)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
  }
  
  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    if (notificationSettings.types & UIUserNotificationType.Alert) != nil {
      application.registerForRemoteNotifications()
    }
  }
  
  // MARK: - Remote Notifications
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    println("Register for remote notifications with device token: \(deviceToken).")
    // TODO: Send device token to push notification service of choice. See appendix on Setting up a Push Notification Server.
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    println("Failed to register for remote notifications. Make sure you are running on an actual device and check the Provisioning Profile.")
    println(error.localizedDescription)
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    if let aps = userInfo["aps"] as? NSDictionary {
      if let category = aps["category"] as? String {
        if category == "new_recipe" {
          let title = userInfo["title"]! as String
          let message = userInfo["message"]! as String
          
          let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
          alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
          alert.addAction(UIAlertAction(title: "View Recipe", style: .Default, handler: { _ in
            //
            // TODO: Call sync/refresh method when a new recipe is received
            //
            self.showRecipeWithUserInfo(userInfo, andInitialController: .Ingredients)
          }))
          
          let tabBarController = window?.rootViewController! as UITabBarController
          let recipesNavigationController = tabBarController.viewControllers![0] as UINavigationController
          recipesNavigationController.presentViewController(alert, animated: true, completion: nil)
        }
      }
    }
  }
  
  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
    if identifier == "viewRecipeButtonAction" {
        //
        // TODO: Call sync/refresh method when a new recipe is received
        //
        showRecipeWithUserInfo(userInfo, andInitialController: .Ingredients)
    }
    completionHandler()
  }
  
  // MARK: - Local Notifications
  
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    if let userInfo = notification.userInfo {
      if let category = userInfo["category"] as? String {
        if category == "timer" {
          let title = userInfo["title"]! as String
          let message = userInfo["message"]! as String

          let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
          alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
          alert.addAction(UIAlertAction(title: "View Directions", style: .Default, handler: { _ in
            self.showRecipeWithUserInfo(userInfo, andInitialController: .Steps)
          }))
          
          let tabBarController = window?.rootViewController! as UITabBarController
          let recipesNavigationController = tabBarController.viewControllers![0] as UINavigationController
          recipesNavigationController.presentViewController(alert, animated: true, completion: nil)
        }
      }
    }
  }
  
  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
    if identifier == "viewDirectionsButtonAction" {
      if let userInfo = notification.userInfo {
        showRecipeWithUserInfo(userInfo, andInitialController: .Steps)
      }
    }
    completionHandler()
  }
  
  func showRecipeWithUserInfo(userInfo: [NSObject : AnyObject]!, andInitialController initialController: RecipeDetailSelection) {
    if let title = userInfo["title"] as? String {
      let matchingRecipes = recipeStore.recipes.filter({$0.name == title})
      let tabBarController = window?.rootViewController! as UITabBarController
      let recipesNavigationController = tabBarController.viewControllers![0] as UINavigationController
      let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
      let recipeDetailController = mainStoryboard.instantiateViewControllerWithIdentifier("RecipeDetail") as RecipeDetailController
      recipeDetailController.recipe = matchingRecipes[0]
      recipeDetailController.initialController = initialController
      recipesNavigationController.pushViewController(recipeDetailController, animated: true)
      tabBarController.selectedIndex = 0
    }
  }
  
  func scheduleTimerNotificationWithUserInfo(userInfo: [NSObject : AnyObject]!) {

    let application = UIApplication.sharedApplication()
    if (application.currentUserNotificationSettings().types & UIUserNotificationType.Alert) != nil {
      let message = userInfo["message"] as String
      let title = userInfo["title"] as String
      let timer = userInfo["timer"] as Int
      let fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(timer * 60))
      
      let notification = UILocalNotification()
      notification.fireDate = fireDate
      notification.alertTitle = title
      notification.alertBody = message
      notification.soundName = UILocalNotificationDefaultSoundName
      notification.category = "timer"
      notification.userInfo = userInfo
      
      application.scheduleLocalNotification(notification)
    }
  }
  
  func updateRecipesWithRemoteServerWithCompletionBlock(block:((Void) -> Void)?) {
    recipeStore.refresh(completion: {
      (recipes, error) -> Void in
      if let block = block {
        block()
      }
    })
  }
  
  func updateRecipesController() {
    updateRecipesWithRemoteServerWithCompletionBlock { (Void) -> Void in
      if let tabBarController = self.window?.rootViewController as? UITabBarController {
        if let navigationController = tabBarController.viewControllers?.first as? UINavigationController {
          if let recipesController = navigationController.viewControllers?.first as? RecipesController {
            recipesController.reloadContent()
          }
        }
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
  
  //In an app that manages a collection of documents, you would register for NSMetaDataQueryDidUpdateNotification
  //and set the query predicate to a more general search, such as for certain file extensions.
  //You would disable updates to "lock" the query result while you handle the found documents, then
  //enable updates again once you've finished. You also would't stop the query.
  func queryGroceryListCloudContainer() {
    groceryListQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
    groceryListQuery.predicate = NSPredicate(format: "(%K = %@)", argumentArray: [NSMetadataItemFSNameKey, GroceryListConfig.filename])
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "metadataQueryDidFinishGathering:", name: NSMetadataQueryDidFinishGatheringNotification, object: groceryListQuery)
    groceryListQuery.startQuery()
  }
  
  @objc private func metadataQueryDidFinishGathering(notification: NSNotification) {
    groceryListQuery.disableUpdates()
    groceryListQuery.stopQuery()
    NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidFinishGatheringNotification, object: groceryListQuery)
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
