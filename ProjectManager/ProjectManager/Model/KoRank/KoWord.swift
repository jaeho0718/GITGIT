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
    static func getToken(_ body : String,native : Bool ,language : textRank_Language = .Korean,completion: @escaping ([String])->()){
        if native{
            let tagger = NLTagger(tagSchemes: [.tokenType])
            var tokens : [String] = []
            var newBody = body.lowercased()
            newBody.removeAll(where: {$0 == "*" || $0 == "#" || $0 == ","})
            tagger.string = newBody
            tagger.enumerateTags(in: newBody.startIndex ..< newBody.endIndex, unit: .word, scheme: .tokenType , options: [.omitPunctuation,.omitWhitespace]){ (tag,range) -> Bool in
                if tag == .word{
                    let str = String(newBody[range])
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
            guard let url = URL(string: "http://aiopen.etri.re.kr:8000/WiseNLU") else {return}
            let requestData = morphologyRequest(request_id: "reserved field", access_key: "2b363e71-71a4-4e13-aeae-25d156d9b892", argument: morphologyArgument(analysis_code: "morp", text: body))
            let noun_type = ["NNG","NNP","NP","VV"]
            var tokens : [String] = []
            do{
                let encodedData = try JSONEncoder().encode(requestData)
                var request = URLRequest(url: url)
                request.httpBody = encodedData
                request.httpMethod = "POST"
                let task = URLSession.shared.dataTask(with: request){ (data,response,error) in
                    if let data = data{
                        //print(String(data: data, encoding: .utf8))
                        if let decode_result = try? JSONDecoder().decode(morphologyResult.self, from: data){
                            for sentence in decode_result.return_object.sentence{
                                for morp in sentence.morp{
                                    if noun_type.contains(morp.type){
                                        //print("type : \(morp.type), lemma : \(morp.lemma)")
                                        tokens.append(morp.lemma)
                                    }
                                }
                            }
                            completion(tokens)
                        }else{
                            
                            print("Error to load Morp")
                        }
                    }
                }
                task.resume()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}

struct morphologyRequest : Codable{
    var request_id : String
    var access_key : String
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
