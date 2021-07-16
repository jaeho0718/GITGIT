//
//  GitubPage.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/10.
//

import SwiftUI
import MarkdownUI
import Liquid
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
            }.onTapGesture {
                if let url = URL(string: repository.site ?? ""){
                    NSWorkspace.shared.open(url)
                }
            }
            Divider()
            if add_issue{
                AddIssueCell(add_issue: $add_issue, issues: $issues, repository: repository).padding([.leading,.top,.trailing]).transition(.scale)
            }
            if issues.isEmpty{
                
            }else{
                List{
                    ForEach(issues){ issue in
                        IssueCell(issue: issue, repo: repository)
                    }
                }.removeBackground()
            }
            Spacer()
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
    }
    func setValue(){
        viewmodel.getIssues(viewmodel.UserInfo, repo: repository, complication: { value in
            issues = value
        })
    }
}

struct IssueCell : View{
    var drag_condition : Bool = true
    @EnvironmentObject var viewmodel : ViewModel
    @State private var comment_add : Bool = false
    @State private var comment : String = ""
    @State private var comment_Markdown : String = ""
    @State private var selection : Int = 0
    @State private var comments : [Comments] = []
    @State private var show_detail : Bool = false
    var issue : Issues
    var repo : Repository
    var body: some View{
        GroupBox(label:Label("\(issue.title) #\(issue.number)", systemImage: "ant.fill")){
            VStack(alignment:.leading){
                HStack(alignment:.center){
                    viewmodel.getUserImage(issue.user.login)
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
                }.padding(.bottom,5)
                if show_detail{
                    Markdown("\(issue.body)")
                    Divider()
                    if !(comments.isEmpty){
                        Section(header:Label("comments", systemImage: "bubble.left.fill")){
                            ForEach(comments,id:\.id){ value in
                                CommentCell(comment:value)
                            }
                        }
                    }
                    if comment_add{
                        TabView(selection:$selection){
                            TextEditor(text: $comment).frame(minHeight:100,maxHeight:350).tabItem { Text("Write") }.tag(0)
                            Markdown("\(comment_Markdown)").frame(minHeight:100,maxHeight:350).tabItem { Text("Preview") }.tag(1)
                        }.onChange(of: selection, perform: { value in
                            comment_Markdown = comment
                        })
                        Text("MarkDown문법을 지원합니다.").font(.caption).opacity(0.7)
                    }
                    HStack{
                        Spacer()
                        Button(action:{
                            comment = ""
                            comment_add.toggle()
                        }){
                            Text(comment_add ? "Cancel" : "Add comment")
                        }.buttonStyle(AddButtonStyle())
                        if comment_add{
                            Button(action:{
                                if !(comment.isEmpty){
                                    viewmodel.createComments(repo: repo, number: issue.number, body: comment)
                                    viewmodel.getComments(repo: repo, number: issue.number, complication: { value in
                                        comments = value
                                    })
                                }
                                comment = ""
                                comment_add.toggle()
                            }){
                                Text("Comment")
                            }//.opacity(comment.isEmpty ? 0.5 : 1.0)
                            .buttonStyle(AddButtonStyle())
                        }
                    }
                }
            }.frame(maxWidth:.infinity)
        }.groupBoxStyle(IssueGroupBoxStyle())
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)){
                show_detail.toggle()
            }
            if !show_detail{
                comment_add = false
            }
        }
        .onAppear{
            viewmodel.getComments(repo: repo, number: issue.number, complication: { value in
                comments = value
            })
        }
        .OnDragable(condition: drag_condition, data: { return NSItemProvider(object: NSURL(string: issue.html_url)!)})
    }
}

struct AddIssueCell : View{
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var add_issue : Bool
    @State private var title : String = ""
    @State private var body_str : String = ""
    @State private var markdown_str : String = ""
    @State private var selection : Int = 0
    @Binding var issues : [Issues]
    var repository : Repository
    var body: some View{
        GroupBox(label:Label("이슈 등록하기", systemImage: "ant.fill")){
            VStack(alignment:.leading){
                HStack(alignment:.center){
                    viewmodel.getUserImage()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:20,height:20).clipShape(Circle())
                        .overlay(Circle().stroke(lineWidth: 1))
                    Text(viewmodel.UserInfo?.user_name ?? "이름을 불러올 수 없음").font(.body)
                    Spacer()
                }.padding(5)
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
                        add_issue.toggle()
                    }){
                        Text("Cancel")
                    }.buttonStyle(CancelButtonStyle())
                    Button(action:{
                        if !(title.isEmpty){
                            viewmodel.createIssues(repo: repository, title: title, body: body_str)
                            viewmodel.getIssues(viewmodel.UserInfo, repo: repository, complication: { value in
                                issues = value
                            })
                            title = ""
                            body_str = ""
                            add_issue.toggle()
                        }
                    }){
                        Text("Submit new issue")
                    }//.opacity(title.isEmpty ? 0.5 : 1.0)
                    .buttonStyle(AddButtonStyle())
                }
            }.frame(maxWidth:.infinity)
        }.groupBoxStyle(IssueGroupBoxStyle())
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
                .aspectRatio(contentMode: .fill)
                .frame(width:20,height:20).clipShape(Circle())
                .overlay(Circle().stroke(lineWidth: 1)) }
        )){
            Markdown("\(comment.body)")
        }
    }
}
