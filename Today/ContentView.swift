import SwiftUI

struct ContentView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel

    var body: some View {
        switch navigationViewModel.currentScreen {
        case .today:
            TodayView()
        case .tomorrow:
            TomorrowView()
        case .performance:
            PerformanceView()
        }
    }
}
