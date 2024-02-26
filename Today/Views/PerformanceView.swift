import SwiftUI
import SwiftData

struct PerformanceView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Query private var toDoListItems: [ToDoListItem]
    @AppStorage("swipeSensitivity") private var swipeSensitivity: Double = 20.0 

    private var pastTasks: [Date: [ToDoListItem]] {
        let tasks = Dictionary(grouping: toDoListItems) { item in
            Calendar.current.startOfDay(for: item.timestamp)
        }
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!
        
        return tasks.filter { $0.key <= yesterday }
    }

    private func completedTasksCount(for group: [ToDoListItem]) -> Int {
        group.filter { $0.isCompleted }.count
    }

    private func taskCompletionRate(for group: [ToDoListItem]) -> CGFloat {
        let completedCount = CGFloat(completedTasksCount(for: group))
        let totalCount = CGFloat(group.count)
        return totalCount > 0 ? (completedCount / totalCount) : 0
    }

    var body: some View {
        VStack {
            VStack{
                Text("Performance")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }.gesture(DragGesture(minimumDistance: swipeSensitivity, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width < 0 {
                        navigationViewModel.currentScreen = .today
                    } else if value.translation.width > 0 {
                        navigationViewModel.currentScreen = .settings
                    }
                })

            List {
                ForEach(pastTasks.keys.sorted().reversed(), id: \.self) { day in
                    if let tasks = pastTasks[day] {
                        DisclosureGroup {
                            ForEach(tasks.sorted { item1, item2 in
                                if item1.isCompleted && !item2.isCompleted {
                                    return false
                                } else {
                                    return true
                                }
                            }) { task in
                                HStack {
                                    Text(task.toDoListText)
                                    Spacer()
                                    Button(action: {
                                        task.isCompleted.toggle()
                                    }) {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(task.isCompleted ? .green : .gray)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(day, formatter: DateFormatter.shortDate)
                                    .font(.title3)
                                Spacer()
                                Text("\(completedTasksCount(for: tasks))/\(tasks.count)")
                                    .font(.title3)
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .frame(width: 100, height: 15)
                                        .foregroundColor(.red)
                                    RoundedRectangle(cornerRadius: 4)
                                        .frame(width: 100 * taskCompletionRate(for: tasks), height: 15)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
            }

            Spacer()

            HStack {
                
                Button(action: {
                    navigationViewModel.currentScreen = .settings
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 26, weight: .bold))
                }.padding()
                
                Button(action: {
           
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.blue)
                        .padding()
                }.opacity(0)
                
                Button(action: {
                    navigationViewModel.currentScreen = .today
                }) {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 26, weight: .bold))
                }.padding()
            
            }
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}
