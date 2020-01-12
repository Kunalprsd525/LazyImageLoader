//
//  APIService.swift
//  MVVMPlayground
//
//  Created by Neo on 01/10/2017.
//  Copyright © 2017 ST.Huang. All rights reserved.
//

import Foundation

enum APIError: String, Error {
    case noServer = "Server Not Found"
    case unoknAPIResponse = "Unknown API response"
    case parseerror = "Parse error"
}
let apiKey = "de24642a8668fb0318ec5b9cecfda18c"



protocol APIServiceProtocol {
    func fetchServerResponse(searchText:String,page:Int, complete: @escaping ( _ success: Bool, _ data: [FlickrPhoto]?,_ paging: Paging?, _ error: APIError? )-> Void)
}

class APIService: APIServiceProtocol {
    
    func fetchServerResponse(searchText:String,page: Int = 1, complete: @escaping ( _ success: Bool, _ data: [FlickrPhoto]?,_ paging: Paging?, _ error: APIError? )->() ) {
           
        guard let searchURL = flickrSearchURLForSearchTerm(searchText,page: page) else {
                      
            complete(false,nil,nil,APIError.unoknAPIResponse)
                return
        }
                  
        let searchRequest = URLRequest(url: searchURL)
        
        
        URLSession.shared.dataTask(with: searchRequest, completionHandler: { (data, response, error) in
            
            if let _ = error {
                OperationQueue.main.addOperation({
                    complete(false,nil,nil,APIError.unoknAPIResponse)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    OperationQueue.main.addOperation({
                        complete(false,nil,nil,APIError.unoknAPIResponse)
                    })
                    return
            }
            
            do {
                
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                    let stat = resultsDictionary["stat"] as? String else {
                        OperationQueue.main.addOperation({
                            complete(false,nil,nil,APIError.unoknAPIResponse)
                        })
                        return
                }
                
                switch (stat) {
                case "ok":
                    print("Results processed OK")
                case "fail":
        
                    OperationQueue.main.addOperation({
                        complete(false,nil,nil,APIError.noServer)
                    })
                    
                    return
                default:
                    OperationQueue.main.addOperation({
                        complete(false,nil,nil,APIError.unoknAPIResponse)
                    })
                    return
                }
                guard let photosContainer = resultsDictionary["photos"] as? [String: AnyObject], let photosReceived = photosContainer["photo"] as? [[String: AnyObject]] else {
                    OperationQueue.main.addOperation({
                        complete(false,nil,nil,APIError.unoknAPIResponse)
                    })
                    return
                }
                var paging : Paging?
                var flickrPhotos = [FlickrPhoto]()
                
                for photoObject in photosReceived {
                    guard let photoID = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String else {
                            break
                    }
                    let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret)
                    flickrPhotos.append(flickrPhoto)
                    
                }
                
                if let currentPage = photosContainer["page"] as? Int,
                    let totalPages = photosContainer["pages"] as? Int ,
                    let numberOfElements = photosContainer["total"] as? String {
                    paging = Paging(totalPages: totalPages, elements: Int32(numberOfElements)!, currentPage: currentPage)
                }
                
                OperationQueue.main.addOperation({
                    complete(true,flickrPhotos,paging,nil)
                })
                
            } catch _ {
                complete(false, nil,nil,APIError.parseerror)
                return
            }
            
            
        }) .resume()

        
        
        
        
        
        
        
        
        
        
        
        
        
        
    
    }
    
    
    fileprivate func flickrSearchURLForSearchTerm(_ searchTerm:String, page: Int = 1) -> URL? {
        
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=20&format=json&nojsoncallback=1&page=\(page)"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
    
    
}






