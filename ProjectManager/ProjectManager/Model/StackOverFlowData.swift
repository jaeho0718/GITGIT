//
//  StackOverFlowData.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/15.
//

import Foundation
import SwiftUI
import Alamofire
struct StackOverFlow_SearchResult : Codable{
    var items : [StackOverFlow_item]
    var has_more : Bool
}

struct StackOverFlow_item : Codable{
    var tags : [String]
    var is_answered : Bool
    var answer_count : Int
    var link : String
    var title : String
    var question_id : Int
}

func sof_searchReseult(search : String,tag : String,completion : @escaping ([StackOverFlow_item])->()){
    let header : HTTPHeaders = [:]
    let parameters : Parameters = ["order":"desc","sort":"activity","intitle":search,"tagged":tag,"site":"stackoverflow"]
    AF.request("https://api.stackexchange.com/2.3/search",parameters: parameters,encoding: URLEncoding.default,headers: header).responseJSON(completionHandler: { (response) in
        switch response.result{
        case .success(let value):
            do{
                let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                let result = try JSONDecoder().decode(StackOverFlow_SearchResult.self, from: data)
                completion(result.items)
            }catch let error{
                print(error.localizedDescription)
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    })
}
