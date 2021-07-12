//
//  AccountView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var viewmodel : ViewModel
    @State private var user_token : String = ""
    @State private var user_name : String = ""
    @State private var alert : error_type? = nil
    enum error_type : Identifiable{
        case failtoupadate,failtocreate
        var id : Int{
            hashValue
        }
    }
    var body: some View {
        Form{
            Section(header:Label("User Information", systemImage:"person.crop.circle")){
                HStack{
                    if viewmodel.UserInfo != nil{
                        viewmodel.getImage(viewmodel.UserInfo).resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width:100,height:100).clipShape(Circle())
                            .overlay(Circle().stroke(lineWidth: 3))
                            .padding(5)
                        VStack(alignment:.leading){
                            if let userdata = viewmodel.GithubUserInfo{
                                Text("Login Name : \(userdata.login)").padding(.bottom,1)
                                Text("User Name : \(userdata.name)").padding(.bottom,1)
                            }else{
                                Text("사용자 정보를 불러올 수 없습니다.").font(.caption2).opacity(0.8)
                            }
                        }
                    }else{
                        Text("사용자 정보를 불러올 수 없습니다.").font(.caption2).opacity(0.8)
                    }
                }
            }.padding(5)
            Section(header:Label("UserTocken", systemImage: "lock.circle")){
                VStack(alignment:.leading){
                    if viewmodel.UserInfo == nil{
                        Text("Access Token이 존재하지 않습니다.").font(.caption2).opacity(0.8)
                            .padding(.top,2)
                        Text("Github>Setting>DeveloperSettings에서 token을 얻을 수 있습니다.").font(.caption2).opacity(0.8)
                    }
                    HStack{
                        Text("user name :").frame(width:100)
                        TextField("user name", text: $user_name)
                    }
                    HStack{
                        Text("access tokens :").frame(width:100)
                        SecureField("personal access tokens", text: $user_token)
                    }
                    HStack{
                        Button(action:{
                            if viewmodel.UserInfo != nil{
                                //not save first time
                                if !(viewmodel.updateUser(User(user_name: user_name, access_token: user_token))){
                                    alert = .failtoupadate
                                }else{
                                    viewmodel.fetchData()
                                    setup()
                                }
                            }else{
                                if !(viewmodel.createUser(User(user_name: user_name, access_token: user_token))){
                                    alert = .failtocreate
                                }else{
                                    viewmodel.fetchData()
                                    setup()
                                }
                            }
                        }){
                            Text("저장")
                        }
                        if viewmodel.UserInfo != nil{
                            Button(action:{
                                if !(viewmodel.deleteUser()){
                                    alert = .failtocreate
                                }else{
                                    user_name = ""
                                    user_token = ""
                                    viewmodel.fetchData()
                                }
                            }){
                                Text("삭제")
                            }
                        }
                    }.frame(maxWidth:.infinity)
                }
            }.padding(5)
            Spacer()
        }.frame(maxWidth:.infinity)
        .alert(item: $alert, content: { type in
            switch type{
            case .failtocreate:
                return Alert(title: Text("오류"), message: Text("저장하는데 실패했습니다."))
            case .failtoupadate:
                return Alert(title: Text("오류"), message: Text("정보를 업데이트하는데 실패했습니다."))
            }
        }).onAppear{
            setup()
        }
        .navigationTitle(Text("계정 설정"))
        
    }
    
    func setup(){
        if let user = viewmodel.UserInfo{
            user_token = user.access_token
            user_name = user.user_name
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView().environmentObject(ViewModel())
    }
}
