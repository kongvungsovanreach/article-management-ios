//
//  AddArticleViewController.swift
//  ArticleManagementiOS
//
//  Created by Kong Vungsovanreach on 12/16/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import UIKit
import Alamofire

class AddArticleViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var imagePicker: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var image : UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

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

    //Save button handler
    @IBAction func saveButtonTap(_ sender: Any) {
        saveArticle()
        self.navigationController?.popToRootViewController(animated: true)
    }

    //Save function to save article to API
    func saveArticle() {
        if let image = image {
            uploadImage(image: image)
        }else {
            let noImage = UIAlertController(title: "Article must has an image!!", message: nil, preferredStyle: .alert)
            noImage.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            self.present(noImage, animated: true, completion: nil)
        }
        if (titleTextField.text?.isEmpty)! {
            let noImage = UIAlertController(title: "Article must has an title!!", message: nil, preferredStyle: .alert)
            noImage.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            self.present(noImage, animated: true, completion: nil)
        }
    }

    //Open camera
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            print("here")
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    //Open gallery
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have perission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

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
                            "IMAGE": data["DATA"] as! String
                        ]
                        let uploadUrl = "http://www.api-ams.me/v1/api/articles"
                        let headers: HTTPHeaders = [
                            "Authorization": "Basic QU1TQVBJQURNSU46QU1TQVBJUEBTU1dPUkQ=",
                            "Accept": "application/json"
                        ]
                        Alamofire.request(uploadUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:headers ).responseData { ( response) in
                            guard response.result.isSuccess,let _ = response.result.value else {
                                print("Error while fetching: \(String(describing: response.result.error))")
                                return
                            }
                        }
                    }
                })
            case .failure(let e):
                print(e)
            }
        }
    }
}

extension AddArticleViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = pickedImage
            self.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func postDataDemo()  {

        let parameters: Parameters = [
            "TITLE": self.randomString(),
            "DESCRIPTION": self.randomString(),
            "AUTHOR": 1,
            "CATEGORY_ID": 2,
            "STATUS": "true",
            "IMAGE": "https://images-na.ssl-images-amazon.com/images/I/4193lkt1F5L.jpg"
        ]
        let uploadUrl = "http://www.api-ams.me/v1/api/articles"
        let headers: HTTPHeaders = [
            "Authorization": "Basic QU1TQVBJQURNSU46QU1TQVBJUEBTU1dPUkQ=",
            "Accept": "application/json"
        ]
        Alamofire.request(uploadUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:headers ).responseData { ( response) in
            guard response.result.isSuccess,let _ = response.result.value else {
                print("Error while fetching: \(String(describing: response.result.error))")
                return
            }
        }

    }

    func randomString() -> String {
        let smallLetter = "bcdfghjklmnpqrstvwxyz"
        let capitalLetter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let vowel = "aeiou"
        return "\(String((0...0).map{ _ in capitalLetter.randomElement()! }))\(String((0...0).map{ _ in vowel.randomElement()! }))\(String((0...1).map{ _ in smallLetter.randomElement()! }))\(String((0...0).map{ _ in vowel.randomElement()! }))"
    }
}


