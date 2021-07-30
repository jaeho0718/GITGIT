//
//  MemoDetailView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/10.
//

import SwiftUI
import MarkdownUI

struct MemoDetailView: View {
    @EnvironmentObject var viewmodel : ViewModel
    var research : Research
    var repo : Repository
    @State var issue_opt : Issues? = nil
    @State private var editmemo : Bool = false
    @State private var memo : String = ""
    @State private var hash_str : String = ""
    @State private var web_site_url : String = ""
    @State private var new_researches : [Research_Info] = []
    @State private var sof_search_results : [StackOverFlow_item] = []
    var body: some View {
        List{
            if editmemo{
                GroupBox(label: Text("Hash")){
                    TextField("hash", text: $hash_str)
                }.groupBoxStyle(IssueGroupBoxStyle())
            }else{
                ScrollView(.horizontal){
                    LazyHStack{
                        ForEach(viewmodel.Hashtags.filter({$0.tagID == research.tagID})){ tag in
                            Text("# \(tag.tag ?? "no tag")")
                                .foregroundColor(.white)
                                .padding([.leading,.trailing],10).padding([.top,.bottom],5).background(Color.black)
                        }
                    }
                }
            }
            if research.issue_url != nil{
                if let issue = issue_opt{
                    IssueCell(drag_condition:false,issue: issue, repo: repo)
                }else{
                    EmptyIssue()
                }
            }
            GroupBox(label:Text("memo")){
                if editmemo{
                    MarkDownEditor(memo: $memo)
                }else{
                    Markdown("\(memo)")
                }
            }.groupBoxStyle(IssueGroupBoxStyle())
            /*
             if viewmodel.settingValue.recomandSearch{
                 if !(editmemo || sof_search_results.isEmpty){
                     ScrollView(.horizontal,showsIndicators:false){
                         HStack{
                             ForEach(sof_search_results,id:\.question_id){ result in
                                 sofSearchResultView(result)
                             }
                         }
                     }
                 }
             }
             */
            Group{
                ForEach(viewmodel.Sites.filter({$0.tagID == research.tagID})){ site in
                    LinkCell(data: site)
                }.onDelete(perform: deleteResearch)
                ForEach(new_researches){ site in
                    URLCell(research: site)
                        .onTapGesture {
                            if let url = URL(string: site.url_str){
                                NSWorkspace.shared.open(url)
                            }
                        }
                }.onDelete(perform: deleteNewResearch)
                if editmemo{
                    HStack{
                        TextField("url", text: $web_site_url,onCommit:{
                            addResearch(web_site_url)
                            web_site_url = ""
                        })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action:{
                            addResearch(web_site_url)
                            web_site_url = ""
                        }){
                            Image(systemName: "plus")
                        }
                    }
                }
                if viewmodel.Sites.filter({$0.tagID == research.tagID}).isEmpty{
                    Rectangle().foregroundColor(.clear).frame(height:100)
                }
            }.onDrop(of: [.url], delegate: UrlDrop(researches: $new_researches,edit: editmemo, completion: { research_info in
                research_info.getSiteName(completion: {
                    title in
                    viewmodel.saveSite(tagID: research.tagID, name: title, url: research_info.url_str)
                    viewmodel.fetchData()
                })
            }))
            if editmemo{
                HStack{
                    Button(action:{
                        saveNew()
                        editmemo = false
                    }){
                        Text("변경사항 저장하기")
                    }.keyboardShortcut(KeyEquivalent("s"), modifiers: .command)
                }.frame(maxWidth:.infinity)
            }
        }
        .navigationSubtitle(Text(research.name ?? "타이틀을 불러올 수 없음"))
        .onAppear{
            setValue()
        }
        .toolbar{
            ToolbarItem{
                Button(action:{editmemo.toggle()}){
                    Label("편집", systemImage: "slider.horizontal.3")
                }
            }
        }
    }
    
    func addResearch(_ url : String){
        if url.isEmpty{
            //alert = .nourl
        }else{
            new_researches.append(Research_Info(url_str: url))
        }
    }
    func setValue(){
        for hash in viewmodel.Hashtags.filter({$0.tagID == research.tagID}){
            hash_str += "#\(hash.tag ?? "")"
        }
        if let issue_site = research.issue_url{
            let url_seperate = issue_site.components(separatedBy: ["/"])
            viewmodel.getIssueName("https://api.github.com/repos/\(url_seperate[3])/\(url_seperate[4])/issues/\(url_seperate[6])", complication: { value in
                issue_opt = value
            })
        }
        if viewmodel.settingValue.recomandSearch{
            sof_searchReseult(search: "", tag: hash_str, completion: { results in
                self.sof_search_results = results
            })
        }
        memo = research.memo ?? ""
    }
    func deleteNewResearch(at indexSet : IndexSet){
        new_researches.remove(atOffsets: indexSet)
    }
    func deleteResearch(at indexSet : IndexSet){
        let researchs = viewmodel.Sites.filter({$0.tagID == self.research.tagID})
        indexSet.forEach({ index in
            let site = researchs[index]
            viewmodel.deleteData(site)
        })
        viewmodel.fetchData()
    }
    func saveNew(){
        DispatchQueue.main.async {
            for site in new_researches{
                if let index = new_researches.firstIndex(where: {$0.id == site.id}){
                    new_researches.remove(at: index)
                    site.getSiteName(completion: { title in
                        viewmodel.saveSite(tagID: research.tagID, name: title, url: site.url_str)
                    })
                }
            }
            for hash in viewmodel.Hashtags.filter({$0.tagID == research.tagID}){
                viewmodel.deleteData(hash)
            }
            for hash in hash_str.components(separatedBy: ["#"]){
                if hash != ""{
                    viewmodel.saveHash(tagID: research.tagID, tag: hash)
                }
            }
            research.memo = memo
            viewmodel.fetchData()
        }
    }
}

struct sofSearchResultView : View{
    var data : StackOverFlow_item
    init(_ data : StackOverFlow_item) {
        self.data = data
    }
    var body: some View{
        GroupBox(label:Label(data.title, systemImage: "lightbulb")){
            HStack{
                if data.is_answered{
                    Text("Answered").padding(5).foregroundColor(.blue).overlay(Capsule().stroke(lineWidth: 1).foregroundColor(.blue)).padding(2)
                }else{
                    Text("NoAnswered").padding(5).foregroundColor(.red).overlay(Capsule().stroke(lineWidth: 1).foregroundColor(.red)).padding(2)
                }
                ForEach(data.tags,id:\.self){ tag in
                    Text("#\(tag)").opacity(0.7)
                }
            }
        }.groupBoxStyle(sofResultStyle())
        .onTapGesture {
            if let url = URL(string: data.link){
                NSWorkspace.shared.open(url)
            }
        }
        .onDrag({
            return NSItemProvider(object: NSURL(string: data.link)!)
        })
    }
}

