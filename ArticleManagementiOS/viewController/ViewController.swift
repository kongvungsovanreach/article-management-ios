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
    var articles = [Article]()
    var pagination = 1
    let loader = UIRefreshControl()
    let randomAuthor = ["Charlie","Justini","Shawnie","Mileyes","Passeng","Maroon5"]
    @IBOutlet weak var articleTableView: UITableView!
    let headers = ["Authorization" : "Basic QU1TQVBJQURNSU46QU1TQVBJUEBTU1dPUkQ="]


    override func viewDidLoad() {
        super.viewDidLoad()
        getArticles(page : pagination)
        articleTableView.dataSource = self
        articleTableView.delegate = self
        articleTableView.refreshControl = loader
        loader.addTarget(self, action: #selector(reloadArticle), for: .valueChanged)
        nibRegister()
    }

    //Reload data when drag down
    @objc func reloadArticle() {
        articles.removeAll()
        pagination = 1
        getArticles(page: pagination)
        articleTableView.reloadData()
        loader.endRefreshing()
    }

    // Fetch the article from API
    func getArticles(page : Int){
        let url = "http://ams.chhaileng.com/v1/api/articles?page=\(page)&limit=15"
            Alamofire.request(url, method: .get, parameters: nil, headers: headers ).responseJSON { ( response) in
                    if response.result.isSuccess{
                        var json = response.result.value as? [String:Any]
                        let jsonData = json?["DATA"] as! NSArray
                        if jsonData.count == 0 {
                            return
                        }
                        for data in jsonData{
                            self.articles.append(Article(JSON: (data as? [String:Any])!)!)
                        }

                        DispatchQueue.main.async{
                            self.articleTableView.reloadData()
                        }
                    }else{
                        print("........")
                    }
                }
    }

    // Register nib file to use in table cell
    func nibRegister() {
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        articleTableView.register(nib, forCellReuseIdentifier: "reusableCell")
    }

    //Delete article from API, table, array
    func deleteArticle(id : Int) {
        let url = "http://ams.chhaileng.com/v1/api/articles/\(id)"
        Alamofire.request(url, method: .delete, parameters: nil, headers: headers )
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
            getArticles(page: pagination + 1)
            pagination += 1
            articleTableView.insertRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: "🗑" ) { (action, view, handler) in
            let id = self.articles[indexPath.row].id
            self.deleteArticle(id: id!)
            self.articles.remove(at: indexPath.row)
            handler(true)
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let updateAction = UIContextualAction(style: .normal, title: "✏️") { (action, view, handler) in
            UpdateArticleViewController.article = self.articles[indexPath.row]
            self.performSegue(withIdentifier: "update", sender: self)
            handler(true)
        }
        updateAction.backgroundColor = .green
        let configuration = UISwipeActionsConfiguration(actions: [updateAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ArticleDetailViewController.article = articles[indexPath.row]
        self.performSegue(withIdentifier: "detail", sender: self)

    }
}
