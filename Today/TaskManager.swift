import Foundation

class TaskManager {
    static let shared = TaskManager()
    
    private init() {}
    
    func isDateInCurrentInterval(_ date: Date, forFrequency frequency: String) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        switch TaskFrequency(rawValue: frequency) {
        case .daily:
            return calendar.isDate(date, inSameDayAs: now)
        case .weekly:
            return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .monthly:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .yearly:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        default:
            return false
        }
    }
    
    func recurringTaskNeedsCompletion(task: ToDoListItem) -> Bool {
        let completionCount = task.completionDates.filter {
            isDateInCurrentInterval($0, forFrequency: task.taskFrequency)
        }.count
        return completionCount < task.interval
    }
    
    func howManyCompletionsDoesRecurringTaskNeed(task: ToDoListItem) -> Int {
        return task.completionDates.filter {
            isDateInCurrentInterval($0, forFrequency: task.taskFrequency)
        }.count
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
}
