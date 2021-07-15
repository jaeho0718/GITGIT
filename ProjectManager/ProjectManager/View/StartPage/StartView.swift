//
//  StartView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/14.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var viewmodel : ViewModel
    var body: some View {
        NavigationView{
            Form{
                Text("안녕하세요").font(.title).bold().foregroundColor(.white)
                NavigationLink(destination:AccountView()){
                    Label("Github계정 연동하기", systemImage: "link").foregroundColor(.white)
                        .font(.caption)
                        .frame(minWidth:200)
                }.background(Color.black)
                .padding([.leading,.trailing],3)
                NavigationLink(destination:ShowFunctions()){
                    Label("기능 보기", systemImage: "text.magnifyingglass").foregroundColor(.white)
                        .font(.caption)
                        .frame(minWidth:200)
                }.background(Color.black).padding([.leading,.trailing],3)
                Button(action:{
                    UserDefaults.standard.setValue(true, forKey: "start")
                }){
                    Text("시작하기").foregroundColor(.white)
                        .font(.caption)
                        .frame(minWidth:200)
                }.background(Color.black)
                .padding([.leading,.trailing],3)
            }.navigationTitle(Text("시작하기"))
            .frame(maxWidth:.infinity,minHeight: 400, maxHeight:.infinity)
            .background(StartBackground())
            .environment(\.colorScheme, .light)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
