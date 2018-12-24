//
//  ViewController.swift
//  ArticleManagementiOS
//
//  Created by Kong Vungsovanreach on 12/14/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper
import Kingfisher
import KVLoading

class ViewController: UIViewController {
    var articlePresenter: ArticlePresenter?
    static var article : Article!
    var articles = [Article]()
    var pagination = 1
    let loader = UIRefreshControl()
    let randomAuthor = ["Charlie","Justini","Shawnie","Mileyes","Passeng","Maroon5"]
    @IBOutlet weak var articleTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        KVLoading.show()
        basicConfig()
        articlePresenter?.getArticles(page: pagination)
        nibRegister()
//       let b =  AddArticleViewController()
//        for _ in 0...100 {
//            b.postDataDemo()
//        }
    }

    func basicConfig() {
        articlePresenter = ArticlePresenter()
        articlePresenter?.delegate = self
        articleTableView.dataSource = self
        articleTableView.delegate = self
        articleTableView.refreshControl = loader
        loader.addTarget(self, action: #selector(reloadArticle), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(autoUpdateArticle), name: Notification.Name("updated") , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(insertNewArticle), name: Notification.Name("inserted") , object: nil)
    }
    @objc func autoUpdateArticle(_ notification : Notification) {
        let (returnArticle, img) = notification.object as! (Article, UIImage)
        let indexPath = returnArticle.index!
        let cell = articleTableView.cellForRow(at: indexPath) as! CustomCell
        cell.title.text = returnArticle.title
        cell.thumbnail.image = img
    }
    @objc func insertNewArticle(_ notification : Notification) {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.timeZone = TimeZone.current
        let dateString = formatter.string(from: now)
        let (returnArticle, img) = notification.object as! (Article, UIImage)
        returnArticle.createdDate = dateString
        let reusableCell = articleTableView.dequeueReusableCell(withIdentifier: "reusableCell") as! CustomCell
        reusableCell.title.text = returnArticle.title
        reusableCell.thumbnail.image = img
        reusableCell.createDate.text = dateString
        reusableCell.authorName.text = randomAuthor[Int.random(in: 0...randomAuthor.count-1)]
        reusableCell.viewAmount.text = String(Int.random(in: 0...1000))
        reusableCell.likeAmount.text = String(Int.random(in: 0...1000))
        reusableCell.shareAmount.text = String(Int.random(in: 0...1000))
        articles.insert(returnArticle, at: 0)
        articleTableView.insertRows(at: [[0,0]], with: .fade)
    }

//  Reload data when drag down
    @objc func reloadArticle() {
        self.articles.removeAll()
        articleTableView.reloadData()
        self.articlePresenter?.getArticles(page: 1)
        loader.endRefreshing()
    }

    // Register nib file to use in table cell
    func nibRegister() {
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        articleTableView.register(nib, forCellReuseIdentifier: "reusableCell")
    }

    //Add new article button tap
    @IBAction func addButtonTap(_ sender: Any) {
        self.performSegue(withIdentifier: "add", sender: self)
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath) as! CustomCell
        reusableCell.title.text = (!articles[indexPath.row].title.isEmpty) ?articles[indexPath.row].title : "No title"
        reusableCell.createDate.text = articles[indexPath.row].createdDate.toDate()
        reusableCell.authorName.text = randomAuthor[Int.random(in: 0...randomAuthor.count-1)]
        reusableCell.viewAmount.text = String(Int.random(in: 0...1000))
        reusableCell.likeAmount.text = String(Int.random(in: 0...1000))
        reusableCell.shareAmount.text = String(Int.random(in: 0...1000))
        reusableCell.thumbnail.kf.indicatorType = .activity
        reusableCell.thumbnail.kf.setImage(
            with: URL(string: articles[indexPath.row].imageUrl ?? ""),
            placeholder: UIImage(named: "no-image"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        return reusableCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastArticle = articles.count - 1
        if indexPath.row == lastArticle {
            articlePresenter!.getArticles(page: pagination + 1)
            pagination += 1
            articleTableView.insertRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        print(indexPath)
        let deleteAction = UIContextualAction(style: .destructive, title: "🗑" ) { (action, view, handler) in
            let id = self.articles[indexPath.row].id
            self.articlePresenter?.deleteArticle(id: id!)
            self.articles.remove(at: indexPath.row)
            handler(true)
        }
        deleteAction.image = UIImage(named: "trash")
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let updateAction = UIContextualAction(style: .normal, title: "") { (action, view, handler) in
            let passingArticle = self.articles[indexPath.row]
            passingArticle.index = indexPath
            UpdateArticleViewController.article = passingArticle
            self.performSegue(withIdentifier: "update", sender: self)
            handler(true)
        }
        updateAction.image = UIImage(named: "edit")
        updateAction.backgroundColor = .blue
        let configuration = UISwipeActionsConfiguration(actions: [updateAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ArticleDetailViewController.article = articles[indexPath.row]
        self.performSegue(withIdentifier: "detail", sender: self)

    }
}

extension ViewController : ArticlePresenterProtocol {
    func didUpdateArticle() {

    }

    func didInsertArticle() {

    }

    func didResponseArticles(articles : [Article]) {
        self.articles += articles
        KVLoading.hide()
        DispatchQueue.main.async {
            self.articleTableView.reloadData()
        }
    }
}
