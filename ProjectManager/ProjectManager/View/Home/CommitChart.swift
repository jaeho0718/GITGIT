//
//  CommitChart.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/26.
//

import Foundation
import SwiftUI
import Charts
import SwiftUIX

struct CommitChart : View{
    @EnvironmentObject var viewmodel : ViewModel
    @State private var entities : [Double] = []
    @TimerState(interval: 60) var timer : Int
    var body: some View{
        VStack{
            HStack{
                Text("Commits").bold().padding(.top,5).font(.title).padding(.leading).padding(.top,5)
                Spacer()
            }
            Chart(data: entities)
                .chartStyle(
                    LineChartStyle(.quadCurve, lineColor: .green, lineWidth: 5)
                )
        }.frame(minWidth:300,maxWidth:.infinity)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear{
            createEntities()
        }
        .onChange(of: timer, perform: { value in
            createEntities()
        })
    }
    
    func createEntities(){
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd"
        let day = Date().get(.day)
        let month = Date().get(.month)
        let year = Date().get(.year)
        var entityInfo : [Int:Int] = [:]
        for toDay in 1...day{
            entityInfo[toDay] = 0
        }
        DispatchQueue.main.async {
            _ = viewmodel.Repositories.map({
                viewmodel.getCommits(repository: $0, completion: { commit in
                    for toDay in 1...day{
                        let date = dateformatter.date(from: "\(year)-\(month)-\(toDay)")
                        let counts = commit.filter({
                            var commit_day : String = $0.commit.committer["date"] ?? "2021-07-24T13:09:15Z"
                            commit_day = commit_day.components(separatedBy: "T").first ?? "2021-07-24"
                            let commit_date = dateformatter.date(from: commit_day)
                            return commit_date == date
                        }).count
                        entityInfo[toDay]! += counts
                    }
                    entities = []
                    let total = Double(entityInfo.keys.reduce(0){$0+$1})/Double(entityInfo.keys.count)
                    let sortedinfo = entityInfo.sorted(by: {$0.key < $1.key})
                    _ = sortedinfo.map({ (key,value) in
                        if value == 0{
                            entities.append(0.1)
                        }else{
                            entities.append(Double(value)/total+0.1)
                        }
                    })
                    print(entities)
                })
            })
        }
    }
}


struct CommitChart_Previews: PreviewProvider {
    static var previews: some View {
        CommitChart().environmentObject(ViewModel())
    }
}
