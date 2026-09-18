import CoreText
import SwiftUI

enum QuoteFont {
    private static let name = "NotoSerifKR-Regular"

    // ponytail: The bundled font covers current quotes; regenerate it when new quote characters are added.
    private static let registration: Void = {
        guard let url = Bundle.main.url(forResource: "NotoSerifKR-Subset", withExtension: "ttf") else {
            return
        }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }()

    static func font(size: CGFloat) -> Font {
        _ = registration
        return .custom(name, size: size)
    }
}
