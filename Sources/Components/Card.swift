import SwiftUI
import UIKit

public struct Card<Content: View>: View {
    @ViewBuilder public let content: Content
    private let background: Color
    private let spacing: CGFloat
    private let innerPadding: CGFloat

    public init(background: Color = Color(.systemBackground), spacing: CGFloat = 6, innerPadding: CGFloat = 14, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.background = background
        self.spacing = spacing
        self.innerPadding = innerPadding
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .padding(innerPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .cornerRadius(7)
        //.shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
}

@ViewBuilder
public func nbItemsCard<Content: View>(background: Color = Color(UIColor.systemGray5), @ViewBuilder _ content: () -> Content) -> some View {
    Card(background: background, innerPadding: 8) {
        content()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 4)
}

public func nbItemsText(_ text: String, color: Color = .secondary) -> some View {
    Text(text)
    .font(.system(size: 14))
    .foregroundColor(color)
    .multilineTextAlignment(.center)
    .padding(.vertical, 1)
}
