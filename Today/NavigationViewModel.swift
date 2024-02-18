import SwiftUI

class NavigationViewModel: ObservableObject {
    enum Screen {
        case today
        case tomorrow
        case performance
    }
    @Published var currentScreen: Screen = .today
}
