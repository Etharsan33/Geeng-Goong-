//
//  ChatBotDataView.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 08/12/2021.
//

import Foundation

struct ChatBotDataView {
    let title: String
    let leftButtonType: ButtonType
    let rightButtonType: ButtonType
    
    struct ButtonType {
        enum `Type`: Int {
            case simple, `default`
        }
        let title: String
        let type: `Type`
    }
}
