//
//  LoginViewModel.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import RxSwift

protocol LoginViewModelInput {
    func selectAvatar(_ avatar: AvatarType)
    func didFinishTapPseudo(_ pseudo: String)
    func tapStartButton()
}

protocol LoginViewModelOutput {
    var buttonIsEnable: Observable<Bool> { get }
    var loginSuccess: PublishSubject<User> { get }
}

protocol LoginViewModel: LoginViewModelInput, LoginViewModelOutput {}

class DefaultLoginViewModel: LoginViewModel {
    
    private let userRepository: UserRepository
    private let socketIOConnectivity: SocketIOConnectivity
    
    private var selectedAvatar = BehaviorSubject<AvatarType?>(value: nil)
    private var pseudoEntered = BehaviorSubject<String?>(value: nil)
    
    // MARK: - Output
    var buttonIsEnable: Observable<Bool>
    let loginSuccess = PublishSubject<User>()
    
    init(userRepository: UserRepository, socketIOConnectivity: SocketIOConnectivity) {
        self.userRepository = userRepository
        self.socketIOConnectivity = socketIOConnectivity
        
        self.buttonIsEnable = Observable.combineLatest(selectedAvatar, pseudoEntered).map {
            return $0.0 != nil && $0.1 != nil
        }
    }
    
    // MARK: - Input
    func selectAvatar(_ avatar: AvatarType) {
        self.selectedAvatar.onNext(avatar)
    }
    
    func didFinishTapPseudo(_ pseudo: String) {
        self.pseudoEntered.onNext(pseudo)
    }
    
    func tapStartButton() {
        guard let avatar = try? self.selectedAvatar.value(),
              let pseudo = try? self.pseudoEntered.value() else {
                  return
              }
        
        _ = self.userRepository
            .register(userName: pseudo, avatarType: avatar)
            .do(onNext: { [weak self] user in
                DispatchQueue.main.async {
                    AppDelegate.appEnv.updateCurrentUser(user)
                    self?.socketIOConnectivity.connect(with: user.id)
                    self?.loginSuccess.onNext(user)
                }
            })
            .subscribe()
    }
}
