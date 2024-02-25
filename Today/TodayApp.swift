import SwiftUI
import SwiftData

@main
struct TodayApp: App {
    
    @StateObject var navigationViewModel = NavigationViewModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ToDoListItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
