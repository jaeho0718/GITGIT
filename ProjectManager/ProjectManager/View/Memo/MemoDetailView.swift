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
    @State private var editmemo : Bool = false
    @State private var memo : String = ""
    @State private var web_site_url : String = ""
    @State private var new_researches : [Research_Info] = []
    var body: some View {
        Form{
            Section(header:Text("Hash")){
                ScrollView(.horizontal){
                    HStack{
                        ForEach(viewmodel.Hashtags.filter({$0.tagID == research.tagID})){ tag in
                            Button(action:{}){
                                Text("#\(tag.tag ?? "no tag")")
                            }
                        }
                    }
                }
            }
            Section(header:Text("memo")){
                GroupBox{
                    if editmemo{
                        TextEditor(text: $memo)
                    }else{
                        Markdown("\(memo)")
                    }
                }
            }.padding(.bottom,3)
            Section(header:Label("자료", systemImage: "books.vertical"),footer:Label("웹사이트에서 Drag and Drop하여 자료를 추가할 수 있습니다. ", systemImage: "info.circle")){
                List{
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
                }.onDrop(of: [.url], delegate: UrlDrop(researches: $new_researches,edit: editmemo))
            }
            if editmemo{
                HStack{
                    Button(action:{
                        saveNew()
                        withAnimation(.spring()){
                            editmemo = false
                        }
                    }){
                        Text("변경사항 저장하기")
                    }.keyboardShortcut(KeyEquivalent("s"), modifiers: .command)
                }.frame(maxWidth:.infinity)
            }
        }
        .padding()
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
            research.memo = memo
            viewmodel.updateData()
        }
    }
}


