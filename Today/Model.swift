import Foundation
import SwiftData

@Model
final class ToDoListItem {
    var id: UUID = UUID() 
    var timestamp: Date = Date()
    var toDoListText: String = ""
    var isCompleted: Bool = false
    var itemType: String = "Regular"
    var completionDates: [Date] = []
    var taskFrequency: String = "Daily"
    var interval: Int = 1
    var priorityTask: Bool = false
    
    init(id: UUID, timestamp: Date, toDoListText: String, isCompleted: Bool, itemType: String, completionDates: [Date], taskFrequency: String, interval: Int, priorityTask: Bool) {
        self.id = id
        self.timestamp = timestamp
        self.toDoListText = toDoListText
        self.isCompleted = isCompleted
        self.itemType = itemType
        self.completionDates = completionDates
        self.taskFrequency = taskFrequency
        self.interval = interval
        self.priorityTask = priorityTask
    }
}


public enum ToDoItemType: String {
    case regular = "Regular"
    case recurring = "Recurring"
    case timeless = "Timeless"
}


public enum TaskFrequency: String, CaseIterable {
    case daily = "Day"
    case weekly = "Week"
    case biweekly = "2 Weeks"
    case monthly = "Month"
    case yearly = "Year"
}
