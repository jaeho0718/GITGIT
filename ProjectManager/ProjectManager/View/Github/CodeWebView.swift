//
//  CodeWebView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/19.
//

import Foundation
import SwiftUI
import WebKit

struct CodeWebView : NSViewRepresentable{
    var text : String
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(text, baseURL: nil)
    }
}
