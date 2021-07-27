//
//  CommitsView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/24.
//

import SwiftUI
import MarkdownUI
import SwiftUIX

struct CommitsView: View {
    @EnvironmentObject var viewmodel : ViewModel
    var repository : Repository
    @State private var commits : [GitCommits] = []
    @State private var updatedDate : String = ""
    @State private var selectedCommit : GitCommits?
    @State private var showDetail : Bool = false
    var dateFormat : DateFormatter{
        let format = DateFormatter()
        format.dateFormat = "YYYY.MM.dd HH:mm"
        return format
    }
    @TimerState(interval: 60) var timer : Int
    
    var botttomBar : some View{
        GeometryReader{ geomtry in
            VStack(alignment:.leading,spacing:0){
                HStack{
                    Text("Commit : \(commits.count)").font(.caption2).padding(.leading,5)
                    Spacer()
                    Text("업데이트 : \(updatedDate)").font(.caption2).padding(.trailing,5)
                }.frame(height:20).background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
                if let commit = selectedCommit,showDetail{
                    CommitDetail(commit: commit).frame(width:geomtry.size.width,height: geomtry.size.height-20)
                }
            }.frame(width: geomtry.size.width)
            .onChange(of: geomtry.size.height, perform: { value in
                if geomtry.size.height < 60{
                    showDetail = false
                }else{
                    showDetail = true
                }
            })
        }
    }
    
    var topBar : some View{
        List{
            if commits.isEmpty{
                EmptyCommit()
            }else{
                ForEach(commits,id:\.sha){ commit in
                    CommitCell(selectedCommit: $selectedCommit, commits: commit)
                    Divider()
                }
            }
        }
    }
    
    var body: some View {
        VSplitView{
            topBar
            botttomBar.frame(minHeight:20)
        }.onAppear{
            viewmodel.getCommits(repository: repository, completion: { result in
                commits = result
                updatedDate = dateFormat.string(from: Date())
            })
        }
        .onChange(of: timer, perform: { value in
            viewmodel.getCommits(repository: repository, completion: { result in
                commits = result
                updatedDate = dateFormat.string(from: Date())
            })
        })
    }
}

struct CommitCell : View{
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var selectedCommit : GitCommits?
    var commits : GitCommits
    var commit : GitCommit{
        return commits.commit
    }
    var body: some View{
        HStack{
            Text(commit.committer["name"] ?? "Null").frame(width:100)
            Divider()
            Text(commit.message).font(.body).foregroundColor(.secondary).frame(maxWidth:.infinity)
            Text(commit.committer["date"] ?? "Null").font(.callout).foregroundColor(.gray).frame(width: 150)
        }.onTapGesture {
            selectedCommit = commits
        }
    }
}

struct CommitDetail : View{
    @EnvironmentObject var viewmodel : ViewModel
    var commit : GitCommits
    @State private var detail : GitCommitsChange?
    
    var title : some View{
        VStack(alignment:.leading,spacing:5){
            Text(commit.commit.committer["name"] ?? "Null").font(.body)
            Text(commit.commit.message).font(.body).bold().foregroundColor(.secondary)
            Text(commit.commit.committer["date"] ?? "").font(.body).foregroundColor(.secondary)
        }
    }
    
    var change : some View{
        List{
            if let content = detail{
                if content.files.isEmpty{
                    EmptyCommit()
                }else{
                    ForEach(content.files,id:\.sha){ file in
                        CommitDetailCell(file: file)
                    }
                }
            }else{
                EmptyCommit()
            }
        }
    }
    
    var body: some View{
        GeometryReader{ geomtry in
            HStack{
                title.frame(width: 150)
                change.frame(width: geomtry.size.width-150)
            }
        }
        .onAppear{
            viewmodel.getCommitDetail(commit, completion: { result in
                detail = result
            })
        }.onDisappear{
            detail = nil
        }
        .onChange(of: commit, perform: { value in
            detail = nil
            viewmodel.getCommitDetail(commit, completion: { result in
                detail = result
            })
        })
    }
}

struct CommitDetailCell : View{
    var file : ChangedCommitFile
    @State private var showDetail : Bool = true
    var body: some View{
        GroupBox(label:Label(title: {Text("파일이름 : \(file.filename)")}, icon: {})){
            HStack(alignment:.bottom){
                Text("추가 : \(file.additions)").bold().foregroundColor(.secondary)
                Text("삭제 : \(file.deletions)").bold().foregroundColor(.secondary)
                Text("변경 : \(file.deletions)").bold().foregroundColor(.secondary)
            }.font(.body)
            if showDetail{
                PatchTextView(patch: file.patch)
            }else{
                Text("Tap to show more").foregroundColor(.secondary)
            }
        }.groupBoxStyle(IssueGroupBoxStyle())
        .onTapGesture {
            showDetail.toggle()
        }
    }
}

struct EmptyCommit : View{
    @State private var moveRightLeft : Bool = false
    @State private var empty : Bool = false
    var body: some View{
        HStack(alignment:.center){
            if empty{
                VStack(alignment:.center){
                    Image("Empty").resizable().aspectRatio(contentMode: .fit).frame(width:200)
                    Text("빈 커밋입니다.")
                }
            }else{
                ZStack{
                    RoundedRectangle(cornerRadius: 5).frame(width:400,height:6,alignment: .center)
                        .foregroundColor(Color(.systemGray).opacity(0.3))
                    RoundedRectangle(cornerRadius: 5).clipShape(Rectangle().offset(x: moveRightLeft ? 240 : -240))
                        .frame(width:340,height:6,alignment: .leading)
                        .foregroundColor(Color(.darkGray).opacity(0.5))
                        .offset(x: moveRightLeft ? 28 : -28)
                }
            }
        }.frame(maxWidth:.infinity).onAppear{
            let time = DispatchTime.now() + .seconds(5)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                withAnimation(.spring()){
                    self.empty = true
                }
            })
            withAnimation(.easeInOut(duration: 1).delay(0.2).repeatForever()){
                moveRightLeft.toggle()
            }
        }
    }
}

struct PatchTextView : View{
    
    var patch : String
    var codes : [CodeType]{
        let strings = patch.components(separatedBy: "\n")
        var items : [CodeType] = []
        var number : Int = 0
        for code in strings{
            if let index = code.firstIndex(of: "+"),index == code.startIndex{
                var editableCode = code
                //let editedCode = editableCode.removeFirst()
                items.append(CodeType(number: number, code: editableCode, type: .add))
            }else if let index = code.firstIndex(of: "-"),index == code.startIndex{
                var editableCode = code
                //let editedCode = editableCode.removeFirst()
                items.append(CodeType(number: number, code: editableCode, type: .delete))
            }else{
                var editableCode = code
                //let editedCode = editableCode.removeFirst()
                items.append(CodeType(number: number, code: editableCode, type: .normal))
            }
            number += 1
        }
        return items
    }
    var body: some View{
        VStack(alignment:.leading,spacing:1){
            ForEach(codes,id:\.number){ code in
                Text(code.code)
                    .foregroundColor(code.fontColor)
                    .background(Rectangle().frame(maxWidth:.infinity).foregroundColor(code.backColor).opacity(0.1))
            }
        }.onAppear{
            //print(codes)
        }
    }
    
    struct CodeType{
        var number : Int
        var code : String
        var type : type
        var backColor : Color{
            switch self.type {
            case .add:
                return .green
            case .delete:
                return .red
            case .normal:
                return .clear
            }
        }
        var fontColor : Color{
            switch self.type {
            case .add:
                return .green
            case .delete:
                return .red
            case .normal:
                return .secondary
            }
        }
        enum type{
            case add,delete,normal
        }
    }
}
