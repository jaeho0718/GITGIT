//
//  ButtonStyle.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/15.
//

import Foundation
import SwiftUI

struct AddButtonStyle : ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.padding([.leading,.trailing]).padding([.top,.bottom],5).background(VisualEffectView(material: .contentBackground, blendingMode: .withinWindow)).clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct CancelButtonStyle : ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.padding([.leading,.trailing]).padding([.top,.bottom],5).foregroundColor(.red).background(VisualEffectView(material: .contentBackground, blendingMode: .withinWindow)).clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct StartButtonStyle : ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.padding([.leading,.trailing]).padding([.top,.bottom],5).background(VisualEffectView(material: .fullScreenUI, blendingMode: .withinWindow)).clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct PinButtonStyle : ButtonStyle{
    var pin : Bool
    func makeBody(configuration: Configuration) -> some View {
        ZStack{
            Image(systemName: pin ? "star.fill" : "star")
        }
    }
}

struct RemoveBackgroundStyle : ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
