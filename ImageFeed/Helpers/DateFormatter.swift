import Foundation

protocol DateFormatting {
    func string(from date: Date) -> String
    func date(from string: String) -> Date?
}

final class ISO8601DateFormatterWrapper: DateFormatting {
    private let formatter = ISO8601DateFormatter()
    
    func string(from date: Date) -> String {
        return formatter.string(from: date)
    }
    
    func date(from string: String) -> Date? {
        return formatter.date(from: string)
    }
}

final class DisplayDateFormatter: DateFormatting {
    private let formatter: DateFormatter
    
    init(localeIdentifier: String, dateFormat: String) {
        formatter = DateFormatter()
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.dateFormat = dateFormat
    }
    
    func string(from date: Date) -> String {
        return formatter.string(from: date)
    }
    
    func date(from string: String) -> Date? {
        return formatter.date(from: string)
    }
}
