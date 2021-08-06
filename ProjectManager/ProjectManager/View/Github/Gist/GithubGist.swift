//
//  GithubGist.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/23.
//

import SwiftUI
import AlertToast
import SwiftUIX

struct GithubGist: View {
    @EnvironmentObject var viewmodel : ViewModel
    @TimerState(interval: 60) private var timer : Int
    @State private var gists : [Gist] = []
    @State private var onLoad : Bool = true
    var body: some View {
        VStack{
            List{
                if gists.isEmpty{
                    Text("None")
                }else{
                    ForEach(gists,id:\.node_id){ gist in
                        GistCell(data: gist)
                    }.onDelete(perform: deleteGist)
                }
            }
            HStack{
                Text("gists : \(gists.count)").font(.caption2).padding(.leading,5)
                Spacer()
            }.frame(maxHeight:20).background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        }.onAppear{
            viewmodel.getGist(completion: { result in
                gists = result
                onLoad = false
            },failer: {
                onLoad = false
            })
        }.toast(isPresenting: $onLoad, alert: {
            AlertToast(displayMode: .alert,type: .regular,title: "LOAD DATA")
        })
        .onChange(of: timer, perform: { value in
            onLoad = true
            viewmodel.getGist(completion: { result in
                gists = result
                onLoad = false
            },failer: {
                onLoad = false
            })
        })
    }
    func deleteGist(at indexOffset : IndexSet){
        indexOffset.forEach({ index in
            let gist = gists[index]
            viewmodel.deleteGist(gist.id)
        })
        gists.remove(atOffsets: indexOffset)
    }
}
