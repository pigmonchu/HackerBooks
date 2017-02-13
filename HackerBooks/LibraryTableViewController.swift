//
//  LibraryTableViewController.swift
//  HackerBooks
//
//  Created by pigmonchu on 12/2/17.
//  Copyright © 2017 digestiveThinking. All rights reserved.
//

import UIKit

class LibraryTableViewController: UITableViewController {
    
    //MARK: - Properties
    let model : Library
    
    var dict : Library.SortedLibrary
    var sections : [String]
    
    
    //MARK: - Initiliazers
    
    init(model: Library) {
        self.model = model
 
        do {
            dict = try model.booksSortedByTag()
        } catch {
            dict = Library.SortedLibrary()
        }

        sections = Array(dict.keys).sorted()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Definir un id para el tipo de celda
        let cellId = "BookCell"
        
        //Averiguar la sección
        let classification = sections[indexPath.section]
        
        //Averiguar el libro
        let book = dict[classification]?[indexPath.row]
        
        //Crear la celda
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        
        if cell == nil { //es más elegante con un guard, así en la práctica
            //El opcional está vacio y toca crear la celda a capón
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        }
        
        //Configurar la celda
        cell?.textLabel?.text       = book?.title
        cell?.detailTextLabel?.text = book?.authors[0]
        cell?.imageView?.image      = book?.coverImage
        
        //Devolverla
        return cell!
    }
}
