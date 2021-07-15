//
//  StartBackground.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/14.
//

import SwiftUI

struct StartBackground: View {
    var body: some View {
        GeometryReader{ geomtry in
            Image("code").resizable()
                .aspectRatio(contentMode: .fill).frame(width:geomtry.size.width+100,height:geomtry.size.height+100)
                .clipped()
                .blur(radius: 5)
        }
    }
}

struct StartBackground_Previews: PreviewProvider {
    static var previews: some View {
        StartBackground()
    }
}
