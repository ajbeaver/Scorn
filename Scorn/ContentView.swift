//
//  ContentView.swift
//  Scorn
//
//  Created by bea on 2/9/26.
//

import SwiftUI
internal import Combine

struct ContentView: View {
    @State private var bannerLines: [String] = ASCIIArt.base
    private let timer = Timer.publish(every: 1.4, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 28) {
                VStack(spacing: 4) {
                    ForEach(bannerLines.indices, id: \.self) { index in
                        Text(bannerLines[index])
                            .font(.system(size: 16, weight: .regular, design: .monospaced))
                            .foregroundColor(ScornColor.red)
                            .kerning(0.4)
                    }
                }
                .onReceive(timer) { _ in
                    bannerLines = ASCIIArt.flicker(from: ASCIIArt.base)
                }

                VStack(spacing: 14) {
                    MenuOption(title: "New")
                    MenuOption(title: "Continue")
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 40)
        }
    }
}

private struct MenuOption: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .regular, design: .monospaced))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .overlay(
                Rectangle()
                    .stroke(ScornColor.red, lineWidth: 1.5)
            )
    }
}

private enum ScornColor {
    static let red = Color(red: 0.82, green: 0.08, blue: 0.08)
}



private enum ASCIIArt {
    static let base: [String] = [
        " oooooooo8    oooooooo8   ooooooo  oooooooooo  oooo   oooo ",
        " 888         o888     88 o888   888o 888    888  8888o  88  ",
        "  888oooooo  888         888     888 888oooo88   88 888o88  ",
        "        888 888o     oo 888o   o888 888  88o    88   8888  ",
        " o88oooo888   888oooo88    88ooo88  o888o  88o8 o88o    88  "
    ]

    static func flicker(from lines: [String]) -> [String] {
        let glyphs = Array("+-=:.")
        return lines.map { line in
            String(line.enumerated().map { index, char in
                if char == " " { return char }
                if Int.random(in: 0..<100) < 6 {
                    return glyphs.randomElement() ?? char
                }
                return char
            })
        }
    }
}
