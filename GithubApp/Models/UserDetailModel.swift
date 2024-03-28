//
//  UserDetailModel.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/24.
//

import Foundation

struct UserDetailModel: Codable, Equatable, Identifiable {
    let id: Int
    let name: String?
    let followers: Int
    let following: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case followers
        case following
    }

    static let mockUserDetail = 
        UserDetailModel(
            id: 1,
            name: "User One",
            followers: 4,
            following: 3
        )
}
