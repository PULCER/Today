import SwiftUI

class NavigationViewModel: ObservableObject {
    enum Screen {
        case today
        case tomorrow
        case performance
        case settings
        case recurring
        case timeless
    }
    @Published var currentScreen: Screen = .today
}
