//
//  ArticleService.swift
//  ArticleManagementiOS
//
//  Created by Kong Vungsovanreach on 12/24/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import Foundation
import  Alamofire
import SwiftyJSON
import KVLoading

protocol ArticleServiceProtocol {
    func didResponeArticle(articles : [Article])
    func didUpdateArticle()
    func didInsertArticle()
}

class ArticleService {
    var delegate: ArticleServiceProtocol?
    let headers = [ "Authorization": "Basic QU1TQVBJQURNSU46QU1TQVBJUEBTU1dPUkQ=",
                   "Content-Type": "application/json",
                   "Accept": "application/json" ]

    func getArticles(page : Int){
        var articles = [Article]()
        let fetchUrl = "http://ams.chhaileng.com/v1/api/articles?page=\(page)&limit=15"
        Alamofire.request(fetchUrl, method: .get, parameters: nil, headers: headers ).responseJSON { ( response) in
            if response.result.isSuccess{
                var json = response.result.value as? [String:Any]
                let jsonData = json?["DATA"] as! NSArray
                if jsonData.count == 0 {
                    return
                }
                for data in jsonData{
                    articles.append(Article(JSON: (data as? [String:Any])!)!)
                }
                self.delegate?.didResponeArticle(articles: articles)
            }else{
                print("........")
            }
        }
    }

    func deleteArticle(id : Int)  {
        let deleteUrl = "http://ams.chhaileng.com/v1/api/articles/\(id)"
        Alamofire.request(deleteUrl, method: .delete, parameters: nil, headers: headers )
    }

    func updateArticle(image : UIImage, article : Article)   {
        KVLoading.show()
        let uploadImageUrl = "http://www.api-ams.me/v1/api/uploadfile/single"
        Alamofire.upload(multipartFormData: { (multipart) in
            multipart.append(image.jpegData(compressionQuality: 0.2)!, withName: "FILE", fileName: ".jpg", mimeType: "image/jpeg")
        }, to: uploadImageUrl, method:.post, headers:headers) { (result) in
            switch result {
            case .success(request: let upload, _ ,  _):
                upload.responseJSON(completionHandler: { (response) in
                    if let data = try? JSONSerialization.jsonObject(with: response.data!, options:[]) as! [String:Any] {
                        let parameters: Parameters = [
                            "TITLE": article.title,
                            "DESCRIPTION": article.description,
                            "AUTHOR": 1,
                            "CATEGORY_ID": 2,
                            "STATUS": "true",
                            "IMAGE" : data["DATA"] as Any
                        ]
                        let updateUrl = "http://ams.chhaileng.com/v1/api/articles/\(String(describing: UpdateArticleViewController.article.id!))"
                        Alamofire.request(updateUrl, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers:self.headers ).responseData { ( response) in
                            KVLoading.hide()
                            self.delegate?.didUpdateArticle()
                            let updatedArticle = UpdateArticleViewController.article
                            updatedArticle?.title = article.title
                            updatedArticle?.description = article.description
                            updatedArticle?.imageUrl = (data["DATA"] as! String)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updated"), object: (object : updatedArticle, image: image))
                        }
                    }
                })
            case .failure(let e):
                print(e)
            }
        }
    }

    func insertArticle(image : UIImage, article : Article) {
            KVLoading.show()
            let uploadFileUrl = "http://www.api-ams.me/v1/api/uploadfile/single"
            Alamofire.upload(multipartFormData: { (multipart) in
                multipart.append(image.jpegData(compressionQuality: 0.2)!, withName: "FILE", fileName: ".jpg", mimeType: "image/jpeg")
            }, to: uploadFileUrl, method:.post, headers:headers) { (result) in
                switch result {
                case .success(request: let upload, _ ,  _):
                    upload.responseJSON(completionHandler: { (response) in
                        if let data = try? JSONSerialization.jsonObject(with: response.data!, options:[]) as! [String:Any] {
                            let parameters: Parameters = [
                                "TITLE": article.title!,
                                "DESCRIPTION": article.description!,
                                "AUTHOR": 1,
                                "CATEGORY_ID": 2,
                                "STATUS": "true",
                                "IMAGE": data["DATA"] as! String
                            ]
                            let insertUrl = "http://www.api-ams.me/v1/api/articles"
                            Alamofire.request(insertUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:self.headers ).responseData { ( response) in
                                KVLoading.hide()
                                self.delegate?.didInsertArticle()
                            }
                            let newArticle = Article()
                            newArticle.title = article.title
                            newArticle.description = article.description
                            newArticle.imageUrl = (data["DATA"] as! String)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "inserted"), object: (object : newArticle, image: image))
                        }
                    })
                case .failure(let e):
                    print(e)
                }
            }
        }
    
}
