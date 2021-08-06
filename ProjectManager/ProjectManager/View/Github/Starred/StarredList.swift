//
//  StarredLIst.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/08/06.
//

import SwiftUI

struct StarredList: View {
    @EnvironmentObject var viewmodel : ViewModel
    @State private var datas : [GitStar] = []
    @State private var onLoad : Bool = true
    var body: some View {
        List{
            ForEach(datas,id:\.id){ data in
                StarredCell(data: data)
            }
        }
        .blur(radius: onLoad ? 10 : 0)
        .overlay({
            ZStack{
                if onLoad{
                    LoadSearch()
                }
            }
        })
        .onAppear{
            viewmodel.getStarred(completion: { result in
                datas = result
                onLoad = false
            }, failer: {
                onLoad = false
            })
        }
    }
}

struct StarredList_Previews: PreviewProvider {
    static var previews: some View {
        StarredList().environmentObject(ViewModel())
    }
}
