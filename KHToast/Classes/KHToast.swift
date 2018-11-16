//
//  KHToast.swift
//  Toast
//
//  Created by MiniMon on 16/11/2018.
//  Copyright © 2018 coke. All rights reserved.
//

import UIKit

extension String {
    func stringRect(width: CGFloat, font: UIFont) -> CGRect {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        var boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        boundingBox.size.width = boundingBox.size.width + 20.0
        boundingBox.size.height = boundingBox.size.height + 20.0
        return boundingBox
    }
}


class KHToastStyle: NSObject {
    
    var titleFont = UIFont.systemFont(ofSize: 18, weight: .heavy)
    var messageFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    var titleColor = UIColor.black
    var messageColor = UIColor.gray
    
}



class KHToast: NSObject {
    
    static var style = KHToastStyle()
    
    
    class var toastEdge:UIEdgeInsets {
        get {
            var top:CGFloat = 20.0
            if #available(iOS 11.0, *) {
                
                if UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20 {
                    top = (UIApplication.shared.delegate?.window??.safeAreaInsets.top)!
                }
            }
            top = top + 44.0
            return UIEdgeInsets.init(top: top, left: 20.0, bottom: 0.0, right: 20.0)
        }
    }
    
    
    class var maxWidth:CGFloat {
        get {
            return UIScreen.main.bounds.width - (toastEdge.left + toastEdge.right)
        }
    }
    
    static let deviceWidth = UIScreen.main.bounds.width
    
    
    
    
    
    
    
    class func getTitleSize(title:String) -> CGRect {
        
        let titleRect = title.stringRect(width: maxWidth, font: style.titleFont)
        
        return CGRect.init(x: (deviceWidth - titleRect.size.width)/2, y: toastEdge.top, width: titleRect.size.width, height: titleRect.size.height)
    }
    
    class func getMessageSize(message:String) -> CGRect {
        let messageRect = message.stringRect(width: maxWidth, font: style.messageFont)
        return CGRect.init(x: (deviceWidth - messageRect.size.width)/2, y: toastEdge.top, width: messageRect.size.width, height: messageRect.size.height)
    }
    
    
    class func showMessage(message:String) {
        self.showMessage(title: "알림", message: message)
    }
    
    class func showMessage(title:String, message:String) {
        
        let titleRect = self.getTitleSize(title: title)
        let messageRect = self.getMessageSize(message: message)
        
        
        let containView = UIView.init(frame: titleRect)
        containView.frame.origin.y = -titleRect.size.height
        containView.layer.cornerRadius = containView.bounds.size.height/2
        containView.backgroundColor = UIColor.white
        containView.alpha = 0
        UIApplication.shared.keyWindow?.addSubview(containView)
        
        let messageLabel = UILabel.init(frame: containView.bounds)
        messageLabel.textColor = style.titleColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = style.titleFont
        messageLabel.text = title
        containView.addSubview(messageLabel)
        self.viewStyle(contentView: containView)
        
        
        
        UIView.animate(withDuration: 1, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            containView.alpha = 1
            containView.frame.origin.y = toastEdge.top
        }) { _ in
            messageLabel.text = ""
            UIView.animate(withDuration: 0.5, animations: {
                containView.frame = messageRect
                messageLabel.frame = containView.bounds
                containView.layer.cornerRadius = containView.bounds.size.height/2
                messageLabel.alpha = 0
            }, completion: { (finish) in
                self.viewStyle(contentView: containView)
                messageLabel.font = style.messageFont
                messageLabel.text = message
                messageLabel.textColor = style.messageColor
                
                UIView.animate(withDuration: 0.5, animations: {
                    messageLabel.alpha = 1
                }, completion: { (finish) in
                    self.perform(#selector(dismiss(contentView:)), with: containView, afterDelay: 4, inModes: [.default])
                })
                
            })
            
        }
        
    }
    
    @objc class func dismiss(contentView:UIView) {
        UIView.animate(withDuration: 1, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            contentView.alpha = 0
            contentView.frame.origin.y = -contentView.bounds.size.height
        }) { _ in
        }
    }
    
    
    private class func viewStyle(contentView:UIView) {
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = contentView.bounds.size.height/2
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 1, height: 5)
        contentView.layer.shadowRadius = 40
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 14, height: 14)).cgPath
    }
    
}
