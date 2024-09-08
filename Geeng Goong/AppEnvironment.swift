//
//  AppEnvironment.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import Foundation

class AppEnvironment {
    
    private(set) var environment: Environment
    private(set) var currentUser: User?
    
    var userIsLoggedIn: Bool {
        return self.currentUser != nil
    }
    
    init(environment: Environment, currentUser: User?) {
        self.environment = environment
        self.currentUser = currentUser
    }
    
    // MARK: - Update
    public func updateCurrentUser(_ user: User) {
        self.currentUser = user
        self.currentUser?.saveInUserDefaults()
    }
    
    // MARK: - Login & Logout
    func login(user: User) {
        self.setUserInfoForServices(user: user)
    }
    
    func logout() {
        self.setUserInfoForServices(user: nil)
    }
    
    private func setUserInfoForServices(user: User?) {
        self.currentUser = user
        self.currentUser?.saveInUserDefaults()
        
        let oauthToken = (user != nil) ? OauthToken(token: user!.id) : nil
        self.environment.apiService.setOauthToken(oauthToken)
    }
}

