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
                   return needsCompletion(task: item)
               } else {
                   return calendar.isDate(item.timestamp, inSameDayAs: Date())
               }
           }.sorted { item1, item2 in
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
                            Text(item.toDoListText)
                                .font(.title3)
                                .bold()
                            
                            if item.itemType == ToDoItemType.recurring.rawValue {
                                let completionCount = currentPeriodCompletionCount(task: item)
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
                            Image(systemName: isCompletedToday(task: item) ? "checkmark.circle.fill" : "circle")
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
                }.padding()
                
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
    
    func needsCompletion(task: ToDoListItem) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let completionCount = task.completionDates.filter { completionDate in
            switch TaskFrequency(rawValue: task.taskFrequency) {
            case .daily:
                return calendar.isDate(completionDate, inSameDayAs: now)
            case .weekly:
                return calendar.isDate(completionDate, equalTo: now, toGranularity: .weekOfYear)
            case .monthly:
                return calendar.isDate(completionDate, equalTo: now, toGranularity: .month)
            case .yearly:
                return calendar.isDate(completionDate, equalTo: now, toGranularity: .year)
            default:
                return false
            }
        }.count
        return completionCount < task.interval
    }
    
    func isCompletedToday(task: ToDoListItem) -> Bool {
        guard task.itemType == ToDoItemType.recurring.rawValue else {
            return task.isCompleted
        }
        
        let calendar = Calendar.current
        return task.completionDates.contains { completionDate in
            calendar.isDate(completionDate, inSameDayAs: Date())
        }
    }
    
    
    func currentPeriodCompletionCount(task: ToDoListItem) -> Int {
        let calendar = Calendar.current
        let now = Date()
        return task.completionDates.filter { completionDate in
            switch TaskFrequency(rawValue: task.taskFrequency) {
            case .daily:
                return calendar.isDate(completionDate, inSameDayAs: now)
            case .weekly:
                return calendar.isDate(completionDate, equalTo: now, toGranularity: .weekOfYear)
            case .monthly:
                return calendar.isDate(completionDate, equalTo: now, toGranularity: .month)
            case .yearly:
                return calendar.isDate(completionDate, equalTo: now, toGranularity: .year)
            default:
                return false
            }
        }.count
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
