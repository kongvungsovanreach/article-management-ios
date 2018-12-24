//
//  ArticleDetailViewController.swift
//  ArticleManagementiOS
//
//  Created by Kong Vungsovanreach on 12/16/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import UIKit

class ArticleDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    static var article : Article!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet  weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let a = ArticleDetailViewController.article
        titleLabel.text = a?.title
        descriptionLabel.text = a?.description
        image.kf.setImage(
            with: URL(string: a?.imageUrl ?? ""),
            placeholder: UIImage(named: "no-image"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        let longPress : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        longPress.delaysTouchesBegan = true
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(longPress)
    }

    @objc func handleLongPress(_ gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state != UIGestureRecognizer.State.began){
            return
        }
        UIImageWriteToSavedPhotosAlbum(image.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

    }


    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }

    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
