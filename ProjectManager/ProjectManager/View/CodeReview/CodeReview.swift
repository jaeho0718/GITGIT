//
//  CodeReview.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/21.
//

import SwiftUI
import CodeMirror_SwiftUI

struct CodeReview: View {
    var data : Code
    @State private var code : String = ""
    var body: some View {
        GeometryReader{ geomtry in
            let width = geomtry.size.width/2
            HSplitView{
                CodeReviewCode(code: $code).frame(minWidth:width,maxWidth:.infinity)
                CodeReviews().frame(minWidth:width,maxWidth:.infinity)
            }
        }.onAppear{
            code = data.code ?? ""
        }
    }
}

struct CodeReviewCode : View{
    @SceneStorage("fontSize") var fontSize : Int = 12
    @Binding var code : String
    var body: some View{
        ZStack(alignment:.bottom){
            CodeView(theme: .irBlack, code: $code, mode: CodeMode.python.mode(), fontSize: fontSize, showInvisibleCharacters: true, lineWrapping: true)
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
            }.frame(maxWidth:.infinity,maxHeight:20).background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        }
    }
}

struct CodeReviews : View{
    var body: some View{
        List{
            AddReviewCell()
        }
    }
}

struct AddReviewCell : View{
    @State private var comments : String = ""
    @State private var code : String = "Hello_World"
    var body: some View{
        VStack{
            CodeView(code: $code, mode: CodeMode.python.mode()).frame(minHeight:150).padding(.top,5)
            MarkDownEditor(memo: $comments)
        }.padding(5).background(VisualEffectView(material: .underPageBackground, blendingMode: .withinWindow)).cornerRadius(5)
    }
}

struct ReviewCell : View{
    var body: some View{
        GroupBox{
            
        }
    }
}
