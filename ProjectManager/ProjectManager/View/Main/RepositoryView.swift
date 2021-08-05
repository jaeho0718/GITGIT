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
    @State var addMemo : Bool = false
    var researchs : [Research]{
        return viewmodel.Researchs.filter({$0.id == repo_data.id})
    }
    var body: some View {
        NavigationView{
            List{
                NavigationLink(destination:GithubCode(repository: repo_data),isActive : $start){
                    Label(
                        title: { Text("Files") },
                        icon: { Image("folder").resizable().aspectRatio(contentMode: .fit).frame(width:15,height:15)}
                    )
                }
                NavigationLink(destination:GitubPage(repository: repo_data)){
                    Label(
                        title: { Text("Issues") },
                        icon: { Image(systemName:"exclamationmark.square.fill").resizable().aspectRatio(contentMode: .fit).frame(width:15,height:15)
                            .foregroundColor(.orange)
                        }
                    )
                }
                NavigationLink(destination: CommitsView(repository: repo_data)){
                    Label(
                        title: { Text("Commits") },
                        icon: { Image("commit").resizable().aspectRatio(contentMode: .fit).frame(width:15,height:15)
                            .foregroundColor(.orange)
                        }
                    )
                }
                Divider()
                Section(header:
                    Label(title: {
                        HStack{
                            Text("자료")
                            Spacer()
                        }
                    }, icon: {
                            Image(systemName: "folder.fill")
                    })
                ){
                    ForEach(researchs,id:\.tagID){ research in
                        Research_Cell(research: research, repo: repo_data)
                    }.onDelete(perform: deleteResearchs)
                    if let id =  repo_data.id{
                        NavigationLink(destination:AddMemoView(addMemo: $addMemo, repo_ID: id)){
                            Label("자료 추가", systemImage: "plus.circle")
                        }.accentColor(.secondary)
                        .onDrop(of: [.data], delegate: IssueDrop(completion: { value in
                            DispatchQueue.main.async {
                                if let id = repo_data.id{
                                    viewmodel.saveResearch(name: value.title, memo: value.body, repo_ID: id, issue_url : value.html_url)
                                    viewmodel.fetchData()
                                }
                            }
                        }))
                    }
                }
                /*
                 Section(header:Label("HashTag", systemImage: "h.square")){
                     ForEach(viewmodel.Hashtags){ hash in
                         NavigationLink(destination:HashDetailView(hash_data: hash)){
                             Text("# \(hash.tag ?? "")").bold().padding([.top,.bottom],5).padding([.leading,.trailing],10).overlay(Capsule().stroke(lineWidth: 1.5)).padding(.leading,3)
                         }
                     }
                 }
                 */
                Divider()
                Section(header:Label(
                    title: { Text("CODE REVIEW") },
                    icon: { Image("codefile").resizable().aspectRatio(contentMode: .fit).frame(width:15,height:15)}
                ),footer:Text("Files에서 드래그앤 드롭을 통해 파일을 추가할 수 있습니다.").font(.caption2).opacity(0.5)){
                    ForEach(viewmodel.Codes.filter({$0.repo_id == repo_data.id})){ code in
                        CodeReviews_Cell(code: code)
                    }.onDelete(perform: deleteCodeReviews)
                }.onDrop(of: [.data], delegate:CodeDrop(completion: { file in
                    DispatchQueue.main.async {
                        if let id = repo_data.id{
                            viewmodel.getGitCode(repo_data,path: "\(file.path)", completion: { str in
                                if let code = try? NSAttributedString(data:  Data(str.utf8), options: [.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil){
                                    viewmodel.saveCode(repo_id: id, title: file.name, path: file.path, code: code.string)
                                    viewmodel.fetchData()
                                }
                            })
                        }
                    }
                }))
                Divider()
                Section(header:
                    Label(
                        title: { Text("tags") },
                        icon: { Image(systemName:"tag.circle").resizable().aspectRatio(contentMode: .fit).frame(width:15,height:15)}
                    )
                ){
                    ForEach(viewmodel.Hashtags.filter{ tags in
                        for research in viewmodel.Researchs.filter({$0.tagID == tags.tagID}){
                            if research.id == repo_data.id{
                                return true
                            }
                        }
                        return false
                    }){ hashtag in
                        NavigationLink(destination:HashTagView(repo: repo_data, tag: hashtag)){
                            Label(hashtag.tag ?? "", systemImage: "tag.fill").accentColor(.black)
                        }
                    }
                }
            }
        }.navigationTitle(Text("\(repo_data.name ?? "No Name")"))
        .onAppear{
            viewmodel.nowRepository = repo_data
        }
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
            })
            viewmodel.fetchData()
        }
    }
    func deleteHash(at indexOffset : IndexSet){
        DispatchQueue.main.async {
            indexOffset.forEach({index in
                let hash = viewmodel.Hashtags[index]
                viewmodel.deleteData(hash)
            })
            viewmodel.fetchData()
        }
    }
    func deleteCodeReviews(at indexOffset : IndexSet){
        DispatchQueue.main.async {
            indexOffset.forEach({ index in
                let CodeReviews = viewmodel.Codes.filter{$0.repo_id == repo_data.id}[index]
                for review in viewmodel.CodeReviews.filter({$0.reviewID == CodeReviews.reviewID}){
                    viewmodel.deleteData(review)
                }
                viewmodel.deleteData(CodeReviews)
            })
            viewmodel.fetchData()
        }
    }
}

struct IssueDrop : DropDelegate{
    var completion : (Issues)->()
    var filer : ()->() = {}
    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: [.data]).first{
            item.loadDataRepresentation(forTypeIdentifier: "public.data", completionHandler: { (data,error) in
                if let DATA = data{
                    if let file = try? JSONDecoder().decode(Issues.self, from: DATA){
                        completion(file)
                    }else{
                        filer()
                    }
                }else{
                    filer()
                }
            })
            return true
        }else{
            return false
        }
    }
}

struct CodeDrop : DropDelegate{
    var completion : (GitFile)->()
    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: [.data]).first{
            item.loadDataRepresentation(forTypeIdentifier: "public.data", completionHandler: { (data,error) in
                if let DATA = data{
                    if let file = try? JSONDecoder().decode(GitFile.self, from: DATA){
                        completion(file)
                    }
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
    @State private var edit : Bool = false
    @State private var editname : String = ""
    var body: some View{
        NavigationLink(destination: MemoDetailView(research: research, repo: repo),isActive: $show){
            HStack{
                if let _ = research.issue_url{
                    //이슈와 연결되있으면
                    Image(systemName: "link")
                }else{
                    Image(systemName: "doc.plaintext.fill")
                }
                if edit{
                    TextField("", text: $editname,onCommit:{
                        research.name = editname
                        DispatchQueue.main.async {
                            viewmodel.fetchData()
                        }
                        edit = false
                    })
                }else{
                    Text(research.name ?? "...")
                }
            }
        }.contextMenu(menuItems: {
            Button(action:{deleteResearchs(research: research)}){
                Text("Delete")
            }
            Button(action:{
                edit = true
            }){
                Text("Edit name")
            }
        })
        .onAppear{
            editname = research.name ?? ""
        }
        
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

struct CodeReviews_Cell : View{
    var code : Code
    var body: some View{
        NavigationLink(destination:CodeReview(data: code)){
            HStack{
                FileType.getType(code.title ?? "").getImage().resizable().aspectRatio(contentMode: .fit).frame(width:15,height:15)
                Text(code.title ?? "")
            }
        }
    }
}
