//
//  CocoaLumberjackLoger.swift
//  iOSTestTasck
//
//  Created by Mac on 3/29/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import CocoaLumberjack

class CocoaLumberjackLoger {
    static let fileLogger = DDFileLogger()
    
    static func prepareForWork() {
        DDLog.add(DDTTYLogger.sharedInstance) // TTY = Xcode console
        DDLog.add(DDASLLogger.sharedInstance) // ASL = Apple System Logs
        
        fileLogger?.maximumFileSize = 1024 * 1024 * 2 // 2MiB
        fileLogger?.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger?.logFileManager.maximumNumberOfLogFiles = 2
        DDLog.add(fileLogger!)
    }
    
    static func getLogFileDataArray() -> [Data] {
        var logFileDataArray = [Data]()
        if let logFilePaths = CocoaLumberjackLoger.fileLogger?.logFileManager.sortedLogFilePaths {
            for logFilePath in logFilePaths {
                let fileUrl = URL(fileURLWithPath: logFilePath)
                if let logFileData = try? Data(contentsOf: fileUrl, options: .dataReadingMapped) {
                    logFileDataArray.insert(logFileData, at: 0)
                }
            }
        }
        return logFileDataArray
    }
}
