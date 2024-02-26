import SwiftUI
import SwiftData

struct RecurringView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @State private var showingAddRecurringTask = false
    @State private var newRecurringTaskText = ""
    @State private var selectedFrequency = TaskFrequency.daily
    @State private var interval = 1
    @AppStorage("swipeSensitivity") private var swipeSensitivity: Double = 20.0
    @Query private var toDoListItems: [ToDoListItem]
    
    private var recurringTasks: [ToDoListItem] {
        toDoListItems.filter { $0.itemType == ToDoItemType.recurring.rawValue }
    }

    var body: some View {
        VStack {
            VStack{
                Text("Recurring")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }        .gesture(DragGesture(minimumDistance: swipeSensitivity, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width > 0 {
                        navigationViewModel.currentScreen = .timeless
                    }
                })
            
            List {
                ForEach(recurringTasks) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.toDoListText) 
                                .font(.title3)
                                .bold()
                            
                            Text("\(intervalDescription(task.interval)) Per \(frequencyDescription(TaskFrequency(rawValue: task.taskFrequency) ?? .daily))")
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        if !TaskManager.shared.needsCompletion(task: task) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                    }
                        
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            
            VStack {
                
                Button(action: {
                    navigationViewModel.currentScreen = .tomorrow
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 26, weight: .bold))
                }.padding()
                
                HStack {
                    
                    Button(action: {
                        navigationViewModel.currentScreen = .timeless
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 26, weight: .bold))
                    }.padding()
                    
                    Button(action: {
                        self.showingAddRecurringTask = true
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
        .sheet(isPresented: $showingAddRecurringTask, onDismiss: resetInputFields) {
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        AutoFocusTextField(text: $newRecurringTaskText, placeholder: "Recurring Task Description")
                            .frame(width: 250)
                        
                    }
                }.padding()
                
                Picker("Frequency", selection: $selectedFrequency) {
                    ForEach(TaskFrequency.allCases, id: \.self) { frequency in
                        Text(frequency.rawValue).tag(frequency)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Stepper(value: $interval, in: 1...100) {
                    Text("\(intervalDescription(interval)) Per \(frequencyDescription(selectedFrequency))")
                }
                .padding()
                
                Spacer()
                
                HStack {
                    Button("Discard") {
                        showingAddRecurringTask = false
                    }
                    .foregroundColor(.gray)
                    .font(.title3)
                    .padding()
                    
                    Spacer()
                    
                    Button("Save") {
                        addRecurringTask()
                        showingAddRecurringTask = false
                    }
                    .foregroundColor(.blue)
                    .font(.title3)
                    .padding()
                }
            }
            .padding()
            .presentationDetents([.height(250)])
        }
    }
        
    private func addRecurringTask() {
        withAnimation {
            let newTask = ToDoListItem(id: UUID(),
                                       timestamp: Date(),
                                       toDoListText: newRecurringTaskText,
                                       isCompleted: false,
                                       itemType: ToDoItemType.recurring.rawValue, // Set as "Recurring"
                                       completionDates: [],
                                       taskFrequency: selectedFrequency.rawValue,
                                       interval: interval)
            modelContext.insert(newTask)
            resetInputFields()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.forEach { offset in
                let taskToDelete = recurringTasks[offset]
                modelContext.delete(taskToDelete)
            }
        }
    }
    
    private func resetInputFields() {
            newRecurringTaskText = ""
            selectedFrequency = .daily
            interval = 1
        }
}
