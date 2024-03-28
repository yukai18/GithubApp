//
//  UserModel.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/24.
//

import Foundation

struct UserModel: Codable, Identifiable, Equatable {
    let id: Int
    let username: String
    let avatarImage: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case username = "login"
        case avatarImage = "avatar_url"
    }
    
    static let mockUsersArray = [
        UserModel(
            id: 1,
            username: "User 1",
            avatarImage: "https://i.pravatar.cc/300"
        ),
        UserModel(
            id: 2,
            username: "User 2",
            avatarImage: "https://i.pravatar.cc/300"
        ),
        UserModel(
            id: 3,
            username: "User 3",
            avatarImage: "https://i.pravatar.cc/300"
        )
    ]
}

