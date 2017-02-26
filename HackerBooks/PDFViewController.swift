//
//  PDFControllerViewController.swift
//  HackerBooks
//
//  Created by pigmonchu on 25/2/17.
//  Copyright © 2017 digestiveThinking. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController {

    //MARK: - Properties
    
    @IBOutlet weak var pdfReader: UIWebView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var model : Book
    
    //MARK: - Initialization
    
    init(model: Book) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Sync Model -> View
    func syncViewWithModel() {
        let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create:true)
        let baseURL = dir?.appendingPathComponent("index.html")
        pdfReader.load(model.pdfData, mimeType: "application/pdf", textEncodingName: "", baseURL: baseURL!)
    }
    
    //MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        syncViewWithModel()
        pdfReader.delegate = self
        
        subscribe()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribe()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: - UIWebViewDelegate
extension PDFViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        spinner.isHidden = false
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        spinner.stopAnimating()
        spinner.isHidden = true
    }
    
}

//MARK: - Notifications
extension PDFViewController {
    func subscribe() {
        let nc = NotificationCenter.default
        
        nc.addObserver(forName: LibraryTableViewController.notificationName, object: nil, queue: OperationQueue.main) { (note: Notification) in
            
            //Extraigo el libro
            let userInfo = note.userInfo
            let book = userInfo?[LibraryTableViewController.bookKey]
            
            //Actualizo información
            self.model = book as! Book
            self.syncViewWithModel()
        }
    }
    
    func unsubscribe() {
        let nc = NotificationCenter.default
        
        nc.removeObserver(self)
    }
}

