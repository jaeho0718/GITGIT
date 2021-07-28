//
//  GitHubData.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import Foundation
import SwiftUI
import Security
import CodeMirror_SwiftUI
/// To call Github Api, need user GithubAccessToken
struct User : Codable{
    var user_name : String
    var access_token : String
}

/// Structure that have user image,name,url
struct User_Info : Codable{
    var html_url : String //User github page
    var avatar_url : String //User profile image
    var name : String //User Nickname
    var login : String
    var public_repos : Int
}


/// Structure that have repositroy information
struct Repository_Info : Codable{
    var node_id : String
    var name : String //Repository name
    var full_name : String //Repository fullname
    var html_url : String //Repository site
    var description : String? //Repository description
    var language : String? //Repository language
    var repo_private : Bool
    
    enum CodingKeys : String,CodingKey{
        case node_id,name,full_name,html_url,description,language
        case repo_private = "private"
    }
}

struct Repositories_Info : Codable{
    var total_count : Int
    var items : [Repository_Info]
}

struct Issues : Codable,Identifiable{
    var id : Int
    var html_url : String
    var title : String
    var number : Int
    var user : Issue_user
    var assignees : [Assignee]
    var created_at : String
    var updated_at : String?
    var comments : Int
    var body : String
    var state : issue_state.RawValue
    enum issue_state : String,Codable{
        case open = "open"
        case closed = "closed"
    }
}

struct Assignee : Codable{
    var login : String
}

struct Issue_user : Codable{
    var login : String
    //var type : String
}

struct IssuePost : Codable{
    var title : String
    var body : String
    var assignees : [String]
    var labels : [String]
}

struct CommentsPost : Codable{
    var body : String
    var assignees : [String]
    var labels : [String]
}

struct Comments : Codable,Identifiable{
    var id : Int
    var user : Issue_user
    var created_at : String
    var updated_at : String?
    var body : String
}

struct GitFile : Codable,Hashable{
    var name : String
    var path : String
    var sha : String
    var type : String
    var url : String
    var git_url : String?
    var html_url : String?
    var _links : GitLinks
    
    func getIcon()->Image{
        switch type{
        case "file":
            return FileType.getType(self.name).getImage()
        case "dir":
            return Image("folder")
        default:
            return Image(systemName: "questionmark")
        }
    }
}

struct GitLinks : Codable,Hashable{
    var git : String?
    var html : String?
}

struct FileType{
    enum type{
        case swift,html,md,c,cpp,java,php,cs,txt,kt,python,none
        var name : String{
            switch self{
            case .swift:
                return "swift"
            case .html:
                return "html"
            case .md:
                return "md"
            case .c:
                return "c"
            case .cpp:
                return "cpp"
            case .java:
                return "java"
            case .php:
                return "php"
            case .cs:
                return "cs"
            case .none:
                return "none"
            case .txt:
                return "txt"
            case .kt:
                return "kt"
            case .python:
                return "py"
            }
        }
        var code_mode : CodeMode{
            switch self {
            case .swift:
                return .swift
            case .html:
                return .html
            case .md:
                return .markdown
            case .c:
                return .c
            case .cpp:
                return .cplus
            case .java:
                return .java
            case .php:
                return .php
            case .cs:
                return .css
            case .none:
                return .markdown
            case .txt:
                return .text
            case .kt:
                return .kotlin
            case .python:
                return .python
            }
        }
        func getImage()->Image{
            switch self {
            case .swift:
                return Image(systemName: "swift")
            case .html:
                return Image("html")
            case .md:
                return Image("coding")
            case .c:
                return Image("coding")
            case .cpp:
                return Image("cplus")
            case .java:
                return Image("coding")
            case .php:
                return Image("php")
            case .cs:
                return Image("css")
            case .none:
                return Image("coding")
            case .txt:
                return Image("txt")
            case .kt:
                return Image("coding")
            case .python:
                return Image("python")
            }
        }
    }
    static func getType(_ filename : String)->type{
        let arr = filename.components(separatedBy: ".")
        if let type_name = arr.last{
            switch type_name {
            case type.swift.name:
                return type.swift
            case type.html.name:
                return type.html
            case type.md.name:
                return type.md
            case type.c.name:
                return type.c
            case type.cpp.name:
                return type.cpp
            case type.java.name:
                return type.java
            case type.php.name:
                return type.php
            case type.cs.name:
                return type.cs
            default:
                return type.none
            }
        }else{
            return type.none
        }
    }
}

struct GistPostData : Codable{
    var description : String
    var files : [String : GistFile]
    var type : Bool
    
    enum CodingKeys : String,CodingKey{
        case description,files
        case type = "public"
    }
}

struct GistFile : Codable{
    var content : String
}

struct Gist : Codable{
    var id : String
    var url : String
    var node_id : String
    var html_url : String
    var created_at : String
    var updated_at : String?
    var comments : Int
    var gist_public : Bool
    var owner : GistOwner
    var files : [String:GistFiles]
    var description : String
    enum CodingKeys : String, CodingKey{
        case url,node_id,html_url,created_at,updated_at,comments,files,owner,description,id
        case gist_public = "public"
    }
}

struct GistFiles : Codable{
    var filename : String
    var type : String
    var language : String
    var raw_url : String
}

struct GistOwner : Codable{
    var login : String
}

struct GitCommits : Codable,Equatable{
    static func == (lhs: GitCommits, rhs: GitCommits) -> Bool {
        return lhs.sha == rhs.sha
    }
    var sha : String
    var node_id : String
    var url : String
    var commit : GitCommit
}

struct GitCommit : Codable{
    var author : [String:String]
    var committer : [String:String]
    var tree : [String:String]
    var message : String
}

struct GitCommitsChange : Codable{
    var files : [ChangedCommitFile]?
}

struct ChangedCommitFile : Codable{
    var sha : String
    var filename : String
    var additions : Int
    var deletions : Int
    var changes : Int
    var patch : String
}

struct GitEvent : Codable{
    var id : String
    var type : String
    var repo : Repository
    var created_at : String
    var event_public : Bool
    enum CodingKeys : String, CodingKey{
        case id,type,repo,created_at
        case event_public = "public"
    }
    struct Repository : Codable{
        var id : Int
        var name : String
        var url : String
    }
}
