//
//  KoWord.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/16.
//

import Foundation
import NaturalLanguage
import Alamofire

struct Word:Hashable{
    var id : Int
    var raw : String
    
    static func splitWord(_ body : String,native : Bool = true,completion : @escaping ([Word])->()){
        if native{
            let tagger = NLTagger(tagSchemes: [.tokenType])
            var words : [Word] = []
            tagger.string = body
            tagger.enumerateTags(in: body.startIndex..<body.endIndex, unit: .word, scheme: .tokenType, options: [.omitWhitespace,.omitPunctuation,.omitOther]){ (tag,range) -> Bool in
                if !isStopWord(String(body[range])){
                    words.append(Word(id: words.count, raw: String(body[range])))
                }
                return true
            }
            completion(words)
        }else{
            guard let url = URL(string: "http://aiopen.etri.re.kr:8000/WiseNLU") else {return }
            let requestData = morphologyRequest(request_id: "reserved field", access_key: "", argument: morphologyArgument(analysis_code: "morp", text: body))
            let noun_type = ["NNG","NNP","NP","VV"]
            var tokens : [String] = []
            var words : [Word] = []
            do{
                let encodedData = try JSONEncoder().encode(requestData)
                var request = URLRequest(url: url)
                request.httpBody = encodedData
                request.httpMethod = "POST"
                let task = URLSession.shared.dataTask(with: request){ (data,response,error) in
                    if let data = data{
                        do{
                            let decode_result = try JSONDecoder().decode(morphologyResult.self, from: data)
                            for sentence in decode_result.return_object.sentence{
                                for morp in sentence.morp{
                                    if noun_type.contains(morp.type){
                                        tokens.append(morp.lemma)
                                    }
                                }
                            }
                            for (i,value) in tokens.enumerated(){
                                words.append(Word(id: i, raw: value))
                            }
                        }catch let error{
                            print(error.localizedDescription)
                        }
                    }
                }
                task.resume()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    static func isStopWord(_ word : String)->Bool{
        return Stopwords.English.contains(word) || Stopwords.Korean.contains(word)
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
