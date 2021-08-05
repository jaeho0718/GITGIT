//
//  KoWordGraph.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/16.
//

import Foundation

class WordGraph{
    typealias nodeList = [Word:Float]
    var window : Int
    var nodes = nodeList()
    var edges = [Word:nodeList]()
    var damping : Float
    var epsilon : Float
    
    init(window : Int,damping : Float = 0.85,epsilon : Float = 0.0001) {
        self.window = window
        self.damping = damping
        self.epsilon = epsilon
    }
    
    struct GraphResult{
        var converged : Bool
        var iteration : Int
        var nodes : nodeList
        var keyword : String{
            return nodes.sorted(by: {$0.value > $1.value}).first?.key.raw ?? "Null"
        }
    }
}

extension WordGraph{
    
    func clearGraph(){
        nodes.removeAll()
        edges.removeAll()
    }
    
    func initializeNode(_ words : [Word]){
        //let initialValue : Float = 1 / Float(words.count)
        for word in words{
            nodes[word] = 1.0
        }
    }
    
    func initializeEdges(){
        for node in nodes{
            let neighborNodes = nodes.filter{abs($0.key.id-node.key.id) < self.window && $0.key.id != node.key.id} as nodeList
            edges[node.key] = neighborNodes
        }
    }
    
    func createGraph(_ words : [Word]){
        clearGraph()
        initializeNode(words)
        initializeEdges()
    }
    
    func run(_ iteration : Int = 20)->GraphResult{
        for i in 1...iteration{
            let priorNodes = nodes
            for node in nodes{
                nodes[node.key] = computeVertexScore(node.key)
            }
            if hasConverged(n1: nodes, n2: priorNodes){
                return GraphResult(converged: true, iteration: i, nodes: nodes)
            }
        }
        return GraphResult(converged: false, iteration: iteration, nodes: nodes)
    }
    
    func computeVertexScore(_ word : Word)->Float{
        guard let inners = edges[word] else {return 0.0}
        let constant : Float = (1-damping)/Float(nodes.count)
        var innerSum : Float = 0.0
        for inner in inners{
            // get innerSum
            guard let outNumber = edges[inner.key]?.count else {return 0.0}
            let score = getVertexScore(inner.key)
            innerSum += (score/Float(outNumber))
        }
        return constant + innerSum*damping
    }
    
    func getVertexScore(_ word : Word)->Float{
        return nodes[word] ?? 0.0
    }
    
    func getTotalVertexScore(_ vertex : nodeList)->Float{
        return vertex.reduce(0, {$0+$1.value})
    }
    
    func hasConverged(n1 : nodeList, n2 : nodeList)->Bool{
        return abs(getTotalVertexScore(n1)-getTotalVertexScore(n2)) < epsilon
    }
}
