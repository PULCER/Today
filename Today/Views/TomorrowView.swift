import SwiftUI
import SwiftData

struct TomorrowView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Query private var toDoListItems: [ToDoListItem]
    @State private var newToDoText = ""
    @State private var showingAddToDo = false
    
    var body: some View {
        VStack{
            
            Text("Tomorrow")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}
