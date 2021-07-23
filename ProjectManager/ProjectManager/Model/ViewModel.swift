//
//  ViewModel.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import Foundation
import SwiftUI
import Security
import Alamofire

enum Start : Identifiable{
    var id: Int{
        hashValue
    }
    case start_first
}

/// ViewModel for processing data.
class ViewModel : ObservableObject{
    @Published var Repositories : [Repository] = []
    @Published var Researchs : [Research] = []
    @Published var Hashtags : [Hashtag] = []
    @Published var Sites : [Site] = []
    @Published var Codes : [Code] = []
    @Published var CodeReviews : [CodeComment] = []
    @Published var UserInfo : User? = nil
    @Published var nowRepository : Repository?
    @Published var GithubUserInfo : User_Info? = nil
    var settingValue : SettingValue{
        if let savedSetting = UserDefaults.standard.object(forKey: "Setting") as? Data {
            if let loadedSetting = try? JSONDecoder().decode(SettingValue.self, from: savedSetting) {
                return loadedSetting
            }else{
                return SettingValue(language_type: .Korean, onAutoKeyword: true, recomandSearch: true, code_type_light: "irWhite", code_type_dark: "irBlack")
            }
        }else{
            return SettingValue(language_type: .Korean, onAutoKeyword: true, recomandSearch: true, code_type_light: "irWhite", code_type_dark: "irBlack")
        }
    }
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores{ (description,error) in
            if let error = error{
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        fetchData()
    }
    
    /// Load Model Data to value
    func fetchData(){
        readUser() //get user data from keychain
        getUserData() //get user data from github
        getRepositoryData(completion: {items in
            self.setData(items)
            self.updateRepository(items)
        }) //update and save repository
        updateData() //update data
        let repository_fetchRequest : NSFetchRequest<Repository> = Repository.fetchRequest()
        let research_fetchRequest : NSFetchRequest<Research> = Research.fetchRequest()
        let hashtag_fetchRequest : NSFetchRequest<Hashtag> = Hashtag.fetchRequest()
        let site_fetchRequest : NSFetchRequest<Site> = Site.fetchRequest()
        let code_fetchRequest : NSFetchRequest<Code> = Code.fetchRequest()
        let code_comment_fetchRequest : NSFetchRequest<CodeComment> = CodeComment.fetchRequest()
        do{
            Repositories = try container.viewContext.fetch(repository_fetchRequest)
            Researchs = try container.viewContext.fetch(research_fetchRequest)
            Hashtags = try container.viewContext.fetch(hashtag_fetchRequest)
            Sites = try container.viewContext.fetch(site_fetchRequest)
            Codes = try container.viewContext.fetch(code_fetchRequest)
            CodeReviews = try container.viewContext.fetch(code_comment_fetchRequest)
        }catch{
            //If fail to load data form container, Value List is empty
            Repositories = []
            Researchs = []
            Hashtags = []
            Sites = []
            Codes = []
            CodeReviews = []
        }
    }
    
    /// Save Repository
    func saveRepository(id : String,name:String,site : String,language : String? = nil,descriptions : String? = nil){
        let repotory = Repository(context: container.viewContext)
        repotory.id = id
        repotory.pin = false
        repotory.site = site
        repotory.name = name
        repotory.language = language
        repotory.descriptions = descriptions
    }
    
    /// Save Research
    /// sites is weblinks
    func saveResearch(tagID : UUID = UUID(),name : String,memo : String, repo_ID : String,issue_url : String? = nil){
        let research = Research(context: container.viewContext)
        research.id = repo_ID
        research.tagID = tagID
        research.name = name
        research.memo = memo
        research.issue_url = issue_url
    }
    
    func saveHash(tagID : UUID?,tag:String){
        let hash = Hashtag(context: container.viewContext)
        hash.tag = tag
        hash.tagID = tagID
    }
    
    func saveSite(tagID : UUID?,name : String,url : String){
        let site = Site(context: container.viewContext)
        site.tagID = tagID
        site.name = name
        site.url = url
    }
    
    func saveCode(reviewID : UUID = UUID(),repo_id : String,title : String ,path : String,code : String){
        let data = Code(context: container.viewContext)
        data.code = code
        data.path = path
        data.repo_id = repo_id
        data.reviewID = reviewID
        data.title = title
    }
    
    func saveCodeComment(reviewID : UUID?,code : String,review : String){
        let data = CodeComment(context: container.viewContext)
        data.code = code
        data.review = review
        data.reviewID = reviewID
        data.node_id = UUID()
    }
    
    func updateData(){
        if container.viewContext.hasChanges{
            do{
                try container.viewContext.save()
            }catch{
                container.viewContext.redo()
            }
        }
    }
    
    func deleteData(_ data : NSManagedObject){
        container.viewContext.delete(data)
    }
}

extension ViewModel{
    // extension for store,edit,delete,read user_info
    
    /// Create keychain about User Github Api access token.
    /// Return True If success to store user infomation.
    func createUser(_ user : User)->Bool{
        guard let data = try? JSONEncoder().encode(user) else {return false}
        let query : [CFString : Any] = [kSecClass : kSecClassGenericPassword,
                                        kSecAttrService : "ProjectManager",
                                        kSecAttrAccount : "GithubAccessTocken",
                                        kSecAttrGeneric : data]
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    /// Read User  Github Api access token.
    /// If User data not exists, the function returns nil.
    func readUser(){
        let query : [CFString : Any] = [kSecClass : kSecClassGenericPassword,
                                        kSecAttrService : "ProjectManager",
                                        kSecAttrAccount : "GithubAccessTocken",
                                        kSecMatchLimit : kSecMatchLimitOne,
                                        kSecReturnAttributes : true,
                                        kSecReturnData : true]
        var item : CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) != errSecSuccess {return}
        guard let existingItem = item as? [CFString : Any],let data = existingItem[kSecAttrGeneric] as? Data,let user = try? JSONDecoder().decode(User.self, from: data) else {return}
        self.UserInfo = user
    }
    
    /// Edit User  Github Api access token.
    /// If Success to update data, return true.
    func updateUser(_ user : User)->Bool{
        guard let data = try? JSONEncoder().encode(user) else {return false}
        let query : [CFString : Any] = [kSecClass : kSecClassGenericPassword,
                                        kSecAttrService : "ProjectManager",
                                        kSecAttrAccount : "GithubAccessTocken"]
        
        let attributes : [CFString : Any] = [kSecAttrAccount : "GithubAccessTocken",
                                             kSecAttrGeneric:data]
        return SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == errSecSuccess
    }
    
    /// Delete User GithubAccessToken.
    /// If Success to delete data, return true.
    func deleteUser()->Bool{
        let query : [CFString : Any] = [kSecClass : kSecClassGenericPassword,
                                        kSecAttrService:"ProjectManager",
                                        kSecAttrAccount:"GithubAccessTocken"]
        self.UserInfo = nil
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}

extension ViewModel{
    //Https parsing
    
    /// parsing user_information form GitHub
    func getUserData(){
        if let user = self.UserInfo{
            let header : HTTPHeaders = [.accept("application/vnd.github.v3+json"),.authorization("token "+user.access_token)]
            let parameters : Parameters = [:]
            AF.request("https://api.github.com/user", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: header)
                .responseJSON(completionHandler: { (response) in
                switch response.result{
                case .success(let value):
                    do{
                        let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                        //let str = String(decoding: data, as: UTF8.self)
                        //print(str)
                        self.GithubUserInfo = try JSONDecoder().decode(User_Info.self, from: data)
                    }catch let error{
                        print("fail to load userdata : \(error.localizedDescription)")
                        self.GithubUserInfo = nil
                    }
                case .failure(let error):
                    print("fail to load : \(error.errorDescription ?? "")")
                }
            })
        }
    }
    
    /// Change imgURL in User structure to Image type.
    /// If this process is faill, return nil.
    func getUserImage()->Image{
        if let user = self.UserInfo{
            guard let url = URL(string: "https://github.com/\(user.user_name).png") else {return Image(systemName: "person.circle")}
            do{
                let data = try Data(contentsOf: url)
                guard let nsimg = NSImage(data: data) else {return Image(systemName: "person.circle")}
                return Image(nsImage: nsimg)
            }catch let error{
                print(error.localizedDescription)
                return Image(systemName: "person.circle")
            }
        }else{
            return Image(systemName: "person.circle")
        }
    }
    
    func getUserImage(_ name : String)->Image{
        guard let url = URL(string: "https://github.com/\(name).png") else {return Image(systemName: "person.circle")}
        do{
            let data = try Data(contentsOf: url)
            guard let nsimg = NSImage(data: data) else {return Image(systemName: "person.circle")}
            return Image(nsImage: nsimg)
        }catch let error{
            print(error.localizedDescription)
            return Image(systemName: "person.circle")
        }
    }
    
    /// parsing repository form GitHub
    func getRepositoryData(completion : @escaping ([Repository_Info])->()){
        if let user = self.UserInfo{
            let header : HTTPHeaders = [.accept("application/vnd.github.v3+json"),.authorization("token "+user.access_token)]
            let parameters : Parameters = [:]
            AF.request("https://api.github.com/search/repositories?q=user:\(user.user_name)", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: header)
                .responseJSON(completionHandler: { (response) in
                switch response.result{
                case .success(let value):
                    do{
                        let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                        //let str = String(decoding: data, as: UTF8.self)
                        //print(str)
                        let repos = try JSONDecoder().decode(Repositories_Info.self, from: data)
                        //print(repos)
                        completion(repos.items)
                    }catch let error{
                        print(error.localizedDescription)
                    }
                case .failure(let error):
                    print("fail to load : \(error.errorDescription ?? "")")
                }
            })
        }
    }
    
    func getGitFiles(_ repository : Repository,path : String = "",completion : @escaping ([GitFile])->()){
        if let user = self.UserInfo{
            let header : HTTPHeaders = [.accept("application/vnd.github.v3+json"),.authorization("token "+user.access_token)]
            let parameters : Parameters = [:]
            AF.request("https://api.github.com/repos/\(user.user_name)/\(repository.name ?? "")/contents/\(path)",method: .get,parameters: parameters,headers: header).responseJSON(completionHandler: { (response) in
                switch response.result{
                case .success(let value):
                    do{
                        let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                        let files = try JSONDecoder().decode([GitFile].self, from: data)
                        completion(files)
                    }catch{
                        completion([])
                    }
                case .failure(let error):
                    completion([])
                    print("Error to load gitfiles :\(error.localizedDescription)")
                }
            })
        }
    }
    
    func getGitCode(_ repository : Repository,path : String = "",completion : @escaping (String)->()){
        if let user = self.UserInfo{
            let header : HTTPHeaders = [.accept("application/vnd.github.VERSION.html"),.authorization("token "+user.access_token)]
            let parameters : Parameters = [:]
            AF.request("https://api.github.com/repos/\(user.user_name)/\(repository.name ?? "")/contents/\(path)",method: .get,parameters: parameters,headers: header)
                .responseData{ data in
                    if let value = data.data{
                        completion(String(data: value, encoding: .utf8) ?? "")
                    }
                }
        }
    }
    
    func getGitCode(_ link : String,completion : @escaping (String)->()){
        if let user = self.UserInfo{
            let header : HTTPHeaders = [.accept("application/vnd.github.VERSION.html"),.authorization("token "+user.access_token)]
            let parameters : Parameters = [:]
            AF.request(link,method: .get,parameters: parameters,headers: header)
                .responseData{ data in
                    if let value = data.data{
                        completion(String(data: value, encoding: .utf8) ?? "")
                    }
                }
        }
    }
}

extension ViewModel{
    
    /// Set Model datas using GithubApi
    func setData(_ items : [Repository_Info]){
         for repositry in self.Repositories{
             if !(items.contains(where: {$0.node_id == repositry.id})){
                for search in Researchs.filter({$0.id == repositry.id}){
                    deleteData(search)
                    for hash in Hashtags.filter({$0.tagID == search.tagID}){
                        deleteData(hash)
                    }
                    for site in Sites.filter({$0.tagID == search.tagID}){
                        deleteData(site)
                    }
                }
             }
         }
        for repotry in items{
            if self.Repositories.filter({$0.id == repotry.node_id}).isEmpty{
                self.saveRepository(id: repotry.node_id, name: repotry.name, site: repotry.html_url,language: repotry.language,descriptions: repotry.description)
            }
        }
    }
    /// detect Change of repository
    func updateRepository(_ items : [Repository_Info]){
        for repotry in items{
            if let repo = self.Repositories.first(where: {$0.id == repotry.node_id}){
                repo.name = repotry.name
                repo.site = repotry.html_url
                repo.language = repotry.language
                repo.descriptions = repotry.description
            }
        }
    }
}

extension ViewModel{
    //Github Upload
    /// Create Issue
    func createIssues(repo : Repository,title:String,body:String){
        if let user = self.UserInfo{
            //let test = IssuePost(title: "Github Issue Post Test", body: "Hello_World", assignees: ["jaeho0718"], labels: [])
            let issue = IssuePost(title: title, body: body, assignees: [user.user_name], labels: [])
            do{
                let json = try JSONEncoder().encode(issue)
                if let url = URL(string: "https://api.github.com/repos/\(user.user_name)/\(repo.name ?? "")/issues") {
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.addValue("token \(user.access_token)", forHTTPHeaderField: "Authorization")
                    request.httpBody = json
                    let task = URLSession.shared.dataTask(with: request){ (data,response,error) in
                        if let error = error{
                            print(error.localizedDescription)
                        }
                        /*
                         if let data = data,let data_str = String(data: data, encoding: .utf8){
                             //print("data : \(data_str)")
                         }
                         */
                    }
                    task.resume()
                }
            }catch{
                
            }
        }
    }
    /// Return Issues throughout complication parameter
    func getIssues(_ info : User?,repo : Repository,complication: @escaping ([Issues])->()){
        if let user = info{
            let header : HTTPHeaders = [.accept("application/vnd.github.v3+json"),.authorization("token "+user.access_token)]
            let parameters : Parameters = [:]
            AF.request("https://api.github.com/repos/\(user.user_name)/\(repo.name ?? "")/issues", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: header).responseJSON(completionHandler: { (response) in
                switch response.result{
                case .success(let value):
                    do{
                        let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                        let repos = try JSONDecoder().decode([Issues].self, from: data)
                        complication(repos)
                    }catch let error{
                        print("Fail to change issue to json : \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("Issues get Error : \(error.localizedDescription)")
                }
            })
        }
    }
    
    func createComments(repo : Repository,number:Int,body:String){
        if let user = self.UserInfo{
            //let test = IssuePost(title: "Github Issue Post Test", body: "Hello_World", assignees: ["jaeho0718"], labels: [])
            let issue = CommentsPost(body: body, assignees: [user.user_name], labels: [])
            do{
                let json = try JSONEncoder().encode(issue)
                if let url = URL(string: "https://api.github.com/repos/\(user.user_name)/\(repo.name ?? "")/issues/\(number)/comments") {
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.addValue("token \(user.access_token)", forHTTPHeaderField: "Authorization")
                    request.httpBody = json
                    let task = URLSession.shared.dataTask(with: request){ (data,response,error) in
                        if let error = error{
                            print(error.localizedDescription)
                        }
                        if let data = data,let data_str = String(data: data, encoding: .utf8){
                            //print("data : \(data_str)")
                        }
                    }
                    DispatchQueue.main.async {
                        task.resume()
                    }
                }
            }catch{
                
            }
        }
    }
    
    func getComments(repo : Repository,number:Int,complication: @escaping ([Comments])->()){
        if let user = self.UserInfo{
            let header : HTTPHeaders = [.accept("application/vnd.github.v3+json"),.authorization("token "+user.access_token)]
            let parameters : Parameters = [:]
            AF.request("https://api.github.com/repos/\(user.user_name)/\(repo.name ?? "")/issues/\(number)/comments", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: header).responseJSON(completionHandler: { (response) in
                switch response.result{
                case .success(let value):
                    do{
                        let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                        let comments = try JSONDecoder().decode([Comments].self, from: data)
                        //print(repos)
                        complication(comments)
                    }catch let error{
                        print("Fail to change issue to json : \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("Issues get Error : \(error.localizedDescription)")
                }
            })
        }
    }
    
    func getIssueName(_ site : String
                      ,complication : @escaping (Issues)->()){
        if let user = self.UserInfo{
            let header : HTTPHeaders = [.accept("application/vnd.github.v3+json"),.authorization("token "+user.access_token)]
            let parameters : Parameters = [:]
            AF.request(site, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: header).responseJSON(completionHandler: { (response) in
                switch response.result{
                case .success(let value):
                    do{
                        let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                        //print(String(data: data, encoding: .utf8))
                        let issues = try JSONDecoder().decode(Issues.self, from: data)
                        //print(repos)
                        complication(issues)
                    }catch let error{
                        print("Fail to change issue to json : \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("Issues get Error : \(error.localizedDescription)")
                }
            })
        }
    }
}

extension ViewModel{
    func createGist(_ data : String,fileName : String,document:String,gistPublic : Bool){
        if let user = self.UserInfo{
            let postData = GistPostData(description: document, files: [fileName : GistFile(content: data)], type: gistPublic)
            guard let postObject = try? JSONEncoder().encode(postData) else {
                print("error decode")
                return}
            let url = URL(string: "https://api.github.com/gists")!
            var request = URLRequest(url: url)
            request.addValue("token "+user.access_token, forHTTPHeaderField:"Authorization")
            request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "accept")
            request.httpMethod = "POST"
            request.httpBody = postObject
            URLSession.shared.dataTask(with: request){ (json,response,error) in
                if let error = error{
                    print(error.localizedDescription)
                }
            }.resume()
        }
    }
}
