import SwiftUI

class NavigationViewModel: ObservableObject {
    enum Screen {
        case today
        case tomorrow
    }
    @Published var currentScreen: Screen = .today
}
