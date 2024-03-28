//
//  GithubClient.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/24.
//

import Foundation
import ComposableArchitecture

struct GithubClient {
    var getUsersList: (Int) async throws -> [UserModel]
    var getUserDetail: (String) async throws -> UserDetailModel
    var getUserRepositories: (String, Int) async throws -> [RepositoryModel]
}

extension GithubClient: DependencyKey {
    static var liveValue: Self {
        return Self(
            getUsersList: { lastUserId in
                let request = createGetUrlRequest(endpoint: "\(Endpoints.usersList.url)\(lastUserId)")
                let (data, _) = try await URLSession.shared.data(for: request)
                let userList = try JSONDecoder().decode([UserModel].self, from: data)
                return userList
            },
            getUserDetail: { username in
                let request = createGetUrlRequest(endpoint: "\(Endpoints.userDetail.url)\(username)")
                let (data, _) = try await URLSession.shared.data(for: request)
                let userDetails = try JSONDecoder().decode(UserDetailModel.self, from: data)
                return userDetails
            },
            getUserRepositories: { username, page in
                let request = createGetUrlRequest(endpoint: "\(Endpoints.userDetail.url)\(username)/\(Endpoints.userRepos.rawValue)\(page)")
                let (data, _) = try await URLSession.shared.data(for: request)
                let userRepos = try JSONDecoder().decode([RepositoryModel].self, from: data)
                return userRepos
            }
        )
        
        func createGetUrlRequest(endpoint: String) -> URLRequest {
            let url = URL(string: endpoint)!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer <#T##Github Personal Token##String#>", forHTTPHeaderField: "Authorization")
            return request
        }
    }
}

extension DependencyValues {
    var githubClient: GithubClient {
        get { self[GithubClient.self] }
        set { self[GithubClient.self] = newValue }
    }
}
