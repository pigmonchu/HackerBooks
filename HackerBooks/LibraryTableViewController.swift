//
//  LibraryTableViewController.swift
//  HackerBooks
//
//  Created by pigmonchu on 12/2/17.
//  Copyright © 2017 digestiveThinking. All rights reserved.
//

import UIKit

class LibraryTableViewController: UITableViewController {
    
    //MARK: - Constants
    static let notificationName = Notification.Name(rawValue: "BookDidChange")
    static let bookKey = "BookKey"
    
    //MARK: - Properties
    let model : Library
    
    var dict = Library.SortedLibrary()
    var sections : [String] = []
    
    weak var delegate: LibraryTableViewControllerDelegate? = nil
    
    //MARK: - Initiliazers
    
    init(model: Library) {
        self.model = model
        
        super.init(nibName: nil, bundle: nil)

        self.fixTags()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Hacker Books"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let book = getBook(At: indexPath) else{
            return
        }
        
        delegate?.libraryTableViewController(self, didSelectBook: book)
        
        // mandamos una notificación
        notify(bookChanged: book)


/*      let bookVC = BookViewController(model: book)
        self.delegate = bookVC
        bookVC.delegate = self
        self.navigationController?.pushViewController(bookVC, animated: true)
*/
 }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let maybeALibrary = dict[sections[section]] else {
            return 0
        }
        return maybeALibrary.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let cell = Bundle.main.loadNibNamed("LibraryTableViewHeader", owner: self, options: nil)?.first
        
        let headerCell : LibraryTableViewHeader
        
        if cell == nil {
            let hC = UITableViewCell(style: .subtitle, reuseIdentifier: "HeaderCell")
            headerCell =  hC as! LibraryTableViewHeader
        } else {
            headerCell = cell as! LibraryTableViewHeader
        }
        
        headerCell.headerLabel.text = (sections[section] != "" ? sections[section] : "Favoritos").uppercased()
        
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Definir un id para el tipo de celda
        let cellId = "BookCell"
        
        let book = getBook(At: indexPath)
        //Averiguar la sección
//        let classification = sections[indexPath.section]
        
        //Averiguar el libro
//        let book = dict[classification]?[indexPath.row]
        
        //Crear la celda -> Es algo así como registrarla pillándola del repositorio (no me gusta)
        
        let cell = Bundle.main.loadNibNamed("LibraryTableViewCell", owner: self, options: nil)?.first
        
        let bookCell : LibraryTableViewCell
        
        if cell == nil {
            let bC = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            bookCell =  bC as! LibraryTableViewCell
        } else {
            bookCell = cell as! LibraryTableViewCell
        }
        
        guard let theBook = book else {
            return bookCell
        }
        
        bookCell.title.text = theBook.title
        
        bookCell.authors.text = extractItems(array: theBook.authors, separator: ", ")
        bookCell.tags.text = extractItems(array: theBook.tags, separator: ", ")
        bookCell.cover.image = theBook.coverImage

        return bookCell
    }
    
//MARK: Utilities
    
    func fixTags() {
        do {
            dict = try model.booksSortedByTag()
        } catch {
            dict = Library.SortedLibrary()
        }
        
        sections = Array(dict.keys).sorted()

    }
    
    func extractItems(array: [String], separator: String, maxLength: Int = 0, defaultText: String = "sin datos") -> String {
        var text = ""
        if array.count > 0 {
            text = array[0]
            var i = 1
            while i < array.count {
                text += (separator + array[i] )
                i += 1
            }
        } else {
            text = defaultText
        }
        
        if maxLength > 0 && text.characters.count > maxLength {
            let index = text.index(text.startIndex, offsetBy: maxLength)
            text = text.substring(to: index) + "..."
        }
        
        return text
    }
    
    func getBook(At indexPath: IndexPath) -> Book? {
        //Averiguar la sección
        let classification = sections[indexPath.section]
        
        //Averiguar el libro
        let book = dict[classification]?[indexPath.row]
        
        return book
    }
}

//MARK: - Delegator
protocol LibraryTableViewControllerDelegate: class {
    func libraryTableViewController(_ lVB: LibraryTableViewController, didSelectBook book: Book)
    
}

//MARK: - Delegate

extension LibraryTableViewController: LibraryTableViewControllerDelegate {
    func libraryTableViewController(_ lVB: LibraryTableViewController, didSelectBook book: Book) {
        let bookVC = BookViewController(model: book)
        lVB.navigationController?.pushViewController(bookVC, animated: true)
        bookVC.delegate = lVB
    }
}

extension LibraryTableViewController: BookViewControllerDelegate {
    func bookViewController(_ booVC: BookViewController, didChangeBookFav book: Book) {
        
        fixTags()
        self.tableView.reloadData()
    
    }
}

//MARK: - Notifications

extension LibraryTableViewController {
    
    func notify(bookChanged book : Book) {
        //Crear instancia del Notification Center
        let nc = NotificationCenter.default
        
        //Notificacion
        let notification = Notification(name: LibraryTableViewController.notificationName, object: self, userInfo: [LibraryTableViewController.bookKey : book])
        
        //El grito
        nc.post(notification)
    }
}
