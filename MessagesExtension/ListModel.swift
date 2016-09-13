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
            items.append(URLQueryItem(name: ShoppingListElementModel.queryItemKey , value: String(element)))
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
        private static let size = CGSize(width: 300.0, height: 300.0)
        private static let opaquePadding = CGSize(width: 60.0, height: 10.0)
    }
    
    func renderSticker(opaque: Bool) -> UIImage? {
        guard let listImage = renderList() else { return nil }
        
        // Determine the size to draw as a sticker.
        let outputSize: CGSize
        let listSize: CGSize
        
        if opaque {
            let scale = min((StickerProperties.size.width - StickerProperties.opaquePadding.width) / listImage.size.height,
                            (StickerProperties.size.height - StickerProperties.opaquePadding.height) / listImage.size.width)
            listSize = CGSize(width: listImage.size.width * scale, height: listImage.size.height * scale)
            outputSize = StickerProperties.size
        }
        else {
            let scale = StickerProperties.size.width / listImage.size.height
            listSize = CGSize(width: listImage.size.width * scale, height: listImage.size.height * scale)
            outputSize = listSize
        }
        
        let renderer = UIGraphicsImageRenderer(size: outputSize)
        let image = renderer.image { context in
            let backgroundColor: UIColor
            if opaque {
                backgroundColor = UIColor.white
            }
            else {
                backgroundColor = UIColor.clear
            }
            
            // Draw the background
            backgroundColor.setFill()
            context.fill(CGRect(origin: CGPoint.zero, size: StickerProperties.size))
            
            // Draw the scaled composited image.
            var drawRect = CGRect.zero
            drawRect.size = listSize
            drawRect.origin.x = (outputSize.width / 2.0) - (listSize.width / 2.0)
            drawRect.origin.y = (outputSize.height / 2.0) - (listSize.height / 2.0)
            
            listImage.draw(in: drawRect)
        }
        
        return image
    }

    private func renderList() -> UIImage? {
        let fontSize: CGFloat = 30
        let textColor: UIColor = UIColor.black
        let boldTextFont: UIFont = UIFont.boldSystemFont(ofSize: fontSize - 2)
        let textFont: UIFont = UIFont.systemFont(ofSize: fontSize - 4)
        let titleFontAttributes = [
            NSFontAttributeName: boldTextFont,
            NSForegroundColorAttributeName: textColor,
        ]
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ]
        
        let imageSize = CGSize(width: 280, height: 280)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let image = renderer.image { context in
            let backgroundColor = UIColor.lightGray
            backgroundColor.setFill()
            context.fill(CGRect(origin: CGPoint.zero, size: imageSize))
            
            var textHeight: CGFloat = fontSize
            
            let string = self.name as NSString
            string.draw(in: CGRect(x: 5, y: textHeight, width: 270, height: fontSize),
                        withAttributes: titleFontAttributes)
            textHeight += fontSize
            for element in self.elements {
                guard textHeight < 280 else {
                    break
                }
                let elementName = element.name as NSString
                elementName.draw(in: CGRect(x: 5, y: textHeight, width: 270, height: fontSize), withAttributes: textFontAttributes)
                textHeight += fontSize
            }
        }
        return image
    }
}
