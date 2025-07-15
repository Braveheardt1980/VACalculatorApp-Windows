import Foundation

// MARK: - DateFormatter Extensions

extension DateFormatter {
    
    // MARK: - Standard Formatters
    
    static let fileNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter
    }()
    
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let fullDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    // MARK: - Convenience Methods
    
    static func fileName(from date: Date = Date()) -> String {
        return fileNameFormatter.string(from: date)
    }
    
    static func display(from date: Date) -> String {
        return displayFormatter.string(from: date)
    }
    
    static func fullDisplay(from date: Date) -> String {
        return fullDisplayFormatter.string(from: date)
    }
    
    static func iso8601String(from date: Date) -> String {
        return iso8601Formatter.string(from: date)
    }
}

// MARK: - Date Extensions

extension Date {
    
    var fileNameString: String {
        return DateFormatter.fileName(from: self)
    }
    
    var displayString: String {
        return DateFormatter.display(from: self)
    }
    
    var fullDisplayString: String {
        return DateFormatter.fullDisplay(from: self)
    }
    
    var iso8601String: String {
        return DateFormatter.iso8601String(from: self)
    }
}