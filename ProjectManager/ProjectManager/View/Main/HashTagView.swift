//
//  HashTagView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/08/04.
//

import SwiftUI
import AlertToast
import WaterfallGrid

struct HashTagView: View {
    @EnvironmentObject var viewmodel : ViewModel
    var repo : Repository
    var tag : Hashtag
    @State private var searchResults : [GitSearchItem] = []
    @State private var onLoad : Bool = true
    var sites : [Site]{
        return viewmodel.Sites.filter({ site in
            for tags in viewmodel.Hashtags.filter({$0.tagID == site.tagID}){
                if tags.tag == tag.tag{
                    return true
                }
            }
            return false
        }).sorted(by: {$0.rate > $1.rate})
    }
    var items: [GridItem] {
        Array(repeating: .init(.flexible(minimum: 200, maximum: .infinity)), count: 2)
    }
    struct siteView : View{
        @State private var popover : Bool = false
        var site : Site
        var body: some View{
            VStack{
                Text(site.name ?? "").font(.title2).bold()
                Spacer()
                HStack{
                    Button(action:{
                        popover.toggle()
                    }){
                        Image(systemName: "doc.text").foregroundColor(.secondary)
                    }.buttonStyle(RemoveBackgroundStyle())
                    Spacer()
                }
            }.padding(5).frame(maxWidth:150,maxHeight:200).background(VisualEffectView(material: .popover, blendingMode: .withinWindow).clipShape(RoundedRectangle(cornerRadius: 10)))
            .popover(isPresented: $popover, content: {
                SitePopUp(url: site.url ?? "", title: site.name ?? "")
            })
        }
    }
    
    var body: some View {
        ScrollView(.vertical,showsIndicators : false){
            VStack(spacing:20){
                HStack{
                    Text("# \(tag.tag ?? "Null")").font(.largeTitle).bold()
                    Spacer()
                }
                ScrollView(.horizontal,showsIndicators:false){
                    HStack(spacing:10){
                        ForEach(sites){ site in
                            siteView(site: site)
                        }
                    }
                }.frame(height:200)
                HStack{
                    Text("추천").font(.largeTitle).bold()
                    Spacer()
                }
                WaterfallGrid(searchResults,id:\.url){ result in
                    GitSearchView(item: result)
                }
            }
        }
        .frame(minWidth:400)
        .padding(10)
        .onAppear{
            DispatchQueue.global().async {
                viewmodel.getGitSearch(keyword: tag.tag ?? "", language: repo.language, completion: { result in
                    self.searchResults = result.items.filter({$0.repository.owner.login != viewmodel.UserInfo?.user_name})
                    onLoad = false
                }, failer: {
                    onLoad = false
                })
            }
        }.onChange(of: onLoad, perform: { value in
            viewmodel.fetchData()
        })
        .onDisappear{
            viewmodel.fetchData()
        }
        .blur(radius: onLoad ? 10 : 0)
        .overlay({
            ZStack{
                if onLoad{
                    LoadSearch()
                }
            }
        })
        
    }
}

struct LoadSearch : View{
    @State private var animation : Bool = false
    var body: some View{
        HStack(alignment:.center){
            Circle().frame(width:15,height:15).foregroundColor(.red).offset(y: animation ? 0 : -50)
                .animation(.interpolatingSpring(stiffness: 170, damping: 5).repeatForever(autoreverses: false))
            Circle().frame(width:15,height:15).foregroundColor(.orange).offset(y: animation ? 0 : -50)
                .animation(.interpolatingSpring(stiffness: 170, damping: 5).repeatForever(autoreverses: false).delay(0.03))
            Circle().frame(width:15,height:15).foregroundColor(.green).offset(y: animation ? 0 : -50)
                .animation(.interpolatingSpring(stiffness: 170, damping: 5).repeatForever(autoreverses: false).delay(0.03*2))
            Circle().frame(width:15,height:15).foregroundColor(.blue).offset(y: animation ? 0 : -50)
                .animation(.interpolatingSpring(stiffness: 170, damping: 5).repeatForever(autoreverses: false).delay(0.03*3))
            Circle().frame(width:15,height:15).foregroundColor(.purple).offset(y: animation ? 0 : -50)
                .animation(.interpolatingSpring(stiffness: 170, damping: 5).repeatForever(autoreverses: false).delay(0.03*4))
        }.onAppear{
            animation.toggle()
        }
    }
}

/*
struct LoadSearchPreview : PreviewProvider{
    static var previews: some View{
        LoadSearch()
    }
}
*/
