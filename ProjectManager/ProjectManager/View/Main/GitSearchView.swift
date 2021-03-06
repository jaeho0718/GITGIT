//
//  GitSearchView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/08/04.
//

import SwiftUI
import CodeMirror_SwiftUI
import Alamofire
import AlertToast

struct GitSearchView: View {
    @EnvironmentObject var viewmodel : ViewModel
    @State private var popup : Bool = false
    @State private var code : String = ""
    @State private var downloadSuccess : Bool = false
    @State private var downloadDirect : String = ""
    @State private var downloadError : Bool = false
    @State private var downloadErrorCode : String = ""
    var item : GitSearchItem
    var path : [String]{
        let str = item.path
        return str.components(separatedBy: "/")
    }
    var CodePopup : some View{
        ScrollView{
            PatchTextView(normalMode: true, patch: code)
        }
    }
    
    var body: some View {
        VStack(alignment:.leading){
            HStack(alignment:.center){
                if let url = URL(string: "https://github.com/\(item.repository.owner.login).png"){
                    AsyncImage(url: url, placeholder: {
                        Image(systemName: "person.circle")
                    }).frame(width:25,height:25).clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
                Text("GITHUB").bold().font(.caption).padding(2)
                    .foregroundColor(.white).background(Color.black)
                    .onTapGesture {
                        if let url = URL(string: item.html_url ?? ""){
                            NSWorkspace.shared.open(url)
                        }
                    }
            }
            Text(item.name).font(.title).bold()
            Text(item.repository.description ?? "").font(.headline).foregroundColor(.secondary)
            if popup{
                Divider()
                CodePopup
            }
            Spacer()
            if !popup{
                Text("Tap to show code").font(.caption).opacity(0.5)
            }
            Divider()
            HStack{
                ScrollView(.horizontal,showsIndicators:false){
                    ScrollViewReader{ value in
                        HStack(spacing:1){
                            ForEach(path,id:\.self){ str in
                                if path.last == str{
                                    Text("\(str)").font(.caption).foregroundColor(.white).padding([.leading,.trailing],5).padding([.bottom,.top],1).background(Color.black).id(1)
                                }else{
                                    Text("\(str)>").font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }.onAppear{
                            value.scrollTo(1, anchor: .trailing)
                        }
                    }
                }.allowsHitTesting(false)
                Button(action:{
                    if let url = showOpenPanel(){
                        viewmodel.downloadGitCode(item.url, downloadUrl: url,completion: {url in
                            downloadDirect = url
                            downloadSuccess.toggle()
                        },failer: { error in
                            downloadErrorCode = error
                            downloadError.toggle()
                        })
                    }else{
                        print("Fail to get folder2")
                    }
                }){
                    Text("Download")
                }.buttonStyle(AddButtonStyle())
            }
        }
        .padding(10).frame(minWidth:200,maxWidth: .infinity,minHeight:130,maxHeight: popup ? 600 : 170).background(VisualEffectView(material: .popover, blendingMode: .withinWindow).clipShape(RoundedRectangle(cornerRadius: 10)))
        .onTapGesture {
            popup.toggle()
        }
        .onAppear{
            viewmodel.getSearchCode(item.url, completion: { result in
                self.code = result
            }, failer: { error in
                self.code = error
            })
        }
        .onDrag({
            if let source_data = try? JSONEncoder().encode(makeFile()){
                let data = source_data
                return NSItemProvider(item: .some(data as NSSecureCoding), typeIdentifier: String(kUTTypeData))
            }else{
                return NSItemProvider()
            }
        })
        .toast(isPresenting: $downloadSuccess, alert: {
            AlertToast(displayMode: .alert, type: .regular,title: "???????????? ??????",subTitle: downloadDirect)
        })
        .toast(isPresenting: $downloadError,duration: 30, tapToDismiss: true, alert: {
            AlertToast(displayMode:.alert, type: .regular, title: "???????????? ??????",subTitle: downloadErrorCode)
        })
    }
    
    func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
    func makeFile()->file{
        return file(name: "\(item.repository.owner.login)/\(item.name)", code: code)
    }
}

struct GitSearchViewPreview : PreviewProvider{
    static var previews: some View{
        GitSearchView(item: GitSearchItem(name: "TextRankTests.swift", path: "Tests/TextRankTests/TextRankTests.swift", sha:"ef8f8bce81e7db08434ba4a763be18d6bd932bab", url: "https://api.github.com/repositories/313021244/contents/Tests/TextRankTests/TextRankTests.swift?ref=cd740f1db67b589db9e22cdfa2b4aa893006d78a", git_url: "https://api.github.com/repositories/313021244/git/blobs/ef8f8bce81e7db08434ba4a763be18d6bd932bab", html_url: "https://github.com/jhrcook/TextRank", repository: .init(id: 313021244, name: "TextRank", full_name: "jhrcook/TextRank", description: "A Swift package that implements the 'TextRank' algorithm for text summarization.", owner: .init(login: "jhrcook")))).environmentObject(ViewModel())
    }
}

extension GitSearchView{
    struct file : Codable{
        var name : String
        var code : String
    }
}

extension String{
    func fromBase64()->String?{
        if let data = Data(base64Encoded: self,options: .ignoreUnknownCharacters){
            return String(data:data as Data,encoding: .utf8)
        }else{
            return nil
        }
    }
}
