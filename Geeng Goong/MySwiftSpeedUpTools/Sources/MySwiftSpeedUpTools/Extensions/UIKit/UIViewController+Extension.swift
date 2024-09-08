//
//  UIViewController+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import MessageUI

public extension UIViewController {
    
    // MARK: - Instance
    static var instance : Self {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: String(describing: self), bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self))
        return vc as! Self
    }
    
    static var instanceCS : CSControllerProtocol {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: String(describing: self), bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! CSControllerProtocol
        vc.setupCS()
        return vc
    }
    
    // MARK: - Background
    @discardableResult func setupBackgroundImageView( _ image: UIImage) -> UIImageView {
        let backgroundImageView = UIImageView()
        backgroundImageView.backgroundColor = .clear
        backgroundImageView.clipsToBounds = true
        
        backgroundImageView.image = image
        backgroundImageView.contentMode = .scaleAspectFill
        
        self.view.insertSubview(backgroundImageView, at: 0)
        backgroundImageView.frame = self.view.frame
        
        return backgroundImageView
    }
    
    // MARK: - Alert
    enum AlertActionButton {
        case title(String, (() -> Void)? = nil)
        case titleWithStyle(String, UIAlertAction.Style, (() -> Void)? = nil)
        
        var titleAndStyleWithAction: (String, UIAlertAction.Style, (() -> Void)?) {
            switch self {
            case .title(let title, let action):
                return (title, .default, action)
            case .titleWithStyle(let title, let style, let action):
                return (title, style, action)
            }
        }
    }
    
    /// - Parameters:
    ///   - title: title of the alert
    ///   - message: message/body of the alert
    ///   - buttonTitles: (Optional)list of button titles for the alert. Default button i.e "OK" will be shown if this paramter is nil
    ///   - highlightedButtonIndex: (Optional) index of the button from buttonTitles that should be highlighted. If this parameter is nil no button will be highlighted
    func showAlert(title: String?, message: String?, buttons: [AlertActionButton]? = nil, highlightedButtonIndex: Int? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var allButtons = buttons ?? [AlertActionButton]()
        if allButtons.count == 0 {
            allButtons.append(.title(MyToolsLoc.Global.OK.localized))
        }

        for index in 0..<allButtons.count {
            let button = allButtons[index].titleAndStyleWithAction
            
            let action = UIAlertAction(title: button.0, style: button.1, handler: { (_) in
                button.2?()
            })
            alertController.addAction(action)
            // Check which button to highlight
            if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
                alertController.preferredAction = action
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Others
    var isDarkMode: Bool {
        if #available(iOS 12.0, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
    
    // MARK: - App Action
    func openInMaps(lat : CLLocationDegrees, lon : CLLocationDegrees, name : String?, wantDirection: Bool = true) {
        
        let coordinate = CLLocationCoordinate2DMake(lat, lon)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = name
        mapItem.openInMaps(launchOptions: (wantDirection) ? [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving] : [:])
        
    }
    
    func call(tel: String?) {
        
        if let number = tel, let url = URL(string: "tel://\(number.removingWhitespaces())"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func sendText(tel: String?, message : String?, delegate: MFMessageComposeViewControllerDelegate?) -> MFMessageComposeViewController? {
        
        guard let number = tel else {
            return nil
        }
        
        if (MFMessageComposeViewController.canSendText()) {
            let messageController = MFMessageComposeViewController()
            messageController.body = message
            messageController.recipients = [number]
            messageController.messageComposeDelegate = delegate
            self.present(messageController, animated: true, completion: nil)
            return messageController
        }
        
        return nil
    }
    
    @discardableResult
    func sendMail(recipients : [String], subject : String?, message : String?, delegate : MFMailComposeViewControllerDelegate?, attachments: [(Data, String, String)] = []) ->  MFMailComposeViewController {
        
        let mcVC = MFMailComposeViewController()
        
        mcVC.mailComposeDelegate = delegate
        mcVC.setToRecipients(recipients)
        mcVC.setSubject(subject ?? "")
        mcVC.setMessageBody(message ?? "", isHTML: false)
        
        attachments.forEach { attachment in
            mcVC.addAttachmentData(attachment.0, mimeType: attachment.1, fileName: attachment.2)
        }
        
        if #available(iOS 10.0, *) {
            if MFMailComposeViewController.canSendMail() { // Error alert handle by iOS on canSendMail fail
                self.present(mcVC, animated: true, completion: nil)
            }
        } else {
            
            if MFMailComposeViewController.canSendMail() {
                self.present(mcVC, animated: true, completion: nil)
            }
            else {
                let sendMailErrorAlert = UIAlertController(title: MyToolsLoc.Mail.ALERT_CAN_NOT_SEND_MAIL_TITLE.localized, message: MyToolsLoc.Mail.ALERT_CAN_NOT_SEND_MAIL_MESSAGE.localized, preferredStyle: .alert)
                sendMailErrorAlert.addAction(UIAlertAction(title: MyToolsLoc.Global.OK.localized, style: .cancel, handler: nil))
                self.present(sendMailErrorAlert, animated: true, completion: nil)
            }
        }
        
        return mcVC
    }
    
    var isModal : Bool {
        
        if let navigationController = self.navigationController{
            return navigationController.isModal
        }
        
        if self.presentingViewController != nil {
            return true
        }
        
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
    
    // MARK: - NavigationController
    func addImageInNavigationBar(_ image: UIImage) {
        let brandImgView = UIImageView()
        
        brandImgView.image = image
        brandImgView.contentMode = .center
        brandImgView.clipsToBounds = true
        
        let height : CGFloat = 44.0
        let imageHeight : CGFloat = image.size.height
        let imageWidth : CGFloat = image.size.width
        let imageRatio = imageWidth/imageHeight
        let width = imageRatio * height
        
        //Container title view
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        
        brandImgView.translatesAutoresizingMaskIntoConstraints = false
        
        //Make sure that everything fits
        brandImgView.frame = titleView.bounds
        titleView.addSubview(brandImgView)
        
        // add constraints
        brandImgView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 0).isActive = true
        brandImgView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: 0).isActive = true
        brandImgView.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 0).isActive = true
        brandImgView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 0).isActive = true
        
        self.navigationItem.titleView = titleView
    }
}
