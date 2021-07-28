//
//  AccountView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import SwiftUI

struct HomeView : View {
    @EnvironmentObject var viewmodel : ViewModel
    
    var scrollBackground : some View{
        AsyncImage(url: URL(string: "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg")!, placeholder: {
            
        }).clipped()
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
        }//.background(scrollBackground)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(ViewModel())
    }
}
