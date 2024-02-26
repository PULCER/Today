import Foundation

class TaskManager {
    static let shared = TaskManager()

    private init() {}

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

    func isTaskUrgent(task: ToDoListItem) -> Bool {
        guard task.itemType == ToDoItemType.recurring.rawValue else {
            return false
        }
        
        let calendar = Calendar.current
        let now = Date()
        var timeLeftInCurrentInterval = 0
        var completionCountThisInterval = 0
        
        switch TaskFrequency(rawValue: task.taskFrequency) {
        case .daily:
            timeLeftInCurrentInterval = 1
        case .weekly:
            let dayOfWeek = calendar.component(.weekday, from: now)
            timeLeftInCurrentInterval = 7 - dayOfWeek
        case .biweekly:
            let weekOfYear = calendar.component(.weekOfYear, from: now)
            timeLeftInCurrentInterval = (weekOfYear % 2 == 0 ? 14 : 7) - calendar.component(.weekday, from: now)
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
        
        completionCountThisInterval = task.completionDates.filter { date in
            switch TaskFrequency(rawValue: task.taskFrequency) {
            case .daily:
                return calendar.isDate(date, inSameDayAs: now)
            case .weekly:
                return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
            case .biweekly:
                // Check if within the current or previous week for biweekly period
                let weekOfYear = calendar.component(.weekOfYear, from: now)
                let completionWeekOfYear = calendar.component(.weekOfYear, from: date)
                return abs(weekOfYear - completionWeekOfYear) <= 1
            case .monthly:
                return calendar.isDate(date, equalTo: now, toGranularity: .month)
            case .yearly:
                return calendar.isDate(date, equalTo: now, toGranularity: .year)
            default:
                return false
            }
        }.count
        
        let completionsNeeded = task.interval - completionCountThisInterval
        return timeLeftInCurrentInterval <= completionsNeeded
    }
}
