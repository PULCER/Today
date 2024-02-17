import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Query private var toDoListItems: [ToDoListItem]
    @State private var newToDoText = ""
    @State private var showingAddToDo = false

    var body: some View {
        VStack{
            
            Text("Today")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            List {
                ForEach(toDoListItems) { item in
                    Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                }
                .onDelete(perform: deleteItems)
            }
            Spacer()
            
            HStack {
                
                Button(action: {
                }) {
                    Image(systemName: "chevron.backward")
                }.padding()
                
                Button(action: {
                    self.showingAddToDo = true
                    addItem()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.blue)
                        .padding()
                }
            
                Button(action: {
                                   navigationViewModel.currentScreen = .tomorrow
                               }) {
                                   Image(systemName: "chevron.forward")
                               }.padding()
            }
            
        }
        
    }
    
    private func addItem() {
           withAnimation {
               let newItem = ToDoListItem(timestamp: Date(), toDoListText: newToDoText, isCompleted: false)
               modelContext.insert(newItem)
               newToDoText = "" // Reset the text field after adding
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
