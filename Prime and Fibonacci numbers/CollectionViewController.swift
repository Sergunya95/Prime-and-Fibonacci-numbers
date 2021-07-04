//
//  ViewController.swift
//  Prime and Fibonacci numbers
//
//  Created by apple on 7/4/21.
//

import UIKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var itemsArray = [1]
    let itemsPerRow: CGFloat = 2
    let sectionsInserts = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    var isLoading = false
    var loadingView: LoadingReusableView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        //Register Item Cell
        let itemCellNib = UINib(nibName: "CollectionViewItemCell", bundle: nil)
        self.collectionView.register(itemCellNib, forCellWithReuseIdentifier: "collectionviewitemcellid")

        //Register Loading Reuseable View
        let loadingReusableNib = UINib(nibName: "LoadingReusableView", bundle: nil)
        collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loadingresuableviewid")

        loadData()

}

func loadData() {
    isLoading = false
    collectionView.collectionViewLayout.invalidateLayout()
    let maxValue: Int = 40
    for i in 2..<maxValue  {
        itemsArray.append(i)
    }
    self.collectionView.reloadData()
}
}

    extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            let paddingWidth = sectionsInserts.left * (itemsPerRow + 1)
            let availabelWidth = collectionView.frame.width - paddingWidth
            let widthPerItem = availabelWidth / itemsPerRow
            return CGSize(width: widthPerItem, height: 50)
        }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionviewitemcellid", for: indexPath) as! CollectionViewItemCell
        cell.NumLabel.text = String(self.itemsArray[indexPath.row])
       // if {} если число из массива четное, то бэкгроунд серый, else белый
        cell.backgroundColor = .gray
        
        return cell
    }
    
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if indexPath.row == itemsArray.count - 16 && !self.isLoading {
                loadMoreData()
            }
        }

        func loadMoreData() {
            if !self.isLoading {
                self.isLoading = true
                let start = itemsArray.count
                let end = start + 50
                DispatchQueue.global().async {
                    // fake background loading task
                    sleep(1)
                    for i in start...end {
                        self.itemsArray.append(i)
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.isLoading = false
                    }
                }
            }
        }

        
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
            if self.isLoading {
                return CGSize.zero
            } else {
                return CGSize(width: collectionView.bounds.size.width, height: 55)
            }
        }

        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionFooter {
                let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "loadingresuableviewid", for: indexPath) as! LoadingReusableView
                loadingView = aFooterView
                loadingView?.backgroundColor = UIColor.clear
                return aFooterView
            }
            return UICollectionReusableView()
        }

        func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
            if elementKind == UICollectionView.elementKindSectionFooter {
                self.loadingView?.activityIndicator.startAnimating()
            }
        }

        func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
            if elementKind == UICollectionView.elementKindSectionFooter {
                self.loadingView?.activityIndicator.stopAnimating()
            }
        }

    }
