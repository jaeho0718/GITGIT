//
//  AccountView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import SwiftUI

struct HomeView : View {
    @EnvironmentObject var viewmodel : ViewModel
    var backImg : String{
        return UserDefaults.standard.string(forKey: "wallpaper") ?? ""
    }
    var scrollBackground : some View{
        Group{
            if let url = URL(string: backImg){
                AsyncImage(url: url, placeholder: {
                    Rectangle().foregroundColor(.clear)
                }).clipped()
            }
        }
    }
    
    var body: some View{
        ScrollView(.vertical){
            HStack{
                Account()
                CommitChart()
            }.padding([.leading,.trailing,.top])
            HStack{
                Text("Event").font(.title).bold().padding(.leading)
                Spacer()
            }.padding(.top,10)
            EventView().padding([.leading,.trailing])
        }.background(scrollBackground)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(ViewModel())
    }
}
