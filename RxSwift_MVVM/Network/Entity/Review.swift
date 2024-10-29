//
//  Review.swift
//  RxSwift_MVVM
//
//  Created by siyeon park on 10/17/24.
//

import Foundation

struct ReviewListModel: Decodable {
    let page: Int
    let results: [ReviewModel]
}

struct ReviewModel: Decodable, Hashable {
    let id: String
    let author: Reviewer
    let createdDate: Date?
    let content: String

    private enum CodingKeys: String, CodingKey {
        case id
        case author = "author_detail"
        case created_date = "created_at"
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.author = try container.decode(Reviewer.self, forKey: .author)
        self.content = try container.decode(String.self, forKey: .content)
        
        let dateString = try container.decode(String.self, forKey: .created_date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        createdDate = dateFormatter.date(from: dateString)
    }
}

struct Reviewer: Decodable, Hashable {
    let name: String
    let username: String
    let rating: Int
    let imageUrl: String
    
    private enum CodingKeys: String, CodingKey {
        case name
        case username
        case rating
        case imageUrl = "avatar_path"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        rating = try container.decode(Int.self, forKey: .rating)
        //decodeIfPresent 옵셔널하게 받아와서 if let 처리 필요
//        if let path = try container.decodeIfPresent(String.self, forKey: .imageUrl) {
//            self.imageUrl = "https://image.tmdb.org/t/p/w500\(path)"
//        } else {
//            self.imageUrl = ""
//
//        }
        

        let path = try container.decode(String.self, forKey: .imageUrl)
        self.imageUrl = "https://image.tmdb.org/t/p/w500\(path)"
    }
}
