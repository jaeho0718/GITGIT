//
//  GitubPage.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/10.
//

import SwiftUI

struct GitubPage: View {
    @EnvironmentObject var viewmodel : ViewModel
    var url : String
    var body: some View {
        VStack(alignment:.leading,spacing:0){
            HStack(alignment:.center){
                Text("GITHUB").bold().foregroundColor(.white)
                    .padding(5).background(Color.black)
                if let info = viewmodel.GithubUserInfo{
                    Text("\(info.name) : ")
                }
                Text(url).font(.caption).opacity(0.8)
            }
            WebView(url: url, user: viewmodel.UserInfo)
        }
    }
}

struct GitubPage_Previews: PreviewProvider {
    static var previews: some View {
        GitubPage(url: "https://github.com/jaeho0718/git-playground").environmentObject(ViewModel())
    }
}
