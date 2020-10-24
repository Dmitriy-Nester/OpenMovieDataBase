//
//  ViewController.swift
//
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
{
    @IBOutlet private var textfield : UISearchBar!
    @IBOutlet private var collectioView : UICollectionView!
    private var lastSearch : Array<MovieModel>!
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        weak var that = self
        NetworkUtil.performSearch(value: searchBar.text ?? "nothing", handler: {
                                    (array, error) in
            if error == nil
            {
                that?.lastSearch = array
                that?.collectioView.reloadData()
            }
            else
            {
                that?.showError(result: error!)
            }
        })
    }
    
    private func showError(result : NSError)
    {
        let alert = UIAlertController(title: "Warning", message: result.description, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return lastSearch != nil ? lastSearch.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionCell", for: indexPath)
        (cell as? MovieCollectionCell)?.setModel(model: lastSearch[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cvsize = collectionView.frame.size
        return CGSize(width: cvsize.width - 20, height: (cvsize.height * 0.5) - 10)
    }
}

