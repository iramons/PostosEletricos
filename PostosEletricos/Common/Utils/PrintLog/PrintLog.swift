//
//  PrintLog.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 23/03/24.
//

import Foundation
import Logging
import PulseLogHandler
import OSLog

// MARK: Public

/// Prints a log message with the provided information.
///
/// - Parameters:
///   - level: Apply the level of Log you need to print.
///   - message: The log message to be printed.
///   - file: The name of the file where the log message is called. (Default: The ID of the file where the function is defined)
///   - function: The name of the function where the log message is called. (Default: The name of the function where the function is defined)
///   - line: The line number where the log message is called. (Default: The line number where the function is defined)
///   - verbose: Determines if the log message should be contains file, function and line info in print (true) or no (false). (Default: true)
/// - Note: Use this function if you want to change level
public func printLog(
    _ level: Logging.Logger.Level = .info,
    _ message: String,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line,
    verbose: Bool = false
) {
    _printLog(
        level: level,
        message: message,
        file: file,
        function: function,
        line: line,
        verbose: verbose
    )
}

/// Prints a log message with the provided information.
///
/// - Parameters:
///   - message: The log message to be printed.
///   - file: The name of the file where the log message is called. (Default: The ID of the file where the function is defined)
///   - function: The name of the function where the log message is called. (Default: The name of the function where the function is defined)
///   - line: The line number where the log message is called. (Default: The line number where the function is defined)
///   - verbose: Determines if the log message should be contains file, function and line info in print (true) or no (false). (Default: true)
/// - Note: Use this function if don't want to change default level.
public func printLog(
    _ message: String,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line,
    verbose: Bool = false
) {
    _printLog(
        level: .info,
        message: message,
        file: file,
        function: function,
        line: line,
        verbose: verbose
    )
}

// MARK: Private

/// A private utility function for logging messages with additional context and control over verbosity.
/// This function is designed to be used internally within the logging system to abstract the complexities of logging with different levels and verbosity.
///
/// - Parameters:
///   - level: The severity level of the log message. Defaults to `.info`.
///   - message: The main content of the log message.
///   - file: The source file name from which the log is being made. This is used to provide context in the log output.
///   - function: The function name from which the log is being made, further adding to the log's context.
///   - line: The line number in the source file at which the log call is made, offering precise location information.
///   - verbose: A Boolean flag that determines if the log should include detailed context information such as file, function, and line number. When `true`, logs are more descriptive.
///
/// This function works by first determining an appropriate emoji representation based on the log level to visually categorize logs. It then constructs a string that combines this emoji with the log level, file name, function name, and line number (if verbose logging is enabled) followed by the actual log message.
///
/// Logging is performed using two mechanisms: logging to Xcode's console and logging to Pulse, depending on the verbosity flag. In verbose mode, detailed information about the source of the log is included, while in non-verbose mode, only the log level and message are logged.
///
/// Note: Logging with this function is only performed in DEBUG mode to avoid logging overhead in production builds. This is controlled using Swift's compilation condition `#if DEBUG`.
private func _printLog(
    level: Logging.Logger.Level = .info,
    message: String,
    file: String,
    function: String,
    line: UInt,
    verbose: Bool
) {
    #if DEBUG
    let emoji: String = getEmoji(for: level)
    let levelInfo: String = "\(emoji) #\(level.rawValue.capitalized):"
    let filename: String = URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent
    let local: String = "\(filename).\(function) line:\(line)"

    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: file)
    let osLevel = level.toOSLogType()

    if verbose {
        let verboseInformation: String = "\(levelInfo) \(local) - \(message)"
        logger.log(level: osLevel, "\(verboseInformation)") /// log in xcode
        LogHandler.logger.log(level: level, "\(verboseInformation)", file: file, function: function, line: line) /// log in pulse
    } else {
        let information: String = "\(levelInfo) - \(message)"
        logger.log(level: osLevel, "\(information)") /// log in xcode
        LogHandler.logger.log(level: level, "\(information)") /// log in pulse
    }
    #endif
}

private func getEmoji(for level: Logging.Logger.Level) -> String {
    return switch level {
    case .info: "ℹ️"
    case .warning: "⚠️"
    case .notice: "🔔"
    case .error: "🧨"
    case .critical: "💥"
    case .debug, .trace: "➡️"
    }
}
