import Foundation

/// A class for logging messages.
open class Logger: Equatable, Identifiable, Hashable, TextOutputStream {
    
    /**
     The type of the closure that determines
     how the log message is formatted.
    
     - Parameters:
       - date: The date at which the message was logged.
       - label: The label of the logger.
       - level: The level of the logger
       - file: The file in which the message was logged.
       - function: The function in which the message was logged.
       - line: The line at which the message was logged.
       - message: The logging message.
     */
    public typealias LogMsgFormatter = (
        _ date: Date, _ label: String, _ level: Level,
        _ file: String, _ function: String, _ line: UInt,
        _ message: () -> String
    ) -> Void
    
    
    /// Prevent a strong reference cycle by holding an array of
    /// weak references to each instance of Logger.
    private static var _allLoggers: [WeakWrapper<Logger>] = []
    
    /**
     All of the instances of this class.
    
     This is a computed property that wraps around an array
     of weak references to each instance. Only the instances
     that have not been deallocated will be returned.
     */
    open class var allLoggers: [Logger] {
        return _allLoggers.compactMap { $0.object }
    }
    
    /// Returns a logger based on its label.
    /// If multiple loggers with the same label exist,
    /// the first one found will be returned.
    open class subscript(_ label: String) -> Logger? {
        for logger in allLoggers {
            if logger.label == label {
                return logger
            }
        }
        
        return nil
    }
    
    /// Enables/disables all loggers.
    /// This property **will** affect loggers created in the future.
    public static var allDisabled = false
    
    
    /// Sets the logging level for all **current** loggers.
    /// This function will **not** affect loggers created in the future.
    /// 
    /// - Parameter level: The log level.
    open class func setLevel(to level: Level) {
        for logger in allLoggers {
            logger.level = level
        }
    }
    
    
    public static func == (lhs: Logger, rhs: Logger) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /**
     Gets called when a message needs to
     be logged to determine how it is formatted
     and where the message is logged.
     
     The default is to print the message using the
     builtin print function,
     but you can customize how the message is logged.
     
     ```
     public typealias LogMsgFormatter = (
         _ date: Date, _ label: String, _ level: Level,
         _ file: String, _ function: String, _ line: UInt,
         _ message: () -> String
     ) -> Void
     ```
     Default implementation:
     ```
     { date, label, level, file, function, line, message in
     
         print("[\(label): \(level): \(function): line \(line)] \(message())")
     }
     ```
     */
    open var logMsgFormatter: LogMsgFormatter = {
        date, label, level, file, function, line, message in
        
        print("[\(label): \(level): \(function) line \(line)] \(message())")
    }

    /// A string identifying the logger.
    open var label: String
    /// The level of the logger. See `Level`.
    open var level: Level
    
    public let id = UUID()
    
    public init(
        label: String,
        level: Level = .debug,
        logMsgFormatter: LogMsgFormatter? = nil
    ) {
        self.label = label
        self.level = level
        if let logMsgFormatter = logMsgFormatter {
            self.logMsgFormatter = logMsgFormatter
        }
        
        Self._allLoggers.append(WeakWrapper(self))
    }
    
    deinit {
        Self._allLoggers.removeFirst { logger in
            logger.object == self
        }
    }
    
    public func write(_ string: String) {
        self.log(level: .trace, string)
    }
    
    /// Logs a message. Unless the log level is determined dynamically,
    /// you should normally use
    /// self.trace, self.debug, self.notice, self.warning,
    /// self.error, or self.critical
    /// to log a message at a given level.
    open func log(
        level: Level,
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        guard !Self.allDisabled && level >= self.level else {
            return
        }
        
        self.logMsgFormatter(
            Date(), label, level, file, function, line, message
        )

    }
    
    /// Logs a trace message.
    @inlinable
    open func trace(
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        self.log(
            level: .trace, message(),
            file: file, function: function, line: line
        )
    }
    
    /// Logs a debugging message.
    @inlinable
    open func debug(
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        self.log(
            level: .debug, message(),
            file: file, function: function, line: line
        )
    }
    
    /// Logs a notice message.
    @inlinable
    open func notice(
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        self.log(
            level: .notice, message(),
            file: file, function: function, line: line
        )
    }
    
    /// Logs a warning message.
    @inlinable
    open func warning(
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        self.log(
            level: .warning, message(),
            file: file, function: function, line: line
        )
    }
    
    /// Logs an error message.
    @inlinable
    open func error(
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        self.log(
            level: .error, message(),
            file: file, function: function, line: line
        )
    }
    
    /// Logs a critical error message.
    @inlinable
    open func critical(
        _ message: @autoclosure @escaping () -> String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        self.log(
            level: .critical, message(),
            file: file, function: function, line: line
        )
    }
    
    
    /// The log level of the logger.
    public enum Level: Int, Comparable, CaseIterable {
        
        case trace
        case debug
        case notice
        case warning
        case error
        case critical
        
        public static func < (lhs: Self, rhs: Self) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        /**
         All of the log levels.
        
         * trace
         * debug
         * notice
         * warning
         * error
         * critical
         
         */
        public static let allCases: [Self] = [
            .trace, .debug, .notice, .warning, .error, .critical
        ]
        
        
    }
    
}
