import Foundation
import SwiftData

@Model
final class ToDoListItem {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
