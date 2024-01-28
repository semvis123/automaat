import Foundation

enum ThemeId: String, CaseIterable, Identifiable {
    case teal
    case red
    case green
    case blue
    case orange
    case yellow
    case pink
    case purple
    case indigo
    case gray
    case black
    case white

    
    var id: Self { self }
    
    var theme: Theme {
        switch self {
        case .teal: .teal
        case .red: .red
        case .green: .green
        case .blue: .blue
        case .orange: .orange
        case .yellow: .yellow
        case .pink: .pink
        case .purple: .purple
        case .indigo: .indigo
        case .gray: .gray
        case .black: .black
        case .white: .white
        }
    }
}
