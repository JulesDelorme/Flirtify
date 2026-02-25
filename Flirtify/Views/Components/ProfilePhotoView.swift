import SwiftUI
import UIKit

struct ProfilePhotoView: View {
    let photoData: Data?
    let fallbackSymbol: String
    let size: CGFloat
    let backgroundColor: Color
    let symbolColor: Color
    let strokeColor: Color

    init(
        photoData: Data?,
        fallbackSymbol: String,
        size: CGFloat = 72,
        backgroundColor: Color = Color.blue.opacity(0.16),
        symbolColor: Color = .blue,
        strokeColor: Color = Color.white.opacity(0.5)
    ) {
        self.photoData = photoData
        self.fallbackSymbol = fallbackSymbol
        self.size = size
        self.backgroundColor = backgroundColor
        self.symbolColor = symbolColor
        self.strokeColor = strokeColor
    }

    var body: some View {
        ZStack {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(backgroundColor)
                Image(systemName: fallbackSymbol)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(symbolColor)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(strokeColor, lineWidth: 1)
        )
    }

    private var uiImage: UIImage? {
        guard let photoData else {
            return nil
        }
        return UIImage(data: photoData)
    }
}
