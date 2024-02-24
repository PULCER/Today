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
                ForEach(recurringTasks) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.recurringToDoItemText).font(.title3)
                            Text("Frequency: \(task.taskFrequency), Interval: \(task.interval) day(s)").font(.caption)
                        }
                        Button(action: {
                            task.isCompleted.toggle()
                        }) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
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
                
                
                Text("Add Recurring Task")
                                   .font(.headline)
                                   .padding()

                               Form {
                                   Section(header: Text("Task Details")) {
                                       AutoFocusTextField(text: $newRecurringTaskText, placeholder: "Enter task description")
                                       Picker("Frequency", selection: $selectedFrequency) {
                                           ForEach(TaskFrequency.allCases, id: \.self) { frequency in
                                               Text(frequency.rawValue).tag(frequency)
                                           }
                                       }
                                       Stepper("Interval: \(interval) day(s)", value: $interval, in: 1...365)
                                       Toggle("Priority Task", isOn: $isPriorityTask)
                                   }
                               }

                HStack {
                    Button("Discard") {
                        showingAddRecurringTask = false
                    }
                    .foregroundColor(.gray)
                    .font(.title3)

                    Spacer()

                    Button("Save") {
                        addRecurringTask()
                        showingAddRecurringTask = false
                    }
                    .foregroundColor(.blue)
                    .font(.title3)
                }
            }
            .padding()
        }
        .presentationDetents([.medium])
    }

    private func addRecurringTask() {
           withAnimation {
               let newTask = RecurringTaskItem(timestamp: Date(), recurringToDoItemText: newRecurringTaskText, isCompleted: false, taskFrequency: selectedFrequency.rawValue, interval: interval, priorityTask: isPriorityTask)
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
