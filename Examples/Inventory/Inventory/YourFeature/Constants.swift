//
//  Constants.swift
//  Inventory
//
//  Created by Akash soni on 07/03/23.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct Constants: Sendable {
  var currentTime: @Sendable () async throws -> Date
  var yourConstant: @Sendable () -> Date
  var currentTimeFromString: @Sendable (String) async throws -> Date
  var yourAsyncThrowConstant: @Sendable (Date) async throws -> String
}


// Mocks
extension String {
    static let currentTimeMock = "12:45"
    static let yourConstantMock = "12:45"
}

extension Date {
    static let currentTimeFromStringMock = Date()
    static let yourAsyncThrowConstantMock = Date()
}

extension Constants {
    public static func `default`() -> Constants {
        return Constants {
            return Date()
        } yourConstant: {
            return Date()
        } currentTimeFromString: { string in
            return Date()
        } yourAsyncThrowConstant: { date in
            return "12:14"
        }

    }
}

extension Constants: TestDependencyKey {
    static var previewValue: Constants {
      .default()
    }

  static let testValue = Self(
    currentTime: XCTUnimplemented("\(Self.self).currentTime"),
    yourConstant: XCTUnimplemented("\(Self.self).currentTime"),
    currentTimeFromString: XCTUnimplemented("\(Self.self).currentTimeFromString"),
    yourAsyncThrowConstant: XCTUnimplemented("\(Self.self).yourAsyncThrowConstant")
  )
}

extension Constants: DependencyKey {
    static let liveValue = Constants {
        return Date()
    } yourConstant: {
        return Date()
    } currentTimeFromString: { dateString in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: dateString) ?? Date()
    } yourAsyncThrowConstant: { date in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
}



extension DependencyValues {
  var constantClient: Constants {
    get { self[Constants.self] }
    set { self[Constants.self] = newValue }
  }
}



struct ConstantsExample {
    @Dependency(\.constantClient) var constant
    
    func yourConstantExample() -> Date {
        return constant.yourConstant()
    }

    func yourAsyncThrowConstantExample() async throws -> String {
        return try await constant.yourAsyncThrowConstant(Date())
    }

    func currentDateExample() async throws -> Date {
        return try await constant.currentTime()
    }
        
    func currentTimeFromStringExample() async throws -> Date {
        return try await constant.currentTimeFromString("12:11")
    }
    
}
