import Foundation
import SwiftUI

public func intervalDescription(_ interval: Int) -> String {
    switch interval {
    case 1:
        return "Once"
    case 2:
        return "Twice"
    case 3:
        return "Three Times"
    case 4:
        return "Four Times"
    case 5:
        return "Five Times"
    case 6:
        return "Six Times"
    case 7:
        return "Seven Times"
    case 8:
        return "Eight Times"
    case 9:
        return "Nine Times"
    case 10:
        return "Ten Times"
    default:
        return "\(interval) Times"
    }
}

public func frequencyDescription(_ frequency: TaskFrequency) -> String {
    switch frequency {
    case .daily:
        return "Day"
    case .weekly:
        return "Week"
    case .monthly:
        return "Month"
    }
}



