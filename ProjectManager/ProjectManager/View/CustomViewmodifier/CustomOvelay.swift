//
//  CustomOvelay.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/27.
//

import Foundation
import SwiftUI

struct conditionalOveraly<OverLay : View> : ViewModifier{
    var condition : Bool
    var overlay : ()->OverLay
    
    init(_ condition : Bool,overlay : @escaping ()->OverLay) {
        self.condition = condition
        self.overlay = overlay
    }
    
    func body(content: Content) -> some View {
        if condition{
           content.overlay(overlay)
        }else{
           content
        }
    }
}

extension View{
    func ConditionalOverlay<Content : View>(_ condition : Bool,overlay : @escaping ()->Content)->some View{
        self.modifier(conditionalOveraly(condition, overlay: overlay))
    }
}
