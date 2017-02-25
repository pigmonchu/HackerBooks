//
//  JSONProcessing.swift
//  HackerBooks
//
//  Created by pigmonchu on 12/2/17.
//  Copyright © 2017 digestiveThinking. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Constants
let localFile = "readable_books.json"
let remoteCover = "image_url"
let remotePDF = "pdf_url"
let _localCover = "image_local"
let _localPDF = "pdf_local"
let _imgPath = ""
let _pdfPath = ""

//MARK: - Aliases
typealias JSONObject        = AnyObject
typealias JSONDictionary    = [String : JSONObject]
typealias JSONArray         = [JSONDictionary]
typealias esLocal           = Bool
typealias JSONDataPath      = (String, esLocal)


/*
 {
 "authors": "Scott Chacon, Ben Straub",
 "image_url": "http://hackershelf.com/media/cache/b4/24/b42409de128aa7f1c9abbbfa549914de.jpg",
 "pdf_url": "https://progit2.s3.amazonaws.com/en/2015-03-06-439c2/progit-en.376.pdf",
 "tags": "version control, git",
 "title": "Pro Git"
 }
 */


//MARK: - Decodification

func decode(Book json: JSONDictionary) -> Book? {
    
    do {
        let title = try decodeTitle(Book: json)
        let authors = decodeAuthors(Book: json)
        let tags = decodeTags(Book: json)
        let coverDataPath = try decodeCoverPath(Book: json)
        let coverImage = try decodeCover(pathData: coverDataPath)
        let coverPath = coverDataPath.0
        let isLocalCover = coverDataPath.1
        
        if !isLocalCover {
            do {
                try saveFile(data: UIImageJPEGRepresentation(coverImage, 0.8)!, path: _imgPath + Bundle.main.URLResource(forUrl: coverPath)!)
            } catch {
                throw HackerBooksErrors.errorSavingFile
            }
        }
        
        let pdfDataPath = try decodePDFPath(Book: json)
        let pdfPath = pdfDataPath.0
        let isLocalPDF = pdfDataPath.1
        let pdfData = try decodePDF(pathData: pdfDataPath)
        
        if !isLocalPDF {
            do {
                try saveFile(data: pdfData, path: _pdfPath + Bundle.main.URLResource(forUrl: pdfPath)!)
            } catch {
                throw HackerBooksErrors.errorSavingFile
            }
        }

        let isFav = try decodeIsFav(Book: json)
        
        return Book(title: title, pdfData: pdfData, coverImage: coverImage, tags: tags, authors: authors, isFav: isFav)
    } catch HackerBooksErrors.emptyPDF {
        print("pdf no informado")
        return nil
    }
    catch HackerBooksErrors.emptyImage {
        print("image no informado")
        return nil
    } catch HackerBooksErrors.wrongURLFormatForJSONResource {
        print("Url incorrecta")
        return nil
    } catch HackerBooksErrors.urlPDFNotReachable {
        print("pdf no descarga")
        return nil
    } catch HackerBooksErrors.urlImageNotReachable {
        print("imagen no informado")
        return nil
    } catch HackerBooksErrors.bookWithoutTitle {
        print("titulo obligado")
        return nil
    }catch HackerBooksErrors.errorSavingFile  {
        print("Imposible guardar imagen o pdf")
        return nil
    } catch{
        print("error general \(error)")
        return nil
    }
    
}

func decodeTitle(Book json: JSONDictionary) throws -> String {
    
    guard let title = json["title"] as! String? else
    {
        print("Book without title")
        throw HackerBooksErrors.bookWithoutTitle
    }
    return title
    
}

func decodeAuthors(Book json: JSONDictionary) -> [String] {
    
    let authorsString = json["authors"] as? String
    let maybeAuthors = authorsString?.components(separatedBy: ", ")
    let authors : [String]
    if withoutData(array: maybeAuthors) {
        authors = [Book.withoutAuthors]
    } else {
        authors = trim(strings: maybeAuthors!)
    }
    
    return authors
}

func decodeTags(Book json: JSONDictionary) -> [String] {
    
    let tagsString = json["tags"] as? String
    let maybeTags = tagsString?.components(separatedBy: ", ")
    var tags : [String]
    if withoutData(array: maybeTags) {
        tags = [Book.withoutTags]
    } else {
        tags = trim(strings: maybeTags!)
    }

    return tags
    
}

func decodeCoverPath(Book json: JSONDictionary) throws -> JSONDataPath {
    let coverLocalPath = json[_localCover] as? String
    let coverRemotePath = json[remoteCover] as? String
    
    guard let coverPath = coverLocalPath ?? coverRemotePath else {
        throw HackerBooksErrors.emptyImage
    }
    
    return (coverPath, coverLocalPath != nil)
}



func decodeCover(pathData: JSONDataPath) throws -> UIImage {
    
    let path = pathData.0
    let isLocal = pathData.1
    let data : Data
    
    if isLocal {
        data = try readFile(path: path)
    } else {
       guard let url = URL(string: path) else {
            throw HackerBooksErrors.wrongURLFormatForJSONResource
        }
        guard let imgData = try? Data(contentsOf: url) else {
            throw HackerBooksErrors.urlImageNotReachable
        }
        data = imgData
   }
    
    
    return UIImage(data: data)!
    
}

func decodePDFPath(Book json: JSONDictionary) throws -> JSONDataPath {
    let pdfLocalPath = json[_localPDF] as? String
    let pdfRemotePath = json[remotePDF] as? String
    
    guard let pdfPath = pdfLocalPath ?? pdfRemotePath else {
        throw HackerBooksErrors.emptyPDF
    }
    
    return (pdfPath, pdfLocalPath != nil)
}

func decodePDF(pathData: JSONDataPath) throws -> Data {
    let path = pathData.0
    let isLocal = pathData.1
    let data : Data
    
    if isLocal {
        data = try readFile(path: path)
    } else {
        guard let pdfUrl = URL(string: path) else {
            throw HackerBooksErrors.wrongURLFormatForJSONResource
        }
        
        guard let pdfData = try? Data(contentsOf: pdfUrl) else {
            throw HackerBooksErrors.urlPDFNotReachable
        }
        data = pdfData
    }
    
    return data
}

func decodeIsFav(Book json: JSONDictionary) throws -> Bool {
    
    guard let isFav = json["isFav"] as! Bool? else
    {
        return false
    }
    return isFav 
    
}




//MARK: - Utils
fileprivate
func withoutData(array : [String]?) -> Bool {
    guard let theArray = array else {
        return true
    }
    
    for item in theArray {
        if !item.isEmpty {
            return false
        }
    }
    return true
}

fileprivate
func trim(strings : [String]) -> [String]{
    var arr = [String]()

    for string in strings {
        arr.append(string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
    }
    return arr
}

func localUrl(fileName: String) -> URL? {
    
    let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create:true)
    let filePath = dir?.appendingPathComponent(fileName)
    return filePath
}

func fileExist(fileName: String) -> Bool {
    let fileManager = FileManager.default
    let filePath = localUrl(fileName: fileName)
    
    return fileManager.fileExists(atPath: filePath!.path)

}

//MARK: - Loading

func loadFromRemote() -> Data? {
    let url = "https://t.co/K9ziV0z3SJ"
    let jsonData = try? Data(contentsOf: URL(string: url)!)
    print("Carga remota de librería")
    return jsonData

}

func loadFromLocalFile(fileName name: String) throws -> Data? {
 
    guard let url = localUrl(fileName: name) else {
        throw HackerBooksErrors.notLocalURL
    }
    
    guard let jsonData = try? Data(contentsOf: url) else {
        print("local file without data")
        throw HackerBooksErrors.notLocalJSON
    }
    
    print("Carga local de librería")
    
    return jsonData
}
//MARK: - Read File
func readFile(path: String) throws -> Data{
    let file = localUrl(fileName: path)
    do {
        return try Data(contentsOf: file!)
    } catch {
        throw HackerBooksErrors.errorReadingFile
    }
}

//MARK: - Saving

func saveFile(string: String, path: String) throws {
    let file = localUrl(fileName: path)
    do{
        try string.write(to: file!, atomically: true, encoding: String.Encoding.utf8)
    }
    catch {
        throw HackerBooksErrors.errorSavingFile
    }
}

func saveFile(data: Data, path: String) throws {
    let file = localUrl(fileName: path)
    do {
        try data.write(to: file!, options: .atomic)
    }
}

func addLocals(toResource json: JSONArray, cleanFav: Bool = false) -> JSONArray {
    var newLibrary = JSONArray()
    
    for itBook in json {
        var newBook = JSONDictionary()
        let localImg = Bundle.main.URLResource(forUrl: itBook[remoteCover] as! String)
        let localDoc = Bundle.main.URLResource(forUrl: itBook[remotePDF] as! String)
        
        for (key, value) in itBook {
            if (key == remoteCover) {
                guard let localFile = localImg else {
                    continue
                }
                newBook[key] = value
                newBook[_localCover] = (_imgPath + localFile) as AnyObject
            } else if (key == remotePDF) {
                guard let localFile = localDoc else {
                    continue
                }
                newBook[key] = value
                newBook[_localPDF] = (_pdfPath + localFile) as AnyObject
            } else {
                newBook[key] = value
            }
            
            if cleanFav {
                newBook["isFav"] = false as AnyObject
            }
            
        }
        newLibrary.append(newBook)
    }

    return newLibrary
}

//MARK: - Parsing
func parse(data: Data) throws -> JSONArray {

    guard let array = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) else {
        print("local file json format error")
        throw HackerBooksErrors.jsonParsingError
    }

    return array as! JSONArray
    
}

func serialize(json: JSONArray) throws -> String? {
    do {
        let jsonD : Data = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        return String.init(data: jsonD, encoding: .utf8)
    } catch {
        throw HackerBooksErrors.jsonSerializingError
    }
    
}


