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

class RecipeDetailInterfaceController: WKInterfaceController {
  var recipe: Recipe?

  @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var nameGroup: WKInterfaceGroup!

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    recipe = context as? Recipe
    nameLabel.setText(recipe?.name)
    
    if let imageName = recipe?.imageURL?.path?.lastPathComponent {
      let cacheHelper = OnDeviceCacheHelper()
      
      if cacheHelper.cacheContainsImageNamed(imageName) == true {
        nameGroup.setBackgroundImageNamed(imageName)
      }
      else if let imageURL = recipe?.imageURL {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
          let imageData = NSData(contentsOfURL: imageURL)!
          let recipeImage = UIImage(data: imageData)!
          
          //IT IS VERY IMPORTANT THAT YOU RESIZE IMAGES BEFORE YOU CACHE THEM
          //OR YOU WILL BE SENDING A HUGE IMGE OVER TO THE USER'S WATCH.
          //REMEMBER, YOU ONLY HAVE 20MB OF IMAGE CACHE.
          let retinaRect = CGRect(x: 0, y: 0, width: self.contentFrame.size.width * 2, height: self.contentFrame.size.height * 2)
          let resizedImage = recipeImage.resizedImageWithAspectRatioInsideRect(retinaRect)
          let overlayedImage = resizedImage.imageWithOverlayedColor(UIColor.blackColor().colorWithAlphaComponent(0.3))
          
          dispatch_async(dispatch_get_main_queue()) {
            cacheHelper.addImageToCache(overlayedImage, name: imageName)
            self.nameGroup.setBackgroundImageNamed(imageName)
          }
        }
      }
    }
  }

  override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
    return recipe
  }
}
