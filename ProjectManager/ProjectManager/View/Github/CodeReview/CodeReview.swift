//
//  CodeReview.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/21.
//

import SwiftUI
import CodeMirror_SwiftUI
import MarkdownUI

struct CodeReview: View {
    var data : Code
    @State private var code : String = ""
    var body: some View {
        GeometryReader{ geomtry in
            let width = geomtry.size.width/2
            HSplitView{
                CodeReviewCode(code: $code,data:data).frame(minWidth:width-100,maxWidth:.infinity)
                CodeReviews(data:data).frame(minWidth:width-100,maxWidth:.infinity)
            }
        }.onAppear{
            code = data.code ?? ""
        }
    }
}

struct CodeReviewCode : View{
    @SceneStorage("fontSize") var fontSize : Int = 12
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var code : String
    var data : Code
    var body: some View{
        ZStack(alignment:.bottom){
            CodeView(theme: colorScheme == .dark ? SettingValue.getTheme(viewmodel.settingValue.code_type_dark) : SettingValue.getTheme(viewmodel.settingValue.code_type_light), code: $code, mode: FileType.getType(data.title ?? "").code_mode.mode(), fontSize: fontSize, showInvisibleCharacters: true, lineWrapping: true)
            HStack{
                Text("words : \(code.count)").font(.caption2).padding(.leading,5)
                Spacer()
                Button(action:{
                    fontSize -= 1
                }){
                    Text("-")
                }
                Text("\(fontSize)").font(.caption2)
                Button(action:{
                    fontSize += 1
                }){
                    Text("+")
                }
            }.frame(maxHeight:20).background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        }
    }
}

struct CodeReviews : View{
    var data : Code
    @EnvironmentObject var viewmodel : ViewModel
    @State private var addReview : Bool = false
    var body: some View{
        List{
            if addReview{
                AddReviewCell(data:data,add:$addReview)
            }
            ForEach(viewmodel.CodeReviews.filter{$0.reviewID == data.reviewID}){ review in
                ReviewCell(data: review,type: data.title ?? "").padding(.bottom,5)
            }.onDelete(perform: deleteReview)
        }.toolbar{
            ToolbarItem{
                Button(action:{addReview.toggle()}){
                    Text(addReview ? "Cancel" : "Add Review")
                }
            }
        }
    }
    
    func deleteReview(at indexOffset : IndexSet){
        DispatchQueue.main.async {
            indexOffset.forEach{ index in
                let review = viewmodel.CodeReviews.filter{$0.reviewID == data.reviewID}[index]
                viewmodel.deleteData(review)
            }
            viewmodel.fetchData()
        }
    }
}

struct AddReviewCell : View{
    var data : Code
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewmodel : ViewModel
    @Binding var add : Bool
    @State private var comments : String = ""
    @State private var code : String = "Hello_World"
    var body: some View{
        VStack{
            CodeView(theme: colorScheme == .dark ? SettingValue.getTheme(viewmodel.settingValue.code_type_dark) : SettingValue.getTheme(viewmodel.settingValue.code_type_light), code: $code, mode: CodeMode.swift.mode(), showInvisibleCharacters: false, lineWrapping: false).frame(minHeight:150).padding(.top,5)
            MarkDownEditor(memo: $comments,filename: data.title)
            HStack{
                Spacer()
                Button(action:{
                    add.toggle()
                }){
                    Text("Cancel")
                }.buttonStyle(AddButtonStyle())
                Button(action:{
                    viewmodel.saveCodeComment(reviewID: data.reviewID, code: code, review: comments)
                    DispatchQueue.main.async {
                        viewmodel.fetchData()
                    }
                    add.toggle()
                }){
                    Text("Add")
                }.buttonStyle(AddButtonStyle())
            }
        }.padding(5).background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)).cornerRadius(5)
    }
}

struct ReviewCell : View{
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewmodel : ViewModel
    @State private var uploadGist : Bool = false
    @State private var code : String = ""
    @State private var memo : String = ""
    @State private var edit : Bool = false
    var data : CodeComment
    var type : String
    @State private var keyword : String = ""
    var body: some View{
        VStack{
            HStack(alignment:.bottom){
                Text(keyword).font(.headline).help("자동으로 추출된 키워드입니다.")
                Spacer()
                Button(action:{
                    uploadGist.toggle()
                }){
                    Image(systemName: "square.and.arrow.up.fill")
                }.buttonStyle(RemoveBackgroundStyle())
                .help("GIST에 업로드하기")
                Button(action:{
                    withAnimation(.spring()){
                        if edit{
                            saveNew()
                        }
                        edit.toggle()
                    }
                }){
                    Image(systemName: edit ? "checkmark" : "pencil")
                }.buttonStyle(RemoveBackgroundStyle())
                
            }.frame(maxWidth:.infinity,maxHeight: 30)
            if edit{
                CodeView(theme: colorScheme == .dark ? SettingValue.getTheme(viewmodel.settingValue.code_type_dark) : SettingValue.getTheme(viewmodel.settingValue.code_type_light), code: $code, mode: FileType.getType(type).code_mode.mode(), showInvisibleCharacters: false, lineWrapping: false).frame(minHeight:150).padding(.top,5)
                MarkDownEditor(memo: $memo,filename: type)
            }else{
                PatchTextView(normalMode: true, patch: data.code ?? "NULL")
                Markdown("\(data.review ?? "")").padding(.bottom,5)
            }
        }.padding(5).background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)).clipShape(RoundedRectangle(cornerRadius: 10))
        .sheet(isPresented: $uploadGist, content: {
            GistUploadView(show: $uploadGist,title:type, comment: data)
        }).onAppear{
            let wordrank = WordRank(data.review ?? "")
            wordrank.run(100, completion: { result in
                keyword = result.keyword
            })
            memo = data.review ?? ""
            code = data.code ?? ""
        }
    }
    
    func saveNew(){
        data.code = code
        data.review = memo
        viewmodel.fetchData()
    }
}
