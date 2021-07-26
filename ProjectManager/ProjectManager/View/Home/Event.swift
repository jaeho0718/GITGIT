//
//  Event.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/26.
//

import Foundation
import SwiftUI
import WaterfallGrid

struct EventView : View{
    @EnvironmentObject var viewmodel : ViewModel
    @State private var events : [GitEvent] = []
    var editedEvent : [GitEvent]{
        if events.count < 8 {
            return events
        }else{
            return Array(events[events.startIndex...events.startIndex+8])
        }
    }
    var body: some View{
        WaterfallGrid(editedEvent,id:\.id){ event in
            EventCell(event: event)
        }
        .gridStyle(spacing: 8)
        .onAppear{
            viewmodel.getGitEvents(completion: { result in
                events = result
            })
        }
    }
}

struct EventCell : View{
    var event : GitEvent
    @EnvironmentObject var viewmodel : ViewModel
    var body: some View{
        HStack(alignment:.center){
            Group{
                if let url = URL(string:"https://github.com/\(event.repo.name.components(separatedBy: "/").first ?? "").png"){
                    AsyncImage(url: url, placeholder: {Image(systemName: "person.crop.circle.fill").resizable()}).frame(width:40,height:40)
                        .clipShape(Circle())
                        .padding(.leading)
                }
                Text(event.repo.name.components(separatedBy: "/").last ?? "").bold()
                Spacer()
            }.frame(width:100)
            Divider()
            Spacer()
            VStack(alignment:.leading){
                Text(event.type).bold().foregroundColor(.secondary)
                Text(getGitDate(event.created_at)).foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth:.infinity,minHeight:50,maxHeight:60)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    func getGitDate(_ date : String)->String{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "YYYY-MM-dd"
        guard let date = dateFormat.date(from: String(date.split(separator: "T").first ?? "")) else {return ""}
        dateFormat.dateFormat = "YYYY.MM.dd"
        return dateFormat.string(from: date)
    }
}

