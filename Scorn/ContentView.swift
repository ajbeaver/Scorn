import SwiftUI

struct ContentView: View {
    private let menuItems = ["New", "Continue", "Exit"]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 28) {
                AnimatedBanner()

                VStack(alignment: .leading, spacing: 14) {
                    ForEach(menuItems, id: \.self) { item in
                        Text(item)
                            .font(.system(.body, design: .monospaced))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                }
                .foregroundColor(.white)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
        }
        .foregroundColor(.white)
    }
}

private struct AnimatedBanner: View {
    private let baseLines = [
        "  _____  _____  ____  _   _ ",
        #"/ ____|/ ____|/ __ \| \ | |"#,
        #"| (___ | |    | |  | |  \| |"#,
        #"\___ \| |    | |  | | . ` |"#,
        #"____) | |____| |__| | |\  |"#,
        #"|_____/ \_____|\____/|_| \_|"#
    ]

    private let glitchChars: [Character] = [".", ":", "`", "'", "~"]

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.8)) { context in
            let seed = UInt64(context.date.timeIntervalSince1970 * 2)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(baseLines.indices, id: \.self) { index in
                    Text(renderedLine(baseLines[index], seed: seed &+ UInt64(index) * 131))
                        .font(.system(size: 22, weight: .regular, design: .monospaced))
                        .foregroundColor(.red)
                }
            }
            .accessibilityLabel("SCORN")
        }
    }

    private func renderedLine(_ line: String, seed: UInt64) -> String {
        var chars = Array(line)
        for i in chars.indices {
            let value = seed &+ UInt64(i) * 1103515245 &+ 12345
            if value % 97 == 0 {
                chars[i] = glitchChars[Int(value % UInt64(glitchChars.count))]
            }
        }
        return String(chars)
    }
}

#Preview {
    ContentView()
}
