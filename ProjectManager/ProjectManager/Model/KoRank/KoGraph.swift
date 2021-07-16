//
//  KoWordGraph.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/16.
//

import Foundation

public class KoGraph {
    public typealias WordList = [Ko_Word : Float]
    
    public var damping : Float = 0.85
    public var epsilon : Float = 0.0001
    
    public var nodes = WordList()
    public var edges = [Ko_Word:WordList]()
    
    public init(){}
    
    public init(damping : Float){
        self.damping = damping
    }
    
    public init(damping : Float, epsilon : Float){
        self.damping = damping
        self.epsilon = epsilon
    }
    
    enum KoGraphError : Error,LocalizedError{
        case NonpositiveEdgeWeight(value : Float)
        
        public var errorDescription: String?{
            switch self {
            case let .NonpositiveEdgeWeight(value):
                return NSLocalizedString("Negative edge weights (\(value)) are not allowed.", comment: "")
            }
        }
    }
    
    public func addEdge(from a : Ko_Word,to b : Ko_Word, withWeight weight : Float = 1.0) throws {
        if weight <= 0 {
            throw KoGraphError.NonpositiveEdgeWeight(value: weight)
        }else{
            for n in [a,b]{
                setValue(of: n)
            }
            setEdge(from: a, to: b, withWeight: weight)
            setEdge(from: b, to: a, withWeight: weight)
        }
    }
    
    func setValue(of node : Ko_Word, value : Float = 1.0){
        nodes[node] = value
    }
    
    func setEdge(from a : Ko_Word,to b : Ko_Word, withWeight weight : Float){
        if var existingEndges = edges[a]{
            existingEndges[b] = weight
            edges[a] = existingEndges
        } else {
            edges[a] = [b : weight]
        }
    }
    
    public func getValue(of node : Ko_Word) -> Float{
        return nodes[node] ?? 0.0
    }
    
    public func getEdgeWeight(from a : Ko_Word,to b : Ko_Word) -> Float{
        if let edges = edges[a]{
            return edges[b] ?? 0.0
        }
        return 0.0
    }
    
    public func getTotalEdgeWeight(of node : Ko_Word) -> Float{
        if let edges = edges[node]{
            return edges.values.reduce(0.0, +)
        }
        return 0.0
    }
    
    public func getNumberOfEdges(from node : Ko_Word) -> Int{
        return edges[node]?.count ?? 0
    }
    
    public func clearGraph(){
        nodes.removeAll()
        edges.removeAll()
    }
}

extension KoGraph{
    public struct KoWordRankResult{
        public let didConverge : Bool
        public let iteraitons : Int
        public let results : WordList
    }
    
    public enum KoWordRankerror : Error{
        case EmptyNodelist,EmptyEdgeList
    }
    
    public func runWordRank(maximumIteraions : Int = 100) throws -> KoWordRankResult{
        if nodes.isEmpty{
            throw KoWordRankerror.EmptyNodelist
        }else if edges.isEmpty{
            throw KoWordRankerror.EmptyEdgeList
        }
        setInitialNodeValues()
        for i in 0 ..< maximumIteraions{
            let newNodes = runRoundOfWordRank(with: nodes)
            if hasConverged(nodes, newNodes){
                return KoWordRankResult(didConverge: true, iteraitons: i, results: newNodes)
            }
            nodes = newNodes
        }
        return KoWordRankResult(didConverge: false, iteraitons: maximumIteraions, results: nodes)
    }
    
    public func runRoundOfWordRank(with node : WordList) -> WordList{
        var nextNodes = nodes
        let dampingConstant : Float = (1-damping) / Float(nodes.count)
        for n in nodes.keys{
            let score = getSumOfNeighborValues(n, in: nodes)
            let nodeEdgeWeights = getTotalEdgeWeight(of: n)
            if nodeEdgeWeights > 0.0{
                nextNodes[n] = dampingConstant + damping * score / nodeEdgeWeights
            }else {
                nextNodes[n] = 0.0
            }
        }
        return nextNodes
    }
    
    func getSumOfNeighborValues(_ node : Ko_Word,in nodelist : WordList) -> Float{
        guard let neighbors = edges[node] else {return 0.0}
        return neighbors
            .map{ (nodelist[$0.key] ?? 0.0) * $0.value / getTotalEdgeWeight(of: $0.key) }
            .reduce(0.0, +)
    }
    
    func setInitialNodeValues(){
        let initialValue : Float = 1.0 / Float(nodes.count)
        for n in nodes.keys{
            nodes[n] = initialValue
        }
    }
    
    func hasConverged(_ n0 : [Ko_Word : Float],_ n1 :  [Ko_Word : Float]) -> Bool{
        for (node,node0value) in n0{
            if let node1Value = n1[node]{
                if abs(node0value - node1Value) > epsilon{
                    return false
                }
            }
        }
        return true
    }
}
