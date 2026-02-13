//
//  NewGameIntroView.swift
//  Scorn
//

import SwiftUI

struct NewGameIntroView: View {
    @State private var overlayOpacity: Double = 0
    @State private var bannerOpacity: Double = 0
    @State private var bannerLines: [String] = ASCIIArt.base
    @State private var bannerScale: CGFloat = 1
    @State private var bannerOffset = CGSize.zero
    @State private var showingText = false
    @State private var typedLines: [String] = []
    @State private var showContinue = false
    @State private var introTask: Task<Void, Never>?

    private let textBlocks = [
        [
            "pressure behind the eyes",
            "darkness",
            "weight"
        ],
        [
            "air tastes like dust",
            "metal",
            "heat"
        ],
        [
            "you are aware",
            "you do not remember arriving"
        ]
    ]

    var body: some View {
        ZStack {
            Color.black
                .opacity(overlayOpacity)
                .ignoresSafeArea()

            if bannerOpacity > 0 {
                VStack(spacing: 4) {
                    ForEach(bannerLines.indices, id: \.self) { index in
                        Text(bannerLines[index])
                            .font(.system(size: 16, weight: .regular, design: .monospaced))
                            .foregroundColor(ScornColor.red)
                            .kerning(0.4)
                    }
                }
                .opacity(bannerOpacity)
                .scaleEffect(bannerScale)
                .offset(bannerOffset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }

            if showingText {
                VStack(spacing: 0) {
                    Spacer()
                        .layoutPriority(2)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(typedLines.indices, id: \.self) { index in
                            Text(typedLines[index])
                                .font(.system(size: 19, weight: .regular, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                        .layoutPriority(1)

                    if showContinue {
                        Button(action: {}) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .regular, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .overlay(
                                    Rectangle()
                                        .stroke(ScornColor.red, lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 24)
                    }
                }
                .padding(.horizontal, 28)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            introTask?.cancel()
            introTask = Task {
                await runIntroSequence()
            }
        }
        .onDisappear {
            introTask?.cancel()
        }
    }

    @MainActor
    private func runIntroSequence() async {
        typedLines = []
        showingText = false
        showContinue = false
        bannerLines = ASCIIArt.base
        overlayOpacity = 0
        bannerOpacity = 0
        bannerScale = 1
        bannerOffset = .zero

        withAnimation(.easeOut(duration: 0.45)) {
            overlayOpacity = 1
        }
        try? await Task.sleep(nanoseconds: 450_000_000)

        withAnimation(.easeIn(duration: 0.22)) {
            bannerOpacity = 1
        }
        try? await Task.sleep(nanoseconds: 200_000_000)

        for frame in 0..<18 {
            bannerLines = ASCIIArt.flicker(from: ASCIIArt.base)
            bannerScale = 1 + CGFloat.random(in: -0.015...0.025)
            bannerOffset = CGSize(
                width: CGFloat.random(in: -3...3),
                height: CGFloat.random(in: -2...2)
            )
            if frame.isMultiple(of: 6) {
                bannerOpacity = 0.75
            } else {
                bannerOpacity = 1
            }
            try? await Task.sleep(nanoseconds: 80_000_000)
        }
        bannerScale = 1
        bannerOffset = .zero

        withAnimation(.easeOut(duration: 0.4)) {
            bannerOpacity = 0
        }
        try? await Task.sleep(nanoseconds: 900_000_000)

        withAnimation(.easeIn(duration: 0.2)) {
            showingText = true
        }

        for blockIndex in textBlocks.indices {
            let block = textBlocks[blockIndex]
            for line in block {
                typedLines.append("")
                let lastIndex = typedLines.count - 1
                for char in line {
                    typedLines[lastIndex].append(char)
                    try? await Task.sleep(nanoseconds: 30_000_000)
                }
                try? await Task.sleep(nanoseconds: 80_000_000)
            }

            if blockIndex < textBlocks.count - 1 {
                try? await Task.sleep(nanoseconds: 700_000_000)
                withAnimation(.easeOut(duration: 0.2)) {
                    typedLines = []
                }
                try? await Task.sleep(nanoseconds: 250_000_000)
            }
        }

        try? await Task.sleep(nanoseconds: 1_350_000_000)
        withAnimation(.easeIn(duration: 0.2)) {
            showContinue = true
        }
    }
}
