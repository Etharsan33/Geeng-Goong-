//
//  UITableViewCell+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 08/05/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public extension UITableViewCell {
    
    // MARK: - Instance
    class func registerNibFor(tableview tableView: UITableView) {
        let nib = UINib(nibName: String(describing: self), bundle: Bundle(for: self))
        tableView.register(nib, forCellReuseIdentifier: String(describing: self))
    }
    
    class func cellForTableView(tableView: UITableView, indexPath : IndexPath) -> Self {
        return tableView.dequeueReusableCell(withIdentifier: String(describing: self), for: indexPath) as! Self
    }
}
