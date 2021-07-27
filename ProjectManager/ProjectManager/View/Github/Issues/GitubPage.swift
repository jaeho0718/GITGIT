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
    @TimerState(interval: 60) var timer : Int
    var body: some View {
        VStack(alignment:.leading,spacing:0){
            HStack(alignment:.center){
                Text("GITHUB").bold().foregroundColor(.white)
                    .padding(5).background(Color.black)
                Text(repository.site ?? "url을 불러올 수 없음.").font(.caption).opacity(0.8)
            }.onTapGesture {
                if let url = URL(string: repository.site ?? ""){
                    NSWorkspace.shared.open(url)
                }
            }
            Divider()
            List{
                if add_issue{
                    AddIssueCell(add_issue: $add_issue, issues: $issues, repository: repository)
                }
                if issues.isEmpty{
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
            })
        }
    }
}

struct CommentCell : View{
    @EnvironmentObject var viewmodel : ViewModel
    var comment : Comments
    var body: some View{
        GroupBox(label:Label(
            title: { HStack{
                Text(comment.user.login)
                Text(comment.created_at).font(.caption).opacity(0.5)
            }},
            icon: { viewmodel.getUserImage(comment.user.login)
                .aspectRatio(contentMode: .fit)
                .frame(width:20,height:20).clipShape(Circle())
                .overlay(Circle().stroke(lineWidth: 1)) }
        )){
            Markdown("\(comment.body)")
        }
    }
}

struct EmptyIssue : View{
    @State private var moveRightLeft : Bool = false
    @State private var moveRightLeft2 : Bool = false
    @State private var empty : Bool = false
    var body: some View{
        GroupBox(label:Label("Issue", systemImage: "exclamationmark.square.fill")){
            if empty{
                Text("이슈가 비어있네요.")
            }else{
                ZStack{
                    RoundedRectangle(cornerRadius: 5).frame(width:200,height:15,alignment: .center)
                        .foregroundColor(Color(.systemGray).opacity(0.3))
                    RoundedRectangle(cornerRadius: 5).clipShape(Rectangle().offset(x: moveRightLeft ? 120 : -120))
                        .frame(width:170,height:15,alignment: .leading)
                        .foregroundColor(Color(.darkGray).opacity(0.5))
                        .offset(x: moveRightLeft ? 14 : -14)
                        .animation(Animation.easeInOut(duration: 1).delay(0.2).repeatForever(autoreverses: true))
                        .onAppear{
                            moveRightLeft.toggle()
                        }
                }
                ZStack{
                    RoundedRectangle(cornerRadius: 5).frame(width:400,height:15,alignment: .center)
                        .foregroundColor(Color(.systemGray).opacity(0.3))
                    RoundedRectangle(cornerRadius: 5).clipShape(Rectangle().offset(x: moveRightLeft2 ? 240 : -240))
                        .frame(width:340,height:15,alignment: .leading)
                        .foregroundColor(Color(.darkGray).opacity(0.5))
                        .offset(x: moveRightLeft2 ? 28 : -28)
                        .animation(Animation.easeInOut(duration: 1).delay(0.2).repeatForever(autoreverses: true))
                        .onAppear{
                            moveRightLeft2.toggle()
                        }
                }
            }
        }.groupBoxStyle(IssueGroupBoxStyle())
        .onAppear{
            let time = DispatchTime.now() + .seconds(5)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                withAnimation(.spring()){
                    self.empty = true
                }
            })
        }
    }
}
