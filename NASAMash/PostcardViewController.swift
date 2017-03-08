//
//  PostcardViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/7/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit
import MessageUI

class PostcardViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var message1: UITextField!
    @IBOutlet var message2: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var sendButtonContainerView: UIView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    
    lazy var imageManager: ImageManager = {
        return ImageManager(containingView: self.view, imageView: self.imageView, activityIndicator: self.activityIndicator, noImagImageView: nil) { [unowned self] (image) in
            
            self.imageLoaded = true
        }
    }()
    
    var imageURLString: String? = nil
    var imageLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sendButtonContainerView.layer.cornerRadius = 3
        imageContainerView.layer.cornerRadius = 20
        imageContainerView.layer.borderColor = UIColor.white.cgColor
        imageContainerView.layer.borderWidth = 4
        
        if let messagePlaceholderText = message1.placeholder {
            message1.attributedPlaceholder = NSAttributedString(string: messagePlaceholderText, attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        }
        
        if let messagePlaceholderText = message2.placeholder {
            message2.attributedPlaceholder = NSAttributedString(string: messagePlaceholderText, attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        }
        
        message1.delegate = self
        message2.delegate = self
        email.delegate = self
        
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(PostcardViewController.onApplicationNotification(notification:)), name: TJMApplicationNotification.ApplicationNotification, object: nil)
        center.addObserver(self, selector: #selector(PostcardViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(PostcardViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageManager.imageURL = imageURLString
    }

    @IBAction func onSend() {
        
        guard MFMailComposeViewController.canSendMail() else {
            let note = TJMApplicationNotification(title: "Oops!", message: "Email services are not available on this device. Sorry.", fatal: false)
            note.postMyself()
            return
        }
        
        guard imageLoaded else {
            let note = TJMApplicationNotification(title: "Oops!", message: "For some reason the image could not be loaded. Please try again later.", fatal: false)
            note.postMyself()
            return
        }

        guard email.text!.isEmail else {
            let note = TJMApplicationNotification(title: "Oops!", message: "That doesn't look like a valid email. Please try again.", fatal: false)
            note.postMyself()
            return
        }
        
        
        if message1.text!.isBlank {
            message1.text = "Greetings from Mars!"
        }
        
        if message2.text!.isBlank {
            // hide placeholder text for image processing
            message2.text = " "
        }
        
        view.layoutIfNeeded()

        guard let image = takeSnapshotOfView(view: imageContainerView),
              let imageData = UIImageJPEGRepresentation(image, 2.0) else {
            let note = TJMApplicationNotification(title: "Oops!", message: "There was a problem creating the postcard image. Please try again.", fatal: false)
            note.postMyself()
            return
        }

        sendEmail(imageData: imageData)
    }
    
    func takeSnapshotOfView(view: UIView) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: view.frame.size.width, height: view.frame.size.height), false, 0.0)
        view.drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension PostcardViewController: MFMailComposeViewControllerDelegate {
    
    func sendEmail(imageData: Data) {
        
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        
        mailVC.setToRecipients([email.text!])
        mailVC.setSubject("Greetings from Mars!")
        mailVC.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "MarsRoverPhoto.jpg")
        
        present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .saved, .sent:
            controller.dismiss(animated: true, completion: { self.dismiss(animated: true, completion: nil) })
            
        case .failed:
            controller.dismiss(animated: true, completion: {
                let note = TJMApplicationNotification(title: "Nope!", message: "That didn't work for some reason: \(error?.localizedDescription)", fatal: false)
                note.postMyself()
            })
            
        case .cancelled:
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

extension PostcardViewController: UITextFieldDelegate {
    
    func releaseTextField() {
        
        if message1.isFirstResponder {
            message1.resignFirstResponder()
        }
        
        if message2.isFirstResponder {
            message2.resignFirstResponder()
        }
        
        if email.isFirstResponder {
            email.resignFirstResponder()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        releaseTextField()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        releaseTextField()
        return false
    }
}

extension PostcardViewController {
    
    func keyboardWillShow(notification: NSNotification) -> Void {
        
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let bottomMargin: CGFloat = 10
        
        let heightAvailableAfterKeyboardShows = view.frame.size.height - keyboardFrame.size.height
        
        let candidateTextfield: UITextField
        
        if message1.isFirstResponder {
            candidateTextfield = message1
        } else if message2.isFirstResponder {
            candidateTextfield = message2
        } else if email.isFirstResponder {
            candidateTextfield = email
        } else {
            return
        }

        let top = candidateTextfield.superview!.convert(candidateTextfield.frame.origin, to: nil).y
        let bottomEdgeOfTextField = top + candidateTextfield.frame.size.height + bottomMargin
        
        let difference = bottomEdgeOfTextField - heightAvailableAfterKeyboardShows
        
        if difference > 0 {
            
            // move top and bottom up at the same time, or it compresses
            topConstraint.constant = -difference
            bottomConstraint.constant = difference
            
            // this animates the changes to the constraint
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func keyboardWillHide(notification : NSNotification) -> Void {
        
        // reset the constraints
        topConstraint.constant = 0
        bottomConstraint.constant = 0
        
        // this animates the changes to the constraint
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
        
            if message1.isFirstResponder && touch.view != message1 {
                message1.resignFirstResponder()
            } else if message2.isFirstResponder && touch.view != message2 {
                message2.resignFirstResponder()
            } else if email.isFirstResponder && touch.view != email {
                email.resignFirstResponder()
            }
        }
    }
}
