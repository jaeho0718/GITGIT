//
//  KoWord.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/16.
//

import Foundation
import NaturalLanguage
import Alamofire

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
    static func getToken(_ body : String,native : Bool = true ,language : textRank_Language = .Korean,completion: @escaping ([String])->()){
        if native{
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
            completion(tokens)
        }else{
            do{
                let httpbody = try JSONEncoder().encode(morphologyRequest(argument: morphologyArgument(analysis_code: "morp", text: body)))
                guard let url = URL(string: "http://aiopen.etri.re.kr:8000/WiseNLU") else {return}
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = httpbody
                URLSession.shared.dataTask(with: request){ data,response,error in
                    if let error = error{
                        print("nonative error : \(error.localizedDescription)")
                    }
                    if let DATA = data{
                        if let result = try? JSONDecoder().decode(morphologyResult.self, from: DATA){
                            var tokens : [String] = []
                            for sentence in result.return_object.sentence{
                                for morp in sentence.morp{
                                    if morp.type == "NNG"{
                                        tokens.append(morp.lemma)
                                    }
                                }
                            }
                            completion(tokens)
                        }else{
                            print("ERROR")
                        }
                    }
                }
            }catch{
                //completion([])
            }
        }
    }
}

struct morphologyRequest : Codable{
    //var request_id : String = "reserved field"
    var access_key : String = "api key"
    var argument : morphologyArgument
}

struct morphologyArgument : Codable{
    var analysis_code : String
    var text : String
}

struct morphologyResult : Codable{
    var return_object : morphologyObject
}
struct morphologyObject : Codable{
    var sentence : [morphologySentence]
}

struct morphologySentence : Codable{
    var morp : [morphology]
}

struct morphology : Codable{
    var type : String
    var lemma : String //형태소
}
