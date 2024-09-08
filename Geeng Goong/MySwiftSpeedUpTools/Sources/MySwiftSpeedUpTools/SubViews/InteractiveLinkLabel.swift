//
//  InteractiveLinkLabel.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 26/03/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

fileprivate extension NSAttributedString.Key {
    static let customLink = NSAttributedString.Key("CustomLink")
    static let customActionIdentifier = NSAttributedString.Key("CustomActionIdentifier")
}

/// label.applyAttributeText([.normal("Some Text"),
///                   .customAction("identifier", "with custom action")],
///                   textAttribute: _ )
/// label.onCommitCustomAction = { identifier in // Do Staff }
open class InteractiveLinkLabel: UILabel {
    
    public enum AttributLinkLabel {
        case normal(_ text: String)
        case link(_ text: String, _ link: String, [NSAttributedString.Key: Any] = [:])
        case customAction(_ id: String, _ text: String, [NSAttributedString.Key: Any] = [:])
    }
    
    public var onCommitCustomAction: ((_ id: String) -> ())?
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    func configure() {
        isUserInteractionEnabled = true
    }
    
    func getAttributeText(_ attributes: [AttributLinkLabel], textAttribute: [NSAttributedString.Key:Any], linkAttribute: [NSAttributedString.Key:Any]) -> NSMutableAttributedString {
        let mutateAttrib = NSMutableAttributedString()
        
        attributes.map { attLink -> NSAttributedString in
            switch attLink {
                case .normal(let text):
                    return NSAttributedString(string: text, attributes: textAttribute)
                case .link(let text, let link, let customAttributes):
                    var attr = linkAttribute
                    attr.add([.underlineStyle: NSUnderlineStyle.single.rawValue, .customLink : link])
                    attr.add(customAttributes)
                    return NSAttributedString(string: text, attributes: attr)
                case .customAction(let id, let text, let customAttributes):
                    var attr = linkAttribute
                    attr.add([.underlineStyle: NSUnderlineStyle.single.rawValue, .customActionIdentifier : id])
                    attr.add(customAttributes)
                    return NSAttributedString(string: text, attributes: attr)
            }
        }
        .forEach(mutateAttrib.append)
        
        return mutateAttrib
    }
    
    public func applyAttributeText(_ attributes: [AttributLinkLabel], textAttribute: [NSAttributedString.Key:Any], linkAttribute: [NSAttributedString.Key:Any]) {
        let mutateAttribute = self.getAttributeText(attributes, textAttribute: textAttribute, linkAttribute: linkAttribute)
        self.attributedText = mutateAttribute
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let superBool = super.point(inside: point, with: event)
        
        // Configure NSTextContainer
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        
        // Configure NSLayoutManager and add the text container
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        guard let attributedText = attributedText else {return false}
        
        // Configure NSTextStorage and apply the layout manager
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addAttribute(NSAttributedString.Key.font, value: font!, range: NSMakeRange(0, attributedText.length))
        textStorage.addLayoutManager(layoutManager)
        
        // get the tapped character location
        let locationOfTouchInLabel = point
        
        // account for text alignment and insets
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        var alignmentOffset: CGFloat!
        switch textAlignment {
        case .left, .natural, .justified:
            alignmentOffset = 0.0
        case .center:
            alignmentOffset = 0.5
        case .right:
            alignmentOffset = 1.0
        @unknown default:
            fatalError()
        }
        
        let xOffset = ((bounds.size.width - textBoundingBox.size.width) * alignmentOffset) - textBoundingBox.origin.x
        let yOffset = ((bounds.size.height - textBoundingBox.size.height) * alignmentOffset) - textBoundingBox.origin.y
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - xOffset, y: locationOfTouchInLabel.y - yOffset)
        
        // work out which character was tapped
        let characterIndex = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // work out how many characters are in the string up to and including the line tapped, to ensure we are not off the end of the character string
        let lineTapped = Int(ceil(locationOfTouchInLabel.y / font.lineHeight)) - 1
        let rightMostPointInLineTapped = CGPoint(x: bounds.size.width, y: font.lineHeight * CGFloat(lineTapped))
        let charsInLineTapped = layoutManager.characterIndex(for: rightMostPointInLineTapped, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        guard characterIndex < charsInLineTapped else {return false}
        
        let attributes = self.attributedText?.attributes(at: characterIndex, effectiveRange: nil)
        
        attributes?.forEach{ (key, value) in
            if key == .customLink {
                if let stringValue = value as? String, let url = URL(string: stringValue) {
                    UIApplication.shared.open(url)
                }
            } else if key == .customActionIdentifier, let id = value as? String {
                self.onCommitCustomAction?(id)
            }
        }
        
        return superBool
        
    }
}
