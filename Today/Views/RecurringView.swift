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
    @State private var isPriorityTask = false
    
    private var recurringTasks: [ToDoListItem] {
        toDoListItems.filter { $0.itemType == ToDoItemType.recurring.rawValue }
    }

    var body: some View {
        VStack {
            Text("Recurring")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            List {
                ForEach(recurringTasks.sorted(by: { $0.priorityTask && !$1.priorityTask })) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.toDoListText) 
                                .font(.title3)
                                .bold()
                                .foregroundColor(task.priorityTask ? .red : .primary)
                            
                            Text("\(intervalDescription(task.interval)) Per \(frequencyDescription(TaskFrequency(rawValue: task.taskFrequency) ?? .daily))")
                                .font(.caption)
                        }
                        
                        Spacer()
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            
            HStack {
                Button(action: {
                    navigationViewModel.currentScreen = .today
                }) {
                    Image(systemName: "chevron.down")
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
                    navigationViewModel.currentScreen = .today
                }) {
                    Image(systemName: "chevron.down")
                }.padding()
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
                
                
                Toggle("Priority Task", isOn: $isPriorityTask) .padding()
                
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
            .presentationDetents([.height(350)])
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
                                       interval: interval,
                                       priorityTask: isPriorityTask)
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
            isPriorityTask = false
        }
}
