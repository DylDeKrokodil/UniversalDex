//
//  ShinyPokemonArtworkView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 08/05/2026.
//

import SwiftUI
import WebKit

struct ShinyPokemonArtworkView: View {
    var url: URL? = nil
    var animatedURL: URL? = nil
    var fallbackURL: URL? = nil
    var sourceURLs: [URL] = []
    
    @State private var isLoading = true
    @State private var didFailToLoad = false

    var body: some View {
        let usesWebSpriteLoader = !sourceURLs.isEmpty || animatedURL != nil

        ZStack {
            if usesWebSpriteLoader && (isLoading || didFailToLoad) {
                Image("PokemonEgg")
                    .resizable()
                    .scaledToFit()
            }

            if !sourceURLs.isEmpty {
                SpriteFallbackWebView(
                    sourceURLs: sourceURLs,
                    isLoading: $isLoading,
                    didFailToLoad: $didFailToLoad
                )
                    .allowsHitTesting(false)
            } else if let animatedURL {
                SpriteFallbackWebView(
                    sourceURLs: [animatedURL] + [url, fallbackURL].compactMap { $0 },
                    isLoading: $isLoading,
                    didFailToLoad: $didFailToLoad
                )
                    .allowsHitTesting(false)
            } else {
                PokemonImageView(urls: [url, fallbackURL].compactMap { $0 })
            }
        }
    }
}

private struct SpriteFallbackWebView: UIViewRepresentable {
    let sourceURLs: [URL]
    @Binding var isLoading: Bool
    @Binding var didFailToLoad: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, didFailToLoad: $didFailToLoad)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "spriteStatus")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.isUserInteractionEnabled = false
        webView.isUserInteractionEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedURLs != sourceURLs else {
            return
        }

        context.coordinator.loadedURLs = sourceURLs
        isLoading = true
        didFailToLoad = false
        webView.loadHTMLString(html(for: sourceURLs), baseURL: nil)
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "spriteStatus")
    }

    private func html(for urls: [URL]) -> String {
        let sources = urls
            .map { "'\($0.absoluteString)'" }
            .joined(separator: ",")

        return """
        <!doctype html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
        html, body {
            margin: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            background: transparent;
        }
        body {
            display: flex;
            align-items: center;
            justify-content: center;
        }
        img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }
        </style>
        </head>
        <body>
            <img id="pokemon-sprite" alt="" onload="spriteDidLoad();" onerror="loadNextSprite();">
            <script>
            const sources = [\(sources)];
            const currentImage = document.getElementById('pokemon-sprite');
            let sourceIndex = 0;

            function postStatus(status) {
                window.webkit.messageHandlers.spriteStatus.postMessage(status);
            }

            function spriteDidLoad() {
                postStatus('loaded');
            }

            function loadNextSprite() {
                if (sourceIndex >= sources.length) {
                    currentImage.style.display = 'none';
                    postStatus('failed');
                    return;
                }

                currentImage.src = sources[sourceIndex];
                sourceIndex += 1;
            }

            loadNextSprite();
            </script>
        </body>
        </html>
        """
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        @Binding var isLoading: Bool
        @Binding var didFailToLoad: Bool
        var loadedURLs: [URL] = []

        init(isLoading: Binding<Bool>, didFailToLoad: Binding<Bool>) {
            _isLoading = isLoading
            _didFailToLoad = didFailToLoad
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if loadedURLs.isEmpty {
                isLoading = false
                didFailToLoad = true
            }
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard let status = message.body as? String else {
                return
            }

            isLoading = false
            didFailToLoad = status != "loaded"
        }
    }
}
