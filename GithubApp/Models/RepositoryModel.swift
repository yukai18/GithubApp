//
//  RepositoryModel.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/25.
//

import Foundation

struct RepositoryModel: Codable, Equatable, Identifiable {
    let id: Int
    let isForked: Bool
    let name: String
    let language: String?
    let stars: Int
    let description: String?
    let urlString: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case isForked = "fork"
        case name
        case language
        case stars = "stargazers_count"
        case description
        case urlString = "html_url"
    }
    
    static let mockRepositoryArray = [
        RepositoryModel(
            id: 1,
            isForked: true,
            name: "AwesomeSDK 1",
            language: "Swift",
            stars: 500,
            description: "A programming language for iOS app",
            urlString: "https://github.com/apple/swift"
        ),
        RepositoryModel(
            id: 2,
            isForked: true,
            name: "AwesomeSDK 2",
            language: "Swift",
            stars: 500,
            description: "A programming language for iOS app",
            urlString: "https://github.com/apple/swift"
        ),
        RepositoryModel(
            id: 3,
            isForked: true,
            name: "AwesomeSDK 3",
            language: "Swift",
            stars: 500,
            description: "A programming language for iOS app",
            urlString: "https://github.com/apple/swift"
        )
    ]
}
