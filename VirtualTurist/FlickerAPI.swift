//
//  FlickerAPI.swift
//  VirtualTurist
//
//  Created by apple on 21/11/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit

struct Result : Mappable {
    var images : [ImageFlicker]?
    
    init(json: NSDictionary) {
        images <- json.value(forKey: "photo")
    }
}
struct ImageFlicker : Mappable {
    var imagePath : String?
    
    init(json: NSDictionary) {
        imagePath <- json.value(forKey: "url_m")
    }
}
struct FlickerAPI {
    
    static func images(pin : Pin, callback : @escaping ([ImageFlicker]?) -> Void) {
        if let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(FlickerKeys.key)&per_page=10&extras=url_m&lat=\(pin.lat)&lon=\(pin.lng)&format=json&nojsoncallback=1") {
            let request = URLRequest(url: url)
            let session = URLSession.shared
            print(CUrl(session: session, request: request).cURLRepresentation())
            let task = session.dataTask(with: request) { data, response, error in
                guard error == nil, let data = data else { callback(nil) ; return }
                var json : NSDictionary? = nil
                json <<< data
                guard let jsonToParse = json?.object(forKey: "photos") as? NSDictionary, json?["error"] == nil else { callback(nil) ; return }
                let result = Result(json: jsonToParse)
                callback(result.images)
            }
            task.resume()
        } else {
            
        }

    }
    
    static func downloadImage(pin : Pin, path : String) {
        if let url = URL(string: path), let data = try? Data(contentsOf: url), let app = UIApplication.shared.delegate as? AppDelegate  {
            if !pin.isDeleted || !pin.isFault {
                let photo = Photo(context: app.stack.context)
                photo.pin = pin
                photo.data = data
                pin.addToPhotos(photo)
            }
        }
    }

}
