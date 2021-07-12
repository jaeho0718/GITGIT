//
//  GitubPage.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/10.
//

import SwiftUI
import MarkdownUI
struct GitubPage: View {
    @EnvironmentObject var viewmodel : ViewModel
    var repository : Repository
    @State private var add_issue : Bool = false
    @State private var issues : [Issues] = []
    var body: some View {
        VStack(alignment:.leading,spacing:0){
            HStack(alignment:.center){
                Text("GITHUB").bold().foregroundColor(.white)
                    .padding(5).background(Color.black)
                Text(repository.site ?? "url을 불러올 수 없음.").font(.caption).opacity(0.8)
            }
            Divider()
            VStack(alignment:.leading){
                Text(repository.name ?? "").font(.title).bold().padding(.bottom,2)
                Text(repository.descriptions ?? "description이 없음").font(.subheadline).padding(.bottom,2)
                //WebView(url: url, user: viewmodel.UserInfo)
                Section(header:Label("Issue", systemImage: "ant.circle")){
                    List{
                        if add_issue{
                            AddIssueCell(add_issue: $add_issue, repository: repository)
                        }
                        ForEach(issues){ issue in
                            IssueCell(issue: issue)
                        }
                    }.removeBackground()
                }
                Spacer()
            }.padding(5)
        }.onAppear{
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
    }
    func setValue(){
        viewmodel.getIssues(viewmodel.UserInfo, repo: repository, complication: { value in
            issues = value
        })
    }
}

struct IssueCell : View{
    @EnvironmentObject var viewmodel : ViewModel
    @State private var comment_add : Bool = false
    @State private var comment : String = ""
    var issue : Issues
    var body: some View{
        GroupBox(label:Label("\(issue.title)", systemImage: "ant.fill")){
            VStack(alignment:.leading){
                HStack(alignment:.center){
                    viewmodel.getImage(issue.user.login)
                        .aspectRatio(contentMode: .fill)
                        .frame(width:20,height:20).clipShape(Circle())
                        .overlay(Circle().stroke(lineWidth: 1))
                    Text(issue.user.login)
                    if let update_at = issue.updated_at{
                        Text("\(update_at)에 편집됨").font(.caption).opacity(0.5)
                    }else{
                        Text("\(issue.created_at)에 만들어짐").font(.caption).opacity(0.5)
                    }
                    Spacer()
                }.padding(5).background(Color.blue.opacity(0.5))
                
                Markdown("\(issue.body)")
                Divider()
                if comment_add{
                    TextEditor(text: $comment).frame(minHeight:100,maxHeight:350)
                }
                HStack{
                    Spacer()
                    Button(action:{
                        comment = ""
                        comment_add.toggle()
                    }){
                        Text(comment_add ? "Cancel" : "Add comment")
                    }
                    if comment_add{
                        Button(action:{
                            comment = ""
                            comment_add.toggle()
                        }){
                            Text("Comment")
                        }.opacity(comment.isEmpty ? 0.5 : 1.0)
                    }
                }
            }.frame(maxWidth:.infinity)
        }
    }
}

struct AddIssueCell : View{
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var add_issue : Bool
    @State private var title : String = ""
    @State private var body_str : String = ""
    @State private var markdown_str : String = ""
    @State private var selection : Int = 0
    var repository : Repository
    var body: some View{
        GroupBox(label:Label("이슈 등록하기", systemImage: "ant.fill")){
            VStack(alignment:.leading){
                HStack(alignment:.center){
                    viewmodel.getImage(viewmodel.UserInfo)
                        .aspectRatio(contentMode: .fill)
                        .frame(width:20,height:20).clipShape(Circle())
                        .overlay(Circle().stroke(lineWidth: 1))
                    Text(viewmodel.UserInfo?.user_name ?? "이름을 불러올 수 없음").font(.body)
                    Spacer()
                }.padding(5).background(Color.blue.opacity(0.5))
                TextField("title", text: $title).textFieldStyle(RoundedBorderTextFieldStyle())
                TabView(selection:$selection){
                    TextEditor(text: $body_str).frame(minHeight:100,maxHeight:350).tabItem { Text("Write") }.tag(0)
                    Markdown("\(markdown_str)").frame(minHeight:100,maxHeight:350).tabItem { Text("Preview") }.tag(1)
                }.onChange(of: selection, perform: { value in
                    markdown_str = body_str
                })
                Text("MarkDown문법을 지원합니다.").font(.caption).opacity(0.7)
                HStack{
                    Spacer()
                    Button(action:{
                        if !(title.isEmpty){
                            viewmodel.createIssues(repo: repository, title: title, body: body_str)
                            title = ""
                            body_str = ""
                            add_issue.toggle()
                        }
                    }){
                        Text("Submit new issue")
                    }.opacity(title.isEmpty ? 0.5 : 1.0)
                }
            }.frame(maxWidth:.infinity)
        }
    }
}
