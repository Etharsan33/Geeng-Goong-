//
//  String+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 19/09/2020.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public struct ReadableHTMLCSS {
    let balise: Balise
    let font: UIFont?
    let fontSize: CGFloat
    let fontWeight: FontWeight
    let customCSS: String?
    
    public enum Balise: String {
        case h1, h2, p, b, body
    }
    
    public enum FontWeight: String {
        case normal, bold
    }
    
    public init(balise: Balise, font: UIFont? = nil, fontSize: CGFloat, fontWeight: FontWeight = .normal, customCSS: String? = nil) {
        self.balise = balise
        self.font = font
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.customCSS = customCSS
    }
    
    func generateStyle() -> String {
        return String(format: "\(balise.rawValue){font-family: '%@', '-apple-system', 'BlinkMacSystemFont'; font-size:%fpx; font-weight: %@; %@ }", font?.fontName ?? "", fontSize, fontWeight.rawValue, customCSS ?? "")
    }
}

public extension String {
    
    func readableHTML(stylesCSS: [ReadableHTMLCSS], customCSS: String? = nil) -> NSAttributedString? {
        
        let modifiedText = self.replacingOccurrences(of: "\n", with: "<br />")
        
        var styledText = "<style>\(stylesCSS.map{$0.generateStyle()}.joined(separator: " "))</style>" + modifiedText
        if let customCSS = customCSS {
            styledText += " <style>\(customCSS)</style>"
        }
        
        // We do the html to NSAttributedString conversion here because it is very time/cpu consuming to do so and can affect severely the rendering of the container
        // The drawback being that we must set the font/fontSize here (see above why)
        if modifiedText != "", let data = styledText.data(using: .unicode, allowLossyConversion: true),
            let attrStr = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding : String.Encoding.utf8.rawValue], documentAttributes: nil) {
            return attrStr
        }
        
        return nil
    }
}
