//
//  DataStructure.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/10.
//

import Foundation
import SwiftUI
import SwiftSoup
import Alamofire
///Use This Structure to record data before save data.
struct Research_Info : Identifiable{
    var id : UUID = UUID()
    var url_str : String
    ///get Site Name
    func getSiteName(completion : @escaping (String)->Void){
        AF.request(url_str).responseString(completionHandler: { response in
            switch response.result{
            case .success(let value):
                do {
                    let doc : Document = try SwiftSoup.parse(value)
                    let link : Element? = try? doc.select("title").first()
                    if let element = link{
                        let title = try element.text()
                        completion(title)
                    }else{
                        completion(url_str)
                    }
                }catch let error{
                    print("Fail to bring name : \(error.localizedDescription)")
                }
            case .failure(let error):
                print("Fail to load web :\(error.localizedDescription)")
                break
            }
        })
    }
}
