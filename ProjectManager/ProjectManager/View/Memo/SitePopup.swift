//
//  SitePopIp.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/31.
//

import Foundation
import SwiftUI
import AlertToast

struct SitePopUp : View{
    var url : String
    var title : String
    @State private var summary : String = ""
    @State private var keyword : [String] = []
    @State private var onLoad : Bool = true
    var body: some View{
        VStack(alignment:.leading){
            Text(title).font(.title).bold()
            if !onLoad{
                ScrollView(.vertical){
                    Text(summary)
                }
                ScrollView(.horizontal){
                    HStack{
                        ForEach(keyword,id:\.self){ word in
                            Text("#\(word)").font(.callout).foregroundColor(.secondary)
                        }
                    }
                }
            }else{
                Spacer()
            }
            HStack{
                Text("요약된 글입니다.").foregroundColor(.secondary).font(.callout)
                Spacer()
                Button(action:{
                    if let url = URL(string: url){
                        NSWorkspace.shared.open(url)
                    }
                }){
                    Text("웹 사이트 열기")
                }
            }
        }.frame(minWidth:200,maxWidth:400,minHeight: 300,maxHeight: 500).padding()
        .onAppear{
            set()
        }
        .toast(isPresenting: $onLoad, alert: {
            AlertToast(displayMode: .alert, type: .loading)
        })
    }
    private func set(){
        DispatchQueue.main.async {
            let crawling = WebCrawler(url)
            crawling.crawl({ result in
                let textRank = TextRank(text: result)
                do{
                    let rankedResults = try textRank.runPageRank()
                    let sentences = rankedResults.results.sorted(by: {$0.value > $1.value}).map({$0.key.text})
                    if sentences.count < 6{
                        var rank : String = ""
                        for sentence in sentences{
                            rank += sentence
                        }
                        summary = rank
                    }else{
                        var rank : String = ""
                        for sentence in sentences[sentences.startIndex..<sentences.startIndex+5]{
                            rank += sentence
                        }
                        summary = rank
                    }
                    let rankModel = WordRank(result,window: 8)
                    rankModel.run(100, completion: { keywords in
                        let words = keywords.nodes.sorted(by: {$0.value > $1.value}).map({$0.key}).map({$0.raw})
                        if words.count < 3{
                            keyword = words
                        }else{
                            keyword = Array(words[words.startIndex ..< words.startIndex+3])
                        }
                        onLoad = false
                    })
                }catch{
                    onLoad = false
                }
            }, failer: {
                onLoad = false
            })
        }
    }
}
