//
//  ProjectManagerApp.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import SwiftUI
import Network
@main
struct ProjectManagerApp: App {
    @StateObject var viewmodel = ViewModel()
    @State private var start : initial_state = .content
    @State private var connectInternet : Bool = true
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup{
            switch start{
                case .start:
                    StartView(initialState: $start).environmentObject(viewmodel)
                case .content:
                    ContentView(internetConnect: $connectInternet).environmentObject(viewmodel).onAppear{
                        if UserDefaults.standard.bool(forKey: "start"){
                            start = .content
                        }else{
                            start = .start
                        }
                        let monitor = NWPathMonitor()
                        monitor.pathUpdateHandler = { path in
                            if path.status == .satisfied{
                                connectInternet = true
                            }else{
                                connectInternet = false
                            }
                        }
                        let queue = DispatchQueue(label: "Monitor")
                        monitor.start(queue: queue)
                    }
            }
            //ContentView().environmentObject(viewmodel)
        }
        .onChange(of: scenePhase, perform: { phase in
            print(phase)
            if phase == .active{
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
