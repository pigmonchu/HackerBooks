//
//  Book.swift
//  HackerBooks
//
//  Created by pigmonchu on 7/2/17.
//  Copyright © 2017 digestiveThinking. All rights reserved.
//

import Foundation
import UIKit

class Book {
    
    //MARK: - Intern constants
    
    static let withoutTags : String = "Unclassified"
    static let withoutAuthors : String = "Anonymous"
    
    
    //MARK: - Stored properties
    
    let title      : String
    let pdfData    : Data
    let coverImage : UIImage
    let tags       : [String]
    let authors    : [String]
    var isFav      : Bool
    
    //MARK: Getters - Setters
    var authorsList : String {
        get {
            return extractTags(fromArray: authors, withSeparator: ", ")
        }
    }
    
    var tagsList : String {
        get {
            return extractTags(fromArray: tags, withSeparator: ", ")
        }
    }
    
    //MARK: - Initialization
    init(title      : String,
         pdfData    : Data,
         coverImage : UIImage,
         tags       : [String],
         authors    : [String],
         isFav      : Bool) {
        
        self.title = title
        self.pdfData = pdfData
        self.coverImage = coverImage
        self.tags = tags
        self.authors = authors
        self.isFav = isFav
    }

    //MARK: - Proxies
    func proxyForEquality() -> String{
        return "\(title)" + extractTags(fromArray  : authors) + extractTags(fromArray : tags)
    }
    
    func proxyForComparison() -> String{
        return proxyForEquality()
    }

    //MARK: - Utilities
    fileprivate
    func extractTags(fromArray array : [String], withSeparator sep : String) -> String {
        
        var tagsString =  ""
        
        for tag in array {
            tagsString += ("\(tag)" + sep)
        }
        
        return tagsString
        
    }

    fileprivate
    func extractTags(fromArray array : [String]) -> String {
            return extractTags(fromArray: array, withSeparator: "")
        
    }
}

//MARK: - Protocols

extension Book : Equatable {
    public static func ==(lhs: Book, rhs: Book) -> Bool {
        return (lhs.proxyForEquality() == rhs.proxyForEquality())
    }
}

extension Book : Comparable {
    public static func <(lhs: Book, rhs: Book) -> Bool {
        return (lhs.proxyForEquality() < rhs.proxyForEquality())
    }
}

extension Book : CustomStringConvertible {
    var description: String {
        get {
            return "<\(type(of:self)): \(title) -- " + extractTags(fromArray: authors, withSeparator: ", ") + ">"
        }
    }
}
