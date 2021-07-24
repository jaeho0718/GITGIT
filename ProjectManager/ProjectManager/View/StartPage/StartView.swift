//
//  StartView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/14.
//

import SwiftUI
import AVKit
import CodeMirror_SwiftUI

enum start_page {
    case start,introduce,introduce2,settingdata,introduce3
}

enum initial_state {
    case start,content
}

struct StartView: View {
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var initialState : initial_state
    @State private var page : start_page = .start
    @State private var language : SettingValue.language = .Korean
    @State private var code_theme_light : CodeViewTheme = .irWhite
    @State private var code_theme_dark : CodeViewTheme = .irBlack
    var player : AVPlayer{
        let av = AVPlayer(url: Bundle.main.url(forResource: "Stars", withExtension: "mp4")!)
        av.isMuted = true
        av.allowsExternalPlayback = false
        av.play()
        return av
    }
    var body: some View {
        ZStack{
            AVPlayerControllerRepresented(player: player).aspectRatio(contentMode: .fill).allowsHitTesting(false)
            VisualEffectView(material: .underWindowBackground, blendingMode: .withinWindow).opacity(0.5)
            switch page{
            case .start:
                Start1(page: $page,language: $language)
            case .introduce:
                Start2(page: $page)
            case .introduce2:
                Start3(code_theme_light:$code_theme_light,code_theme_dark:$code_theme_dark,page: $page)
            case .settingdata:
                Start4(page: $page, language: $language, code_theme_light: $code_theme_light, code_theme_dark: $code_theme_dark)
            case .introduce3:
                Start5(state: $initialState)
            }
        }.frame(width:1280,height:720)
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(initialState: .constant(.start)).environmentObject(ViewModel())
    }
}

struct Start1 : View{
    @Binding var page : start_page
    @Binding var language : SettingValue.language
    var body: some View {
        VStack{
            Text("GITGIT").bold().font(.largeTitle)
            Text("Code Manager").font(.headline).opacity(0.7)
                .padding(.bottom,40)
            HStack{
                /*
                 Picker("", selection: $language){
                     ForEach(SettingValue.language.allCases,id:\.self){ value in
                         Text(value.name)
                     }
                 }.frame(maxWidth:400).labelsHidden()
                 */
                Button(action:{
                    page = .introduce
                }){
                    Text("시작하기")
                }.buttonStyle(AddButtonStyle())
            }
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
            Group{
                Image("github").resizable().aspectRatio(contentMode: .fit)
                    .frame(width:70,height:70)
                Text("깃허브 연동").bold().font(.largeTitle)
                Text("프로그램을 이용하기 위해서 Github와 연동해야합니다.").font(.callout)
            }
            Spacer()
            Group{
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
                            page = .introduce2
                        }
                    }else{
                        if !(viewmodel.createUser(User(user_name: id, access_token: password))){
                        }else{
                            viewmodel.fetchData()
                            page = .introduce2
                        }
                    }
                }
            }){
                Text("Connect")
                    .bold()
                    .font(.callout)
                    .foregroundColor(.white)
                    .frame(maxWidth:.infinity,maxHeight:40)
            }.buttonStyle(RemoveBackgroundStyle()).background(Color.green)
            .cornerRadius(10)
            .padding([.leading,.trailing])
            Link("AccessToken 얻는 법", destination: URL(string: "https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token")!).font(.callout)
        }.padding([.top,.bottom])
        .frame(width:300,height:300)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
    @Binding var code_theme_light : CodeViewTheme
    @Binding var code_theme_dark : CodeViewTheme
    @Binding var page : start_page
    let code : String = "import SwiftUI \nimport Foundation\n struct ContentView : View{\n     var body : some View {\n         VStack{\n           Text(\"Hello_World\")\n        }\n    }\n }"
    var body: some View{
        VStack(alignment:.center){
            Text("코드 에디터").font(.title).bold()
            GeometryReader{ geometry in
                HStack {
                    VStack{
                        Text("LIGHT MODE")
                        CodeView(theme: code_theme_light, code: .constant(code), mode: CodeMode.swift.mode(), fontSize: 10, showInvisibleCharacters: false, lineWrapping: false)
                        Picker("Theme", selection: $code_theme_light){
                            ForEach(CodeViewTheme.allCases,id:\.self){ theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }.labelsHidden()
                    }.frame(width:geometry.size.width/2,height:250)
                    VStack{
                        Text("DARK MODE")
                        CodeView(theme: code_theme_dark, code: .constant(code), mode: CodeMode.swift.mode(), fontSize: 10, showInvisibleCharacters: false, lineWrapping: false)
                        Picker("Theme", selection: $code_theme_dark){
                            ForEach(CodeViewTheme.allCases,id:\.self){ theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }.labelsHidden()
                    }.frame(width:geometry.size.width/2,height:250)
                }
            }.frame(maxWidth:.infinity)
            .padding([.leading,.trailing,.top])
            HStack{
                Spacer()
                Button(action:{
                    page = .settingdata
                }){
                    Text("완료")
                }
            }.padding([.leading,.trailing])
        }.padding([.top,.bottom])
        .frame(width:600,height:400)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct Start4 : View{
    @EnvironmentObject var viewmodel : ViewModel
    @State private var middle : Bool = false
    @State private var inner : Bool = false
    @State private var outter : Bool = false
    @State private var image : Bool = false
    @State private var load_state : state = .loadData
    @Binding var page : start_page
    @Binding var language : SettingValue.language
    @Binding var code_theme_light : CodeViewTheme
    @Binding var code_theme_dark : CodeViewTheme
    enum state{
        case loadData,fetchData,setting,done
        var description : LocalizedStringKey{
            switch self {
            case .loadData:
                return "데이터 불러오는 중"
            case .fetchData:
                return "데이터 적용 중"
            case .setting:
                return "설정 적용 중"
            case .done:
                return "완료"
            }
        }
    }
    var body: some View{
        VStack{
            ZStack{
                Circle().foregroundColor(.black).frame(width:260,height: 260)
                    .scaleEffect(outter ? 1.1 : 0.5,anchor: .center).opacity(0.5)
                Circle().foregroundColor(.gray).frame(width:240,height: 240)
                    .scaleEffect(middle ? 1.1 : 0.5,anchor: .center).opacity(0.5)
                Circle().foregroundColor(.white).frame(width:200,height: 200)
                    .scaleEffect(inner ? 1.1 : 0.5,anchor: .center).opacity(0.5)
                viewmodel.getUserImage().resizable().aspectRatio(contentMode: .fit).clipShape(Circle()).frame(width:150,height: 150)
                    .scaleEffect(image ? 1.1 : 0.8,anchor: .center)
            }
            Text(load_state.description)
                .font(.callout)
                .bold()
                .padding(.top,20)
        }.onAppear{
            withAnimation(Animation.easeOut(duration: 1.6).repeatForever(autoreverses: true).delay(0.7)){
                image.toggle()
            }
            withAnimation(Animation.easeOut(duration: 1.6).repeatForever(autoreverses: true).delay(0.5)){
                middle.toggle()
            }
            withAnimation(Animation.easeOut(duration: 1.6).repeatForever(autoreverses: true).delay(0.3)){
                inner.toggle()
            }
            withAnimation(Animation.easeOut(duration: 1.7).repeatForever(autoreverses: true).delay(0.1)){
                outter.toggle()
            }
            load_state = .fetchData
        }.onChange(of: load_state, perform: { value in
            switch value{
            case .loadData:
                break
            case .fetchData:
                let time = DispatchTime.now() + .seconds(8)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    fetchData()
                }
            case .setting:
                let time = DispatchTime.now() + .seconds(4)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    setting()
                }
            case .done:
                let time = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    page = .introduce3
                }
            }
        })
    }
    
    func setting(){
        let storeValue = SettingValue(language_type: language, onAutoKeyword: true, recomandSearch: true, code_type_light: code_theme_light.rawValue, code_type_dark: code_theme_dark.rawValue)
        if let encode = try? JSONEncoder().encode(storeValue){
            UserDefaults.standard.setValue(encode, forKey: "Setting")
        }
        withAnimation(.easeIn){
            load_state = .done
        }
    }
    
    func fetchData(){
        viewmodel.fetchData()
        withAnimation(.easeIn){
            load_state = .setting
        }
    }
    
}

struct Start5 : View{
    @Binding var state : initial_state
    var body: some View{
        VStack{
            Text("다음 기능들을 이용해보세요.").font(.largeTitle).bold()
            Divider()
            HStack{
                Image(systemName: "filemenu.and.selection").resizable().aspectRatio(contentMode: .fit).frame(width:50)
                Text("깃허브에 있는 레퍼토리를 관리하세요.")
                Spacer()
            }.frame(width:350)
            HStack{
                Image(systemName: "exclamationmark.square").resizable().aspectRatio(contentMode: .fit).frame(width:50)
                Text("이슈를 등록 및 확인하세요.")
                Spacer()
            }.frame(width:350)
            HStack{
                Image(systemName: "doc.text.magnifyingglass").resizable().aspectRatio(contentMode: .fit).frame(width:50)
                Text("드래그앤드랍으로 개발에 필요한 자료들을 모아보세요.")
                Spacer()
            }.frame(width:350)
            HStack{
                Image(systemName: "chevron.left.slash.chevron.right").resizable().aspectRatio(contentMode: .fit).frame(width:50)
                Text("코드를 분석하고 GIST에 올려보세요.")
                Spacer()
            }.frame(width:350)
            HStack{
                Image(systemName: "books.vertical").resizable().aspectRatio(contentMode: .fit).frame(width:50)
                HStack{
                    Text("BETA").font(.caption2).italic().padding(4).overlay(Capsule().stroke()).foregroundColor(.red).opacity(0.8)
                    Text("자동으로 추천해주는 자료를 확인하세요.")
                }
                Spacer()
            }.frame(width:350)
            Spacer()
            Button(action:{
                UserDefaults.standard.setValue(true, forKey: "start")
                state = .content
            }){
                Text("시작하기")
            }.buttonStyle(AddButtonStyle())
        }.frame(width:400,height:400)
    }
}

struct AVPlayerControllerRepresented : NSViewRepresentable {
    var player : AVPlayer
    
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .none
        view.player = player
        return view
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        
    }
}
