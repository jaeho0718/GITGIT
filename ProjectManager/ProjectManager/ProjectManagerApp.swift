//
//  ProjectManagerApp.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import SwiftUI

@main
struct ProjectManagerApp: App {
    @StateObject var viewmodel = ViewModel()
    @State private var start : initial_state = .content
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup{
            switch start{
                case .start:
                    StartView(initialState: $start).environmentObject(viewmodel)
                case .content:
                    ContentView().environmentObject(viewmodel).onAppear{
                        if UserDefaults.standard.bool(forKey: "start"){
                            start = .content
                        }else{
                            start = .start
                        }
                    }
            }
            //ContentView().environmentObject(viewmodel)
        }.onChange(of: scenePhase, perform: { value in
            print(value)
            if value == .active{
                if UserDefaults.standard.bool(forKey: "start"){
                    start = .content
                }else{
                    start = .start
                }
            }
        }).windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        
        Settings{
            Setting()
        }
    }
}

enum Windows : String,CaseIterable{
    case CodeReview = "CodeReview"
    
    func open(){
        if let url = URL(string: "ProjectManager://\(self.rawValue)"){
            NSWorkspace.shared.open(url)
        }
    }
}
