//
//  KoWord.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/16.
//

import Foundation

public struct Ko_Word : Hashable{
    public let text : String
    public var length : Int{
        text.count
    }
    public let originalTextIndex : Int
    
    public init(text : String, originalTextIndex : Int){
        self.text = Ko_Word.clean(text)
        self.originalTextIndex = originalTextIndex
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
    
    static func clean(_ s : String) -> String{
        return s.lowercased()
    }
    
    /// remove stopwords
    /// - Parameter Sentence : Original sentence
    /// - Returns : retrun sentence removed stopwords.
    static func removeStopWords(from Sentence : String, additionalStopwords : [String] = Stopwords.English)->String{
        var s = Sentence
        for stop_words in additionalStopwords{
            s = s.replacingOccurrences(of: stop_words, with: "")
        }
        return s
    }
}
