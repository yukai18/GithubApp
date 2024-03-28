//
//  AvatarAsyncImage.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/25.
//

import SwiftUI

struct AvatarAsyncImage: View {
    let imageUrl: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { result in
            switch result {
            case .failure:
                Image(systemName: "person.crop.circle.badge.exclamationmark")
            case .success(let image):
                image.resizable()
            default:
                ProgressView()
            }
        }
        .clipShape(Circle())
    }
}

#Preview {
    AvatarAsyncImage(imageUrl: "https://i.pravatar.cc/300")
}
