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
