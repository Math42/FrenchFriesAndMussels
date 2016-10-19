//
//  DetailListViewController.swift
//  moulesFrites
//
//  Created by fauquette fred on 9/09/16.
//  Copyright © 2016 Fredfoc. All rights reserved.
//

import Foundation
import UIKit

/**
 A delegate protocol for the `DetailListViewControllerDelegate` class.
 */
protocol DetailListViewControllerDelegate: class {
    func detailListViewController(_ controller: DetailListViewController)
}

class DetailListViewController: UIViewController {
    // MARK: Properties
    
    @IBOutlet weak var mainTitleTextView: UITextField!
    @IBOutlet weak var tableView: UITableView!
    static let storyboardIdentifier = "DetailListViewController"
    
    weak var delegate: DetailListViewControllerDelegate?
    
    var shoppingList: ShoppingListModel?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTitleTextView.text = shoppingList?.name ?? "Indicate a name"
    }
    
    fileprivate func elementAtIndexPath(_ indexPath: NSIndexPath) -> ShoppingListElementModel? {
        return shoppingList?.elements[indexPath.row]
    }
    
    @IBAction func addElement(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Element ?", message: "Please give this new element a name:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0], let elementName = field.text {
                let newElement = ShoppingListElementModel(name: elementName)
                self.shoppingList?.addElement(element: newElement)
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Element"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func sendMessage(_ sender: AnyObject) {
        shoppingList?.changeName(name: mainTitleTextView.text ?? "New List")
        delegate?.detailListViewController(self)
    }
}

extension DetailListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        mainTitleTextView.resignFirstResponder()
        return true
    }
    
}

extension DetailListViewController: UITableViewDelegate {
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            shoppingList?.removeElementAtIndex(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension DetailListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList?.elements.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DetailListViewCell
        cell.label?.text = elementAtIndexPath(indexPath as NSIndexPath)?.name
        return cell
    }
}

class DetailListViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}
