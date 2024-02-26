import SwiftUI
import SwiftData

struct TomorrowView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Query private var toDoListItems: [ToDoListItem]
    @State private var newToDoText = ""
    @State private var showingAddToDo = false
    @AppStorage("swipeSensitivity") private var swipeSensitivity: Double = 20.0 
    
    private var tomorrowsTasks: [ToDoListItem] {
        let calendar = Calendar.current
        let tomorrowStart = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)

        return toDoListItems.filter { item in
            calendar.isDate(item.timestamp, inSameDayAs: tomorrowStart)
        }
        .sorted { item1, item2 in
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
            Text("Tomorrow")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            List {
                ForEach(tomorrowsTasks) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.toDoListText)
                                .font(.title3)
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
            
            VStack {
                
                Button(action: {
                    navigationViewModel.currentScreen = .recurring
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 26, weight: .bold))
                }.padding()
                
                HStack {
                    
                    Button(action: {
                        navigationViewModel.currentScreen = .today
                    }) {
                        Image(systemName: "chevron.backward")
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
                        navigationViewModel.currentScreen = .tomorrow
                    }) {
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 26, weight: .bold))
                    }.padding().opacity(0)
                }
            }
            
        }
        .gesture(DragGesture(minimumDistance: swipeSensitivity, coordinateSpace: .local)
            .onEnded { value in
                if value.translation.width > 0 {
                    navigationViewModel.currentScreen = .today
                }
            })
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
            let calendar = Calendar.current
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
            let newItem = ToDoListItem(id: UUID(),
                                       timestamp: tomorrow,
                                       toDoListText: newToDoText,
                                       isCompleted: false,
                                       itemType: ToDoItemType.regular.rawValue,
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
                let idToDelete = tomorrowsTasks[offset].id
                if let indexToDelete = toDoListItems.firstIndex(where: { $0.id == idToDelete }) {
                    let itemToDelete = toDoListItems[indexToDelete]
                    modelContext.delete(itemToDelete)
                }
            }
        }
    }
}


