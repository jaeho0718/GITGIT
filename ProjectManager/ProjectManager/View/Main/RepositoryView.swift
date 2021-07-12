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
    var body: some View {
        NavigationView{
            List{
                NavigationLink(destination:GitubPage(repository: repo_data),isActive : $start){
                    Label("Issues", systemImage: "ladybug.fill")
                }
                Section(header:Label("자료", systemImage: "folder.fill")){
                    ForEach(viewmodel.Researchs.filter({$0.id == repo_data.id})){ research in
                        NavigationLink(destination:MemoDetailView(research: research)){
                            HStack{
                                if let _ = research.issue_url{
                                    //이슈와 연결되있으면
                                    Image(systemName: "link")
                                }else{
                                    Image(systemName: "doc.plaintext.fill")
                                }
                                Text(research.name ?? "...")
                            }
                        }
                    }.onDelete(perform: deleteResearchs)
                    if let id = repo_data.id{
                        NavigationLink(destination:AddMemoView(repo_ID:id)){
                            Label("자료 추가하기", systemImage: "plus")
                        }
                    }
                }
                
                Section(header:Label("HashTag", systemImage: "h.square")){
                    ForEach(viewmodel.Hashtags){ hash in
                        NavigationLink(destination:HashDetailView(hash_data: hash)){
                            Text("# \(hash.tag ?? "")").bold().padding([.top,.bottom],5).padding([.leading,.trailing],10).overlay(Capsule().stroke(lineWidth: 1.5)).padding(.leading,3)
                        }
                    }.onDelete(perform: deleteHash)
                }
            }
            
        }.navigationTitle(Text("\(repo_data.name ?? "No Name")"))
    }
    func deleteResearchs(at indexOffset : IndexSet){
        indexOffset.forEach({ index in
            let repo = viewmodel.Researchs[index]
            for hash in viewmodel.Hashtags.filter({$0.tagID == repo.tagID}){
                viewmodel.deleteData(hash)
            }
            for site in viewmodel.Sites.filter({$0.tagID == repo.tagID}){
                viewmodel.deleteData(site)
            }
            viewmodel.deleteData(repo)
        })
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
