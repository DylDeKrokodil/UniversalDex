//
//  AppLaunchView.swift
//  UniversalDex
//
//  Created by Codex on 09/05/2026.
//

import SwiftUI

struct AppLaunchView: View {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @State private var didAppear = false
    @State private var scanLineOffset: CGFloat = -0.44

    private let sparkles = SplashSparkle.presets

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate

            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                launchBackground(elapsed: elapsed)
                sparkleField(elapsed: elapsed)

                VStack(spacing: 28) {
                    Spacer(minLength: 36)

                    scannerCore(elapsed: elapsed)
                        .scaleEffect(didAppear ? 1 : 0.84)
                        .opacity(didAppear ? 1 : 0)

                    titleStack
                        .opacity(didAppear ? 1 : 0)
                        .offset(y: didAppear ? 0 : 18)

                    Spacer(minLength: 28)

                    loadingPill
                        .opacity(didAppear ? 1 : 0)
                        .offset(y: didAppear ? 0 : 12)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 36)
            }
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("UniversalDex is opening")
        .onAppear {
            withAnimation(.spring(response: 0.72, dampingFraction: 0.78)) {
                didAppear = true
            }

            guard !reduceMotion else {
                scanLineOffset = 0.32
                return
            }

            withAnimation(.easeInOut(duration: 1.18).repeatForever(autoreverses: true)) {
                scanLineOffset = 0.44
            }
        }
    }

    private func launchBackground(elapsed: TimeInterval) -> some View {
        let driftX = reduceMotion ? CGFloat(0) : CGFloat(cos(elapsed * 0.42) * 0.07)
        let driftY = reduceMotion ? CGFloat(0) : CGFloat(sin(elapsed * 0.34) * 0.05)

        return ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    AppTheme.accentColor.opacity(0.16),
                    Color.orange.opacity(0.14),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    AppTheme.accentColor.opacity(0.28),
                    AppTheme.accentColor.opacity(0.08),
                    .clear
                ],
                center: UnitPoint(
                    x: 0.5 + driftX,
                    y: 0.36 + driftY
                ),
                startRadius: 12,
                endRadius: 340
            )

            AngularGradient(
                colors: [
                    .clear,
                    Color.white.opacity(0.22),
                    .clear,
                    AppTheme.accentColor.opacity(0.16),
                    .clear
                ],
                center: .center,
                startAngle: .degrees(elapsed * 10),
                endAngle: .degrees(elapsed * 10 + 360)
            )
            .blur(radius: 48)
            .opacity(reduceMotion ? 0.36 : 0.72)
        }
    }

    private func sparkleField(elapsed: TimeInterval) -> some View {
        GeometryReader { proxy in
            ForEach(sparkles) { sparkle in
                let pulse = reduceMotion ? CGFloat(1) : CGFloat(0.48 + abs(sin(elapsed * sparkle.speed + sparkle.delay)) * 0.52)

                Image(systemName: "sparkle")
                    .font(.system(size: sparkle.size, weight: .bold))
                    .foregroundStyle(.white.opacity(Double(0.42 + pulse * 0.38)))
                    .scaleEffect(sparkle.scale + pulse * 0.22)
                    .position(
                        x: proxy.size.width * sparkle.x,
                        y: proxy.size.height * sparkle.y
                    )
            }
        }
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
    }

    private func scannerCore(elapsed: TimeInterval) -> some View {
        let outerPulse = reduceMotion ? CGFloat(1) : CGFloat(1 + abs(sin(elapsed * 1.8)) * 0.08)

        return ZStack {
            Circle()
                .stroke(AppTheme.accentColor.opacity(0.12), lineWidth: 1)
                .frame(width: 286, height: 286)
                .scaleEffect(outerPulse)

            Circle()
                .trim(from: 0.03, to: 0.3)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.1), .white.opacity(0.88), AppTheme.accentColor],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 242, height: 242)
                .rotationEffect(.degrees(elapsed * 70))
                .shadow(color: AppTheme.accentColor.opacity(0.28), radius: 16)

            Circle()
                .trim(from: 0.58, to: 0.88)
                .stroke(
                    Color.orange.opacity(0.74),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [9, 12])
                )
                .frame(width: 214, height: 214)
                .rotationEffect(.degrees(-elapsed * 42))

            PokedexBeacon()
                .frame(width: 156, height: 156)
                .shadow(color: AppTheme.accentColor.opacity(0.32), radius: 30, y: 18)

            scanLine
                .frame(width: 190, height: 86)
                .offset(y: scanLineOffset * 168)
                .mask {
                    Circle()
                        .frame(width: 184, height: 184)
                }
                .opacity(reduceMotion ? 0.34 : 0.72)
        }
        .frame(width: 302, height: 302)
    }

    private var scanLine: some View {
        LinearGradient(
            colors: [
                .clear,
                Color.white.opacity(0.82),
                AppTheme.accentColor.opacity(0.48),
                .clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .blur(radius: 1.2)
        .overlay(alignment: .center) {
            Rectangle()
                .fill(Color.white.opacity(0.9))
                .frame(height: 2)
                .blur(radius: 0.8)
        }
    }

    private var titleStack: some View {
        VStack(spacing: 10) {
            Text("UNIVERSALDEX")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .tracking(3)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text("Shiny signal acquired")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }

    private var loadingPill: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.accentColor)

            Text("Syncing your hunt deck")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
        }
    }
}

private struct PokedexBeacon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.white)

            VStack(spacing: 0) {
                AppTheme.accentColor
                Color.white
            }
            .clipShape(Circle())

            Rectangle()
                .fill(Color.primary.opacity(0.82))
                .frame(height: 10)

            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 54, height: 54)
                .overlay {
                    Circle()
                        .stroke(Color.primary.opacity(0.82), lineWidth: 8)
                }

            Circle()
                .stroke(Color.primary.opacity(0.82), lineWidth: 8)
        }
    }
}

private struct SplashSparkle: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let scale: CGFloat
    let speed: Double
    let delay: Double

    static let presets: [SplashSparkle] = [
        SplashSparkle(id: 0, x: 0.16, y: 0.21, size: 16, scale: 0.8, speed: 1.9, delay: 0.2),
        SplashSparkle(id: 1, x: 0.82, y: 0.18, size: 12, scale: 0.9, speed: 2.3, delay: 1.1),
        SplashSparkle(id: 2, x: 0.73, y: 0.35, size: 18, scale: 0.76, speed: 1.7, delay: 2.2),
        SplashSparkle(id: 3, x: 0.23, y: 0.62, size: 13, scale: 0.86, speed: 2.1, delay: 2.9),
        SplashSparkle(id: 4, x: 0.86, y: 0.69, size: 15, scale: 0.72, speed: 1.8, delay: 0.8),
        SplashSparkle(id: 5, x: 0.34, y: 0.82, size: 11, scale: 0.94, speed: 2.4, delay: 1.7)
    ]
}

struct AppLaunchView_Previews: PreviewProvider {
    static var previews: some View {
        AppLaunchView()
    }
}
