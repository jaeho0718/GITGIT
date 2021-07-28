//
//  GithubGist.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/23.
//

import SwiftUI

struct GithubGist: View {
    @EnvironmentObject var viewmodel : ViewModel
    @State private var gists : [Gist] = []
    var body: some View {
        VStack{
            List{
                ForEach(gists,id:\.node_id){ gist in
                    GistCell(data: gist)
                }.onDelete(perform: deleteGist)
            }
            HStack{
                Text("gists : \(gists.count)").font(.caption2).padding(.leading,5)
                Spacer()
            }.frame(maxHeight:20).background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        }.onAppear{
            viewmodel.getGist(completion: { result in
                gists = result
            })
        }
    }
    func deleteGist(at indexOffset : IndexSet){
        indexOffset.forEach({ index in
            let gist = gists[index]
            viewmodel.deleteGist(gist.id)
        })
        gists.remove(atOffsets: indexOffset)
    }
}
