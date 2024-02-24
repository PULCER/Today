import SwiftUI
import SwiftData

struct RecurringView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @AppStorage("swipeSensitivity") private var swipeSensitivity: Double = 20.0
    
    
    var body: some View {
        VStack {
            Text("Tomorrow")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}


