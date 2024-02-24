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
    @Query private var recurringTasks: [RecurringTaskItem]
    @State private var isPriorityTask = false
    
    var body: some View {
        VStack {
            Text("Recurring")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            List {
                ForEach(recurringTasks.sorted(by: { $0.priorityTask && !$1.priorityTask })) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.recurringToDoItemText)
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
    
    private func intervalDescription(_ interval: Int) -> String {
        switch interval {
        case 1:
            return "Once"
        case 2:
            return "Twice"
        case 3:
            return "Three Times"
        case 4:
            return "Four Times"
        case 5:
            return "Five Times"
        case 6:
            return "Six Times"
        case 7:
            return "Seven Times"
        case 8:
            return "Eight Times"
        case 9:
            return "Nine Times"
        case 10:
            return "Ten Times"
        default:
            return "\(interval) Times"
        }
    }
    
    private func frequencyDescription(_ frequency: TaskFrequency) -> String {
        switch frequency {
        case .daily:
            return "Day"
        case .weekly:
            return "Week"
        case .monthly:
            return "Month"
        case .yearly:
            return "Year"
        }
    }
    
    private func addRecurringTask() {
            withAnimation {
                let newTask = RecurringTaskItem(timestamp: Date(), recurringToDoItemText: newRecurringTaskText, taskFrequency: selectedFrequency.rawValue, interval: interval, priorityTask: isPriorityTask)
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
