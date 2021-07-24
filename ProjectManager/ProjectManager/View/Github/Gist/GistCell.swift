//
//  GistCell.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/23.
//

import SwiftUI
import CodeMirror_SwiftUI
import MarkdownUI

struct GistCell: View {
    @EnvironmentObject var viewmodel : ViewModel
    @Environment(\.colorScheme) var colorScheme
    var data : Gist
    @State private var code : String = ""
    @State private var show_detail : Bool = true
    var body: some View {
        GroupBox(label:Label(
            title: {
                HStack {
                    Text(data.files.first?.value.filename ?? "No Name")
                    Spacer()
                    if data.gist_public{
                        Text("Public").font(.caption2).padding(5)
                            .overlay(Capsule().stroke(lineWidth: 2)).foregroundColor(.blue)
                    }else{
                        Text("Private").font(.caption2).padding(5)
                            .overlay(Capsule().stroke(lineWidth: 2)).foregroundColor(.red)
                    }
                }
            },
            icon: { viewmodel.getUserImage(data.owner.login).resizable().aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .overlay(Circle().stroke())
                .frame(width:20)
                .help(data.owner.login)
            }
        )){
            if show_detail{
                CodeView(theme:  colorScheme == .dark ? SettingValue.getTheme(viewmodel.settingValue.code_type_dark) : SettingValue.getTheme(viewmodel.settingValue.code_type_light), code: $code, mode: FileType.getType(data.files.first?.value.filename ?? "Null.swift").code_mode.mode(), fontSize: 12, showInvisibleCharacters: false, lineWrapping: false).frame(minHeight:300,maxHeight:600)
                Markdown("\(data.description)")
            }else{
                Text("Tap to show more").font(.caption2).opacity(0.6)
            }
        }.groupBoxStyle(IssueGroupBoxStyle()).onAppear{
            viewmodel.getGitCode(data.files.first?.value.raw_url ?? "", completion: { value in
                code = value
            })
        }.onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)){
                show_detail.toggle()
            }
        }
    }
}

struct GistCell_Previews: PreviewProvider {
    static var previews: some View {
        GistCell(data: Gist(id: "", url: "https://api.github.com/gists/a6a488078cad59adad876944aebee102", node_id: "MDQ6R2lzdGE2YTQ4ODA3OGNhZDU5YWRhZDg3Njk0NGFlYmVlMTAy", html_url: "https://gist.github.com/a6a488078cad59adad876944aebee102", created_at: "2021-07-23T07:07:37Z", updated_at: "2021-07-23T07:07:37Z", comments: 1, gist_public: false, owner: GistOwner(login: "jaeho0718"), files: ["GitHubData.swift": GistFiles(filename: "GitHubData.swift", type: "text/plain", language: "Swift", raw_url: "https://gist.githubusercontent.com/jaeho0718/a6a488078cad59adad876944aebee102/raw/ab4c2df2399c9eb393430d232dbfe00f52e17020/GitHubData.swift")], description: "test"))
            .environmentObject(ViewModel())
    }
}
