//
//  CommitsView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/24.
//

import SwiftUI
import MarkdownUI

struct CommitsView: View {
    @EnvironmentObject var viewmodel : ViewModel
    var repository : Repository
    @State private var commits : [GitCommits] = []
    var body: some View {
        List{
            if commits.isEmpty{
                EmptyCommit()
            }else{
                ForEach(commits,id:\.sha){ commit in
                    CommitCell(commits: commit)
                    Divider()
                }
            }
        }.onAppear{
            viewmodel.getCommits(repository: repository, completion: { result in
                commits = result
            })
        }.frame(minWidth:300,maxWidth: .infinity)
    }
}

struct CommitCell : View{
    @EnvironmentObject var viewmodel : ViewModel
    @State private var showDetail : Bool = false
    var commits : GitCommits
    var commit : GitCommit{
        return commits.commit
    }
    var body: some View{
        VStack{
            HStack{
                Text(commit.committer["name"] ?? "Null").frame(width:100)
                Divider()
                Button(action:{
                    showDetail.toggle()
                }){
                    Image(systemName: showDetail ? "chevron.up.square.fill" : "chevron.down.square.fill")
                }.buttonStyle(RemoveBackgroundStyle())
                Text(commit.message).font(.body).foregroundColor(.secondary)
                Spacer()
                Text(commit.committer["date"] ?? "Null").font(.callout).foregroundColor(.gray)
            }
            if showDetail{
                Divider()
                CommitDetail(commit: commits)
            }
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
        HSplitView{
            title.frame(minWidth:200,maxHeight: .infinity)
            change.frame(minWidth:200,maxHeight: .infinity)
        }
        .frame(maxWidth:.infinity,minHeight:450,maxHeight: .infinity)
        .onAppear{
            viewmodel.getCommitDetail(commit, completion: { result in
                detail = result
            })
        }.onDisappear{
            detail = nil
        }
    }
}

struct CommitDetailCell : View{
    var file : ChangedCommitFile
    @State private var showDetail : Bool = true
    /*
     private let nextPlus = try! NSRegularExpression(pattern: "_[^_]+_", options: [])
     private var rule : [HighlightRule]{
         return [HighlightRule(pattern: nextPlus, formattingRules: [
             TextFormattingRule(fontTraits: [.bold]),
             TextFormattingRule(key: .foregroundColor,value: NSColor.blue)
         ])]
     }
     */
    var body: some View{
        GroupBox(label:Label(title: {Text("파일이름 : \(file.filename)")}, icon: {})){
            HStack(alignment:.bottom){
                Text("추가 : \(file.additions)").bold().foregroundColor(.blue)
                Text("삭제 : \(file.deletions)").bold().foregroundColor(.red)
                Text("변경 : \(file.deletions)").bold().foregroundColor(.green)
            }.font(.body)
            if showDetail{
                //HighlightedTextEditor(text: .constant(file.patch), highlightRules: rule).frame(minHeight:300)
                Markdown("\(file.patch)").background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
            }else{
                Text("Tap to show more").foregroundColor(.secondary)
            }
            //CodeView(theme:  colorScheme == .dark ? SettingValue.getTheme(viewmodel.settingValue.code_type_dark) : SettingValue.getTheme(viewmodel.settingValue.code_type_light), code: .constant(file.patch), mode: FileType.getType(file.filename).code_mode.mode(), fontSize: 12, showInvisibleCharacters: true, lineWrapping: true)
                //.frame(minHeight:400).allowsTightening(false)
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

