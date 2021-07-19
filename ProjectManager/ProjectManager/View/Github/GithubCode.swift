//
//  GithubCode.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/17.
//

import SwiftUI
import WaterfallGrid

struct GithubCode: View {
    @EnvironmentObject var viewmodel : ViewModel
    var repository : Repository
    @State private var nowFile : [GitFile] = []
    @State private var file_order : [GitFile] = []
    var body: some View {
        Form{
            List{
                if nowFile.isEmpty{
                    if let file = file_order.last{
                        GitFileCode(gitfile:file,repository:repository)
                    }else{
                        EmptyGitFile()
                    }
                }else{
                    ForEach(nowFile,id:\.sha){ file in
                        GitFileView(nowFile: $nowFile, file_order: $file_order, repository: repository, file: file)
                    }
                }
            }
            GitFileDirectory(repository: repository, nowFile: $nowFile, file_order: $file_order).padding([.bottom,.leading,.trailing],5)
        }.onAppear{
            viewmodel.getGitFiles(repository, completion: { value in
                nowFile = value
            })
        }
    }
}

struct GitFileView : View{
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var nowFile : [GitFile]
    @Binding var file_order : [GitFile]
    var repository : Repository
    var file : GitFile
    var body: some View{
        GroupBox{
            HStack{
                file.getIcon().resizable().aspectRatio(contentMode: .fit).frame(width:20,height:20)
                Text(file.name)
                Spacer()
            }
        }.groupBoxStyle(LinkGroupBoxStyle())
        .onTapGesture {
            viewmodel.getGitFiles(repository,path: file.path, completion: { value in
                file_order.append(file)
                nowFile = value
            })
        }
    }
}

struct GitFileDirectory : View{
    @EnvironmentObject var viewmodel : ViewModel
    var repository : Repository
    @Binding var nowFile : [GitFile]
    @Binding var file_order : [GitFile]
    var body: some View{
        ScrollView(.horizontal){
            HStack{
                Text(repository.name ?? "")
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.black)
                    .onTapGesture {
                        file_order.removeAll()
                        viewmodel.getGitFiles(repository, completion: { files in
                            nowFile = files
                        })
                    }
                ForEach(file_order,id:\.self){ file in
                    HStack{
                        Text("> ")
                        file.getIcon().resizable().aspectRatio(contentMode: .fit).frame(width:10,height:10)
                        Text(file.name)
                    }.onTapGesture {
                        guard let index = file_order.firstIndex(of: file) else {return}
                        if index <= file_order.count{
                            file_order.removeSubrange(index+1..<file_order.count)
                        }
                        viewmodel.getGitFiles(repository, path: file.path, completion: { files in
                            nowFile = files
                        })
                    }
                }
            }
        }
        .frame(maxWidth:.infinity)
    }
}

struct GitFileCode : View{
    @EnvironmentObject var viewmodel : ViewModel
    @State private var code : String = ""
    var gitfile : GitFile
    var repository : Repository
    var body: some View{
        GroupBox(label:Label(gitfile.name, systemImage: "chart.bar.doc.horizontal")){
            CodeWebView(text: code).frame(minHeight:500,maxHeight:.infinity)
        }.groupBoxStyle(IssueGroupBoxStyle())
        .onAppear{
            viewmodel.getGitCode(repository,path: "\(gitfile.path)", completion: { str in
                code = str
            })
        }
    }
}

struct EmptyGitFile : View{
    @State private var moveRightLeft : Bool = false
    @State private var empty : Bool = false
    var body: some View{
        GroupBox{
            if empty{
                Text("레파토리가 비어있어요.").frame(maxWidth:.infinity)
            }else{
                HStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 5).frame(width:400,height:15,alignment: .center)
                            .foregroundColor(Color(.systemGray).opacity(0.3))
                        RoundedRectangle(cornerRadius: 5).clipShape(Rectangle().offset(x: moveRightLeft ? 240 : -240))
                            .frame(width:340,height:15,alignment: .leading)
                            .foregroundColor(Color(.darkGray).opacity(0.5))
                            .offset(x: moveRightLeft ? 28 : -28)
                            .animation(Animation.easeInOut(duration: 1).delay(0.2).repeatForever(autoreverses: true))
                            .onAppear{
                                moveRightLeft.toggle()
                            }
                    }
                    Spacer()
                }.frame(maxWidth:.infinity)
            }
        }.groupBoxStyle(LinkGroupBoxStyle()).onAppear{
            let time = DispatchTime.now() + .seconds(5)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                withAnimation(.spring()){
                    self.empty = true
                }
            })
        }
    }
}
