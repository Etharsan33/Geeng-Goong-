//
//  GameListViewController.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 27/11/2021.
//

import UIKit
import RxSwift
import MySwiftSpeedUpTools

class GameListViewController: CustomInfinityScrollViewController, CustomEmptyViewProtocol {
    
    var viewModel: GameListViewModel!
    private let disposeBag = DisposeBag()
    
    private var games: [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Mes matchs"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(navigationAddAction))
        
        GameListViewCell.registerNibFor(collectionView: collectionView)
        
        self.bindViewModel()
        self.viewModel.viewDidLoad()
        
        self.onCommitReachInfinityScroll = { [weak self] in
            self?.viewModel.didScrollToEndPage()
        }
    }
    
    // MARK: - Private
    private func bindViewModel() {
        Observable.combineLatest(viewModel.gamesLoaded, viewModel.nextPage)
            .subscribe(onNext: { [weak self] games, nextPage in
                self?.emptyViewState = games.isEmpty ? .emptyWithBtn("Jouer un match") : .none
                self?.games = games
                self?.pageAfter = nextPage
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.gamesNextPageLoaded, viewModel.nextPage)
            .subscribe(onNext: { [weak self] games, nextPage in
                self?.games = games
                self?.pageAfter = nextPage
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.showChatVC
            .subscribe(onNext: { [weak self] (gameID, currentUser) in
                let chatVC = GameChatViewController.instance
                chatVC.viewModel = AppDelegate.container.resolve(GameChatViewModel.self, arguments: gameID, currentUser)!
                self?.navigationController?.pushViewController(chatVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.showUsersOnlineVC
            .subscribe(onNext: { [weak self] currentUser in
                let vc = UserListOnlineViewController.instance
                let actions = UserListOnlineViewModelActions(showGameChat: { [weak vc] gameID in
                    vc?.dismiss(animated: false) { [weak self] in
                        self?.viewModel.didTapStartBtnUserOnline(gameID: gameID)
                    }
                })
                vc.viewModel = AppDelegate.container.resolve(UserListOnlineViewModel.self, arguments: currentUser, actions)!
                self?.present(UINavigationController(rootViewController: vc), animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.moveGameToTop
            .subscribe(onNext: { [weak self] index, games in
                self?.games = games
                DispatchQueue.main.async {
                    let fromIndex = IndexPath(row: index, section: 0)
                    let toIndex = IndexPath(row: 0, section: 0)
                    self?.collectionView.performBatchUpdates({ [weak self] in
                        self?.collectionView.moveItem(at: fromIndex, to: toIndex)
                    }, completion: { [weak self] _ in
                        if fromIndex == toIndex {
                            self?.collectionView.reloadItems(at: [toIndex])
                        } else {
                            self?.collectionView.reloadItems(at: [fromIndex, toIndex])
                        }
                    })
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func navigationAddAction() {
        self.viewModel.didTapNavigationItemAdd()
    }
}

// MARK: - UITableViewDataSource
extension GameListViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.games.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = GameListViewCell.cellForCollection(collectionView: collectionView, indexPath: indexPath)
        cell.widthConstraint.constant = collectionView.bounds.width
        cell.configure(game: self.games[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension GameListViewController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.bounds.width, height: 86.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let game = self.games[indexPath.row]
        self.viewModel.didTapGameCell(gameID: game.id)
    }
}

// MARK: - EmptyViewProtocol
extension GameListViewController {
    
    var emptyViewContainer: UIView? {
        return self.collectionView
    }
    var emptyViewText: String? {
        return "Vous n'avez pas de match en cours"
    }
    func emptyViewTryAgainAction() {}
    
    func emptyViewCancelAction() {
        self.viewModel.didTapListEmptyButton()
    }
}
