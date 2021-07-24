//
//  IssueCell.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/24.
//

import SwiftUI
import MarkdownUI
struct IssueCell : View{
    var drag_condition : Bool = true
    @EnvironmentObject var viewmodel : ViewModel
    @State private var comment_add : Bool = false
    @State private var comment : String = ""
    @State private var comments : [Comments] = []
    @State private var show_detail : Bool = false
    var issue : Issues
    var repo : Repository
    var body: some View{
        GroupBox(label:
                 Label(title: {
                    HStack{
                        Text("\(issue.title) #\(issue.number)")
                        Spacer()
                        Text("\(issue.comments)").font(.caption2).foregroundColor(.white).padding(5).background(Circle().foregroundColor(.black))
                    }
                 }, icon: {
                        Image(systemName: "exclamationmark.square.fill")
                 })
        ){
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
                        }.accentColor(.gray)
                    }
                    if comment_add{
                        MarkDownEditor(memo: $comment)
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
        .OnDragable(condition: drag_condition, data: {
            if let source_data = try? JSONEncoder().encode(issue){
                let data = source_data
                return NSItemProvider(item: .some(data as NSSecureCoding), typeIdentifier: String(kUTTypeData))
            }else{
                return NSItemProvider()
            }
        })
    }
}

struct AddIssueCell : View{
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var add_issue : Bool
    @State private var title : String = ""
    @State private var body_str : String = ""
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
                MarkDownEditor(memo: $body_str)
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
