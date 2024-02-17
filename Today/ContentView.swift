import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var toDoListItems: [ToDoListItem]

    var body: some View {
        
        List {
            ForEach(toDoListItems) { item in
                
                Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                
            }
            .onDelete(perform: deleteItems)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = ToDoListItem(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(toDoListItems[index])
            }
        }
    }
}
