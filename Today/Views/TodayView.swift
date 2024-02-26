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
        return toDoListItems.filter { item in
            guard item.itemType != ToDoItemType.timeless.rawValue else {
                return false
            }
            
            if item.itemType == ToDoItemType.recurring.rawValue {
                return TaskManager.shared.needsCompletion(task: item)
            } else {
                return calendar.isDate(item.timestamp, inSameDayAs: Date())
            }
        }.sorted { item1, item2 in
            if item1.itemType == ToDoItemType.recurring.rawValue && item2.itemType != ToDoItemType.recurring.rawValue {
                return false
            } else if item1.itemType != ToDoItemType.recurring.rawValue && item2.itemType == ToDoItemType.recurring.rawValue {
                return true
            }
            
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
            VStack{
                Text("Today")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }.gesture(DragGesture(minimumDistance: swipeSensitivity, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width < 0 {
                        navigationViewModel.currentScreen = .tomorrow
                    } else if value.translation.width > 0 {
                        navigationViewModel.currentScreen = .performance
                    } else if value.translation.height < 0 { // Check for swipe-up gesture
                        navigationViewModel.currentScreen = .timeless
                    }
                })

            List {
                ForEach(todaysTasks) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.toDoListText)
                                .font(.title3)
                                .bold()
                                .foregroundColor(TaskManager.shared.isTaskUrgent(task: item) ? .red : .primary)
                            
                            if item.itemType == ToDoItemType.recurring.rawValue {
                                let completionCount = TaskManager.shared.currentPeriodCompletionCount(task: item)
                                Text("\(intervalDescription(item.interval)) Per \(frequencyDescription(TaskFrequency(rawValue: item.taskFrequency) ?? .daily)) (\(completionCount)/\(item.interval))")
                                    .font(.caption)
                            }
                            
                        }
                        
                        Spacer()
                        
                        if item.itemType == ToDoItemType.recurring.rawValue {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.caption2)
                        }
                        Button(action: {
                            if item.itemType == ToDoItemType.recurring.rawValue {
                                let calendar = Calendar.current
                                if let index = item.completionDates.firstIndex(where: { completionDate in
                                    calendar.isDate(completionDate, inSameDayAs: Date())
                                }) {
                                    item.completionDates.remove(at: index)
                                } else {
                                    item.completionDates.append(Date())
                                }
                            } else {
                                item.isCompleted.toggle()
                            }
                        }) {
                            Image(systemName: TaskManager.shared.isCompletedToday(task: item) ? "checkmark.circle.fill" : "circle")
                        }
                        
                        
                    }
                }
                .onDelete(perform: deleteItems)
            }
            Spacer()
            
            VStack {
                
                Button(action: {
                    navigationViewModel.currentScreen = .timeless
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 26, weight: .bold))
                }.padding()
                
                HStack {
                    
                    Button(action: {
                        navigationViewModel.currentScreen = .performance
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
                    }.padding()
                }
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
                let taskToDelete = todaysTasks[offset]
                if taskToDelete.itemType != ToDoItemType.recurring.rawValue {
                    modelContext.delete(taskToDelete)
                }
            }
        }
    }
}
