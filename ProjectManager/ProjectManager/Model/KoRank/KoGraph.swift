//
//  KoWordGraph.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/16.
//

import Foundation
import simd
class KoGraph{
    typealias Ko_NodeList = [KoWord : CGFloat]
    var words : [KoWord]
    var edges = [KoWord:Ko_NodeList]() //metrix
    var nodes = Ko_NodeList()
    let windowsize : Int
    let damping : CGFloat
    let epsilon : CGFloat
    let iteration : Int
    init() {
        self.damping = 0.85
        self.epsilon = 0.001
        self.iteration = 20
        self.windowsize = 5
        self.words = []
    }
    
    init(_ words : [KoWord],damping : CGFloat = 0.85,windowsize : Int = 5,epsilon : CGFloat = 0.001,iteration : Int = 20) {
        self.damping = damping
        self.epsilon = epsilon
        self.iteration = iteration
        self.windowsize = windowsize
        self.words = words
    }
}
 
extension KoGraph{
    func getEdge(){
        clear()
        for (i,word1) in words.enumerated(){
            if i+windowsize < words.count{
                for (j,word2) in words[i+1 ..< i+windowsize].enumerated(){
                    if j > words.count{
                        break
                    }else{
                        addEdge(from: word1, to: word2)
                    }
                }
            }
        }
    }
    func setValue(_ node : KoWord, value : CGFloat = 1.0){
        nodes[node] = value
    }
    func addEdge(from a: KoWord, to b: KoWord, withWeight weight: CGFloat = 1.0){
        if weight > 0 {
            for n in [a, b] {
                setValue(n)
            }
            setEdge(from: a, to: b, withWeight: weight)
            setEdge(from: b, to: a, withWeight: weight)
        }
    }
    func setEdge(from a: KoWord, to b: KoWord, withWeight weight: CGFloat){
        if var existingEdges = edges[a] {
            existingEdges[b] = weight
            edges[a] = existingEdges
        } else {
            edges[a] = [b: weight]
        }
    }
    func clear(){
        nodes.removeAll()
        edges.removeAll()
    }
}

extension KoGraph{
    
    func run()->KoGraphResult{
        clear()
        getEdge()
        for i in 0..<iteration{
            let newNodes = runRoundOfPageRank(with: nodes)
            //check Coverage
            if abs(nodes.values.reduce(0.0, +) - newNodes.values.reduce(0.0, +)) < epsilon{
                return KoGraphResult(hasConverge: true, results: newNodes, iteration: i)
            }
            nodes = newNodes
        }
        return KoGraphResult(hasConverge: false, results: nodes, iteration: iteration)
    }
    
    func runRoundOfPageRank(with nodes: Ko_NodeList)->Ko_NodeList{
        var nextNodes = nodes
        for n in nodes.keys{
            let score = getSumOfOutPutValues(n, in: nodes)
            let nodeEdgeWeights = getTotalEdgeWeight(n)
            if nodeEdgeWeights > 0.0 {
                nextNodes[n] = (1-damping) + damping * score / nodeEdgeWeights
            } else {
                nextNodes[n] = 0.0
            }
        }
        return nextNodes
    }
    
    func getTotalEdgeWeight(_ node : KoWord)->CGFloat{
        if let edge = edges[node]{
            return edge.values.reduce(0.0, +)
        }else{
            return 0.0
        }
    }
    
    func getSumOfOutPutValues(_ node: KoWord, in nodelist: Ko_NodeList) -> CGFloat {
        guard let outputs = edges[node] else { return 0.0 }
        return outputs.map({ (nodelist[$0.key] ?? 0.0) * $0.value / getTotalEdgeWeight($0.key)
        }).reduce(0.0, +)
    }
}
