//
//  ShinyPokemonCryPlayerView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 08/05/2026.
//

import SwiftUI
import WebKit

struct ShinyPokemonCryPlayerView: UIViewRepresentable {
    let url: URL?
    let playbackID: Int

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url, playbackID > 0, context.coordinator.playbackID != playbackID else {
            return
        }

        context.coordinator.playbackID = playbackID
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
            width: 1px;
            height: 1px;
            overflow: hidden;
            background: transparent;
        }
        </style>
        </head>
        <body>
            <audio autoplay>
                <source src="\(url.absoluteString)" type="audio/ogg">
            </audio>
        </body>
        </html>
        """
    }

    final class Coordinator {
        var playbackID = 0
    }
}
