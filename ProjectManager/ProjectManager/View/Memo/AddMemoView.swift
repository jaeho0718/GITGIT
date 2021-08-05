//
//  AddMemoView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/10.
//

import SwiftUI
import MarkdownUI
import AlertToast

struct AddMemoView: View {
    @Binding var addMemo : Bool
    @State private var hash_str : String = ""
    @State private var title : String = ""
    @State private var memo : String = ""
    @State private var selection : Int = 0
    @State private var web_site_url : String = ""
    @State private var alert : alert_type? = nil
    @State private var site : [Site] = []
    @State private var nourl : Bool = false
    @EnvironmentObject var viewmodel : ViewModel
    var repo_ID : String
    private enum alert_type : Identifiable{
        case notitle,nourl
        var id : Int{
            hashValue
        }
    }
    struct Site : Hashable{
        var id : UUID = UUID()
        var title : String
        var url : String
    }
    struct SiteView : View{
        @State private var popOver : Bool = false
        var data : Site
        var body: some View{
            GroupBox{
                Text(data.title).frame(maxWidth:.infinity)
            }.groupBoxStyle(LinkGroupBoxStyle())
            .onTapGesture {
                popOver.toggle()
            }
            .popover(isPresented: $popOver, content:{
                SitePopUp(url: data.url, title: data.title)
            })
        }
    }
    
    var body: some View {
        Form{
            List{
                Section(header: Text("Title")){
                    TextField("타이틀", text: $title)
                }
                Section(header:Text("Hash")){
                    TextField("해시태그", text: $hash_str)
                }
                Section(header:Text("memo")){
                    MarkDownEditor(memo: $memo,repository: viewmodel.Repositories.first(where: {$0.id == repo_ID}))
                }.padding(.bottom,5)
                Section(header:Label("자료", systemImage: "books.vertical"),footer:Label("웹사이트에서 Drag and Drop하여 자료를 추가할 수 있습니다. ", systemImage: "info.circle")){
                    GroupBox{
                        HStack{
                            TextField("url", text: $web_site_url,onCommit:{
                                addResearch(web_site_url)
                                web_site_url = ""
                            })
                                .textFieldStyle(PlainTextFieldStyle())
                            Button(action:{
                                addResearch(web_site_url)
                                web_site_url = ""
                            }){
                                Image(systemName: "plus")
                            }.buttonStyle(AddButtonStyle())
                        }
                    }.groupBoxStyle(LinkGroupBoxStyle())
                    ForEach(site,id:\.id){ data in
                        SiteView(data: data)
                    }.onDelete(perform: deleteSite)
                }.onDrop(of: [.url], delegate: UrlDrop(completion: { url in
                    addResearch(url)
                }))
            }
        }
        .alert(item: $alert, content: { type in
            switch type{
            case .notitle:
                return Alert(title: Text("타이틀은 필수입니다."))
            case .nourl:
                return Alert(title: Text("빈 주소를 추가할 수 없습니다."))
            }
        })
        .frame(minWidth:400)
        .toolbar(content: {
            ToolbarItem{
                Button(action:{
                    if title.isEmpty{
                            
                    }else{
                        DispatchQueue.main.async {
                            let tagID = UUID()
                            viewmodel.saveResearch(tagID:tagID,name: title, memo: memo, repo_ID: repo_ID)
                            for info in site{
                                viewmodel.saveSite(tagID: tagID, name: info.title, url: info.url)
                            }
                            for hash in hash_str.components(separatedBy: ["#"]){
                                if hash != ""{
                                    viewmodel.saveHash(tagID: tagID, tag: hash)
                                }
                            }
                            viewmodel.fetchData()
                        }
                        //NSApplication.shared.keyWindow?.close()
                        addMemo = false
                    }
                }){
                    Text("저장")
                }.buttonStyle(AddButtonStyle())
            }
        })
        .toast(isPresenting: $nourl, alert: {
            AlertToast(displayMode: .alert, type: .regular,subTitle: "빈 URL은 추가할 수 없습니다.")
        })
    }

    func deleteSite(at indexOffset : IndexSet){
        site.remove(atOffsets: indexOffset)
    }
    func addResearch(_ url : String){
        if url.isEmpty{
            nourl = true
        }else{
            DispatchQueue.main.async {
                getSiteName(url_str: url, completion: { title in
                    self.site.append(Site(title: title, url: url))
                })
            }
        }
    }
}

struct AddMemoView_Previews: PreviewProvider {
    static var previews: some View {
        AddMemoView(addMemo: .constant(true), repo_ID: "")
    }
}

struct UrlDrop : DropDelegate{
    let completion : (String)->()
    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: [.url]).first{
            item.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (urlData,error) in
                DispatchQueue.main.async {
                    if let data = urlData as? Data{
                        let url = NSURL(absoluteURLWithDataRepresentation: data, relativeTo: nil) as URL
                        //print(url.absoluteString)
                        //print(url.absoluteString)
                        completion(url.absoluteString)
                    }
                }
            })
            return true
        }else{
            return false
        }
    }
}
