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

    var body: some View {
        if !sourceURLs.isEmpty {
            SpriteFallbackWebView(sourceURLs: sourceURLs)
                .allowsHitTesting(false)
        } else if let animatedURL {
            SpriteFallbackWebView(
                sourceURLs: [animatedURL] + [url, fallbackURL].compactMap { $0 }
            )
                .allowsHitTesting(false)
        } else {
            PokemonImageView(urls: [url, fallbackURL].compactMap { $0 })
        }
    }
}

private struct SpriteFallbackWebView: UIViewRepresentable {
    let sourceURLs: [URL]

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
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
        webView.loadHTMLString(html(for: sourceURLs), baseURL: nil)
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
            <img id="pokemon-sprite" alt="" onerror="loadNextSprite();">
            <script>
            const sources = [\(sources)];
            const currentImage = document.getElementById('pokemon-sprite');
            let sourceIndex = 0;

            function loadNextSprite() {
                if (sourceIndex >= sources.length) {
                    currentImage.style.display = 'none';
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

    final class Coordinator {
        var loadedURLs: [URL] = []
    }
}
