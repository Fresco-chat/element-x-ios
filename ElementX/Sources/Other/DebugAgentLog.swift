//
// Copyright 2026 Fresco contributors.
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

/// Session-scoped debug logging for agent-assisted investigations.
enum DebugAgentLog {
    private static let sessionID = "83240d"
    private static let defaultLogPath = "/home/ender/Projects/Fresco/.cursor/debug-\(sessionID).log"
    
    static func write(hypothesisId: String,
                      location: String,
                      message: String,
                      data: [String: String] = [:],
                      runId: String = "pre-fix") {
        // #region agent log
        let payload: [String: Any] = [
            "sessionId": sessionID,
            "runId": runId,
            "hypothesisId": hypothesisId,
            "location": location,
            "message": message,
            "data": data,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let jsonLine = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        MXLog.info("[DEBUG-\(sessionID)] \(jsonLine)")
        
        let logPath = ProcessInfo.processInfo.environment["CURSOR_DEBUG_LOG_PATH"] ?? defaultLogPath
        guard let lineData = (jsonLine + "\n").data(using: .utf8) else { return }
        if let handle = FileHandle(forWritingAtPath: logPath) {
            handle.seekToEndOfFile()
            handle.write(lineData)
            try? handle.close()
        } else {
            FileManager.default.createFile(atPath: logPath, contents: lineData)
        }
        // #endregion
    }
}
