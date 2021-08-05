//
//  WebCrawling.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/29.
//

import Foundation
import SwiftSoup

class WebCrawler{
    var url_str : String{
        didSet{
            setURL()
        }
    }
    var url : URL?
    
    init(_ url : String) {
        self.url_str = url
        setURL()
    }
    
    func setURL(){
        self.url = URL(string: self.url_str)
    }
}

extension WebCrawler{
    //#posts > article > div.post-body
    func crawl(_ completion : @escaping (String)->(),failer : @escaping ()->() = {}){
        do {
            if let url = self.url{
                let html = try String(contentsOf: url, encoding: .utf8)
                let doc : Document = try SwiftSoup.parse(html)
                let result = try doc.select("div").select("p")
                var body : String = ""
                for entry in result.array(){
                    body += try entry.text()
                }
                completion(body)
            }
        }catch let error{
            failer()
            print("\(error.localizedDescription)")
        }
    }
}
