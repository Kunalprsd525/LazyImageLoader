

import Foundation




class ViewControllerViewModel {
    
    var showAlertClosure: (()->())?
    var reloadTableViewClosure: (()->())?
    let apiService: APIServiceProtocol
    var updateLoadingStatus: (()->())?
    var searchTerm:String = ""
    var paging:Paging?
    var pageNumber = 1
    var loadMore:Bool = false
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    init( apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    var alertMessage: String? {
           didSet {
               self.showAlertClosure?()
           }
    }
       
    fileprivate var flickrPhotos = [FlickrPhoto](){
        didSet{
            self.reloadTableViewClosure?()
        }
        
    }
    
    
    
    
    func initFetch() {
        if pageNumber == 1{
            self.isLoading = true
        }
        apiService.fetchServerResponse(searchText: searchTerm, page: pageNumber) { [weak self] (success, data, paging, error) in
            self?.isLoading = false
            switch success{
            case true:
                self?.flickrPhotos = (self?.flickrPhotos ?? []) + (data ?? [])
                self?.paging = paging
                self?.loadMore = true
            case false:
                self?.alertMessage = error?.rawValue
                
            }
        }
    }
    
    
    func photoForIndexPath(indexPath: IndexPath) -> FlickrPhoto {
        return flickrPhotos[(indexPath as NSIndexPath).row]
    }
    
    func getNoOfRows() -> Int{
        return self.flickrPhotos.count
    }
    
    func resetFlickerCollection(){
        self.flickrPhotos.removeAll()
    }
    
}

