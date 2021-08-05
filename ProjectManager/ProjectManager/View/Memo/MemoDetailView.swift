//
//  MemoDetailView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/10.
//

import SwiftUI
import MarkdownUI
import SwiftSoup
import Alamofire
import AlertToast

struct MemoDetailView: View {
    @EnvironmentObject var viewmodel : ViewModel
    var research : Research
    var repo : Repository
    @State var issue_opt : Issues? = nil
    @State private var editmemo : Bool = false
    @State private var memo : String = ""
    @State private var hash_str : String = ""
    @State private var web_site_url : String = ""
    @State private var sof_search_results : [StackOverFlow_item] = []
    @State private var noURL : Bool = false
    var sites : [Site]{
        return viewmodel.Sites.filter{$0.tagID == research.tagID}.sorted(by:{$0.rate > $1.rate})
    }
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
                    MarkDownEditor(memo: $memo,repository:repo)
                }else{
                    Markdown("\(memo)")
                }
            }.groupBoxStyle(IssueGroupBoxStyle())
            Group{
                if editmemo{
                    GroupBox{
                        HStack{
                            TextField("url", text: $web_site_url,onCommit:{
                                saveSite(web_site_url)
                                web_site_url = ""
                            }).textFieldStyle(PlainTextFieldStyle())
                            Button(action:{
                                saveSite(web_site_url)
                                web_site_url = ""
                            }){
                                Image(systemName: "plus")
                            }
                        }
                    }.groupBoxStyle(LinkGroupBoxStyle()).padding([.top,.bottom],5)
                }
                ForEach(sites){ site in
                    LinkCell(data: site, keyword : viewmodel.Hashtags.filter({$0.tagID == research.tagID}).first?.tag,research: research)
                }.onDelete(perform: deleteResearch)
                if viewmodel.Sites.filter({$0.tagID == research.tagID}).isEmpty{
                    Rectangle().foregroundColor(.clear).frame(height:100)
                }
            }.onDrop(of: [.url], delegate: UrlDrop(completion: { url in
                saveSite(url)
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
        .toast(isPresenting: $noURL, alert: {
            AlertToast(displayMode: .alert, type: .regular,subTitle: "빈 URL은 추가할 수 없습니다.")
        })
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
    func deleteResearch(at indexSet : IndexSet){
        indexSet.forEach({ index in
            let site = sites[index]
            viewmodel.deleteData(site)
        })
        viewmodel.fetchData()
    }
    
    func saveSite(_ url : String){
        if !(url.isEmpty){
            getSiteName(url_str: url, completion: { result in
                viewmodel.saveSite(tagID: research.tagID, name: result,url: url)
                viewmodel.fetchData()
            })
        }else{
            noURL = true
        }
    }
    
    func saveNew(){
        DispatchQueue.main.async {
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

