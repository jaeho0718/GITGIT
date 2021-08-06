//
//  StarredCell.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/08/06.
//

import SwiftUI

struct StarredCell: View {
    var data : GitStar
    var body: some View {
        GroupBox{
            VStack(alignment:.leading,spacing:5){
                HStack{
                    if let url = URL(string: "https://github.com/\(data.owner.login).png"){
                        AsyncImage(url: url, placeholder: {Text("test")})
                            .frame(width:35,height:35)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    HStack(spacing:0){
                        Text("\(data.owner.login)").bold()
                        Text(" / \(data.owner.html_url)").bold().foregroundColor(.secondary)
                    }
                }
                Divider()
                Text(data.name).font(.title).bold()
                Text(data.description ?? "").font(.headline).foregroundColor(.secondary)
                HStack(spacing:10){
                    Label("watchers : \(data.watchers)", systemImage: "eye").padding(5)
                        .foregroundColor(.white)
                        .background(Color.black).clipShape(RoundedRectangle(cornerRadius: 10))
                    Label("stargazers : \(data.stargazers_count)", systemImage: "star.fill").padding(5)
                        .foregroundColor(.white)
                        .background(Color.black).clipShape(RoundedRectangle(cornerRadius: 10))
                    Spacer()
                    Button(action:{
                        if let url = URL(string: data.html_url){
                            NSWorkspace.shared.open(url)
                        }
                    }){
                        Label("사이트 이동", systemImage: "safari.fill").padding(5)
                            .foregroundColor(.white)
                            .background(Color.black).clipShape(RoundedRectangle(cornerRadius: 10))
                    }.buttonStyle(RemoveBackgroundStyle())
                }.padding([.bottom,.top],5)
            }
        }.groupBoxStyle(LinkGroupBoxStyle())
        .onDrag({
            if let url = NSURL(string: data.html_url){
                return NSItemProvider(object: url)
            }else{
                return NSItemProvider()
            }
        })
    }
}

struct StarredCell_Previews: PreviewProvider {
    static var previews: some View {
        StarredCell(data: GitStar(id: 302898696, node_id: "MDEwOlJlcG9zaXRvcnkzMDI4OTg2OTY=", name:"Swipeable-View", full_name: "mroffmix/Swipeable-View", description: "Simple editActionsForRowAt functionality, written on SWIFTUI", html_url: "https://github.com/mroffmix/Swipeable-View", language: "Swift", watchers: 34,stargazers_count:34, owner: .init(login: "mroffmix", id: 6120645, html_url: "https://github.com/mroffmix")))
    }
}
