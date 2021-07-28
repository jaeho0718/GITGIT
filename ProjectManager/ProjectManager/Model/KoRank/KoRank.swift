//
//  Ko_Rank.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/16.
//

import Foundation

class KoRank{
    let windowsize : Int
    let damping : CGFloat
    let epsilon : CGFloat
    let iteration : Int
    let body : String
    let language : textRank_Language
    let native : Bool
    init(_ body : String,native : Bool = true,damping : CGFloat = 0.85,windowsize : Int = 5,epsilon : CGFloat = 0.001,iteration : Int = 20,language : textRank_Language = .Korean){
        self.damping = damping
        self.epsilon = epsilon
        self.iteration = iteration
        self.windowsize = windowsize
        self.body = body
        self.language = language
        self.native = native
    }
}

extension KoRank{
    func BodyToWord(_ completion : @escaping ([KoWord])->()){
        //let newbody = KoWord.removeStopwords(body, language: language)
        KoWord.getToken(body,native : native, language: language ,completion: { token in
            var tokens : [String] = []
            tokens = token
            var words : [KoWord] = []
            for word in tokens{
                words.append(KoWord(word,language:self.language, index: words.count))
            }
            completion(words)
        })
    }
    func makeGraph(_ completion : @escaping (KoGraph)->()){
        BodyToWord({ result in
            let graph = KoGraph(result, damping: self.damping, windowsize: self.windowsize, epsilon: self.epsilon, iteration: self.iteration)
            completion(graph)
        })
    }
    func run(_ completion : @escaping (KoGraphResult)->()){
        makeGraph({ graph in
            let result = graph.run()
            completion(result)
        })
    }
}

struct KoGraphResult{
    var hasConverge : Bool
    var results : KoGraph.Ko_NodeList
    var iteration : Int
    var keyword : String{
        let nodes = results.sorted(by: {$0.value > $1.value})
        if let key = nodes.first{
            return key.key.word
        }else{
            return "No KeyWord"
        }
    }
}
