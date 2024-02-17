import Foundation
import SwiftData

@Model
final class ToDoListItem {
    var timestamp: Date
    var toDoListText: String
    var isCompleted: Bool
    
    init(timestamp: Date, toDoListText: String, isCompleted: Bool = false) {
        self.timestamp = timestamp
        self.toDoListText = toDoListText
        self.isCompleted = isCompleted
    }
}
