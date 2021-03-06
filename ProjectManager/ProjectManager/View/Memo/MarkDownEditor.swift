//
//  MarkDownEditor.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/18.
//

import SwiftUI
import HighlightedTextEditor

struct MarkDownEditor: View {
    @Binding var memo : String
    @State private var nowpositoin : Int = 0
    var repository : Repository? = nil
    var filename : String? = nil
    var tool : some View{
        ScrollView(.horizontal,showsIndicators:false){
            HStack(alignment:.center){
                Label("도구", systemImage: "keyboard")
                Button(action:{
                    let s_Index = memo.index(memo.startIndex, offsetBy: nowpositoin)
                    var key = "\n```\n //CODE \n```"
                    if let repo = repository,let language = repo.language{
                        key = "\n```\(language)\n //CODE \n```"
                    }else if let file = filename{
                        key = "\n```\(FileType.getType(file).name)\n //CODE \n```"
                    }
                    memo.insert(contentsOf: key, at: s_Index)
                }){
                    Label("code", systemImage: "chevron.left.slash.chevron.right")
                }
                Button(action:{
                    let s_Index = memo.index(memo.startIndex, offsetBy: nowpositoin)
                    let key = "[SiteName](www.google.com)"
                    memo.insert(contentsOf: key, at: s_Index)
                }){
                    Label("URL", systemImage: "curlybraces.square")
                }
                Button(action:{
                    let s_Index = memo.index(memo.startIndex, offsetBy: nowpositoin)
                    let key = "+ Top\n    + Item1\n    + Item2"
                    memo.insert(contentsOf: key, at: s_Index)
                }){
                    Label("List", systemImage: "list.bullet.indent")
                }
                Button(action:{
                    let s_Index = memo.index(memo.startIndex, offsetBy: nowpositoin)
                    let key = "**TEXT**"
                    memo.insert(contentsOf: key, at: s_Index)
                }){
                    Label("Bold", systemImage: "bold")
                }
                Button(action:{
                    let s_Index = memo.index(memo.startIndex, offsetBy: nowpositoin)
                    let key = "_italic_"
                    memo.insert(contentsOf: key, at: s_Index)
                }){
                    Label("Italic", systemImage: "italic")
                }
                Button(action:{
                    let s_Index = memo.index(memo.startIndex, offsetBy: nowpositoin)
                    let key = "# Title"
                    memo.insert(contentsOf: key, at: s_Index)
                }){
                    Label("Title", systemImage: "textformat.size.larger")
                }
            }
        }
    }
    
    var body: some View {
        GroupBox{
            tool
            HighlightedTextEditor(text: $memo, highlightRules: .markdown)
                .onSelectionChange { (range: NSRange) in
                    nowpositoin = range.location}
                .frame(minHeight:200,maxHeight:500)
            Text("MarkDown 문법을 지원합니다.").font(.caption2)
        }.touchBar(TouchBar {
            tool
        })
    }
}

struct MarkDownEditor_Previews: PreviewProvider {
    static var previews: some View {
        MarkDownEditor(memo: .constant("HelloWorld"))
    }
}
