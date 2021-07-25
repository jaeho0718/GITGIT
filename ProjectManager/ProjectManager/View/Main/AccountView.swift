//
//  AccountView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import SwiftUI
import Charts
import WaterfallGrid

struct HomeView : View {
    @EnvironmentObject var viewmodel : ViewModel
    
    var body: some View{
        ScrollView(.vertical){
            HStack{
                Account()
                CommitChart()
            }.padding([.leading,.trailing,.top])
            HStack{
                Text("Event").font(.title).bold().padding(.leading)
                Spacer()
            }.padding(.top,10)
            EventView().padding([.leading,.trailing])
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(ViewModel())
    }
}

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
                Text("Remove")
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

struct CommitChart : View{
    @EnvironmentObject var viewmodel : ViewModel
    @State private var entities : [Double] = []
    var body: some View{
        VStack{
            Text("Commits").padding(.top,5).font(.callout).foregroundColor(.secondary)
            Chart(data: entities)
                .chartStyle(
                    LineChartStyle(.quadCurve, lineColor: .green, lineWidth: 4)
                )
                .padding([.leading,.trailing])
        }.frame(minWidth:300,maxWidth:.infinity)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear{createEntities()}
    }
    
    func createEntities(){
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd"
        let day = Date().get(.day)
        let month = Date().get(.month)
        let year = Date().get(.year)
        var entityInfo : [Int:Int] = [:]
        for toDay in 1...day{
            entityInfo[toDay] = 0
        }
        DispatchQueue.main.async {
            _ = viewmodel.Repositories.map({
                viewmodel.getCommits(repository: $0, completion: { commit in
                    for toDay in 1...day{
                        let date = dateformatter.date(from: "\(year)-\(month)-\(toDay)")
                        let counts = commit.filter({
                            var commit_day : String = $0.commit.committer["date"] ?? "2021-07-24T13:09:15Z"
                            commit_day = commit_day.components(separatedBy: "T").first ?? "2021-07-24"
                            let commit_date = dateformatter.date(from: commit_day)
                            return commit_date == date
                        }).count
                        entityInfo[toDay]! += counts
                    }
                    entities = []
                    let total = Double(entityInfo.keys.reduce(0){$0+$1})/Double(entityInfo.keys.count)
                    let sortedinfo = entityInfo.sorted(by: {$0.key < $1.key})
                    _ = sortedinfo.map({ (key,value) in
                        if value == 0{
                            entities.append(0.1)
                        }else{
                            entities.append(Double(value)/total+0.1)
                        }
                    })
                })
            })
        }
    }
}

struct EventView : View{
    @EnvironmentObject var viewmodel : ViewModel
    @State private var events : [GitEvent] = []
    var body: some View{
        WaterfallGrid(events,id:\.id){ event in
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
                    AsyncImage(url: url, placeholder: {Text("Test")}).frame(width:25,height:25)
                        .clipShape(Circle())
                        .padding(.leading)
                }
                Text(event.repo.name.components(separatedBy: "/").last ?? "").bold()
                Spacer()
            }.frame(width:100)
            Divider()
            Spacer()
            Text(event.type).bold().foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth:.infinity,minHeight:50,maxHeight:60)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
