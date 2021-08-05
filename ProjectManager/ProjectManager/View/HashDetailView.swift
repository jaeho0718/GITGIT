//
//  HashDetailView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/11.
//

import SwiftUI

struct LinkCell : View{
    @EnvironmentObject var viewmodel : ViewModel
    @State private var popOver : Bool = false
    var data : Site
    var keyword : String?
    var research : Research
    var body: some View{
        GroupBox{
            HStack{
                /*
                 Button(action: {
                     data.star.toggle()
                     viewmodel.fetchData()
                 }){
                 }.buttonStyle(PinButtonStyle(pin: data.star))
                 */
                Spacer()
                Text(data.name ?? "이름을 불러올 수 없음")
                Spacer()
            }
        }.groupBoxStyle(LinkGroupBoxStyle())
        .onDrag {
            //optional 처리하기
            if let url = NSURL(string: data.url ?? ""){
                return NSItemProvider(object: url)
            }else{
                return NSItemProvider()
            }
        }
        .onTapGesture {
            popOver.toggle()
        }
        .contextMenu(ContextMenu(menuItems: {
            Button(action:{
                NSPasteboard.general.declareTypes([.string], owner: nil)
                NSPasteboard.general.setString(data.url ?? "", forType: .string)
            }){
                Text("링크복사")
            }
        }))
        .popover(isPresented: $popOver,arrowEdge: .top, content:{
            SitePopUp(url: data.url ?? "", title: data.name ?? "")
        })
    }
}
