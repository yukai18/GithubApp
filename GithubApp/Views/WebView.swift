//
//  WebView.swift
//  GithubApp
//
//  Created by Yukai on 2024/03/28.
//

import SwiftUI
import SafariServices
import ComposableArchitecture

struct WebView: View {
    @Bindable var store: StoreOf<WebFeature>
    
    var body: some View {
        SafariRepresentable(urlString: store.state.urlString)
    }
}

#Preview {
    WebView(
        store: Store.init(
            initialState: WebFeature.State(urlString: "https://google.com"),
            reducer: { 
                WebFeature()
            }
        )
    )
}

struct SafariRepresentable: UIViewControllerRepresentable {
    let urlString: String
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return SFSafariViewController(url: URL(string: urlString)!)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
