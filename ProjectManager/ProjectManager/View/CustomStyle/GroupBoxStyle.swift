//
//  GroupBox.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/15.
//

import Foundation
import AppKit
import SwiftUI

struct IssueGroupBoxStyle : GroupBoxStyle{
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment:.leading){
            configuration.label.foregroundColor(.secondary).font(.headline)
            Divider()
            configuration.content.padding(.top,5)
        }.padding(10).background(VisualEffectView(material: .popover, blendingMode: .withinWindow)).clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct sofResultStyle : GroupBoxStyle{
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment:.leading){
            configuration.label.font(.title2)
            Divider()
            configuration.content.padding(.top,5)
        }.padding(10).background(VisualEffectView(material: .fullScreenUI, blendingMode: .withinWindow)).clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct VisualEffectView: NSViewRepresentable{
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView
    {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context)
    {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

struct LinkGroupBoxStyle : GroupBoxStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.content.padding(10).background(VisualEffectView(material: .popover, blendingMode: .withinWindow)).clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
