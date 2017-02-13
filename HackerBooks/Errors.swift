//
//  Errors.swift
//  HackerBooks
//
//  Created by pigmonchu on 7/2/17.
//  Copyright © 2017 digestiveThinking. All rights reserved.
//

import Foundation

enum HackerBooksErrors : Error {
    case titleWithoutInstanceAssociated
    case jsonParsingError
    case jsonSerializingError
    case wrongURLFormatForJSONResource
    case bookWithoutTitle
    case remoteBooksUrlNotReachable
    case notLocalURL
    case notLocalJSON
    case errorSavingFile
    case errorReadingFile
    case urlImageNotReachable
    case urlPDFNotReachable
    case emptyPDF
    case emptyImage
}
