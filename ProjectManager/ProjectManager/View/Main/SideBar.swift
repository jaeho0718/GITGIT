//
//  SideBar.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import SwiftUI
import Network
struct SideBar: View {
    @EnvironmentObject var viewmodel : ViewModel
    @SceneStorage("pin") var pin : Bool = true
    @SceneStorage("repository") var repository : Bool = true
    @State private var home : Bool = true
    @Binding var connectInternet : Bool
    var body: some View {
        NavigationView{
            Form{
                if !connectInternet{
                    DisconnectInternet().padding([.leading,.trailing])
                }
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
        SideBar(connectInternet: .constant(true)).environmentObject(ViewModel())
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
                if let description = data.descriptions{
                    Text(description).font(.caption2).opacity(0.7)
                }else if let language = data.language{
                    Text(language).font(.caption).opacity(0.7)
                }
                //Text(data.site ?? "No site").font(.caption).opacity(0.7)
            }
        }
    }
}

struct DisconnectInternet : View{
    @State private var animation : Bool = false
    var body: some View{
        HStack(alignment:.center,spacing:10){
            Image(systemName: "wifi.slash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:20)
                .offset(y: animation ? -5 : 0)
                .rotationEffect(.degrees(animation ? -5 : 5))
                .foregroundColor(.red)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true))
            VStack(alignment:.leading){
                Text("인터넷 연결이 끊어졌어요.").font(.callout).bold().foregroundColor(.secondary)
                Text("일부 기능이 제한됩니다.").font(.caption2).foregroundColor(.secondary)
            }
        }.frame(maxWidth:.infinity).onAppear{
            animation.toggle()
        }.padding(5)
        .background(VisualEffectView(material: .contentBackground, blendingMode: .withinWindow))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
