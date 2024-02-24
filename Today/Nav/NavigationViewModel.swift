import SwiftUI

class NavigationViewModel: ObservableObject {
    enum Screen {
        case today
        case tomorrow
        case performance
        case settings
        case recurring
    }
    @Published var currentScreen: Screen = .today
}
