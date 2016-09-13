//
//  HomeViewController.swift
//  moulesFrites
//
//  Created by fauquette fred on 9/09/16.
//  Copyright © 2016 Fredfoc. All rights reserved.
//

import UIKit


/**
 A delegate protocol for the `HomeViewController` class.
 */
protocol HomeViewControllerDelegate: class {
    func homeViewControllerControllerDidSelectAdd()
}

class HomeViewController: UIViewController {
    static let storyboardIdentifier = "HomeViewController"
    
    weak var delegate: HomeViewControllerDelegate?
    @IBAction func createNewParty(_ sender: AnyObject) {
        delegate?.homeViewControllerControllerDidSelectAdd()
    }
}

