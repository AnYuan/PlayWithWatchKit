//
//  GroceryList.swift
//  SousChef
//
//  Created by Ryan Nystrom on 11/24/14.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import Foundation

public struct GroceryListConfig {
  // replace IDs with the ones you set up in target Capabilities
  public static let groupID = "group.com.baidu.lebo.documents"
  public static let iCloudID = "iCloud.com.baidu.Lebo.SousChef"
  public static let filename = "com.rw.souschef.groceries.json"
  public static var url = NSURL()
  public static var cloudURL = NSURL()
  public static var groupURL: NSURL {
    let sharedURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(groupID)
    return sharedURL!.URLByAppendingPathComponent(filename)
  }
}

public typealias FlatGroceryItem = (item: AnyObject, id: String)

public class GroceryList: UIDocument {
  let fileManager = NSFileManager.defaultManager()
  
  private func copyCloudToGroup() {
    let groupURL = GroceryListConfig.groupURL
    if fileManager.fileExistsAtPath(groupURL.path!) {
      fileManager.removeItemAtPath(groupURL.path!, error: nil)
    }
    dispatch_async(dispatch_get_global_queue(
      DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        fileCoordinator.coordinateReadingItemAtURL(self.fileURL,
          options: NSFileCoordinatorReadingOptions.WithoutChanges,
          error: nil) { newURL in
            let success = self.fileManager.copyItemAtURL(self.fileURL,
              toURL: groupURL, error: nil)
            if success {
              println("copyCloudToGroup: success")
            } else {
              println("copyCloudToGroup: failed")
            }
        }
    }
  }
  // MARK: Table Convenience

  public func sectionForIndex(index: Int) -> IngredientType {
    return sections[index]
  }

  public var sectionCount: Int {
    return sections.count
  }

  public func sectionForType(type: IngredientType) -> Int? {
    let sections = self.sections
    return find(sections, type)
  }

  public func numberOfItemsInSection(section: Int) -> Int {
    let type = sectionForIndex(section)
    return table[type]?.count ?? 0
  }

  public func itemForIndexPath(path: NSIndexPath) -> Ingredient? {
    let type = sectionForIndex(path.section)
    return table[type]?[path.row]
  }

  public func indexPathForItem(item: Ingredient) -> NSIndexPath? {
    if let group = table[item.type] {
      if let index = find(group, item) {
        return NSIndexPath(forRow: index, inSection: sectionForType(item.type)!)
      }
    }
    return nil
  }

  public func quantityForItem(item: Ingredient) -> Int {
    return list.reduce(0, combine: { acc, ingredient in
      acc + (item == ingredient ? 1 : 0)
    })
  }

  public func flattenedGroceries() -> [FlatGroceryItem] {
    var list = [FlatGroceryItem]()
    
    for section in 0..<self.sectionCount {
      let type = self.sectionForIndex(section)
      list.append((type.rawValue, "GroceryTypeRow"))
      
      for row in 0..<self.numberOfItemsInSection(section) {
        if let item = self.itemForIndexPath(NSIndexPath(forRow: row, inSection: section)) {
          list.append((item, "GroceryRow"))
        }
      }
    }
    
    return list
  }
  
  public func purchasedItems() -> [Ingredient] {
    var purchasedItems = [Ingredient]()
    list.map { (var anItem: Ingredient) -> Void in
      if anItem.purchased == true {
        purchasedItems.append(anItem)
      }
    }
    return purchasedItems
  }
  
  /// Marks all quantities of an ingredient as purchased.
  public func setIngredient(ingredient: Ingredient, purchased: Bool) {
    list.map { (var anItem: Ingredient) -> Void in
      if anItem.name == ingredient.name {
        anItem.purchased = purchased
      }
    }
  }
  
  // MARK: Persistence

  public func sync() {
    saveCurrentState()
  }

  //reload(contents:) is a revised version of the existing reload() method, which will
  //receive its contents to a revised syncedGroceryItems(contents:) method to create a 
  //list, then updates table, as before
  public func reload(contents: NSData) {
    list = syncedGroceryItems(contents)
    table = updatedTable(list)
  }
  
  //loadFromContents simply passes its contents argument to reload, which sets
  //the list and table properties
  public override func loadFromContents(contents: AnyObject, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
    reload(contents as NSData)
    return true
  }
  
  //returns the grocery list as an instance of NSData, which the saveToURL uses to save the document
  public override func contentsForType(typeName: String, error outError: NSErrorPointer) -> AnyObject? {
    return NSKeyedArchiver.archivedDataWithRootObject(list)
  }

  // MARK: List mutability

  public func addItemToList(newItem: Ingredient) {
    // the table is a uniqued list
    if !contains(list, newItem) {
      if var group = table[newItem.type] {
        group.append(newItem)
        table[newItem.type] = group
      } else {
        table[newItem.type] = [newItem]
      }
    }

    list.append(newItem)
  }

  public func removeItem(oldItem: Ingredient) {
    if var group = table[oldItem.type] {
      if let index = find(group, oldItem) {
        group.removeAtIndex(index)
        table[oldItem.type] = group
      }
    }

    if let index = find(list, oldItem) {
      list.removeAtIndex(index)
    }
  }

  public func removeAllItems() {
    list = GroceryItems()
    table = GroceryTable()
  }

  // MARK: Private

  private let savedGroceriesPath: String = {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let docPath = paths.first as String
    return "\(docPath)/com.rw.souschef.groceries.json"
  }()

  private typealias GroceryTable = Dictionary<IngredientType, [Ingredient]>
  private typealias GroceryItems = [Ingredient]

  private var list: GroceryItems = GroceryItems()
  private var table: GroceryTable = GroceryTable()

  private var sections: [IngredientType] {
    return table.keys.array
  }

  private func updatedTable(itemList: GroceryItems) -> GroceryTable {
    var table = GroceryTable()
    for item in itemList {
      if var group = table[item.type] {
        if !contains(group, item) {
          group.append(item)
          table[item.type] = group // changing mutable arrays makes a copy in swift, need to reassign
        }
      } else {
        table[item.type] = [item]
      }
    }
    return table
  }

  private func syncedGroceryItems(contents: NSData) -> GroceryItems {
    if contents.length > 0 {
      if let rawGroceries = NSKeyedUnarchiver.unarchiveObjectWithData(contents) as? GroceryItems {
        return rawGroceries
      }
    }
    return GroceryItems()
  }

  private func saveCurrentState() {
    saveToURL(fileURL, forSaveOperation: UIDocumentSaveOperation.ForOverwriting, completionHandler: {
      success in
      if success {
        if self.fileManager.isUbiquitousItemAtURL(self.fileURL) {
          self.copyCloudToGroup()
        } else {
          println("saveCurrentState: doc is in group container")
        }
      }
    })
  }

}