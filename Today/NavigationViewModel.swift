import SwiftUI

class NavigationViewModel: ObservableObject {
    enum Screen {
        case today
        case tomorrow
        case performance
        case settings
    }
    @Published var currentScreen: Screen = .today
}
