//
//  EmployeeModel.swift
//  visionGate
//
//  Created by Bahadır Enes Atay on 3.07.2019.
//  Copyright © 2019 Bahadır Enes Atay. All rights reserved.
//

import UIKit

struct EmployeeModel: Codable {
    
    var id: Int?
    var images: [ImageModel]?
    var name: String?
    var surname: String?
    var updateTimestamp: String?
    static var currentTrainingMode : Bool = false

    
    func downloadImages(completionHandler: @escaping ([UIImage]) -> Void) {
        var imageArray = [UIImage]()
        
        for imageItem in images ?? [] {
            getData(from: URL(string:imageItem.url!)!) { data, response, error in
                guard let data = data, error == nil, let image = UIImage(data: data) else { return }
                imageArray.append(image)
                
                guard self.images?.count == imageArray.count else { return }
            
                completionHandler(imageArray)
            }
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

struct ImageModel: Codable {
    var thumbnailUrl: String?
    var url: String?
}

struct createEmployee: Codable {
    var name: String = ""
    var surname: String = ""
    var personalImage : Array<ImageModel>
}

struct createImage: Codable {
    var url : String = ""
    var thumbnailUrl : String = ""
}

struct passedPersonal : Codable {
    var name: String?
    var surname: String?
    var date: String?
    var entrance: Bool?
    var id: Int?
    var image: String?
}

