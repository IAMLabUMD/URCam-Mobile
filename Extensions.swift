//
//  Extensions.swift
//
//
//  Created by Ernest Essuah Mensah on 6/6/19.
//  Copyright © 2019 Ernest Mensah. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications



extension UIColor {
    
    static let themeForeground = #colorLiteral(red: 0.1490196078, green: 0.5490196078, blue: 0.7098039216, alpha: 1)
    static let themeBackground = #colorLiteral(red: 0.937254902, green: 0.9411764706, blue: 0.9607843137, alpha: 1)
}


extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)

        guard #available(iOS 13.0, *), let descriptor = systemFont.fontDescriptor.withDesign(.rounded) else { return systemFont }
        return UIFont(descriptor: descriptor, size: size)
    }
}

extension UNUserNotificationCenter{
    func cleanRepeatingNotifications(){
        //cleans notification with a userinfo key endDate
        //which have expired.
        getPendingNotificationRequests {
            (requests) in
            for request in requests{
                if let endDate = request.content.userInfo["lastDay"]{
                    if Date() >= (endDate as! Date){
                        let center = UNUserNotificationCenter.current()
                        center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    }
                }
            }
        }
    }
    
    
}

extension UIView {
    
    func roundButton(withBackgroundColor: UIColor, opacity: Float) {
        
        let color = withBackgroundColor.cgColor
        layer.cornerRadius = layer.frame.height / 2
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.shadowOpacity = opacity
        layer.shadowColor = color
        
    }
    
    func setCardView() {
        layer.cornerRadius = 12
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowOpacity = 0.1
    }
    
    func addShadow() {
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowOpacity = 0.05
    }
    
    func setupGradientBackground() {
        
        let gradient = CAGradientLayer()
        let cGray = #colorLiteral(red: 0.9697127654, green: 0.9793138819, blue: 0.9793138819, alpha: 1)
        gradient.frame = frame
        gradient.colors = [UIColor.white.cgColor, cGray.cgColor, UIColor.white.cgColor]
        layer.insertSublayer(gradient, at: 0)
    }
    
    func setupView(viewToAdd: UIView, leadingView: UIView?, shouldSwitchLeading: Bool, leadingConstant: CGFloat, trailingView: UIView?, shouldSwitchTrailing: Bool, trailingConstant: CGFloat, topView: UIView?, shouldSwitchTop: Bool, topConstant: CGFloat, bottomView: UIView?, shouldSwitchBottom: Bool, bottomConstant: CGFloat) {
        
        self.addSubview(viewToAdd)
        viewToAdd.translatesAutoresizingMaskIntoConstraints = false
        
        if leadingView != nil {
            if shouldSwitchLeading {
                viewToAdd.leadingAnchor.constraint(equalTo: leadingView!.trailingAnchor, constant: leadingConstant).isActive = true
            } else {
                viewToAdd.leadingAnchor.constraint(equalTo: leadingView!.leadingAnchor, constant: leadingConstant).isActive = true
            }
            
        }
        
        if trailingView != nil {
            if shouldSwitchTrailing {
                viewToAdd.trailingAnchor.constraint(equalTo: trailingView!.leadingAnchor, constant: trailingConstant).isActive = true
            } else {
                viewToAdd.trailingAnchor.constraint(equalTo: trailingView!.trailingAnchor, constant: trailingConstant).isActive = true
            }
            
        }
        
        if topView != nil {
            if shouldSwitchTop {
                viewToAdd.topAnchor.constraint(equalTo: topView!.bottomAnchor, constant: topConstant).isActive = true
            } else {
                viewToAdd.topAnchor.constraint(equalTo: topView!.topAnchor, constant: topConstant).isActive = true
            }
        }
        
        if bottomView != nil {
            if shouldSwitchBottom {
                viewToAdd.bottomAnchor.constraint(equalTo: bottomView!.topAnchor, constant: bottomConstant).isActive = true
            } else {
                viewToAdd.bottomAnchor.constraint(equalTo: bottomView!.bottomAnchor, constant: bottomConstant).isActive = true
            }
        }
        viewToAdd.widthAnchor.constraint(equalToConstant: viewToAdd.frame.width).isActive = true
        viewToAdd.heightAnchor.constraint(equalToConstant: viewToAdd.frame.height).isActive = true
    }
    
    func showView(viewToShow: UIView) {
        
        self.addSubview(viewToShow)
        viewToShow.center = CGPoint(x: self.center.x, y: self.center.y - 8)
        viewToShow.transform = CGAffineTransform(translationX: 0, y: 32)
        viewToShow.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
            
            viewToShow.transform = .identity
            viewToShow.alpha = 1
        })
    }
    
    func showView2(viewToShow: UIView) {
        
        self.addSubview(viewToShow)
        viewToShow.center = CGPoint(x: self.center.x, y: self.center.y - 100)
        viewToShow.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
            viewToShow.transform = .identity
            viewToShow.alpha = 1
        })
    }
    
}

struct Device {
    static let iPhoneX = CGSize(width: 1125.0, height: 2436.0)
    static let iPhonePlus = CGSize(width: 1242.0, height: 2208.0)
    static let iPhoneXR = CGSize(width: 828.0, height: 1792.0)
    static let iPhoneXsMax = CGSize(width: 1242.0, height: 2688.0)
}

public enum Model : String {
    case simulator   = "simulator/sandbox",
    iPod1            = "iPod 1",
    iPod2            = "iPod 2",
    iPod3            = "iPod 3",
    iPod4            = "iPod 4",
    iPod5            = "iPod 5",
    iPad2            = "iPad 2",
    iPad3            = "iPad 3",
    iPad4            = "iPad 4",
    iPhone4          = "iPhone 4",
    iPhone4S         = "iPhone 4S",
    iPhone5          = "iPhone 5",
    iPhone5S         = "iPhone 5S",
    iPhone5C         = "iPhone 5C",
    iPadMini1        = "iPad Mini 1",
    iPadMini2        = "iPad Mini 2",
    iPadMini3        = "iPad Mini 3",
    iPadAir1         = "iPad Air 1",
    iPadAir2         = "iPad Air 2",
    iPadPro9_7       = "iPad Pro 9.7\"",
    iPadPro9_7_cell  = "iPad Pro 9.7\" cellular",
    iPadPro10_5      = "iPad Pro 10.5\"",
    iPadPro10_5_cell = "iPad Pro 10.5\" cellular",
    iPadPro12_9      = "iPad Pro 12.9\"",
    iPadPro12_9_cell = "iPad Pro 12.9\" cellular",
    iPhone6          = "iPhone 6",
    iPhone6plus      = "iPhone 6 Plus",
    iPhone6S         = "iPhone 6S",
    iPhone6Splus     = "iPhone 6S Plus",
    iPhoneSE         = "iPhone SE",
    iPhone7          = "iPhone 7",
    iPhone7plus      = "iPhone 7 Plus",
    iPhone8          = "iPhone 8",
    iPhone8plus      = "iPhone 8 Plus",
    iPhoneX          = "iPhone X",
    iPhoneXS         = "iPhone XS",
    iPhoneXSmax      = "iPhone XS Max",
    iPhoneXR         = "iPhone XR",
    unrecognized     = "?unrecognized?"
}

public extension UIDevice {
    var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
                
            }
        }
        let modelMap : [ String : Model ] = [
            "i386"       : .simulator,
            "x86_64"     : .simulator,
            "iPod1,1"    : .iPod1,
            "iPod2,1"    : .iPod2,
            "iPod3,1"    : .iPod3,
            "iPod4,1"    : .iPod4,
            "iPod5,1"    : .iPod5,
            "iPad2,1"    : .iPad2,
            "iPad2,2"    : .iPad2,
            "iPad2,3"    : .iPad2,
            "iPad2,4"    : .iPad2,
            "iPad2,5"    : .iPadMini1,
            "iPad2,6"    : .iPadMini1,
            "iPad2,7"    : .iPadMini1,
            "iPhone3,1"  : .iPhone4,
            "iPhone3,2"  : .iPhone4,
            "iPhone3,3"  : .iPhone4,
            "iPhone4,1"  : .iPhone4S,
            "iPhone5,1"  : .iPhone5,
            "iPhone5,2"  : .iPhone5,
            "iPhone5,3"  : .iPhone5C,
            "iPhone5,4"  : .iPhone5C,
            "iPad3,1"    : .iPad3,
            "iPad3,2"    : .iPad3,
            "iPad3,3"    : .iPad3,
            "iPad3,4"    : .iPad4,
            "iPad3,5"    : .iPad4,
            "iPad3,6"    : .iPad4,
            "iPhone6,1"  : .iPhone5S,
            "iPhone6,2"  : .iPhone5S,
            "iPad4,1"    : .iPadAir1,
            "iPad4,2"    : .iPadAir2,
            "iPad4,4"    : .iPadMini2,
            "iPad4,5"    : .iPadMini2,
            "iPad4,6"    : .iPadMini2,
            "iPad4,7"    : .iPadMini3,
            "iPad4,8"    : .iPadMini3,
            "iPad4,9"    : .iPadMini3,
            "iPad6,3"    : .iPadPro9_7,
            "iPad6,11"   : .iPadPro9_7,
            "iPad6,4"    : .iPadPro9_7_cell,
            "iPad6,12"   : .iPadPro9_7_cell,
            "iPad6,7"    : .iPadPro12_9,
            "iPad6,8"    : .iPadPro12_9_cell,
            "iPad7,3"    : .iPadPro10_5,
            "iPad7,4"    : .iPadPro10_5_cell,
            "iPhone7,1"  : .iPhone6plus,
            "iPhone7,2"  : .iPhone6,
            "iPhone8,1"  : .iPhone6S,
            "iPhone8,2"  : .iPhone6Splus,
            "iPhone8,4"  : .iPhoneSE,
            "iPhone9,1"  : .iPhone7,
            "iPhone9,2"  : .iPhone7plus,
            "iPhone9,3"  : .iPhone7,
            "iPhone9,4"  : .iPhone7plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,2" : .iPhone8plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSmax,
            "iPhone11,6" : .iPhoneXSmax,
            "iPhone11,8" : .iPhoneXR
        ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            return model
        }
        return Model.unrecognized
    }
}
