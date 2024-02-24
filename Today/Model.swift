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

@Model
final class RecurringTaskItem {
    var id = UUID()
    var timestamp: Date = Date()
    var recurringToDoItemText: String = ""
    var isCompleted: Bool = false
    var frequency: TaskFrequency = .daily
    var interval: Int = 1

    enum TaskFrequency: String, CaseIterable, Codable { // Make Codable for persistence with SwiftData
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }

    init(id: UUID = UUID(), timestamp: Date, recurringToDoItemText: String, isCompleted: Bool, frequency: TaskFrequency, interval: Int) {
      self.id = id
      self.timestamp = timestamp
      self.recurringToDoItemText = recurringToDoItemText
      self.isCompleted = isCompleted
      self.frequency = frequency
      self.interval = interval
    }
}
