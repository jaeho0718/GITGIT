//
//  IssueCell.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/24.
//

import SwiftUI
import MarkdownUI
import AlertToast
struct IssueCell : View{
    var drag_condition : Bool = true
    @EnvironmentObject var viewmodel : ViewModel
    @State private var comment_add : Bool = false
    @State private var comment : String = ""
    @State private var comments : [Comments] = []
    @State private var show_detail : Bool = false
    var issue : Issues
    var repo : Repository
    @State private var showFailAelrt : Bool = false
    @State private var showSuccessAelrt : Bool = false
    var commentDetail : some View{
        Section(header:Label("comments", systemImage: "bubble.left.fill")){
            ForEach(comments,id:\.id){ value in
                CommentCell(comment:value)
            }
        }.accentColor(.gray)
    }
    var bottomButton : some View{
        HStack{
            Spacer()
            if checkAssigne(){
                Button(action:{
                    viewmodel.changeIssueState(repo: repo, issue: issue, state: issue.state == "open" ? .closed : .open,onSuccess: {showSuccessAelrt.toggle()},onFail: {showFailAelrt.toggle()})
                }){
                    Text(issue.state == "open" ? "Closed this issue" : "Open this issue").foregroundColor(.red)
                }.buttonStyle(AddButtonStyle())
            }
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
                    Text("AddComment")
                }//.opacity(comment.isEmpty ? 0.5 : 1.0)
                .buttonStyle(AddButtonStyle())
            }
        }
    }
    var groupLabel : some View{
        Label(title: {
           HStack{
               Text(issue.state)
                   .foregroundColor(issue.state == "open" ? .blue : .red)
                   .padding([.leading,.trailing],5).padding([.top,.bottom],2)
                   .overlay(Capsule().stroke(lineWidth: 1.2).foregroundColor(issue.state == "open" ? .blue : .red))
               Text("\(issue.title) #\(issue.number)")
               Spacer()
               Text("\(issue.comments)").font(.caption2).foregroundColor(.white).padding(5).background(Circle().foregroundColor(.black))
           }
        }, icon: {
        })
    }
    var addCommentView : some View{
        VStack{
            HStack{
                if let url = URL(string:"https://github.com/\(viewmodel.UserInfo?.user_name ?? "").png"){
                    AsyncImage(url: url, placeholder: {Image(systemName: "person.crop.circle.fill")})
                        .frame(width:20,height:20).clipShape(Circle())
                }
                Text(viewmodel.UserInfo?.user_name ?? "")
                Spacer()
            }
            MarkDownEditor(memo: $comment)
        }
    }
    var body: some View{
        GroupBox(label:
            groupLabel
        ){
            VStack(alignment:.leading){
                HStack(alignment:.center){
                    if let url = URL(string: "https://github.com/\(issue.user.login).png"){
                        AsyncImage(url: url, placeholder: {Image(systemName: "person.crop.circle.fill")}).frame(width:25,height:25).clipShape(Circle())
                    }
                    Text(issue.user.login)
                    if let update_at = issue.updated_at{
                        Text("\(update_at)에 편집됨").font(.caption).opacity(0.5)
                    }else{
                        Text("\(issue.created_at)에 만들어짐").font(.caption).opacity(0.5)
                    }
                    Spacer()
                }.padding(.bottom,5)
                Markdown("\(issue.body)")
                if show_detail{
                    Divider()
                    if !(comments.isEmpty){
                        commentDetail
                    }
                    if comment_add{
                        Divider()
                        addCommentView
                    }
                    bottomButton
                }
            }.frame(maxWidth:.infinity)
        }.groupBoxStyle(IssueGroupBoxStyle())
        .overlay(showSuccessAelrt || showFailAelrt ? Color.black.opacity(0.2) : Color.clear)
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)){
                show_detail.toggle()
            }
            if !show_detail{
                comment_add = false
            }
        }
        .onAppear{
            DispatchQueue.main.async {
                viewmodel.getComments(repo: repo, number: issue.number, complication: { value in
                    comments = value
                })
            }
        }
        .OnDragable(condition: drag_condition, data: {
            if let source_data = try? JSONEncoder().encode(issue){
                let data = source_data
                return NSItemProvider(item: .some(data as NSSecureCoding), typeIdentifier: String(kUTTypeData))
            }else{
                return NSItemProvider()
            }
        })
        .toast(isPresenting: $showFailAelrt, alert: {
            AlertToast(displayMode: .alert, type: .regular,title: "변경실패")
        })
        .toast(isPresenting: $showSuccessAelrt, alert: {
            AlertToast(displayMode: .alert, type: .regular, title: "변경완료",subTitle: "적용되기까지 시간이 소요될 수 있습니다.")
        })
    }
    
    func checkAssigne()->Bool{
        if let user = viewmodel.UserInfo?.user_name{
            if issue.assignees.contains(where: {$0.login == user}){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
}

struct AddIssueCell : View{
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var add_issue : Bool
    @State private var title : String = ""
    @State private var body_str : String = ""
    @Binding var issues : [Issues]
    var repository : Repository
    
    var IssueUserInfo : some View{
        HStack(alignment:.center){
            viewmodel.getUserImage()
                .aspectRatio(contentMode: .fill)
                .frame(width:20,height:20).clipShape(Circle())
                .overlay(Circle().stroke(lineWidth: 1))
            Text(viewmodel.UserInfo?.user_name ?? "이름을 불러올 수 없음").font(.body)
            Spacer()
        }
    }
    
    var bottomButton : some View{
        HStack{
            Spacer()
            Button(action:{
                add_issue.toggle()
            }){
                Text("Cancel")
            }.buttonStyle(CancelButtonStyle())
            Button(action:{
                saveIssue()
            }){
                Text("Submit new issue")
            }//.opacity(title.isEmpty ? 0.5 : 1.0)
            .buttonStyle(AddButtonStyle())
        }
    }
    
    var body: some View{
        GroupBox(label:Label("이슈 등록하기", systemImage: "ant.fill")){
            VStack(alignment:.leading){
                IssueUserInfo.padding(5)
                TextField("title", text: $title).textFieldStyle(RoundedBorderTextFieldStyle())
                MarkDownEditor(memo: $body_str)
                bottomButton
            }.frame(maxWidth:.infinity)
        }.groupBoxStyle(IssueGroupBoxStyle())
    }
    
    private func saveIssue(){
        if !(title.isEmpty){
            viewmodel.createIssues(repo: repository, title: title, body: body_str)
            viewmodel.getIssues(viewmodel.UserInfo, repo: repository, complication: { value in
                issues = value
            })
            title = ""
            body_str = ""
            add_issue.toggle()
        }
    }
}
