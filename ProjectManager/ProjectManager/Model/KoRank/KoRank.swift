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
    init(_ body : String,damping : CGFloat = 0.85,windowsize : Int = 5,epsilon : CGFloat = 0.001,iteration : Int = 20,language : textRank_Language = .Korean){
        self.damping = damping
        self.epsilon = epsilon
        self.iteration = iteration
        self.windowsize = windowsize
        self.body = body
        self.language = language
    }
}

extension KoRank{
    func BodyToWord()->[KoWord]{
        //let newbody = KoWord.removeStopwords(body, language: language)
        let tokens = KoWord.getToken(body,language: language)
        var words : [KoWord] = []
        for word in tokens{
            words.append(KoWord(word,language:language, index: words.count))
        }
        return words
    }
    func makeGraph()->KoGraph{
        return KoGraph(BodyToWord(), damping: damping, windowsize: windowsize, epsilon: epsilon, iteration: iteration)
    }
    func run()->KoGraphResult{
        let graph = makeGraph()
        return graph.run()
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
