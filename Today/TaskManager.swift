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
    
    func isTaskUrgent(task: ToDoListItem) -> Bool {
        guard task.itemType == ToDoItemType.recurring.rawValue else {
            return false
        }

        let calendar = Calendar.current
        let now = Date()
        var timeLeftInCurrentInterval = 0
        
        switch TaskFrequency(rawValue: task.taskFrequency) {
        case .daily:
            timeLeftInCurrentInterval = 1
        case .weekly:
            let dayOfWeek = calendar.component(.weekday, from: now)
            timeLeftInCurrentInterval = 7 - dayOfWeek
        case .monthly:
            let daysInMonth = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
            let dayOfMonth = calendar.component(.day, from: now)
            timeLeftInCurrentInterval = daysInMonth - dayOfMonth
        case .yearly:
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 0
            let daysInYear = calendar.range(of: .day, in: .year, for: now)?.count ?? 365
            timeLeftInCurrentInterval = daysInYear - dayOfYear
        default:
            break
        }
        
        let completionCountThisInterval = howManyCompletionsDoesRecurringTaskNeed(task: task)
        let completionsNeeded = task.interval - completionCountThisInterval
        return timeLeftInCurrentInterval <= completionsNeeded
    }
}
