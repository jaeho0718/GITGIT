//
//  TextFieldStyle.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/15.
//

import Foundation
import SwiftUI

struct titleTextField : TextFieldStyle{
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
                .padding(10)
                .background(VisualEffectView(material: .windowBackground, blendingMode: .withinWindow))
                .cornerRadius(20)
    }
}
