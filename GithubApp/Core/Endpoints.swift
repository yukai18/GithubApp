//
//  Endpoints.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/24.
//

import Foundation

enum Endpoints: String {
    case usersList = "users?since="
    case userDetail = "users/"
    case userRepos = "repos?page="
    
    var url: String {
        "https://api.github.com/" + self.rawValue
    }
}
