//
//  FoundationExtensions.swift
//  HackerBooks
//
//  Created by pigmonchu on 13/2/17.
//  Copyright © 2017 digestiveThinking. All rights reserved.
//

import Foundation

extension Bundle{
    func URLResource(forUrl name: String) -> String? {
        let tokens = name.components(separatedBy: "/")
        
        return tokens.last
    }
}
