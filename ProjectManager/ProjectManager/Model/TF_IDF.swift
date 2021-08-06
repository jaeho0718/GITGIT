//
//  TF_IDF.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/08/03.
//

import Foundation
import NaturalLanguage

class TF_IDF{
    typealias Documents = [Site:[String]]
    
    var sites : [Site]
    var documents = Documents()
    
    init(sites : [Site]) {
        self.sites = sites
    }
    
    private func preset(completion : @escaping ()->()){
        DispatchQueue.global().async {
            for site in self.sites{
                let webCrawler = WebCrawler(site.url ?? "")
                webCrawler.crawl({ body in
                    self.documents[site] = self.getWords(body: body)
                }, failer: {
                    self.documents[site] = self.getWords(body: "")
                })
            }
        }
    }
}

extension TF_IDF{
    
    private func getWords(body : String)->[String]{
        var words : [String] = []
        let tagger = NLTagger(tagSchemes: [.tokenType])
        tagger.string = body
        tagger.enumerateTags(in: body.startIndex ..< body.endIndex, unit: .word, scheme: .tokenType){ (tag,range) -> Bool in
            words.append(String(body[range]))
            return true
        }
        return words
    }
    
    private func tf(site : Site ,keyword : String)->Double{
        if let words = documents[site]{
            return Double(words.filter({$0.contains(keyword)}).count)
        }else{
            return 0.0
        }
    }
    
    private func df(keyword : String)->Double{
        return Double(documents.filter({
            for word in $0.value{
                if word.contains(keyword){
                    return true
                }
            }
            return false
        }).count)
    }
    
    private func idf(keyword : String)->Double{
        if self.documents.count == 0 {
            return 0.0
        }else{
            let totalDocuments = Double(self.documents.count)
            let df_value = self.df(keyword: keyword)
            return log(totalDocuments/(1+df_value))
        }
    }
    
    func getTfIdf(site : Site,keyword : String,completion: @escaping (Double)->()){
        if documents.isEmpty{
            preset(completion:{
                completion(self.tf(site: site, keyword: keyword) * self.idf(keyword: keyword))
            })
        }else{
            completion(tf(site: site, keyword: keyword) * idf(keyword: keyword))
        }
    }
}
