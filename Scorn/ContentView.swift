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
    @State private var screen: MenuScreen = .main
    @State private var showingNewGameIntro = false
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

                switch screen {
                case .main:
                    MainMenuView { selection in
                        screen = selection
                    }
                case .play:
                    PlaySubmenuView(
                        onNewGame: {
                            showingNewGameIntro = true
                        },
                        onBack: {
                            screen = .main
                        }
                    )
                case .settings:
                    SettingsMenuView {
                        screen = .main
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 40)
            .opacity(showingNewGameIntro ? 0 : 1)
            .animation(.easeOut(duration: 0.3), value: showingNewGameIntro)

            if showingNewGameIntro {
                NewGameIntroView()
                    .transition(.opacity)
            }
        }
    }
}

private struct MainMenuView: View {
    let onSelect: (MenuScreen) -> Void

    var body: some View {
        VStack(spacing: 14) {
            MenuOption(title: "Play") {
                onSelect(.play)
            }
            MenuOption(title: "Settings") {
                onSelect(.settings)
            }
        }
    }
}

private struct PlaySubmenuView: View {
    let onNewGame: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            MenuOption(title: "New Game") {
                onNewGame()
            }
            MenuOption(title: "Continue")
            MenuOption(title: "Back") {
                onBack()
            }
        }
    }
}

private struct SettingsMenuView: View {
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            MenuOption(title: "Back") {
                onBack()
            }
        }
    }
}

private struct MenuOption: View {
    let title: String
    var action: (() -> Void)?

    var body: some View {
        Button(action: { action?() }) {
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
        .buttonStyle(.plain)
    }
}

private enum MenuScreen {
    case main
    case play
    case settings
}

enum ScornColor {
    static let red = Color(red: 0.82, green: 0.08, blue: 0.08)
}



enum ASCIIArt {
    static let base: [String] = [
        " oooooooo8    oooooooo8    ooooooo  oooooooooo  oooo   oooo ",
        " 888         o888     88 o888   888o 888    888  8888o  88  ",
        "  888oooooo  888         888     888 888oooo88   88 888o88  ",
        "        888  888o     oo 888o   o888 888  88o    88   8888  ",
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
