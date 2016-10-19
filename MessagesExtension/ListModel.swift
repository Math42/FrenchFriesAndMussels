//
//  ListModel.swift
//  moulesFrites
//
//  Created by fauquette fred on 9/09/16.
//  Copyright © 2016 Fredfoc. All rights reserved.
//

import Foundation
import Messages

struct ShoppingListModel {
    
    static let queryNameKey = "name"
    
    var name = "Mussels Party"
    var elements = [ShoppingListElementModel]()
    
    init(withMussels: Bool = true) {
        if withMussels {
            elements.append(ShoppingListElementModel(name: "Mussels"))
            elements.append(ShoppingListElementModel(name: "Fries"))
            elements.append(ShoppingListElementModel(name: "Blop"))
        }        
    }
    
    mutating func addElement (element: ShoppingListElementModel) {
        elements.append(element)
    }
    
    mutating func removeElementAtIndex(_ index: Int) {
        elements.remove(at: index)
    }
    
    mutating func changeName(name: String) {
        self.name = name
    }
}

/**
 Extends `ShoppingListModel` to be able to be represented by and created with an array of
 `NSURLQueryItem`s.
 */
extension ShoppingListModel {
    // MARK: Computed properties
    
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        items.append(URLQueryItem(name: ShoppingListModel.queryNameKey, value: name))
        for element in elements {
            items.append(URLQueryItem(name: ShoppingListElementModel.queryItemKey , value: String(describing: element)))
        }
        return items
    }
    
    // MARK: Initialization
    
    init?(queryItems: [URLQueryItem]) {
        for queryItem in queryItems {
            guard let value = queryItem.value else { continue }
            switch queryItem.name {
            case ShoppingListModel.queryNameKey:
                name = value
            case ShoppingListElementModel.queryItemKey:
                let newElement = ShoppingListElementModel(name: value)
                elements.append(newElement)
            default:
                break
            }
        }
    }
}



/**
 Extends `ShoppingListModel` to be able to be created with the contents of an `MSMessage`.
 */
extension ShoppingListModel {
    init?(message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems else { return nil }
        
        self.init(queryItems: queryItems)
    }
}



struct ShoppingListElementModel {
    var name: String
    static let queryItemKey = "element"
}

extension ShoppingListElementModel: CustomStringConvertible {
    var description: String {
        return name
    }
}

extension ShoppingListModel {
    
    struct StickerProperties {
        fileprivate static let size = CGSize(width: 380.0, height: 220.0)
        fileprivate static let lightGray = UIColor(red: 229.0/255.0, green: 230.0/255.0, blue: 233.0/255.0, alpha: 1.0)
    }
    
    func renderSticker(opaque: Bool) -> UIImage? {
        guard let listImage = renderList() else { return nil }
        
        let canvasSize = StickerProperties.size
        let titleHeight = canvasSize.height - listImage.size.height
        
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let image = renderer.image { context in
            
            // Draw the background
            UIColor.white.setFill()
            context.fill(CGRect(origin: CGPoint.zero, size: canvasSize))
            
            // Draw list name
            let string = "Liste barbecue samedi"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 24)!,
                         NSForegroundColorAttributeName : UIColor.green,
                         NSParagraphStyleAttributeName: paragraphStyle]
            
            let titleTopMargin: CGFloat = 10
            let titleLeftMargin: CGFloat = 62 // 54 to touch app icon + 8 of margin
            let titleRightMargin: CGFloat = 53 // 45 to touch close icon + 8 of margin
            
            string.draw(with: CGRect(x: titleLeftMargin,
                                     y: titleTopMargin,
                                     width: canvasSize.width - titleLeftMargin - titleRightMargin,
                                     height: titleHeight),
                        options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            
            // Draw the list.
            let drawRect = CGRect(x: 0, y: titleHeight, width: listImage.size.width, height: listImage.size.height)
            listImage.draw(in: drawRect)
            
            // Add blur on top of everything
            
        }
        
        
        
        
        
        return image
    }

    /*
        Draw an image with 3 elements, separeted by a line.
        Each "cell" containing 1 line and an element is 50 height
        Image will be 150
     */
    private func renderList() -> UIImage? {
        let numberOfCellToDraw: CGFloat = 3
        let imageSize = CGSize(width: 380, height: 150)
        let cellHeight = imageSize.height / numberOfCellToDraw
        
        // Setup font
        let elementFontSize: CGFloat = 18
        let elementCheckboxSize: CGFloat = 28
        let elementNameMargin: CGFloat = 10
        let elementTopMargin: CGFloat = (cellHeight - elementFontSize) / 2
        
        // Creating the image
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let image = renderer.image { context in
            
            // Background
            UIColor.white.setFill()
            context.fill(CGRect(origin: CGPoint.zero, size: imageSize))
            
            // List Elements
            var lineRect = CGRect(x: 0, y: 0, width: imageSize.width, height: 1)
            var elementNameRect = CGRect(x: elementNameMargin,
                                         y: elementTopMargin,
                                         width: imageSize.width - elementNameMargin * 2,
                                         height: cellHeight - lineRect.height)
            var checkBoxRect = CGRect(x: imageSize.width - elementCheckboxSize - elementNameMargin * 2,
                                      y: (cellHeight - elementCheckboxSize) / 2,
                                      width: elementFontSize * 2,
                                      height: elementFontSize * 2)
            
            for element in self.elements {
                // Draw a line
                StickerProperties.lightGray.setFill()
                context.fill(lineRect)
                
                // Draw elementName
                let paragraphStyle = NSMutableParagraphStyle()
                let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: elementFontSize)!,
                             NSForegroundColorAttributeName : UIColor.darkGray,
                             NSParagraphStyleAttributeName: paragraphStyle]
                
                element.name.draw(with: elementNameRect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
                
                // Draw checkbox
                StickerProperties.lightGray.setFill()
                context.fill(checkBoxRect)
                
                // Prepare for next line
                lineRect.origin.y += cellHeight
                elementNameRect.origin.y += cellHeight
                checkBoxRect.origin.y += cellHeight
                
                
                
                
                let context = context.cgContext
                let colors = [UIColor.white.withAlphaComponent(0).cgColor,
                              UIColor.white.withAlphaComponent(0.1).cgColor,
                              UIColor.white.cgColor,
                              UIColor.white.cgColor] as CFArray
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                
                let colorLocations:[CGFloat] = [0, 0.2, 0.9, 1]
                
                let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: colorLocations)
                
                let startPoint = CGPoint.zero
                let endPoint = CGPoint(x:0, y:imageSize.height)
                context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)
            }
        }
        
        /*
        if let ciImage = image.cgImage as CGImage! {
            let imageToBlur = CIImage(cgImage:ciImage)
            let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
            gaussianBlurFilter?.setValue(imageToBlur, forKey: "inputImage")
            gaussianBlurFilter?.setValue(NSNumber(value: 3), forKey: "inputRadius")
            if let resultImage = gaussianBlurFilter?.value(forKey: "outputImage") as! CIImage! {
                return UIImage(ciImage:resultImage, scale: 2, orientation: .up)
            }
        }
        */
        
        
        
        
        return image
    }
}
