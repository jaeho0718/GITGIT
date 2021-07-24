//
//  Setting.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/20.
//

import SwiftUI
import CodeMirror_SwiftUI

struct Setting: View {
    @State private var language : SettingValue.language = .Korean
    @State private var autoKeyword : Bool = false
    @State private var autoSearch : Bool = false
    @State private var code_theme_light : CodeViewTheme = .irWhite
    @State private var code_theme_dark : CodeViewTheme = .irBlack
    var body: some View {
        TabView{
            BasicSetting(language: $language, autoKeyword: $autoKeyword, autoSearch: $autoSearch).tabItem { Label("기본 설정", systemImage: "gear") }
            CodeThemeSetting(code_theme_light: $code_theme_light, code_theme_dark: $code_theme_dark).tabItem { Label("코드 테마", systemImage: "chevron.left.slash.chevron.right") }
        }.onDisappear{saveChange()}.onAppear{loadData()}
        .onChange(of: language, perform: { value in
            saveChange()
        })
        .onChange(of: autoKeyword, perform: { value in
            saveChange()
        })
        .onChange(of: autoSearch, perform: { value in
            saveChange()
        })
        .onChange(of: code_theme_light, perform: { value in
            saveChange()
        })
        .onChange(of: code_theme_dark, perform: { value in
            saveChange()
        })
    }
    
    func saveChange(){
        let storeValue = SettingValue(language_type: language, onAutoKeyword: autoKeyword, recomandSearch: autoSearch, code_type_light: code_theme_light.rawValue, code_type_dark: code_theme_dark.rawValue)
        if let encode = try? JSONEncoder().encode(storeValue){
            UserDefaults.standard.setValue(encode, forKey: "Setting")
        }
    }
    
    func loadData(){
        if let setting = UserDefaults.standard.object(forKey: "Setting") as? Data{
            if let loadedSetting = try? JSONDecoder().decode(SettingValue.self, from: setting){
                language = loadedSetting.language_type
                autoKeyword = loadedSetting.onAutoKeyword
                autoSearch = loadedSetting.recomandSearch
                code_theme_dark = SettingValue.getTheme(loadedSetting.code_type_dark)
                code_theme_light = SettingValue.getTheme(loadedSetting.code_type_light)
            }
        }
    }
}

struct Setting_Previews: PreviewProvider {
    static var previews: some View {
        Setting()
    }
}

struct CodeThemeSetting : View{
    @Binding var code_theme_light : CodeViewTheme
    @Binding var code_theme_dark : CodeViewTheme
    var body: some View{
        GeometryReader{ geomtry in
            let width = geomtry.size.width/2
            HStack {
                VStack(alignment:.center){
                    Text("Light").font(.callout).bold().padding(.top)
                    ThemePreview(theme: code_theme_light).frame(maxWidth:width,maxHeight:500).padding([.bottom,.leading,.trailing])
                    Picker("Theme", selection: $code_theme_light){
                        ForEach(CodeViewTheme.allCases,id:\.self){ theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }.padding([.bottom,.leading,.trailing])
                }
                VStack(alignment:.center){
                    Text("Dark").font(.callout).bold().padding(.top)
                    ThemePreview(theme: code_theme_dark).frame(maxWidth:width,maxHeight:500).padding([.bottom,.leading,.trailing])
                    Picker("Theme", selection: $code_theme_dark){
                        ForEach(CodeViewTheme.allCases,id:\.self){ theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }.padding([.bottom,.leading,.trailing])
                }
            }
        }
    }
}

struct BasicSetting : View{
    @Binding var language : SettingValue.language
    @Binding var autoKeyword : Bool
    @Binding var autoSearch : Bool
    var body: some View{
        ScrollView(.vertical){
            VStack{
                /*
                 Picker("언어", selection: $language){
                     ForEach(SettingValue.language.allCases){ type in
                         Text(type.name).tag(type)
                     }
                 }.pickerStyle(MenuPickerStyle())
                 */
                Toggle("오토 키워드", isOn: $autoKeyword).toggleStyle(SwitchToggleStyle())
                    .frame(maxWidth:.infinity)
                Toggle("검색 추천", isOn: $autoSearch).toggleStyle(SwitchToggleStyle())
                    .frame(maxWidth:.infinity)
            }.padding()
        }
    }
}

struct ThemePreview : View{
    var theme : CodeViewTheme
    var code : String = "printf(Hello_World)\n //This is a code."
    var body: some View{
        VStack(alignment:.center,spacing:0){
            CodeView(theme: theme, code: .constant(code), mode: CodeMode.c.mode(), fontSize: 12, showInvisibleCharacters: false, lineWrapping: false)
            Text(theme.rawValue).font(.callout).bold()
        }
    }
}
