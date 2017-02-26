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
    
    @IBOutlet weak var favouriteButton: UIBarButtonItem!

    var model: Book

    weak var delegate: BookViewControllerDelegate? = nil

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

        edgesForExtendedLayout = .all

    }
    
    //MARK: Utilities
    func syncFavIcon() {
        if model.isFav {
            self.favouriteButton.image = #imageLiteral(resourceName: "favOn")
        } else  {
            self.favouriteButton.image = #imageLiteral(resourceName: "fav")
        }
        
    }
    
    func syncViewWithModel() {
        self.coverView.image = model.coverImage
        self.title = model.title
        self.authorsLabel.text = model.authorsList
        self.TAGsLabel.text = model.tagsList

        syncFavIcon()
    }
    
    @IBAction func openReader(_ sender: UIBarButtonItem) {
        let pdfVC = PDFViewController(model: model)
        self.navigationController?.pushViewController(pdfVC, animated: true)
        
    }

    @IBAction func setUnsetFavourite(_ sender: UIBarButtonItem) {
        
        var newJsonBook = JSONDictionary()
        var i:Int = 0
        
        model.isFav = !model.isFav
        
        for oldJsonBook in contextJson {
            if oldJsonBook["title"] as! String == model.title {
                for (key, value) in oldJsonBook {
                    if key == "isFav" {
                        newJsonBook[key] = model.isFav as AnyObject
                    } else {
                        newJsonBook[key] = value
                    }
                }
                
                contextJson.remove(at: i)
                contextJson.append(newJsonBook)
                break
            }
            i+=1
        }
        
        syncFavIcon()

        delegate?.bookViewController(self, didChangeBookFav: model)
    }
}

extension BookViewController: LibraryTableViewControllerDelegate  {
    
    func libraryTableViewController(_ lVC: LibraryTableViewController, didSelectBook book: Book) {
        model = book
        syncViewWithModel()
    }

}

protocol BookViewControllerDelegate: class {
    func bookViewController(_ booVC: BookViewController, didChangeBookFav book: Book)
}
