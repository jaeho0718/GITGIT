//
//  GitHubData.swift
//  ProjectManager
//
//  Created by Lee Jaeho on 2021/07/09.
//

import Foundation
import SwiftUI
import Security

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

/*
 {
   "login" : "jaeho0718",
   "public_gists" : 0,
   "twitter_username" : null,
   "created_at" : "2017-11-17T15:55:41Z",
   "id" : 33758013,
   "company" : null,
   "blog" : "jaeho0718.github.io",
   "collaborators" : 0,
   "html_url" : "https:\/\/github.com\/jaeho0718",
   "node_id" : "MDQ6VXNlcjMzNzU4MDEz",
   "url" : "https:\/\/api.github.com\/users\/jaeho0718",
   "organizations_url" : "https:\/\/api.github.com\/users\/jaeho0718\/orgs",
   "repos_url" : "https:\/\/api.github.com\/users\/jaeho0718\/repos",
   "location" : null,
   "hireable" : null,
   "type" : "User",
   "following_url" : "https:\/\/api.github.com\/users\/jaeho0718\/following{\/other_user}",
   "avatar_url" : "https:\/\/avatars.githubusercontent.com\/u\/33758013?v=4",
   "following" : 4,
   "total_private_repos" : 6,
   "starred_url" : "https:\/\/api.github.com\/users\/jaeho0718\/starred{\/owner}{\/repo}",
   "received_events_url" : "https:\/\/api.github.com\/users\/jaeho0718\/received_events",
   "followers_url" : "https:\/\/api.github.com\/users\/jaeho0718\/followers",
   "email" : null,
   "owned_private_repos" : 6,
   "two_factor_authentication" : false,
   "name" : "LeeProgrammer",
   "subscriptions_url" : "https:\/\/api.github.com\/users\/jaeho0718\/subscriptions",
   "gists_url" : "https:\/\/api.github.com\/users\/jaeho0718\/gists{\/gist_id}",
   "private_gists" : 0,
   "plan" : {
     "private_repos" : 9999,
     "collaborators" : 0,
     "space" : 976562499,
     "name" : "pro"
   },
   "gravatar_id" : "",
   "bio" : "WWDC2021 Swift Student Challenge Winner",
   "followers" : 5,
   "disk_usage" : 180101,
   "updated_at" : "2021-07-09T10:40:57Z",
   "public_repos" : 8,
   "site_admin" : false,
   "events_url" : "https:\/\/api.github.com\/users\/jaeho0718\/events{\/privacy}"
 }
 The data couldn’t be read because it is missing.
 {
   "login" : "jaeho0718",
   "public_gists" : 0,
   "twitter_username" : null,
   "created_at" : "2017-11-17T15:55:41Z",
   "id" : 33758013,
   "company" : null,
   "blog" : "jaeho0718.github.io",
   "collaborators" : 0,
   "html_url" : "https:\/\/github.com\/jaeho0718",
   "node_id" : "MDQ6VXNlcjMzNzU4MDEz",
   "url" : "https:\/\/api.github.com\/users\/jaeho0718",
   "organizations_url" : "https:\/\/api.github.com\/users\/jaeho0718\/orgs",
   "repos_url" : "https:\/\/api.github.com\/users\/jaeho0718\/repos",
   "location" : null,
   "hireable" : null,
   "type" : "User",
   "following_url" : "https:\/\/api.github.com\/users\/jaeho0718\/following{\/other_user}",
   "avatar_url" : "https:\/\/avatars.githubusercontent.com\/u\/33758013?v=4",
   "following" : 4,
   "total_private_repos" : 6,
   "starred_url" : "https:\/\/api.github.com\/users\/jaeho0718\/starred{\/owner}{\/repo}",
   "received_events_url" : "https:\/\/api.github.com\/users\/jaeho0718\/received_events",
   "followers_url" : "https:\/\/api.github.com\/users\/jaeho0718\/followers",
   "email" : null,
   "owned_private_repos" : 6,
   "two_factor_authentication" : false,
   "name" : "LeeProgrammer",
   "subscriptions_url" : "https:\/\/api.github.com\/users\/jaeho0718\/subscriptions",
   "gists_url" : "https:\/\/api.github.com\/users\/jaeho0718\/gists{\/gist_id}",
   "private_gists" : 0,
   "plan" : {
     "private_repos" : 9999,
     "collaborators" : 0,
     "space" : 976562499,
     "name" : "pro"
   },
   "gravatar_id" : "",
   "bio" : "WWDC2021 Swift Student Challenge Winner",
   "followers" : 5,
   "disk_usage" : 180101,
   "updated_at" : "2021-07-09T10:40:57Z",
   "public_repos" : 8,
   "site_admin" : false,
   "events_url" : "https:\/\/api.github.com\/users\/jaeho0718\/events{\/privacy}"
 }
 */

/// Structure that have repositroy information
struct Repository_Info : Codable{
    var node_id : String
    var name : String //Repository name
    var full_name : String //Repository fullname
    var html_url : String //Repository site
    var description : String? //Repository description
    var language : String? //Repository language
}
/*
 {
   "keys_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/keys{\/key_id}",
   "statuses_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/statuses\/{sha}",
   "issues_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/issues{\/number}",
   "license" : null,
   "issue_events_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/issues\/events{\/number}",
   "has_projects" : true,
   "id" : 274156038,
   "default_branch" : "master",
   
   "events_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/events",
   "subscription_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/subscription",
   "watchers" : 1,
   "git_commits_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/git\/commits{\/sha}",
   "subscribers_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/subscribers",
   "clone_url" : "https:\/\/github.com\/wwdc-kr\/Assets.git",
   "has_wiki" : true,
   "url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets",
   "pulls_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/pulls{\/number}",
   "fork" : false,
   "notifications_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/notifications{?since,all,participating}",
   "description" : "WWDC Scholars Korea 에서 사용하는 에셋 모음입니다. ",
   "collaborators_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/collaborators{\/collaborator}",
   "deployments_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/deployments",
   "archived" : false,
   "languages_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/languages",
   "has_issues" : true,
   "comments_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/comments{\/number}",
   "private" : true,
   "size" : 1348,
   "git_tags_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/git\/tags{\/sha}",
   "updated_at" : "2020-07-12T12:25:24Z",
   "ssh_url" : "git@github.com:wwdc-kr\/Assets.git",
   "name" : "Assets",
   "contents_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/contents\/{+path}",
   "archive_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/{archive_format}{\/ref}",
   "milestones_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/milestones{\/number}",
   "blobs_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/git\/blobs{\/sha}",
   "node_id" : "MDEwOlJlcG9zaXRvcnkyNzQxNTYwMzg=",
   "contributors_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/contributors",
   "open_issues_count" : 0,
   "permissions" : {
     "admin" : false,
     "push" : true,
     "pull" : true
   },
   "forks_count" : 0,
   "trees_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/git\/trees{\/sha}",
   "svn_url" : "https:\/\/github.com\/wwdc-kr\/Assets",
   "commits_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/commits{\/sha}",
   "created_at" : "2020-06-22T14:13:22Z",
   "forks_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/forks",
   "has_downloads" : true,
   "mirror_url" : null,
   "homepage" : "",
   "teams_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/teams",
   "branches_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/branches{\/branch}",
   "disabled" : false,
   "issue_comment_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/issues\/comments{\/number}",
   "merges_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/merges",
   "git_refs_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/git\/refs{\/sha}",
   "git_url" : "git:\/\/github.com\/wwdc-kr\/Assets.git",
   "forks" : 0,
   "open_issues" : 0,
   "hooks_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/hooks",
   "html_url" : "https:\/\/github.com\/wwdc-kr\/Assets",
   "stargazers_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/stargazers",
   "assignees_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/assignees{\/user}",
   "compare_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/compare\/{base}...{head}",
   "full_name" : "wwdc-kr\/Assets",
   "tags_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/tags",
   "releases_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/releases{\/id}",
   "pushed_at" : "2020-06-24T09:22:33Z",
   "labels_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/labels{\/name}",
   "downloads_url" : "https:\/\/api.github.com\/repos\/wwdc-kr\/Assets\/downloads",
   "stargazers_count" : 1,
   "watchers_count" : 1,
   "language" : null,
   "has_pages" : false
 },
 
 */

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
            return Image("coding")
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
