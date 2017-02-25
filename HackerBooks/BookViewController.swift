//
//  BookViewController.swift
//  HackerBooks
//
//  Created by pigmonchu on 24/2/17.
//  Copyright © 2017 digestiveThinking. All rights reserved.
//

import UIKit

class BookViewController: UIViewController {

    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var TAGsLabel: UILabel!
    
    var model: Book
    
    init(model: Book) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View LifeStyle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.syncViewWithModel()
    }
    
    //MARK: Utilities
    func syncViewWithModel() {
        self.coverView.image = model.coverImage
        self.title = model.title
        self.authorsLabel.text = model.authorsList
        self.TAGsLabel.text = model.tagsList
    }
    
    @IBAction func openReader(_ sender: UIBarButtonItem) {
    }

    @IBAction func setUnsetFavourite(_ sender: UIBarButtonItem) {
    }
}

extension BookViewController: LibraryTableViewControllerDelegate {
    
    func libraryTableViewController(_ libVC: LibraryTableViewController, didSelectBook book: Book) {
        model = book
        
        self.syncViewWithModel()
    }
}
