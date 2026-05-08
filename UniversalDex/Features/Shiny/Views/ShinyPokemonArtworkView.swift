//
//  ShinyPokemonArtworkView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 08/05/2026.
//

import SwiftUI
import WebKit

struct ShinyPokemonArtworkView: View {
    let url: URL?
    var animatedURL: URL? = nil

    var body: some View {
        if let animatedURL {
            AnimatedShinySpriteView(url: animatedURL)
                .allowsHitTesting(false)
        } else {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}

private struct AnimatedShinySpriteView: UIViewRepresentable {
    let url: URL

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
        guard context.coordinator.loadedURL != url else {
            return
        }

        context.coordinator.loadedURL = url
        webView.loadHTMLString(html(for: url), baseURL: nil)
    }

    private func html(for url: URL) -> String {
        """
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
            <img src="\(url.absoluteString)" onerror="this.style.display='none';">
        </body>
        </html>
        """
    }

    final class Coordinator {
        var loadedURL: URL?
    }
}
