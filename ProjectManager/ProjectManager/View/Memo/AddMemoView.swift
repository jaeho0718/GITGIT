//
//  AddMemoView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/10.
//

import SwiftUI
import MarkdownUI
struct AddMemoView: View {
    @State private var hash_str : String = ""
    @State private var title : String = ""
    @State private var memo : String = ""
    @State private var memo_markdown : String = ""
    @State private var selection : Int = 0
    @State private var web_site_url : String = ""
    @State private var alert : alert_type? = nil
    @State private var researches : [Research_Info] = []
    @EnvironmentObject var viewmodel : ViewModel
    var repo_ID : String
    private enum alert_type : Identifiable{
        case notitle,nourl
        var id : Int{
            hashValue
        }
    }
    var body: some View {
        VStack(alignment:.leading){
            Section(header: Text("Title")){
                TextField("타이틀", text: $title)
            }
            Section(header:Text("Hash")){
                TextField("해시태그", text: $hash_str)
            }
            Section(header:Text("memo"),footer:Label("MarkDown문법을 지원합니다.", systemImage: "info.circle")){
                GroupBox{
                    TabView(selection:$selection){
                        TextEditor(text: $memo).frame(minHeight:100,maxHeight: 500).tabItem { Text("Writing") }.tag(0)
                        Markdown("\(memo_markdown)").frame(minHeight:100,maxHeight: 500).tabItem { Text("Preview") }.tag(1)
                    }.onChange(of: selection, perform: { value in
                        memo_markdown = memo
                    })
                }
            }.padding(.bottom,5)
            Section(header:Label("자료", systemImage: "books.vertical"),footer:Label("웹사이트에서 Drag and Drop하여 자료를 추가할 수 있습니다. ", systemImage: "info.circle")){
                List{
                    ForEach(researches){ research in
                        URLCell(research: research)
                    }.onDelete(perform: deleteResearch)
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
                }.removeBackground()
                .onDrop(of: [.url], delegate: UrlDrop(researches: $researches, completion: { _ in}))
            }
            Spacer()
            HStack{
                Button(action:{
                    if title.isEmpty{
                        alert = .notitle
                    }else{
                        viewmodel.saveResearch(name: title, memo: memo, repo_ID: repo_ID)
                        viewmodel.fetchData()
                    }
                }){
                    Text("저장")
                }
                //.keyboardShortcut(KeyEquivalent("s"), modifiers: .command)
            }.frame(maxWidth:.infinity)
        }.padding()
        .alert(item: $alert, content: { type in
            switch type{
            case .notitle:
                return Alert(title: Text("타이틀은 필수입니다."))
            case .nourl:
                return Alert(title: Text("빈 주소를 추가할 수 없습니다."))
            }
        })
    }
    
    func deleteResearch(at indexSet : IndexSet){
        researches.remove(atOffsets: indexSet)
    }
    
    func addResearch(_ url : String){
        if url.isEmpty{
            alert = .nourl
        }else{
            researches.append(Research_Info(url_str: url))
        }
    }
}

struct AddMemoView_Previews: PreviewProvider {
    static var previews: some View {
        AddMemoView(repo_ID: "")
    }
}

struct UrlDrop : DropDelegate{
    @Binding var researches : [Research_Info]
    var edit : Bool = true
    let completion : (Research_Info)->()
    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: [.url]).first{
            item.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (urlData,error) in
                DispatchQueue.main.async {
                    if let data = urlData as? Data{
                        let url = NSURL(absoluteURLWithDataRepresentation: data, relativeTo: nil) as URL
                        //print(url.absoluteString)
                        //print(url.absoluteString)
                        print(url.absoluteURL.absoluteString)
                        if edit{
                            researches.append(Research_Info(url_str: url.absoluteString))
                        }else{
                            let research_info = Research_Info(url_str: url.absoluteString)
                            completion(research_info)
                        }
                    }
                }
            })
            return true
        }else{
            return false
        }
    }
}

struct URLCell : View{
    var research : Research_Info
    @State private var site_name : String = ""
    var body: some View{
        GroupBox{
            HStack{
                Text(site_name).padding(.leading,3)
                Spacer()
            }.frame(maxWidth:.infinity)
        }.onAppear{
            research.getSiteName(completion: { title in
                site_name = title
            })
        }
    }
}
