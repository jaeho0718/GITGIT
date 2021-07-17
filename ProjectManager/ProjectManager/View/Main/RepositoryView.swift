//
//  RepositoryView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import SwiftUI

struct RepositoryView: View {
    var repo_data : Repository
    @EnvironmentObject var viewmodel : ViewModel
    @State private var start : Bool = true
    @State private var addMemo : Bool = false
    var researchs : [Research]{
        return viewmodel.Researchs.filter({$0.id == repo_data.id})
    }
    var body: some View {
        NavigationView{
            List{
                NavigationLink(destination:GithubCode(repository: repo_data),isActive : $start){
                    Label("Files", systemImage: "ladybug.fill")
                }
                NavigationLink(destination:GitubPage(repository: repo_data)){
                    Label("Issues", systemImage: "ladybug.fill")
                }
                Section(header:Label("자료", systemImage: "folder.fill")){
                    ForEach(researchs,id:\.tagID){ research in
                        Research_Cell(research: research, repo: repo_data)
                    }.onDelete(perform: deleteResearchs)
                    if let id = repo_data.id{
                        NavigationLink(destination:AddMemoView(addMemo: $addMemo, repo_ID:id),isActive:$addMemo){
                            Label("자료 추가하기", systemImage: "plus")
                        }
                    }
                }.onDrop(of: [.url], delegate: IssueDrop(completion: {
                    url in
                    if url.contains("github.com") && url.contains("\(repo_data.name ?? "")") && url.contains("issues"){
                        //데이터 유형이 일치하지 않음
                        let url_seperate = url.components(separatedBy: ["/"])
                        viewmodel.getIssueName("https://api.github.com/repos/\(url_seperate[3])/\(url_seperate[4])/issues/\(url_seperate[6])", complication: { value in
                            viewmodel.saveResearch(name: "Issue #\(value.number) : \(value.title)", memo: "\(value.body)", repo_ID: repo_data.id ?? "",issue_url: value.html_url)
                            viewmodel.fetchData()
                        })
                    }
                }))
                /*
                 Section(header:Label("HashTag", systemImage: "h.square")){
                     ForEach(viewmodel.Hashtags){ hash in
                         NavigationLink(destination:HashDetailView(hash_data: hash)){
                             Text("# \(hash.tag ?? "")").bold().padding([.top,.bottom],5).padding([.leading,.trailing],10).overlay(Capsule().stroke(lineWidth: 1.5)).padding(.leading,3)
                         }
                     }
                 }
                 */
            }
        }.navigationTitle(Text("\(repo_data.name ?? "No Name")"))
    }
    func deleteResearchs(at indexOffset : IndexSet){
        DispatchQueue.main.async {
            indexOffset.forEach({ index in
                let repo = viewmodel.Researchs[index]
                for hash in viewmodel.Hashtags.filter({$0.tagID == repo.tagID}){
                    viewmodel.deleteData(hash)
                }
                for site in viewmodel.Sites.filter({$0.tagID == repo.tagID}){
                    viewmodel.deleteData(site)
                }
                viewmodel.deleteData(repo)
                viewmodel.fetchData()
            })
        }
    }
    func deleteHash(at indexOffset : IndexSet){
        DispatchQueue.main.async {
            indexOffset.forEach({index in
                let hash = viewmodel.Hashtags[index]
                viewmodel.deleteData(hash)
            })
        }
    }
}

struct IssueDrop : DropDelegate{
    var completion : (String)->()
    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: [.url]).first{
            item.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (urlData,error) in
                if let data = urlData as? Data{
                    let url = NSURL(absoluteURLWithDataRepresentation: data, relativeTo: nil) as URL
                    //print(url.absoluteURL.absoluteString)
                    completion(url.absoluteURL.absoluteString)
                }
            })
            return true
        }else{
            return false
        }
    }
}

struct Research_Cell : View{
    @EnvironmentObject var viewmodel : ViewModel
    var research : Research
    var repo : Repository
    @State private var show : Bool = false
    var body: some View{
        NavigationLink(destination: MemoDetailView(research: research, repo: repo),isActive: $show){
            HStack{
                if let _ = research.issue_url{
                    //이슈와 연결되있으면
                    Image(systemName: "link")
                }else{
                    Image(systemName: "doc.plaintext.fill")
                }
                Text(research.name ?? "...")
            }
        }.contextMenu(menuItems: {
            Button(action:{deleteResearchs(research: research)}){
                Text("Delete")
            }
        })
    }
    func deleteResearchs(research : Research){
        DispatchQueue.main.async {
            for hash in viewmodel.Hashtags.filter({$0.tagID == research.tagID}){
                viewmodel.deleteData(hash)
            }
            for site in viewmodel.Sites.filter({$0.tagID == research.tagID}){
                viewmodel.deleteData(site)
            }
            viewmodel.deleteData(research)
            viewmodel.fetchData()
        }
    }
}
