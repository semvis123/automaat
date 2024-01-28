import Foundation
import SwiftUI
import SwiftUITheme

struct Theme {
    let color: Color
}

extension Theme {
    static let teal = Theme(color: .init(hue: 0.55, saturation: 1, brightness: 0.51))
    static let red = Theme(color: .red)
    static let green = Theme(color: .green)
    static let blue = Theme(color: .blue)
    static let orange = Theme(color: .orange)
    static let yellow = Theme(color: .yellow)
    static let pink = Theme(color: .pink)
    static let purple = Theme(color: .purple)
    static let indigo = Theme(color: .indigo)
    static let gray = Theme(color: .gray)
    static let black = Theme(color: Color(light: .black, dark: Color.init(hue: 0, saturation: 0, brightness: 0.2)))
    static let white = Theme(color: Color(light: .white, dark: Color.init(hue: 0, saturation: 0, brightness: 0.75)))
}

extension Theme: BaseTheme {
    static var defaultValue: Theme = Theme.teal
    static var environmentValue: WritableKeyPath<EnvironmentValues, Theme> { \.theme }
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[Theme.self] }
        set { self[Theme.self] = newValue }
    }
}

extension ThemeColor where Self == ThemeColor<automaat.Theme> {
    static var themedColor: Self { Self(\.color) }
}

extension UIColor {
    convenience init(
        light lightModeColor: @escaping @autoclosure () -> UIColor,
        dark darkModeColor: @escaping @autoclosure () -> UIColor
     ) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return lightModeColor()
            case .dark:
                return darkModeColor()
            case .unspecified:
                return lightModeColor()
            @unknown default:
                return lightModeColor()
            }
        }
    }
}

extension Color {
    init(
        light lightModeColor: @escaping @autoclosure () -> Color,
        dark darkModeColor: @escaping @autoclosure () -> Color
    ) {
        self.init(UIColor(
            light: UIColor(lightModeColor()),
            dark: UIColor(darkModeColor())
        ))
    }
}

