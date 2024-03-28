//
//  WebFeature.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/28.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WebFeature {
    @ObservableState
    struct State: Equatable {
        var urlString: String
    }
    
    enum Action {
        // User's action
        case cancelButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { _ in await self.dismiss() }
            }
        }
    }
}
