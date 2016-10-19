//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by fauquette fred on 9/09/16.
//  Copyright © 2016 Fredfoc. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Present the view controller appropriate for the conversation and presentation style.
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        // Determine the controller to present.
        let controller: UIViewController
        if presentationStyle == .compact {
            controller = instantiateHomeViewController()
        }
        else {
            /*
             Parse a `shoppingList` from the conversation's `selectedMessage` or
             create a new `shoppingList` if there isn't one associated with the message.
             */
            let shoppingList = ShoppingListModel(message: conversation.selectedMessage) ?? ShoppingListModel(withMussels: true)
            controller = instantiateDetailListViewController(with: shoppingList)
        }
        
        // Remove any existing child controllers.
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        // Embed the new controller.
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
    }
    
    private func instantiateHomeViewController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: HomeViewController.storyboardIdentifier) as? HomeViewController else { fatalError("Unable to instantiate an HomeViewController from the storyboard") }
        
        controller.delegate = self
        
        return controller
    }
    
    private func instantiateDetailListViewController(with shoppingList: ShoppingListModel) -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: DetailListViewController.storyboardIdentifier) as? DetailListViewController else { fatalError("Unable to instantiate a DetailListViewController from the storyboard") }
        controller.shoppingList = shoppingList
        controller.delegate = self
        
        return controller
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }
        
        // Present the view controller appropriate for the conversation and presentation style.
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    // MARK: Convenience
    
    fileprivate func composeMessage(with shoppingList: ShoppingListModel, caption: String, session: MSSession? = nil) -> MSMessage {
        var components = URLComponents()
        components.queryItems = shoppingList.queryItems
        
        let layout = MSMessageTemplateLayout()
        layout.image = shoppingList.renderSticker(opaque: false)
        layout.caption = caption
        
        let message = MSMessage(session: session ?? MSSession())
        message.url = components.url!
        message.layout = layout
        
        return message
    }

}


/**
 Extends `MessagesViewController` to conform to the `HomeViewControllerDelegate`
 protocol.
 */
extension MessagesViewController: HomeViewControllerDelegate {
    func homeViewControllerControllerDidSelectAdd() {
        /*
         The user tapped 'new party button'
         Change the presentation style to `.expanded`.
         */
        requestPresentationStyle(.expanded)
    }
}

/**
 Extends `MessagesViewController` to conform to the `DetailListViewControllerDelegate`
 protocol.
 */
extension MessagesViewController: DetailListViewControllerDelegate {
    func detailListViewController(_ controller: DetailListViewController) {
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        guard let shoppingList = controller.shoppingList else { fatalError("Expected the controller to be displaying a shoppingList") }
        
        // Create a new message with the same session as any currently selected message.
        let message = composeMessage(with: shoppingList, caption: "8 produits restants")
        
        // Add the message to the conversation.
        conversation.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
        
        dismiss()
    }
}
