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
        case failtoupadate,failtocreate,alerttodelete
        var id : Int{
            hashValue
        }
    }
    var body: some View {
        Form{
            GroupBox(label:Label("GitHub Information", systemImage:"person.crop.circle")){
                if viewmodel.UserInfo != nil{
                    HStack{
                        viewmodel.getUserImage().resizable()
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
                    }
                }else{
                    Text("GitHub와 연동할 수 없습니다.").font(.caption2).opacity(0.8).padding(5)
                }
            }.groupBoxStyle(IssueGroupBoxStyle())
            
            GroupBox(label:Label("GitHub ID", systemImage: "lock.circle")){
                VStack(alignment:.leading){
                    HStack{
                        Text("user name :").frame(width:100)
                        TextField("user name", text: $user_name)
                    }
                    HStack{
                        Text("access tokens :").frame(width:100)
                        SecureField("personal access tokens", text: $user_token)
                    }
                    if viewmodel.UserInfo == nil{
                        Text("Access Token이 존재하지 않습니다.").font(.caption2).opacity(0.8)
                            .padding(.top,2)
                        Text("Github>Setting>DeveloperSettings에서 token을 얻을 수 있습니다.").font(.caption2).opacity(0.8)
                    }
                    HStack{
                        Button(action:{
                            if check(){
                                if viewmodel.UserInfo != nil{
                                    //not save first time
                                    if !(viewmodel.updateUser(User(user_name: user_name, access_token: user_token))){
                                        alert = .failtoupadate
                                    }else{
                                        setup()
                                        viewmodel.fetchData()
                                    }
                                }else{
                                    if !(viewmodel.createUser(User(user_name: user_name, access_token: user_token))){
                                        alert = .failtocreate
                                    }else{
                                        setup()
                                        viewmodel.fetchData()
                                    }
                                }
                            }else{
                                alert = .failtocreate
                            }
                        }){
                            Text("저장")
                        }.buttonStyle(AddButtonStyle())
                        if viewmodel.UserInfo != nil{
                            Button(action:{
                                alert = .alerttodelete
                            }){
                                Text("삭제")
                            }.buttonStyle(AddButtonStyle())
                        }
                    }.frame(maxWidth:.infinity)
                }
            }.groupBoxStyle(IssueGroupBoxStyle())
            Button(action:{
                UserDefaults.standard.setValue(false, forKey: "start")
            }){
                Text("시작화면 테스트용 초기화")
            }
            Spacer()
        }
        .frame(maxWidth:.infinity)
        .padding()
        .alert(item: $alert, content: { type in
            switch type{
            case .failtocreate:
                return Alert(title: Text("오류"), message: Text("저장하는데 실패했습니다."))
            case .failtoupadate:
                return Alert(title: Text("오류"), message: Text("정보를 업데이트하는데 실패했습니다."))
            case .alerttodelete:
                return Alert(title: Text("경고"), message: Text("계정을 삭제하면 이와 관련된 자료들이 모두 삭제됩니다."), primaryButton: .default(Text("계정 지우기"), action: {
                    removeAllData()
                }), secondaryButton: .cancel())
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
    
    func removeAllData(){
        DispatchQueue.main.async {
            if !(viewmodel.deleteUser()){
                alert = .failtocreate
            }else{
                for research in viewmodel.Researchs{
                    viewmodel.deleteData(research)
                }
                for hashtag in viewmodel.Hashtags{
                    viewmodel.deleteData(hashtag)
                }
                for site in viewmodel.Sites{
                    viewmodel.deleteData(site)
                }
                for repo in viewmodel.Repositories{
                    viewmodel.deleteData(repo)
                }
                user_name = ""
                user_token = ""
                viewmodel.fetchData()
            }
        }
    }
    
    func check()->Bool{
        if user_token.isEmpty{
            return false
        }else{
            return true
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView().environmentObject(ViewModel())
    }
}
