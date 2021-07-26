//
//  Account.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/26.
//

import Foundation
import SwiftUI

struct Account : View{
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
    
    var body: some View{
        VStack(spacing:5){
            Spacer()
            Group{
                if let user = viewmodel.GithubUserInfo{
                    viewmodel.getUserImage().resizable().aspectRatio(contentMode: .fit).frame(width:70,height:70).clipShape(Circle())
                    Text(user.name).bold().font(.largeTitle)
                    Link("> GitHub <", destination: URL(string: user.html_url)!)
                }else{
                    Image("github").resizable().aspectRatio(contentMode: .fit)
                        .frame(width:70,height:70)
                    Text("깃허브 연동").bold().font(.largeTitle)
                    Text("프로그램을 이용하기 위해서 Github와 연동해야합니다.").font(.callout)
                }
            }
            Spacer()
            Group{
                TextField("깃허브 ID", text: $user_name).textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Access Token", text: $user_token).textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding([.leading,.trailing])
            Spacer()
            Button(action:{
                update()
            }){
                Text(viewmodel.UserInfo == nil ? "Connect" : "Update")
                    .bold()
                    .font(.callout)
                    .foregroundColor(.white)
                    .frame(maxWidth:.infinity,maxHeight:40)
            }.buttonStyle(RemoveBackgroundStyle()).background(Color.green)
            .cornerRadius(10)
            .padding([.leading,.trailing])
            Button(action:{
                alert = .alerttodelete
            }){
                Text("Disconnect")
                    .bold()
                    .font(.callout)
                    .foregroundColor(.white)
                    .frame(maxWidth:.infinity,maxHeight:40)
            }.buttonStyle(RemoveBackgroundStyle()).background(Color.gray)
            .cornerRadius(10)
            .padding([.leading,.trailing])
            Spacer()
        }.frame(width:350,height:350)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear{setup()}
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
        })
        
    }
    
    func setup(){
        if let user = viewmodel.UserInfo{
            user_token = user.access_token
            user_name = user.user_name
        }
    }
    
    func update(){
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
    }
    
    func check()->Bool{
        if user_token.isEmpty{
            return false
        }else{
            return true
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
                for code in viewmodel.Codes{
                    viewmodel.deleteData(code)
                }
                for review in viewmodel.CodeReviews{
                    viewmodel.deleteData(review)
                }
                user_name = ""
                user_token = ""
                viewmodel.fetchData()
            }
        }
    }
}

struct Account_Previews: PreviewProvider {
    static var previews: some View {
        Account().environmentObject(ViewModel())
    }
}
