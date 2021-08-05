//
//  Ko_Rank.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/16.
//

import Foundation

class WordRank{
    var damping : Float
    var window : Int
    var body : String
    var graph : WordGraph
    var native : Bool
    
    init(_ body : String,native : Bool = true,window : Int = 5,damping : Float = 0.85) {
        self.body = body
        self.window = window
        self.damping = damping
        self.native = native
        self.graph = WordGraph(window: self.window, damping: self.damping, epsilon: 0.0001)
    }
}

extension WordRank{
    func splitBody(_ completion : @escaping ([Word])->()){
        Word.splitWord(self.body,native: self.native, completion: { result in
            completion(result)
        })
    }
    
    func run(_ maxIteration : Int,completion : @escaping (WordGraph.GraphResult)->()){
        splitBody({ result in
            self.graph.createGraph(result)
            let graphresult = self.graph.run(maxIteration)
            completion(graphresult)
        })
    }
}
