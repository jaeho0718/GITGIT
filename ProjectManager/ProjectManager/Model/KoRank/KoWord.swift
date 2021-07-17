//
//  KoWord.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/16.
//

import Foundation
import NaturalLanguage

struct KoWord : Hashable{
    let word : String
    var length : Int{
        return word.count
    }
    let originalTextIndex: Int
    let language : textRank_Language
    
    init() {
        self.word = ""
        self.language = .Korean
        self.originalTextIndex = 0
    }
    
    init(_ word : String,index : Int) {
        self.word = word
        self.language = .Korean
        self.originalTextIndex = index
    }
    
    init(_ word : String, language : textRank_Language = .Korean,index : Int) {
        self.word = word
        self.language = language
        self.originalTextIndex = index
    }
}

extension KoWord{
    static func removeStopwords(_ body : String, language : textRank_Language = .Korean)->String{
        var new_body : String = ""
        switch language {
        case .Korean:
            for stopword in Stopwords.Korean{
                new_body = new_body.replacingOccurrences(of: stopword, with: "")
            }
        case .English:
            for stopword in Stopwords.English{
                new_body = new_body.replacingOccurrences(of: stopword, with: "")
            }
        }
        return new_body
    }
    
    /// Toknization body
    /// - Parameter body :  put string
    static func getToken(_ body : String, language : textRank_Language = .Korean)->[String]{
        let tagger = NLTagger(tagSchemes: [.tokenType])
        var tokens : [String] = []
        tagger.string = body
        tagger.enumerateTags(in: body.startIndex ..< body.endIndex, unit: .word, scheme: .tokenType , options: [.omitPunctuation,.omitWhitespace]){ (tag,range) -> Bool in
            if tag == .word{
                let str = String(body[range])
                switch language{
                case .English:
                    if !(Stopwords.English.contains(str)){
                        tokens.append(str)
                    }
                case .Korean:
                    if !(Stopwords.Korean.contains(str)){
                        tokens.append(str)
                    }
                }
            }
            return true
        }
        return tokens
    }
}
