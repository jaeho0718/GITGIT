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
    }
    func setValue(){
        DispatchQueue.main.async {
            viewmodel.getIssues(viewmodel.UserInfo, repo: repository, complication: { value in
                issues = value
            })
        }
    }
}

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
        .OnDragable(condition: drag_condition, data: { return NSItemProvider(object: NSURL(string: issue.html_url)!)})
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

struct EmptyIssue : View{
    @State private var moveRightLeft : Bool = false
    @State private var moveRightLeft2 : Bool = false
    @State private var empty : Bool = false
    var body: some View{
        GroupBox(label:Label("Issue", systemImage: "ant")){
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
