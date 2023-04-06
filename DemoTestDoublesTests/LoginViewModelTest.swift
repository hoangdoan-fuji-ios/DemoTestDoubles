//
//  LoginViewModelTest.swift
//  DemoTestDoublesTests
//
//  Created by Hoàng Doãn on 05/04/2023.
//

import XCTest
@testable import DemoTestDoubles

final class UserServiceDummy: UserServiceProtocol {
    
    func login(_ user: User, callback: (Result<Void, Error>) -> Void) {
        //callback(.success(()))
    }
}

final class UserServiceFake: UserServiceProtocol {
    
    func login(_ user: User, callback: (Result<Void, Error>) -> Void) {
        if user.name == "Mock" {
            callback(.success(()))
        }
    }
    
}

final class UserServiceStub: UserServiceProtocol {
    
    var loginResultToBeReturned: Result<Void, Error> = .success(())
    func login(_ user: User, callback: (Result<Void, Error>) -> Void) {
        callback(loginResultToBeReturned)
    }
    
}

final class LocalStorageSpy: LocalStorageProtocol {
    
    private(set) var storeUserDataCalled = false
    private(set) var listUser: [User] = []
    func storeUserData(_ user: User) {
        storeUserDataCalled = true
        listUser.append(user)
    }
    
    func isContainUserWithName(_ name: String) -> Bool {
        listUser.contains(where: { $0.name == name })
    }
    
}

final class LoginViewModelTest: XCTestCase {
    
    // Dummy
    func testLogin_dummy() {
        // Given
        let sut = LoginViewModel(userService: UserServiceDummy())
        
        // When
        sut.performLoginForUser(User(name: "dummy", password: "dummy")) {}
        
        // Then
        XCTAssertNil(sut.loggedUser)
    }
    
    // Fake
    func testLogin_fake() {
        
        // Given
        let sut = LoginViewModel(userService: UserServiceFake())
        let userMock = User(name: "Mock", password: "Mock")
        
        // When
        let performLoginExpectation = expectation(description: "performLoginExpectation")
        sut.performLoginForUser(userMock) {
            performLoginExpectation.fulfill()
        }
        wait(for: [performLoginExpectation], timeout: 1.0)
        
        // Then
        XCTAssertNotNil(sut.loggedUser)
    }
    
    
    // Stub
    func testLogin_stub() {
        
        // Given
        let service = UserServiceStub()
        service.loginResultToBeReturned = .success(())
        let sut = LoginViewModel(userService: service)
        let userMock = User(name: "Mock", password: "Mock")
        
        // When
        let performLoginExpectation = expectation(description: "performLoginExpectation")
        sut.performLoginForUser(userMock) {
            performLoginExpectation.fulfill()
        }
        wait(for: [performLoginExpectation], timeout: 1.0)
        
        // Then
        XCTAssertNotNil(sut.loggedUser)
    }
    
    // Stub
    func testLogin_spy() {
        
        // Given
        let service = UserServiceStub()
        service.loginResultToBeReturned = .success(())
        let sut = LoginViewModel(userService: service)
        let local = LocalStorageSpy()
        sut.setLocalStorage(local)
        let userMock = User(name: "Mock", password: "Mock")
        
        // When
        let performLoginExpectation = expectation(description: "performLoginExpectation")
        sut.performLoginForUser(userMock) {
            performLoginExpectation.fulfill()
        }
        wait(for: [performLoginExpectation], timeout: 1.0)
        
        // Then
        XCTAssertNotNil(sut.loggedUser)
        XCTAssertTrue(local.storeUserDataCalled)
    }
    
    
    // Mock
    func testLogin_mock() {

        let service = UserServiceStub()
        service.loginResultToBeReturned = .success(())
        let sut = LoginViewModel(userService: service)
        let local = LocalStorageSpy()
        sut.setLocalStorage(local)

        XCTContext.runActivity(named: "") { _ in
            let performLoginExpectation = expectation(description: "performLoginExpectation")
            let userMock = User(name: "Mock", password: "Mock")
            sut.performLoginForUser(userMock) {
                performLoginExpectation.fulfill()
            }
            wait(for: [performLoginExpectation], timeout: 1.0)
            XCTAssertFalse(sut.localStorage?.isContainUserWithName("Hoang") ?? false)
        }


        XCTContext.runActivity(named: "") { _ in
            let performLoginExpectation = expectation(description: "performLoginExpectation")
            let userMock = User(name: "Hoang", password: "Hoang")
            sut.performLoginForUser(userMock) {
                performLoginExpectation.fulfill()
            }
            wait(for: [performLoginExpectation], timeout: 1.0)
            XCTAssertTrue(sut.localStorage?.isContainUserWithName("Hoang") ?? false)
        }


    }
}
