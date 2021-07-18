//
//  StartView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/14.
//

import SwiftUI
enum start_page {
    case start,introduce,introduce2
}

struct StartView: View {
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var show : Bool
    @State private var page : start_page = .start
    var body: some View {
        ZStack{
            switch page{
            case .start:
                Start1(page: $page)
            case .introduce:
                Start2(page: $page)
            case .introduce2:
                Start3(page: $page, show: $show)
            }
        }.frame(width:300,height:300)
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(show: .constant(true)).environmentObject(ViewModel())
    }
}

struct Start1 : View{
    @Binding var page : start_page
    var body: some View {
        VStack{
            Text("안녕하세요").bold().font(.largeTitle)
            Text("안녕하세요").bold().font(.largeTitle)
            Button(action:{
                page = .introduce
            }){
                Text("시작하기")
            }.buttonStyle(StartButtonStyle())
            .shadow(radius: 0.5)
        }
    }
}

struct Start2 : View{
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var page : start_page
    @State private var id : String = ""
    @State private var password : String = ""
    var body: some View {
        VStack{
            Text("깃허브 연동").bold().font(.largeTitle)
            Text("프로그램을 이용하기 위해서 Github와 연동해야합니다.").font(.callout)
            Spacer()
            Group{
                ZStack{
                    viewmodel.getUserImage().resizable().clipShape(Circle()).overlay(Circle().stroke(lineWidth: 2)).padding()
                }.aspectRatio(contentMode: .fit)
                TextField("깃허브 ID", text: $id).textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Access Token", text: $password).textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding([.leading,.trailing])
            Spacer()
            Button(action:{
                if check(){
                    if viewmodel.UserInfo != nil{
                        //not save first time
                        if !(viewmodel.updateUser(User(user_name: id, access_token: password))){
                        }else{
                            viewmodel.fetchData()
                            if viewmodel.UserInfo != nil{
                                page = .introduce2
                            }
                        }
                    }else{
                        if !(viewmodel.createUser(User(user_name: id, access_token: password))){
                        }else{
                            viewmodel.fetchData()
                            if viewmodel.UserInfo != nil{
                                page = .introduce2
                            }
                        }
                    }
                }
            }){
                Text("연동하기")
            }.buttonStyle(StartButtonStyle())
            .shadow(radius: 0.5)
        }.padding([.top,.bottom])
        .onAppear{
            id = viewmodel.UserInfo?.user_name ?? ""
            password = viewmodel.UserInfo?.access_token ?? ""
        }
    }
    func check()->Bool{
        if password.isEmpty && id.isEmpty{
            return false
        }else{
            return true
        }
    }
}

struct Start3 : View{
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var page : start_page
    @Binding var show : Bool
    var body: some View{
        VStack{
            Text("기능").bold().font(.largeTitle)
            Group{
                HStack{
                    Image(systemName: "link").resizable().foregroundColor(.blue).aspectRatio(contentMode: .fit).frame(width:20,height:20)
                    Spacer()
                    Text("깃허브 연동으로 이슈를 확인하고 이슈와 관련한 자료를 쉽게 수집할 수 있어요.").frame(width:250)
                }
            }
            Divider()
            Group{
                HStack{
                    Image(systemName: "doc.text.magnifyingglass").resizable().foregroundColor(.orange).aspectRatio(contentMode: .fit).frame(width:20,height:20)
                    Spacer()
                    Text("프로젝트와 관련된 자료들을 드래그앤드롭으로 바로 추가하세요.").frame(width:250)
                }
            }
            Divider()
            Group{
                HStack{
                    Image(systemName: "number.square").resizable().foregroundColor(.green).aspectRatio(contentMode: .fit).frame(width:20,height:20)
                    Spacer()
                    VStack(alignment:.leading){
                        Text("사용자가 정리한 자료를 바탕으로 도움이 될만한 자료를 추천해줘요.")
                        Text("Beta기능으로 불안정할 수 있습니다.").font(.caption2).opacity(0.6)
                    }.frame(width:250)
                }
            }
            Spacer()
            Button(action:{
                viewmodel.fetchData()
                show = false
            }){
                Text("시작하기")
            }.buttonStyle(StartButtonStyle())
            .shadow(radius: 0.5)
        }.padding()
    }
}
