//
//  UpdateArticleViewController.swift
//  ArticleManagementiOS
//
//  Created by Kong Vungsovanreach on 12/16/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import UIKit
import Alamofire
import  Kingfisher
import KVLoading

class UpdateArticleViewController: UIViewController {

    var articlePresenter : ArticlePresenter!
    static var article : Article!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    var image : UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        basicConfig()
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)))
    }

    //Basic config when view loaded
    func basicConfig() {
        articlePresenter = ArticlePresenter()
        articlePresenter.delegate = self
        let article = UpdateArticleViewController.article
        titleTextField.text = article?.title
        descriptionTextView.text = article?.description
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: URL(string: article?.imageUrl ?? ""),
            placeholder: UIImage(named: "no-image"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
    }
    
    //Update article button tap handler
    @IBAction func updateArticleTap(_ sender: Any) {
        UpdateArticleViewController.article.title = titleTextField.text!
        UpdateArticleViewController.article.description = descriptionTextView.text!
        articlePresenter.updateArticle(image: image ?? imageView.image!, article: UpdateArticleViewController.article)
    }

    //Choose image button tap handler
    @objc func chooseImage() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }

    //Function to open camera
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    //Function to open gallery
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have perission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UpdateArticleViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = pickedImage
            self.image = pickedImage            
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UpdateArticleViewController : ArticlePresenterProtocol {
    func didResponseArticles(articles: [Article]) { }

    func didUpdateArticle() {
        navigationController?.popToRootViewController(animated: true)
    }

    func didInsertArticle() { }
}
