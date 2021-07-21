//
//  SettingValue.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/21.
//

import Foundation
import SwiftUI
import CodeMirror_SwiftUI

struct SettingValue : Codable{
    /// Program Language type
    enum language : String,Identifiable,CaseIterable,Codable{
        case English,Korean
        var id : Int{
            hashValue
        }
        var name : LocalizedStringKey{
            switch self{
            case .English:
                return "영어"
            case .Korean:
                return "한국어"
            }
        }
    }
    
    var language_type : language
    var onAutoKeyword : Bool
    var recomandSearch : Bool
    var code_type_light : String
    var code_type_dark : String
    
    static func getTheme(_ type : String)->CodeViewTheme{
        if let theme = CodeViewTheme.allCases.first(where: {$0.rawValue == type}){
            return theme
        }else{
            return .irBlack
        }
    }

}
