//
//  ArticlePresenter.swift
//  ArticleManagementiOS
//
//  Created by Kong Vungsovanreach on 12/24/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import UIKit

protocol ArticlePresenterProtocol {
    func didResponseArticles(articles: [Article])
    func didUpdateArticle()
    func didInsertArticle()
}

class ArticlePresenter : ArticleServiceProtocol {
    func didUpdateArticle() {
        delegate?.didUpdateArticle()
    }

    func didInsertArticle() {
        delegate?.didInsertArticle()
    }

    func didResponeArticle(articles : [Article]) {
        delegate?.didResponseArticles(articles : articles)
    }

    var delegate: ArticlePresenterProtocol?
    var articleService: ArticleService?

    init(){
        self.articleService = ArticleService()
        self.articleService?.delegate = self
    }

    func getArticles(page: Int){
        articleService?.getArticles(page: page)
    }

    func deleteArticle(id : Int)  {
        articleService?.deleteArticle(id: id)
    }

    func updateArticle(image : UIImage, article : Article){
        articleService?.updateArticle(image: image, article: article)
    }

    func insertArticle(image : UIImage, article : Article) {
        articleService?.insertArticle(image: image, article: article)
    }
}
