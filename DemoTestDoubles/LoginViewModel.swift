//
//  LoginViewModel.swift
//  DemoTestDoubles
//
//  Created by Hoàng Doãn on 05/04/2023.
//

import Foundation

struct User {
    let name: String
    let password: String
}

protocol UserServiceProtocol {
    func login(_ user: User, callback: (Result<Void, Error>) -> Void)
}

protocol LocalStorageProtocol: AnyObject {
    func storeUserData(_ user: User)
    func isContainUserWithName(_ name: String) -> Bool
}

final class LoginViewModel {
    
    private let userService: UserServiceProtocol
    weak var localStorage: LocalStorageProtocol?
    private(set) var loggedUser: User?
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
    }
    
    func setLocalStorage(_ local: LocalStorageProtocol) {
        localStorage = local
    }
    
    func performLoginForUser(_ user: User, callback: @escaping () -> Void) {
        userService.login(user) { [weak self] result in
            let loginDidSucceed = (try? result.get()) != nil
            if loginDidSucceed {
                self?.loggedUser = user
                self?.localStorage?.storeUserData(user)
            }
            callback()
        }
    }
}
