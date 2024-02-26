import SwiftUI
import SwiftData

struct TimelessView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Query private var toDoListItems: [ToDoListItem]
    @State private var newToDoText = ""
    @State private var showingAddToDo = false
    @AppStorage("swipeSensitivity") private var swipeSensitivity: Double = 20.0
    
    private var timelessTasks: [ToDoListItem] {
        toDoListItems.filter { $0.itemType == ToDoItemType.timeless.rawValue }
    }
    
    var body: some View {
        VStack {
            VStack{
                Text("Timeless")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }.gesture(DragGesture(minimumDistance: swipeSensitivity, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width < 0 {
                        navigationViewModel.currentScreen = .recurring
                    }
                })
            
            List {
                ForEach(timelessTasks) { item in
                    Text(item.toDoListText)
                        .font(.title3)
                        .bold()
                } .onDelete(perform: deleteItems)
            }
            
            HStack {
                Button(action: {
                    navigationViewModel.currentScreen = .today
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 26, weight: .bold))
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
                    navigationViewModel.currentScreen = .recurring
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 26, weight: .bold))
                }.padding()
            }
        }
        .sheet(isPresented: $showingAddToDo) {
            
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        AutoFocusTextField(text: $newToDoText, placeholder: "Enter new task")
                            .frame(width: 250)
                    }
                }
                
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
                    .foregroundColor(.blue)
                    .font(.title3)
                    
                }.padding(.vertical)
                
            }
            .padding()
            .presentationDetents([.height(100)])
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = ToDoListItem(id: UUID(),
                                       timestamp: Date(),
                                       toDoListText: newToDoText,
                                       isCompleted: false,
                                       itemType: ToDoItemType.timeless.rawValue,
                                       completionDates: [],
                                       taskFrequency: TaskFrequency.daily.rawValue,
                                       interval: 1)
            modelContext.insert(newItem)
            newToDoText = ""
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.forEach { offset in
                let idToDelete = timelessTasks[offset].id
                if let indexToDelete = timelessTasks.firstIndex(where: { $0.id == idToDelete }) {
                    let itemToDelete = timelessTasks[indexToDelete]
                    modelContext.delete(itemToDelete)
                }
            }
        }
    }
    
}

