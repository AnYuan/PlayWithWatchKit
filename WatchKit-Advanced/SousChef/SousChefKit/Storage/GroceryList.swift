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
  public static let groupID = "group.com.razeware.SousChef"
  public static let iCloudID = "iCloud.com.razeware.SousChef"
  public static let filename = "com.rw.souschef.groceries.json"
  public static var url = NSURL()
  public static var cloudURL = NSURL()
  public static var groupURL: NSURL {
    let sharedURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(groupID)
    return sharedURL!.URLByAppendingPathComponent(filename)
  }
}

public typealias FlatGroceryItem = (item: AnyObject, id: String)

public class GroceryList {

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

  public func reload() {
    list = syncedGroceryItems()
    table = updatedTable(list)
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

  // MARK: Init

  public init() {
    reload()
  }

  public convenience init(useSample: Bool) {
    self.init()

    if useSample && sectionCount == 0 {
      let store = RecipeStore()
      let recipe = store.recipes[0]
      for item in recipe.ingredients {
        addItemToList(item)
      }
      sync()
    }
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

  private func syncedGroceryItems() -> GroceryItems {
    if let data = NSData(contentsOfFile: savedGroceriesPath) {
      if let rawGroceries = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? GroceryItems {
        return rawGroceries
      }
    }
    return GroceryItems()
  }

  private func saveCurrentState() {
    let data = NSKeyedArchiver.archivedDataWithRootObject(list)
    if !NSFileManager.defaultManager().createFileAtPath(savedGroceriesPath, contents: data, attributes: nil) {
      println("error saving grocery list")
    }
  }

}