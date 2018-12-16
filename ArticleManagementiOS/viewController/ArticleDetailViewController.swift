//
//  ArticleDetailViewController.swift
//  ArticleManagementiOS
//
//  Created by Kong Vungsovanreach on 12/16/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import UIKit

class ArticleDetailViewController: UIViewController {
    static var article : Article!

    @IBOutlet weak var descriptionLabel: UILabel!
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

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
