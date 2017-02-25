//
//  Library.swift
//  HackerBooks
//
//  Created by pigmonchu on 7/2/17.
//  Copyright © 2017 digestiveThinking. All rights reserved.
//

import Foundation

class Library {
    //MARK: - Utility types
    typealias BooksArray = [Book]
    
    typealias Cards = [String]
    
    fileprivate
    typealias BooksDictionary = [String: Book]
    
    typealias SortedLibrary = [String : BooksArray]
    
    typealias IndexCards = MultiDictionary<String, String>
    
    //MARK: - Stored properties

    fileprivate
    var allBooks = BooksDictionary() //byTitle
    
    var tagsFile  = IndexCards()    //key: Tag, Set: Titles
    var authorsFile = IndexCards()  //Key: Author, Set: Titles
    fileprivate
    var favouritesFile = Set<String>()

    //MARK: - Initializators

    init(books : BooksArray) {
        
        for book in books {
            allBooks[book.title] = book
            self.storeAuthors(book: book)
            self.storeTags(book: book)
            if book.isFav {
                self.favouritesFile.insert(book.title)
            }
        }
        
        
    }
    
    init(books: Data) {
        
    }

    //MARK: - Accessors
    
    var tagsCount : Int {
        get {
            return tagsFile.countUnique
        }
    }
    
    var authorsCount : Int {
        get {
            return authorsFile.countUnique
        }
    }
    
    func book(byTitle title : String) -> Book? {
        return allBooks[title]
    }
    
    func booksSorted(byAuthor author : String) throws -> BooksArray {
        let titles = self.authorsFile[author]?.sorted()
        return try subSebLibraryBy(arrayOfTitles: titles)
    }

    func booksSorted(byIndexCard ixCards : IndexCards) throws -> SortedLibrary {
        
        var dict = SortedLibrary()
        for key in ixCards.keys {
            guard let values = ixCards[key] else {
                continue
            }
            let titles = Array(values)
            
            dict[key] = try subSebLibraryBy(arrayOfTitles: titles)
        }
        
        return dict
    }
    
    func booksSortedByTag() throws -> SortedLibrary {
        var sortedLibrary = try booksSorted(byIndexCard: self.tagsFile)
        
        let favourites = self.favourites
        if favourites.count > 0 {
            sortedLibrary[""] = favourites
        }
        
        return sortedLibrary
        
    }
    
    func booksSortedByAuthor() throws -> SortedLibrary {
        var sortedLibrary =  try booksSorted(byIndexCard: self.authorsFile)
        
        let favourites = self.favourites
        if favourites.count > 0 {
            sortedLibrary[""] = favourites
        }
        
        return sortedLibrary
        
    }

    
    var favourites : BooksArray {
        get {
            var favourites = BooksArray()
            for title in self.favouritesFile {
                favourites.append(self.book(byTitle: title)!)
            }
            
            return favourites.sorted()
        }
    }
    

    //MARK: Utils
    
    fileprivate
    func storeAuthors(book : Book) {
        for author in book.authors {
            authorsFile.insert(value: book.title, forKey: author)
        }
    }
    
    fileprivate
    func storeTags(book : Book) {
        for tag in book.tags {
            tagsFile.insert(value: book.title, forKey: tag)
        }
    }
    
    fileprivate
    func subSebLibraryBy(arrayOfTitles titles: [String]?) throws -> BooksArray {
        var books = BooksArray()
        guard let auxTitles = titles else{
            return books
        }
        for title in auxTitles {
            
            guard let auxBook = book(byTitle: title) else {
                throw HackerBooksErrors.titleWithoutInstanceAssociated
            }
            books.append(auxBook)
        }
        return books
        
    }
    
}
