//
//  AppDelegate.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 23/11/2021.
//

import UIKit
import Swinject
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static let container = Container()
    
    static var appEnv: AppEnvironment! {
        return Self.container.resolve(AppEnvironment.self)!
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let assembler = Assembler([
            AppMainAssembly(),
            SocketsAssembly(),
            RepositoriesAssembly(),
            UseCasesAssembly(),
            ViewModelsAssembly()
        ], container: AppDelegate.container)
        
        // Connect Socket
        if let currentUser = Self.appEnv.currentUser {
            Self.appEnv.environment.socketIOConnectivity.connect(with: currentUser.id)
        }
        
        // if no launcher window might be nil
        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        func getVC() -> UIViewController {
            if let currentUser = Self.appEnv.currentUser {
                let gameListVC = GameListViewController.instance
                gameListVC.viewModel = assembler.resolver.resolve(GameListViewModel.self, argument: currentUser)!
                return UINavigationController(rootViewController: gameListVC)
            }
            let loginVC = LoginViewController.instance
            loginVC.viewModel = assembler.resolver.resolve(LoginViewModel.self)!
            return loginVC
        }

        self.window?.rootViewController = getVC()
        self.window?.makeKeyAndVisible()
        
        let service = assembler.resolver.resolve(PersistenceCoreDataService.self)! as! DefaultPersistenceCoreDataService
        
//        let predicate = NSPredicate(format: "gameId == %@", "61df0a863cdee0a21c5fd3ee")
//        let sort = NSSortDescriptor(keyPath: \LocalMessage.creationDateMs, ascending: false)
//        let limit: Int = 8
//        let offset: Int = 0
//
//        service.fetchItems(
//            entity: LocalMessage.self,
//            predicate: predicate,
//            range: (limit, offset * limit),
//            sortDescriptors: [sort]) { localMessages in
//                let messages = localMessages
//                    .sorted(by: {$0.creationDateMs < $1.creationDateMs})
//                    .compactMap { $0.toDomain() }
//                print(messages.map { $0.text })
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            service.deleteItems(entity: LocalMessage.self, predicate: nil, completion: nil)
//            service.deleteItems(entity: LocalUser.self, predicate: nil, completion: nil)
            
//            service.insertItems(completionItems: { context in
//                let localMessage = LocalMessage(context: context)
//                localMessage.id = "fdfsdf"
//                localMessage.text = "text"
//                localMessage.creationDateMs = 20201
//                localMessage.type = "user"
//                localMessage.gameId = "ffd"
//
//                let localUser = LocalUser(context: context)
//                localUser.id = "userID"
//                localUser.userName = "userna"
//                localUser.avatarType = "fdsf"
//                localMessage.user = localUser
//
//                return [localMessage]
//            }, entity: LocalMessage.entity())
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            do {
                let request = LocalMessage.fetchRequest()
                let messages = try service.viewContext.fetch(request)
                print("Archived Messages: \n\(messages)")
                messages.forEach { lo in
                    print(lo.id)
                }
            } catch {
                print("Error fetching chat history:", error)
            }

            service.fetchItems(entity: LocalMessage.self) { result in
                print("Archived Messages: \n\(result)")
            }
        }
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Self.appEnv.environment.socketIOConnectivity.closeConnection()
    }

}

