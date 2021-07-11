//
//  WebView.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/10.
//

import SwiftUI
import WebKit

/// Use to load webpage in view
struct WebView : NSViewRepresentable{
    
    var url : String
    var user : User?
    func makeNSView(context: Context) -> WKWebView {
        guard let Url = URL(string: url) else { return WKWebView()}
        let webview = WKWebView()
        let request = URLRequest(url: Url)
        if let _ = user{
           //request.addValue("Authorization", forHTTPHeaderField: "token \(info.access_token)")
        }
        webview.load(request)
        return webview
    }
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
}
