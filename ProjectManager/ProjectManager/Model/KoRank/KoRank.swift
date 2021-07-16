//
//  Ko_Rank.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/16.
//

import Foundation

public class KoRank{
    var text : String{
        didSet{
            textToWords()
        }
    }
    public var graph: KoGraph
    public var words = [Ko_Word]()
    public var summarizationFraction: Float = 0.2
    public var graphDamping: Float = 0.85
    public var stopwords = [String]() {
        didSet {
            textToWords()
        }
    }
    
    public init() {
        text = ""
        graph = KoGraph(damping: graphDamping)
    }
    
    public init(text : String){
        self.text = text
        graph = KoGraph(damping: graphDamping)
        textToWords()
    }
    
    public init(text: String, summarizationFraction: Float = 0.2, graphDamping: Float = 0.85){
        self.text = text
        self.summarizationFraction = summarizationFraction
        self.graphDamping = graphDamping
        graph = KoGraph(damping: graphDamping)
        textToWords()
    }
    
    func textToWords(){
        words = KoRank.splitIntoWords(text,additionalStopwords: stopwords).filter{$0.length > 0}
    }
}

extension KoRank{
    public func runTextRank() throws -> KoGraph.KoWordRankResult{
        buildGraph()
        return try graph.runWordRank()
    }
    
    func buildGraph(){
        graph.clearGraph()
        var numberOfErrors = 0
        for (i,s1) in words.enumerated(){
            for s2 in words[(i+1) ..< words.count]{
                do{
                    try graph.addEdge(from: s1, to: s2)
                }catch{
                    numberOfErrors += 1
                }
            }
        }
    }
}

extension KoRank{
    static func splitIntoWords(_ text : String,additionalStopwords stopwords : [String] = Stopwords.Korean) -> [Ko_Word]{
        if text.isEmpty{
            return []
        }
        let removedtext = Ko_Word.removeStopWords(from: text, additionalStopwords: stopwords) //remove stopword
        var x = [Ko_Word]()
        removedtext.enumerateSubstrings(in: removedtext.startIndex ..< removedtext.endIndex, options: [.byWords,.localized]){ substring,_,_,_ in
            if let substring = substring, !substring.isEmpty{
                x.append(Ko_Word(text: substring, originalTextIndex: x.count))
            }
        }
        return x
    }
}
