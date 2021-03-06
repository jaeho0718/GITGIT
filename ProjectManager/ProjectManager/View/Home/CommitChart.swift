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
    @State private var onLoad : Bool = true
    let month = ["","January","February","March","April","May","June","July","August","September","October","November","December"]
    @TimerState(interval: 60) var timer : Int
    var body: some View{
        ZStack(alignment:.center){
            Text(month[Date().get(.month)]).font(.system(size:115)).bold().opacity(0.2).clipped()
            VStack{
                HStack{
                    Text("Commits").bold().padding(.top,5).font(.title).padding(.leading).padding(.top,5)
                    Spacer()
                }
                if !onLoad{
                    Chart(data: entities.reversed())
                        .chartStyle(
                            ColumnChartStyle(column: Capsule().foregroundColor(.green), spacing: 2)
                        )
                }else{
                    Spacer()
                }
            }
        }.frame(minWidth:300,maxWidth:.infinity)
        .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear{
            createEntities()
        }
        .onChange(of: timer, perform: { value in
            createEntities()
        })
    }
    
    func createEntities(){
        entities.removeAll()
        onLoad = true
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd"
        let day = Date().get(.day)
        let month = Date().get(.month)
        let year = Date().get(.year)
        var entityInfo : [Int:Int] = [:]
        let calendar = Calendar.current
        let date1 = calendar.date(byAdding: .month, value: 0, to: Date())!
        let range = calendar.range(of: .day, in: .month, for: date1)!
        let numDays = range.count //????????? ???
        for toDay in 1...numDays{
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
                    onLoad.toggle()
                },failer: {
                    onLoad.toggle()
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
