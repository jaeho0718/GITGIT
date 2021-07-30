//
//  ContentView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import SwiftUI
struct ContentView: View {
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var internetConnect : Bool
    var body: some View {
        SideBar(connectInternet: $internetConnect)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(internetConnect: .constant(true)).environmentObject(ViewModel())
    }
}
