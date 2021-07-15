//
//  CustomDrag.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/14.
//

import Foundation
import SwiftUI

struct onDragable : ViewModifier{
    let condition : Bool
    let data : ()->NSItemProvider
    
    init(condition : Bool,data : @escaping ()->NSItemProvider) {
        self.condition = condition
        self.data = data
    }
    
    func body(content: Content) -> some View {
        if condition{
            content.onDrag(data)
        }else{
            content
        }
    }
}
extension View{
    func OnDragable(condition : Bool,data : @escaping ()->NSItemProvider) -> some View {
        self.modifier(onDragable(condition: condition, data: data))
    }
}
