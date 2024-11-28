//
//  JournalViewModelTests.swift
//  MacroTests
//
//  Created by Nicholas Christian Irawan on 20/11/24.
//

import XCTest
@testable import Macro
import SwiftData

final class JournalViewModelTests: XCTestCase {
    var viewModel: JournalViewModel!
    var mockJournals: [Journal]!

    override func setUp() {
        super.setUp()
        viewModel = JournalViewModel()
        mockJournals = []
    }

    override func tearDown() {
        viewModel = nil
        mockJournals = nil
        super.tearDown()
    }
    
    func testDaysInCurrentWeek() {
        let days = viewModel.daysInCurrentWeek()
        XCTAssertEqual(days.count, 7, "Should return 7 days in the current week.")
    }
    
    func testIsSelectedDate() {
        let today = Date()
        viewModel.selectedDate = today
        XCTAssertTrue(viewModel.isSelected(date: today), "Should correctly identify the selected date.")
        
        let otherDate = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        XCTAssertFalse(viewModel.isSelected(date: otherDate), "Should correctly identify a non-selected date.")
    }
    
    func testModifyDate() {
        let originalDate = viewModel.selectedDate
        viewModel.modifyDate()
        let updatedDate = viewModel.selectedDate
        
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.hour, from: updatedDate), calendar.component(.hour, from: Date()), "Hours should be updated.")
        XCTAssertEqual(calendar.component(.minute, from: updatedDate), calendar.component(.minute, from: Date()), "Minutes should be updated.")
        XCTAssertEqual(calendar.component(.second, from: updatedDate), calendar.component(.second, from: Date()), "Seconds should be updated.")
        XCTAssertNotEqual(originalDate, updatedDate, "Selected date should be modified.")
    }
    
    func testSleepClassificationMessage() {
        let mockJournal = Journal(
            timestamp: Date(),
            foods: [],
            sleep: Sleep(timestamp: Date(), duration: 7 * 60 * 60, start: Date(), end: Date())
        )
        mockJournals.append(mockJournal)
        
        let message = viewModel.sleepClassificationMessage(journals: mockJournals)
        XCTAssertEqual(message, "Tidurmu sudah baik, pertahankan ya!", "Message should match the expected sleep duration classification.")
    }
}
