//
//  RecipeStore.swift
//  SousChef
//
//  Created by Ryan Nystrom on 11/24/14.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import Foundation

private let kRecipesFileName = "Recipes"
private let kRecipesFileExtension = "json"

public class RecipeStore {

  public init() {}

  public lazy var recipes: [Recipe] = {
    var recipes = [Recipe]()
    if let data = NSData(contentsOfURL: self.savedRecipesURL) {
      recipes = self.recipesFromData(data)
    }
    return recipes
    }()

  // MARK: Private
  
  private func recipesFromData(data: NSData) -> [Recipe] {
    var newRecipes = [Recipe]()
    let json = JSON(data: data)
    
    // turn all of the recipe data into Recipe objects
    for (_, recipeJSON) in json {
      // all keys are required
      let imageURL = recipeJSON["imageURL"].stringValue
      let originalURL = recipeJSON["originalURL"].stringValue
      let name = recipeJSON["name"].stringValue
      
      // get all of the recipe's ingredients
      var ingredients = [Ingredient]()
      for (_, ingredientJSON) in recipeJSON["ingredients"] {
        // all keys are required
        let quantity = ingredientJSON["quantity"].stringValue
        let name = ingredientJSON["name"].stringValue
        let type = IngredientType(rawValue: ingredientJSON["type"].stringValue)
        
        if type == nil {
          let t = ingredientJSON["type"]
          println("Invalid type \(t)")
        }
        
        ingredients.append(Ingredient(quantity: quantity, name: name, type: type!))
      }
      
      // get all of the recipe's steps
      var steps = [String]()
      for (_, stepJSON) in recipeJSON["steps"] {
        steps.append(stepJSON.stringValue)
      }
      
      // get all of the recipe's timers
      // these should be 1:1 to steps
      var timers = [Int]()
      for (_, timerJSON) in recipeJSON["timers"] {
        timers.append(timerJSON.intValue)
      }
      
      assert(steps.count == timers.count, "Steps and timers are not 1:1 for recipe \(name). Have \(steps.count) steps and \(timers.count) timers.")
      
      newRecipes.append(Recipe(
        name: name,
        ingredients: ingredients,
        steps: steps,
        timers: timers,
        imageURL: NSURL(string: imageURL),
        originalURL: NSURL(string: originalURL))
      )
    }
    
    // sort alphabetically
    return newRecipes.sorted({ $0.name < $1.name })
  }

  private let savedRecipesURL: NSURL = {
    var docURL = NSURL()
    if let bundledRecipes = NSBundle(forClass: RecipeStore.self).URLForResource(kRecipesFileName, withExtension: kRecipesFileExtension) {
      docURL = bundledRecipes
    }
    return docURL
    }()

}