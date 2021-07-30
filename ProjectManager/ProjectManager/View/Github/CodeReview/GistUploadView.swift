//
//  GistUploadView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/22.
//

import SwiftUI
import CodeMirror_SwiftUI
import AlertToast
struct GistUploadView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var show : Bool
    @State private var code : String = ""
    @State private var description : String = ""
    enum open : String,CaseIterable{
        case open = "public"
        case close = "private"
        var value : Bool{
            switch self {
            case .open:
                return true
            case .close:
                return false
            }
        }
    }
    @State private var open_State : open = .open
    @State private var failUpload : Bool = false
    @State private var successToUpload : Bool = false
    var title : String
    var comment : CodeComment
    var body: some View {
        VStack{
            HStack(alignment:.bottom){
                Text(title).bold()
                Spacer()
                Picker("", selection: $open_State){
                    ForEach(open.allCases,id:\.self){ value in
                        Text(value.rawValue)
                    }
                }.frame(width:100).labelsHidden()
            }
            Divider()
            CodeView(theme: colorScheme == .dark ? SettingValue.getTheme(viewmodel.settingValue.code_type_dark) : SettingValue.getTheme(viewmodel.settingValue.code_type_light),code: $code, mode: FileType.getType(title).code_mode.mode())
                .frame(minHeight:200)
            MarkDownEditor(memo: $description)
            Button(action:{
                viewmodel.createGist(code, fileName: title, document: description,gistPublic: open_State.value,onFail: {
                    failUpload.toggle()
                },onSuccess: {
                    successToUpload.toggle()
                })
            }){
                Text("UPLOAD")
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth:.infinity)
                    .padding(5).background(Color.green).cornerRadius(10)
            }.buttonStyle(RemoveBackgroundStyle())
            Button(action:{show.toggle()}){
                Text("Cancel").frame(maxWidth:.infinity)
            }.buttonStyle(CancelButtonStyle())
        }.padding()
        .onAppear{
            code = comment.code ?? ""
            description = comment.review ?? ""
        }.toast(isPresenting: $failUpload, alert: {
            AlertToast(displayMode: .alert, type: .error(.red), title: "실패",subTitle: "인터넷연결을 확인하세요.")
        }).toast(isPresenting: $successToUpload, alert: {
            AlertToast(displayMode: .alert, type: .complete(.green), title: "업로드 완료",subTitle: "적용까지 시간이 소요될 수 있습니다.")
        }, completion: { show.toggle()})
    }
}
