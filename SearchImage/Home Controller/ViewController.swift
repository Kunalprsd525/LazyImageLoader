

import UIKit

class ViewController: UIViewController {

@IBOutlet weak var collectionView: UICollectionView!
var itemsPerRow: CGFloat = 3
let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
@IBOutlet weak var indicator: UIActivityIndicatorView!
@IBOutlet weak var searchField: UITextField!
let footerViewReuseIdentifier = "RefreshFooterView"
var footerView:CustomFooterView?
    
    lazy var viewModel: ViewControllerViewModel = {
        return ViewControllerViewModel()
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.initVM()
    }
    
    
    @IBAction func searchClick(_ sender: UIBarButtonItem) {
        searchField.resignFirstResponder()
        
        guard let searchText = searchField.text , searchText.count > 0 else {
            return
        }
        viewModel.searchTerm = searchText
        viewModel.paging = nil
        viewModel.loadMore = false
        viewModel.pageNumber = 1
        ImageDownloadManager.shared.cancelAll()
        viewModel.resetFlickerCollection()
        viewModel.initFetch()
        
    }
    
    
    func setupView(){
         collectionView?.register(UINib(nibName: "CustomFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerViewReuseIdentifier)
    }
    
    
    
    func initVM() {
        
        // Naive binding
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }
        
        
        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.indicator.startAnimating()
                }else {
                    self?.indicator.stopAnimating()
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
               self?.collectionView.dataSource = self
               self?.collectionView.delegate = self
               self?.collectionView.reloadData()
            }
        }
        
    }
    


}



//MARK:- Handle error
extension ViewController{
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
