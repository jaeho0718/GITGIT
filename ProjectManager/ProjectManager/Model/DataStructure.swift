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

public func getSiteName(url_str : String,completion : @escaping (String)->Void){
    AF.request(url_str).responseString(completionHandler: { response in
        switch response.result{
        case .success(let value):
            do {
                let document : Document = try SwiftSoup.parse(value)
                let link : Element? = try? document.select("title").first()
                if let element = link{
                    let title = try element.text()
                    completion(title)
                }else{
                    completion(url_str)
                }
            }catch let error{
                completion(url_str)
                print("Fail to bring name : \(error.localizedDescription)")
            }
        case .failure(let error):
            completion(url_str)
            print("Fail to load web :\(error.localizedDescription)")
        }
    })
}
