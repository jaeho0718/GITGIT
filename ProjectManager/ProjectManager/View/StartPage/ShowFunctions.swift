//
//  ShowFunctions.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/14.
//

import SwiftUI

struct ShowFunctions: View {
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading,spacing:10){
                Text("다양한 기능을 활요해보세요.").font(.title).bold()
                Section(header:Label("Repository 관리", systemImage: "filemenu.and.selection")){
                    Text("Github와의 연동성은 사용자에게 강력한 도구가되죠. 연동을 통해 레파지토리를 관리하고 관련된 자료를 정리할 수 있어요.")
                }
                Section(header:Label("Issues 관리", systemImage: "ladybug")){
                    Text("Issue를 바로 확인하고 Comments를 달아보세요! 각 레퍼지토리 마다 잘 정리된 Issue들은 어떤 것을 수정해야하는지 영감을 줍니다.")
                }
                Section(header:Label("자료 찾기", systemImage: "doc.text.fill.viewfinder")){
                    Text("깃허브,스택오버플로우와의 연동은 사용자가 자료를 찾는데 막강 도구가 됩니다.")
                }
            }.padding([.leading,.trailing,.top])
        }.navigationTitle(Text("기능"))
    }
}

struct ShowFunctions_Previews: PreviewProvider {
    static var previews: some View {
        ShowFunctions()
    }
}
