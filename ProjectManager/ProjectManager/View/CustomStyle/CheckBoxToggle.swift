//
//  CheckBoxToggle.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/10.
//

import Foundation
import SwiftUI

struct CheckBoxStyle : ToggleStyle{
    var true_img : String
    var false_img : String
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: configuration.isOn ? true_img : false_img)
            .onTapGesture {
                withAnimation(.spring()){
                    configuration.isOn.toggle()
                }
            }
    }
}
