//
//  GitubPage.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/10.
//

import SwiftUI
import MarkdownUI
import SwiftUIX

struct GitubPage: View {
    @EnvironmentObject var viewmodel : ViewModel
    var repository : Repository
    @State private var add_issue : Bool = false
    @State private var issues : [Issues] = []
    @State private var onLoad : Bool = true
    @TimerState(interval: 60) var timer : Int
    var body: some View {
        VStack(alignment:.leading,spacing:0){
            List{
                if add_issue{
                    AddIssueCell(add_issue: $add_issue, issues: $issues, repository: repository)
                }
                if onLoad{
                    EmptyIssue().frame(maxWidth:.infinity)
                }else{
                    ForEach(issues){ issue in
                        IssueCell(issue: issue, repo: repository)
                    }
                }
            }
            HStack{
                Text("Issues : \(issues.count)").font(.caption2).padding(.leading,5)
                Spacer()
                Text("이슈를 자료에 드래그해 자료를 수집하세요.").font(.caption2).padding(.trailing,5)
            }.frame(maxWidth:.infinity,maxHeight:20).background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        }
        .onAppear{
            setValue()
        }
        .toolbar{
            ToolbarItem{
                Button(action:{
                    add_issue.toggle()
                }){
                    Text(add_issue ? "Cancel" : "New issue")
                }
            }
        }
        .touchBar{
            Button(action:{
                add_issue.toggle()
            }){
                Label(add_issue ? "Cancel" : "NewIssue", systemImage: add_issue ? "xmark.square" : "plus.app")
            }
        }
        .onChange(of: timer, perform: { value in
            setValue()
        })
    }
    func setValue(){
        DispatchQueue.main.async {
            viewmodel.getIssues(viewmodel.UserInfo, repo: repository, complication: { value in
                issues = value
                onLoad = false
            },failer: {
                onLoad = false
            })
        }
    }
}

struct CommentCell : View{
    @EnvironmentObject var viewmodel : ViewModel
    var comment : Comments
    var body: some View{
        GroupBox(label:Label(
            title: {
            HStack{
                Text(comment.user.login)
                Text(comment.created_at).font(.caption).opacity(0.5)
            }},
            icon: {
                if let url = URL(string: "https://github.com/\(comment.user.login).png"){
                    AsyncImage(url: url, placeholder: {Image(systemName: "person.crop.circle.fill")}).frame(width:20,height:20).clipShape(Circle())
                }
            }))
        {
            Markdown("\(comment.body)")
        }
    }
}

struct EmptyIssue : View{
    @State private var moveRightLeft : Bool = false
    @State private var moveRightLeft2 : Bool = false
    var body: some View{
        GroupBox(label:Label("Issue", systemImage: "exclamationmark.square.fill")){
            ZStack{
                RoundedRectangle(cornerRadius: 5).frame(width:200,height:15,alignment: .center)
                    .foregroundColor(Color(.systemGray).opacity(0.3))
                RoundedRectangle(cornerRadius: 5).clipShape(Rectangle().offset(x: moveRightLeft ? 120 : -120))
                    .frame(width:170,height:15,alignment: .leading)
                    .foregroundColor(Color(.darkGray).opacity(0.5))
                    .offset(x: moveRightLeft ? 14 : -14)
            }
            ZStack{
                RoundedRectangle(cornerRadius: 5).frame(width:400,height:15,alignment: .center)
                    .foregroundColor(Color(.systemGray).opacity(0.3))
                RoundedRectangle(cornerRadius: 5).clipShape(Rectangle().offset(x: moveRightLeft2 ? 240 : -240))
                    .frame(width:340,height:15,alignment: .leading)
                    .foregroundColor(Color(.darkGray).opacity(0.5))
                    .offset(x: moveRightLeft2 ? 28 : -28)
            }
        }.groupBoxStyle(IssueGroupBoxStyle())
        .onAppear{
            withAnimation(.easeInOut(duration: 1).delay(0.2).repeatForever(autoreverses: true)){
                moveRightLeft2.toggle()
                moveRightLeft.toggle()
            }
        }
    }
}
