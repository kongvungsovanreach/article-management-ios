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

class UpdateArticleViewController: UIViewController {
    static var article : Article!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var imagePicker: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var image : UIImage!
    var isUpdate : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        basicConfig()
    }

    //Basic config when view loaded
    func basicConfig() {
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

    // Upload file to api and get link back
    func uploadImage(image : UIImage)   {
        let url = "http://www.api-ams.me/v1/api/uploadfile/single"
        let header = [ "Authorization": "Basic QU1TQVBJQURNSU46QU1TQVBJUEBTU1dPUkQ=",
                       "Content-Type": "application/json",
                       "Accept": "application/json" ]
        Alamofire.upload(multipartFormData: { (multipart) in
            multipart.append(image.jpegData(compressionQuality: 0.2)!, withName: "FILE", fileName: ".jpg", mimeType: "image/jpeg")
        }, to: url, method:.post, headers:header) { (result) in
            switch result {
            case .success(request: let upload, _ ,  _):
                upload.responseJSON(completionHandler: { (response) in
                    if let data = try? JSONSerialization.jsonObject(with: response.data!, options:[]) as! [String:Any] {
                        let parameters: Parameters = [
                            "TITLE": "\(self.titleTextField.text!)",
                            "DESCRIPTION": "\(self.descriptionTextView.text!)",
                            "AUTHOR": 1,
                            "CATEGORY_ID": 2,
                            "STATUS": "true",
                            "IMAGE": self.isUpdate ? data["DATA"] as! String : UpdateArticleViewController.article.imageUrl
                        ]

                        let url = "http://ams.chhaileng.com/v1/api/articles/\(String(describing: UpdateArticleViewController.article.id!))"
                        let headers: HTTPHeaders = [
                            "Authorization": "Basic QU1TQVBJQURNSU46QU1TQVBJUEBTU1dPUkQ=",
                            "Accept": "application/json"
                        ]
                        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers:headers ).responseData { ( response) in
                            guard response.result.isSuccess,let _ = response.result.value else {
                                print("Error while fetching: \(String(describing: response.result.error))")
                                return
                            }
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                })
            case .failure(let e):
                print(e)
            }
        }
    }

    //Update article button tap handler
    @IBAction func updateArticleTap(_ sender: Any) {
        uploadImage(image: image ?? #imageLiteral(resourceName: "no-image"))
    }

    //Choose image button tap handler
    @IBAction func imagePickerButtonTap(_ sender: Any) {
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
            isUpdate = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
