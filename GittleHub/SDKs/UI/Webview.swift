//
//  Webview.swift
//  GittleHub
//
//  Created by Softwind on 2025/5/8.
//

import Foundation
import SwiftUI
import WebKit

struct Webview: UIViewRepresentable {
    
    typealias UIViewType = WKWebView
    typealias InterceptBeforeLoad = (WKWebView, WKNavigationAction) -> WKNavigationActionPolicy

    let content: UIViewType
    let configuration: Configuration = .init()
    
    init() {
        self.content = .init()
    }

    func makeUIView(context: Context) -> WKWebView {
        self.content.navigationDelegate = context.coordinator
        return self.content
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {

    }
    
    func load(url: String) -> Self {
        if let url = URL(string: url) {
            self.content.load(.init(url: url))
        }
        return self
    }
    
    func interceptBeforeLoad(action: @escaping InterceptBeforeLoad) -> Self {
        self.configuration.addInterceptor(
            action,
            for: .beforLoad
        )
        return self
    }

    func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }
    
    class Configuration {
        var interceptors: [LifeCycle: [Any]] = [:]
        func addInterceptor(_ interceptor: Any, for lifecycle: LifeCycle) {
            var list = self.interceptors[lifecycle] ?? []
            list.append(interceptor)
            self.interceptors[lifecycle] = list
        }
        
        enum LifeCycle: Hashable, Equatable, Codable {
            case beforLoad
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {

        let parent: Webview

        init(parent: Webview) {
            self.parent = parent
            super.init()
            
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            (self.parent.configuration.interceptors[.beforLoad] ?? [])
                .compactMap { $0 as? InterceptBeforeLoad }
                .reduce(.allow) { old, action in
                    let new = action(webView, navigationAction)
                    if old == .cancel {
                        return old
                    } else {
                        return new
                    }
                }
        }
    }
}
