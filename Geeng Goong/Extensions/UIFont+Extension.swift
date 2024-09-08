//
//  UIFont+Extension.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 23/11/2021.
//

import UIKit

extension UIFont {
    
    /// Returns a bolded version of `self`.
    var regular: UIFont { return withWeight(.regular) }
    
    /// Returns a bolded version of `self`.
    var bolded: UIFont { return withWeight(.bold) }
    
    /// Returns a semi-bolded version of `self`.
    var semibolded: UIFont { return withWeight(.semibold) }
    
    /// Returns a light version of `self`.
    var lighted: UIFont { return withWeight(.light) }
    
    /// Returns a semi-bolded version of `self`.
    var extrabolded: UIFont { return withWeight(.heavy) }

    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        return UIFont(descriptor: descriptor, size: 0.0)
    }
    
    /// regular, custom font
    static func gv_customBody(size: CGFloat) -> UIFont {
        return self.mainRegularFont(size: size).dynamicTypeFont(.body)
    }
    
    /// regular, 16pt font
    static func gv_body1() -> UIFont {
        return self.mainRegularFont(size: 16).dynamicTypeFont(.body)
    }
    
    /// regular, 14pt font
    static func gv_body2() -> UIFont {
        return self.mainRegularFont(size: 14).dynamicTypeFont(.subheadline)
    }
    
    /// regular, 12pt font
    static func gv_smallBody() -> UIFont {
        return self.mainRegularFont(size: 12).dynamicTypeFont(.caption1)
    }
    
    /// regular, 24pt font
    static func gv_title() -> UIFont {
        return self.mainRegularFont(size: 24).dynamicTypeFont(.title1)
    }
    
    /// regular, 20pt font
    static func gv_subTitle() -> UIFont {
        return self.mainRegularFont(size: 20).dynamicTypeFont(.title2)
    }
    
    /// bold, 10pt font
    static func gv_counter() -> UIFont {
        return self.mainRegularFont(size: 10).bolded
    }
    
    /// regular, 16pt font
    static func gv_button() -> UIFont {
        return self.mainRegularFont(size: 16).dynamicTypeFont(.body)
    }
    
    // MARK: - Private
    private static func mainRegularFont(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Regular", size: size)!
    }
    
    private func dynamicTypeFont(_ style: UIFont.TextStyle) -> UIFont {
        if #available(iOS 11.0, *) {
            let fontMetrics = UIFontMetrics(forTextStyle: style)
            return fontMetrics.scaledFont(for: self)
        }
        return self
    }
}
