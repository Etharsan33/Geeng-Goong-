//
//  GameListViewModel.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 27/11/2021.
//

import RxSwift
import RxRelay

protocol GameListViewModelInput {
    func viewDidLoad()
    func didTapStartBtnUserOnline(gameID: String)
    func didTapGameCell(gameID: String)
    func didTapNavigationItemAdd()
    func didScrollToEndPage()
    func didTapListEmptyButton()
}

protocol GameListViewModelOutput {
    var gamesLoaded: BehaviorRelay<[Game]> { get }
    var showChatVC: PublishSubject<(gameID: String, currentUser: User)> { get }
    var showUsersOnlineVC: PublishSubject<User> { get }
    var gamesNextPageLoaded: PublishSubject<[Game]> { get }
    var moveGameToTop: PublishSubject<(index: Int, [Game])> { get }
    var nextPage: BehaviorRelay<String?> { get }
}

protocol GameListViewModel: GameListViewModelInput, GameListViewModelOutput {}

class DefaultGameListViewModel: GameListViewModel {
    
    private let socket: SocketIOGameList
    private let currentUser: User
    
    private static let LIMIT_PAGE: Int = 8
    private var games: [Game] = []
    
    // MARK: - Output
    let gamesLoaded = BehaviorRelay<[Game]>(value: [])
    let showChatVC = PublishSubject<(gameID: String, currentUser: User)>()
    let showUsersOnlineVC = PublishSubject<User>()
    let gamesNextPageLoaded = PublishSubject<[Game]>()
    let moveGameToTop = PublishSubject<(index: Int, [Game])>()
    let nextPage = BehaviorRelay<String?>(value: nil)
    
    init(socket: SocketIOGameList, currentUser: User) {
        self.socket = socket
        self.currentUser = currentUser
    }
    
    // MARK: - Input
    func viewDidLoad() {
        self.socket.setUserID(self.currentUser.id)
        self.listenSockets()
    }
    
    func didTapStartBtnUserOnline(gameID: String) {
        self.showChatVC.onNext((gameID, self.currentUser))
    }
    
    func didTapGameCell(gameID: String) {
        self.showChatVC.onNext((gameID, self.currentUser))
    }
    
    func didTapNavigationItemAdd() {
        self.showUsersOnlineVC.onNext(self.currentUser)
    }
    
    func didScrollToEndPage() {
        guard let lastGameId = self.gamesLoaded.value.last?.id else {
            return
        }
        self.socket.getGamesNext(userId: self.currentUser.id,
                                 limit: Self.LIMIT_PAGE,
                                 lastGameId: lastGameId) { [weak self] games in
            guard let self = self else { return }
            
            self.games.append(contentsOf: games)
            
            let lastGameID = self.getLastGameID(games)
            self.nextPage.accept(lastGameID)
            self.gamesNextPageLoaded.onNext(self.games)
        }
    }
    
    func didTapListEmptyButton() {
        self.showUsersOnlineVC.onNext(self.currentUser)
    }
    
    // MARK: - Private
    private func listenSockets() {
        // TODO: REMOVE !!
        self.games = [.init(id: "61df0a863cdee0a21c5fd3ee", creationDateMs: Date().timeIntervalSinceNow, lastActionDateMs: Date().timeIntervalSinceNow, action: nil, unreadMessageCount: 0, opponent: .init(id: "", userName: "Test Msg Status", avatarType: .yellow))]
        self.gamesLoaded.accept(self.games)
        
        socket.onGetGames { [weak self] games in
            let lastGameID = (games.count >= Self.LIMIT_PAGE) ? games.last?.id : nil
            self?.games = games
            self?.nextPage.accept(lastGameID)
            self?.gamesLoaded.accept(games)
        }
        
        socket.onGameCreated { [weak self] game in
            guard let self = self else { return }
            self.games.insert(game, at: 0)
            self.gamesLoaded.accept(self.games)
        }
        
        socket.onGameDeclined { [weak self] gameID in
            guard let self = self,
                  let index = self.games.firstIndex(where: { $0.id == gameID }) else {
                return
            }
            self.games.remove(at: index)
            self.gamesLoaded.accept(self.games)
        }
        
        socket.onGameRoundPosted { [weak self] game in
            self?.moveGameAtTop(game)
        }
        
        socket.onGameUnreadMsgUpdated { [weak self] game in
            self?.moveGameAtTop(game)
        }
    }
    
    private func moveGameAtTop(_ game: Game) {
        guard let index = self.games.firstIndex(where: { $0.id == game.id }) else {
            return
        }
        
        self.games.remove(at: index)
        self.games.insert(game, at: 0)
        
        self.moveGameToTop.onNext((index, self.games))
    }
    
    private func getLastGameID(_ games: [Game]) -> String? {
        return (games.count >= Self.LIMIT_PAGE) ? games.last?.id : nil
    }
}
