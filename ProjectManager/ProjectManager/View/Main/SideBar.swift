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
    var body: some View {
        NavigationView{
            Form{
                List{
                    NavigationLink(destination: AccountView()){
                        if let user = viewmodel.UserInfo{
                            HStack{
                                viewmodel.getUserImage().resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width:15,height:15).clipShape(Circle())
                                    .overlay(Circle().stroke())
                                if let user_info = viewmodel.GithubUserInfo{
                                    Text(user_info.name)
                                }else{
                                    Text(user.user_name)
                                }
                            }
                        }else{
                            Label("Account", systemImage: "person.crop.circle")
                        }
                    }
                    DisclosureGroup(isExpanded: $pin, content: {
                        if viewmodel.Repositories.isEmpty{
                            Text("Github의 레퍼토리를 불러올 수 없습니다.").font(.caption)
                        }else{
                            ForEach(viewmodel.Repositories.filter({$0.pin})){ repository in
                                RepositoryCell(data: repository)
                            }
                        }
                    }, label: {
                        Label("pin", systemImage: "pin.circle.fill")
                    })
                    DisclosureGroup(isExpanded: $repository, content: {
                        if viewmodel.Repositories.isEmpty{
                            Text("Github의 레퍼토리를 불러올 수 없습니다.").font(.caption)
                        }else{
                            ForEach(viewmodel.Repositories.filter({!($0.pin)})){ repository in
                                RepositoryCell(data: repository)
                            }
                        }
                    }, label: {
                        Label("repositroy", systemImage: "doc.fill")
                    })
                }
            }
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
    @State private var pin : Bool = false
    @EnvironmentObject var viewmodel : ViewModel
    var body: some View{
        HStack{
            Toggle("", isOn: $pin).toggleStyle(CheckBoxStyle(true_img: "pin.fill", false_img: "pin")).onChange(of: pin, perform: { value in
                data.pin = value
                viewmodel.updateData()
            })
            
            VStack(alignment:.leading,spacing:2){
                NavigationLink(destination:RepositoryView(repo_data : data)){
                    Text(data.name ?? "No name").bold()
                }
                Text(data.site ?? "No site").font(.caption).opacity(0.7)
            }
        }
        .onAppear{
            pin = data.pin
        }
    }
}
