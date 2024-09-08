//
//  LoginViewController.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 23/11/2021.
//

import UIKit
import RxSwift

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var pseudoTextField: UITextField!
    @IBOutlet private weak var avatarStackView: UIStackView!
    @IBOutlet private weak var startButton: UIButton!
    
    var viewModel: LoginViewModel!
    private let disposeBag = DisposeBag()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pseudoTextField.setBorder(borderWidth: 2, color: .black)
        pseudoTextField.setCornerRadius(20)
        pseudoTextField.font = .gv_body1()
        pseudoTextField.attributedPlaceholder = NSAttributedString(string: "Pseudo", attributes: [.foregroundColor: UIColor.lightGray])
        pseudoTextField.setLeftPaddingPoints(15)
        pseudoTextField.delegate = self
        
        AvatarType.allCases.map { avatar -> UIButton in
            let button = UIButton()
            button.setImage(avatar.image, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.aspectRation(1).isActive = true
            button.addTapGestureRecognizer { [weak self] in
                self?.viewModel.selectAvatar(avatar)
                
                button.setCornerRadius(button.frame.height / 2)
                self?.avatarStackView.arrangedSubviews.forEach { $0.setBorder(borderWidth: 3, color: .clear) }
                button.setBorder(borderWidth: 3, color: .black)
            }
            return button
        }.forEach(self.avatarStackView.addArrangedSubview)
        
        startButton.applyPrimaryBtnStyle()
        startButton.setTitle("Commencer", for: .normal)
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.buttonIsEnable
            .subscribe(onNext: { [weak self] isEnable in
                self?.startButton.isEnabled = isEnable
            })
            .disposed(by: disposeBag)
        
        viewModel.loginSuccess
            .subscribe(onNext: { user in
                DispatchQueue.main.async {
                    let gameListVC = GameListViewController.instance
                    gameListVC.viewModel = AppDelegate.container.resolve(GameListViewModel.self, argument: user)!
                    UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: gameListVC)
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @IBAction func startTapAction(_ sender: UIButton) {
        self.viewModel.tapStartButton()
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController {
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if let text = textField.text {
            self.viewModel.didFinishTapPseudo(text)
        }
        return true
    }
}
