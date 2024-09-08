//
//  UserListOnlineViewController.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import UIKit
import RxSwift

class UserListOnlineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var startButton: UIButton!
    
    var viewModel: UserListOnlineViewModel!
    private let disposeBag = DisposeBag()
    
    private var users: [User] = []
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Qui est en ligne ?"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        if #available(iOS 13.0, *) {} else {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissAction))
        }
        
        startButton.applyPrimaryBtnStyle()
        startButton.setTitle("Commencer", for: .normal)
        startButton.isEnabled = false
        
        UserListOnlineViewCell.registerNibFor(tableview: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        self.bindViewModel()
        self.viewModel.viewDidLoad()
    }
    
    private func bindViewModel() {
        viewModel.usersLoaded
            .subscribe(onNext: { [weak self] users in
                self?.users = users
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @IBAction func startTapAction(_ sender: UIButton) {
        guard let indexPath = tableView.indexPathForSelectedRow,
              let user = self.users[safe: indexPath.row] else {
                  return
              }
        self.viewModel.tapStartBtn(userSelected: user)
    }
    
    @objc private func dismissAction() {
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension UserListOnlineViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserListOnlineViewCell.cellForTableView(tableView: tableView, indexPath: indexPath)
        cell.configure(user: self.users[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UserListOnlineViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startButton.isEnabled = true
    }
}
