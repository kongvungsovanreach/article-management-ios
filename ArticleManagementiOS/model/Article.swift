//
//  Article.swift
//  ArticleManagementiOS
//
//  Created by Kong Vungsovanreach on 12/16/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import UIKit
import ObjectMapper
class Article : Mappable {
    var id : Int!
    var title : String!
    var createdDate : String!
    var imageUrl : String!
    var description : String!

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.id <- map["ID"]
        self.title <- map["TITLE"]
        self.createdDate <- map["CREATED_DATE"]
        self.imageUrl <- map["IMAGE"]
        self.description <- map["DESCRIPTION"]
    }


//    init(title : String, createdDate : String, imageUrl : String) {
//        self.title = title
//        self.createdDate = createdDate
//        self.imageUrl = imageUrl
//    }
}
