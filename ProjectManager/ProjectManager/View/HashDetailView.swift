//
//  HashDetailView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/11.
//

import SwiftUI

struct HashDetailView: View {
    @EnvironmentObject var viewmodel : ViewModel
    var hash_data : Hashtag
    var body: some View {
        Form{
            Section(header:Label("이 레파토리와 관련된 링크", systemImage: "")){
                List{
                    ForEach(viewmodel.Sites.filter({$0.tagID == hash_data.tagID})){ site in
                        LinkCell(data: site)
                    }
                }
            }
        }.navigationTitle(Text("#\(hash_data.tag ?? "이름을 불러올 수 없음")"))
    }
}

struct LinkCell : View{
    @EnvironmentObject var viewmodel : ViewModel
    var data : Site
    var body: some View{
        GroupBox{
            HStack{
                Text(data.name ?? "이름을 불러올 수 없음")
            }.frame(maxWidth:.infinity)
        }.groupBoxStyle(LinkGroupBoxStyle())
        .onTapGesture {
            if let url = URL(string: data.url ?? ""){
                NSWorkspace.shared.open(url)
            }
        }.onDrag {
            //optional 처리하기
            return NSItemProvider(object: NSURL(string: data.url ?? "")!)
        }
    }
}
