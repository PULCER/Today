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

    var body: some View {
        VStack {
            Text("Recurring")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

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
                    }
                }

                Spacer()

                HStack {
                    Button("Cancel") {
                        showingAddRecurringTask = false
                    }
                    .padding()
                    .foregroundColor(.red)

                    Spacer()

                    Button("Add") {
                        addRecurringTask()
                        showingAddRecurringTask = false
                    }
                    .padding()
                    .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }

    private func addRecurringTask() {
        withAnimation {
            let newTask = RecurringTaskItem(timestamp: Date(), recurringToDoItemText: newRecurringTaskText, isCompleted: false, taskFrequency: selectedFrequency.rawValue, interval: interval)
            modelContext.insert(newTask)
            // After adding the task, reset the form fields
            resetInputFields()
        }
    }

    private func resetInputFields() {
        newRecurringTaskText = ""
        selectedFrequency = .daily
        interval = 1
    }
}
