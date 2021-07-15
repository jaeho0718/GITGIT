//
//  ContentView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewmodel : ViewModel
    var body: some View {
        SideBar()
            .sheet(isPresented: .constant(false), content: {
                StartView()
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewModel())
    }
}
