import Foundation
import SwiftData

@Model
final class ToDoListItem {
  var id = UUID()
  var timestamp: Date = Date()
  var toDoListText: String = ""
  var isCompleted: Bool = false
  
  init(id: UUID = UUID(), timestamp: Date, toDoListText: String, isCompleted: Bool) {
    self.id = id
    self.timestamp = timestamp
    self.toDoListText = toDoListText
    self.isCompleted = isCompleted
  }
}

import Foundation

@Model
final class RecurringTaskItem {
    var id = UUID()
    var timestamp: Date = Date()
    var recurringToDoItemText: String = ""
    var completionDates: [Date] = [] // Store completion dates here
    var taskFrequency: String = "Daily"
    var interval: Int = 1
    var priorityTask: Bool = false

    init(id: UUID = UUID(), timestamp: Date, recurringToDoItemText: String, completionDates: [Date] = [], taskFrequency: String, interval: Int, priorityTask: Bool) {
        self.id = id
        self.timestamp = timestamp
        self.recurringToDoItemText = recurringToDoItemText
        self.completionDates = completionDates
        self.taskFrequency = taskFrequency
        self.interval = interval
        self.priorityTask = priorityTask
    }
}

enum TaskFrequency: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}