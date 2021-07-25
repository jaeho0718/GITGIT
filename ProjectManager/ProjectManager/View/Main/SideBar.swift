//
//  SideBar.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import SwiftUI

struct SideBar: View {
    @EnvironmentObject var viewmodel : ViewModel
    @SceneStorage("pin") var pin : Bool = true
    @SceneStorage("repository") var repository : Bool = true
    @State private var home : Bool = true
    var body: some View {
        NavigationView{
            Form{
                List{
                    NavigationLink(destination: HomeView(),isActive:$home){
                        Label("Home", systemImage: "house.fill")
                    }.accentColor(.gray)
                    NavigationLink(destination:GithubGist()){
                        Label("GITHUB GIST", systemImage: "chevron.left.slash.chevron.right")
                    }.accentColor(.gray)
                    DisclosureGroup(isExpanded: $pin, content: {
                        if viewmodel.Repositories.isEmpty{
                            Text("Github의 레퍼토리를 불러올 수 없습니다.").font(.caption)
                        }else{
                            ForEach(viewmodel.Repositories.filter({$0.pin}),id:\.id){ repository in
                                RepositoryCell(data: repository)
                            }
                        }
                    }, label: {
                        Label("Favorite", systemImage: "star.fill")
                    }).accentColor(.gray)
                    DisclosureGroup(isExpanded: $repository, content: {
                        if viewmodel.Repositories.isEmpty{
                            Text("Github의 레퍼토리를 불러올 수 없습니다.").font(.caption)
                        }else{
                            ForEach(viewmodel.Repositories.filter({!($0.pin)}),id:\.id){ repository in
                                RepositoryCell(data: repository)
                            }
                        }
                    }, label: {
                        Label("Repositroy", systemImage: "doc.fill")
                    }).accentColor(.gray)
                }
            }.frame(minWidth:300)
            .listStyle(SidebarListStyle())
            .navigationTitle("Title")
            .toolbar{
                ToolbarItem{
                    Button(action:{
                        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                    }){
                        Image(systemName: "sidebar.left")
                    }
                }
                ToolbarItem{
                    Button(action:{
                        DispatchQueue.main.async {
                            viewmodel.fetchData()
                        }
                    }){
                        Label("refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct SideBar_Previews: PreviewProvider {
    static var previews: some View {
        SideBar().environmentObject(ViewModel())
    }
}

struct RepositoryCell : View{
    var data : Repository
    @EnvironmentObject var viewmodel : ViewModel
    var body: some View{
        HStack{
            Button(action:{
                data.pin.toggle()
                viewmodel.fetchData()
            }){
                
            }.buttonStyle(PinButtonStyle(pin: data.pin))
            VStack(alignment:.leading,spacing:2){
                NavigationLink(destination:RepositoryView(repo_data : data)){
                    Text(data.name ?? "No name").bold()
                }
                Text(data.site ?? "No site").font(.caption).opacity(0.7)
            }
        }
    }
}
