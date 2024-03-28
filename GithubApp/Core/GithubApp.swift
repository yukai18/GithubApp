//
//  GithubAppApp.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct GithubApp: App {
    static let store = Store(initialState: UsersListFeature.State()) {
        UsersListFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            UsersListView(store: GithubApp.store)
        }
    }
}
