import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Query private var toDoListItems: [ToDoListItem]
    @State private var newToDoText = ""
    @State private var showingAddToDo = false
    @AppStorage("swipeSensitivity") private var swipeSensitivity: Double = 20.0 
    
    private var todaysTasks: [ToDoListItem] {
            let calendar = Calendar.current
            let filteredItems = toDoListItems.filter { item in
                calendar.isDate(item.timestamp, inSameDayAs: Date())
            }
            return filteredItems.sorted { item1, item2 in
                if item1.isCompleted && !item2.isCompleted {
                    return false
                } else if !item1.isCompleted && item2.isCompleted {
                    return true
                } else {
                    return item1.timestamp < item2.timestamp
                }
            }
        }
    
    var body: some View {
        VStack {
            Text("Today")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            List {
                ForEach(todaysTasks) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.toDoListText).font(.title3)
                        }
                        Spacer()
                        
                        Button(action: {
                            item.isCompleted.toggle()
                        }) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            Spacer()
            
            HStack {
                
                Button(action: {
                    navigationViewModel.currentScreen = .performance
                }) {
                    Image(systemName: "chevron.backward")
                }.padding()
                
                Button(action: {
                    self.showingAddToDo = true
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
        .gesture(DragGesture(minimumDistance: swipeSensitivity, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            navigationViewModel.currentScreen = .tomorrow
                        } else if value.translation.width > 0 {
                            navigationViewModel.currentScreen = .performance
                        }
                    })
        .sheet(isPresented: $showingAddToDo) {
            
            VStack {
                TextField("Enter new task", text: $newToDoText)
                
                Spacer()
                
                HStack{
                    
                    Button("Discard") {
                        newToDoText = ""
                        self.showingAddToDo = false
                    }
                    .foregroundColor(.gray)
                    .font(.title3)
                    
                    Spacer()
                    
                    Button("Save") {
                        addItem()
                        self.showingAddToDo = false
                    }
                    .foregroundColor(.gray)
                    .font(.title3)
                    
                }.padding(.vertical)
                
            }
            .padding()
            .presentationDetents([.height(125)])
        }
        
    }
    
    private func addItem() {
        withAnimation {
            let newItem = ToDoListItem(timestamp: Date(), toDoListText: newToDoText, isCompleted: false)
            modelContext.insert(newItem)
            newToDoText = ""
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.forEach { offset in
                let idToDelete = todaysTasks[offset].id
                if let indexToDelete = toDoListItems.firstIndex(where: { $0.id == idToDelete }) {
                    let itemToDelete = toDoListItems[indexToDelete]
                    modelContext.delete(itemToDelete)
                }
            }
        }
    }
}
