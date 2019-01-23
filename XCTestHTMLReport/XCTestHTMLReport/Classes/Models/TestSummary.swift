//
//  Summary.swift
//  XCTestHTMLReport
//
//  Created by Titouan van Belle on 21.07.17.
//  Copyright © 2017 Tito. All rights reserved.
//

import Foundation

struct TestSummary: HTML
{
    var uuid: String
    var testName: String
    var tests: [Test]
    var status: Status {
        if tests.isEmpty {
            return .success
        }
        
        let computedStatus = tests.reduce(.unknown) { (accumulator, test) -> Status in
            if accumulator == .failure {
                return .failure
            }
            let testStatus = test.status
            if accumulator == .success {
                return testStatus == .failure ? .failure : .success
            }
            return testStatus
        }
        return computedStatus
    }
    
    init(screenshotsPath: String, dict: [String : Any])
    {
        Logger.substep("Parsing TestSummary")
        
        uuid = NSUUID().uuidString
        testName = dict["TestName"] as! String
        let rawTests = dict["Tests"] as! [[String: Any]]
        tests = rawTests.map { Test(screenshotsPath: screenshotsPath, dict: $0) }
    }
    
    // PRAGMA MARK: - HTML
    
    var htmlTemplate = HTMLTemplates.testSummary
    
    var htmlPlaceholderValues: [String: String] {
        return [
            "UUID": uuid,
            "TESTS": tests.reduce("", { (accumulator: String, test: Test) -> String in
                return accumulator + test.html
            })
        ]
    }
}
