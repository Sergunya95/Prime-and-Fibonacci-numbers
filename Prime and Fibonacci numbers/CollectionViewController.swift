//
//  ViewController.swift
//  Prime and Fibonacci numbers
//
//  Created by apple on 7/4/21.
//
import UIKit

final class CollectionViewController: UIViewController {
    
    // MARK: – IBOutlets
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var control: UISegmentedControl!
    
    // MARK: – Properties
    
    var itemsArray: [UInt64] = []
    var isLoading = false
    var loadingView: LoadingReusableView?
    
    // MARK: – Enums
    
    private enum Constants {
        static let cellHeight: CGFloat = 70
        static let footerHeight: CGFloat = 55
        static let sectionsInserts = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        static let itemsPerRow: CGFloat = 2
    }
    
    // MARK: – Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        loadData()
        
        control.backgroundColor = .purple
    }
    
    @IBAction func didChangeSrgment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loadData1()
            loadMoreData1()
        } else if sender.selectedSegmentIndex == 1 {
            loadData()
            loadMoreData()
    
        }
    }
    
    // MARK: – Private functions
    
    private func setupViews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            UINib(nibName: "CollectionViewItemCell", bundle: nil),
            forCellWithReuseIdentifier: "collectionviewitemcellid"
        )
        collectionView.register(
            UINib(nibName: "LoadingReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "loadingresuableviewid"
        )
    }
    
    private func loadData1() {
        
            isLoading = false
            collectionView.collectionViewLayout.invalidateLayout()
            
            let maxValue: Int = 40
            for i in 2..<maxValue  {
                itemsArray.append(UInt64(i))
            }
            
            collectionView.reloadData()
        }
        
        private func loadMoreData1() {
            guard !isLoading else { return }
            
            isLoading = true
            
            let start = itemsArray.count
            let end = start + 50
            
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                
                sleep(1)
                
                for i in start...end {
                    self.itemsArray.append(UInt64(i))
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.collectionView.reloadData()
                    self.isLoading = false
                }
            }
        }
    
    private func loadData() {
       
        var fiboNumberOne = 1
        var fiboNumberTwo = 0
        
        isLoading = false
        collectionView.collectionViewLayout.invalidateLayout()
        
        let maxValue: Int = 4
        for _ in 1..<maxValue  {
            
            let temp = fiboNumberOne + fiboNumberTwo
            fiboNumberOne = fiboNumberTwo
            fiboNumberTwo = temp
            itemsArray.append(UInt64(temp))
        }
        
        collectionView.reloadData()
    }
    
    private func loadMoreData() {
        guard !isLoading else { return }
        
        isLoading = true
      
        let start = itemsArray.count
        let end = start + 2
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            var fiboNumberOne = self.itemsArray.preLast()
            var fiboNumberTwo = self.itemsArray.last
            
           // while self.itemsArray.last! < Int64.max {
            for i in start...end {
                
                if i >= 92 {break} // вечная загрузка
                
                let temp = UInt64(fiboNumberOne!) + UInt64(fiboNumberTwo!)
                fiboNumberOne = fiboNumberTwo
                fiboNumberTwo = temp
                
                self.itemsArray.append(UInt64(temp))
            }
            //}
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.collectionView.reloadData()
                self.isLoading = false
            }
        }
   }
}

// MARK: – Collection view delegate, data sourse and flow layout functions

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let paddingWidth = Constants.sectionsInserts.left * (Constants.itemsPerRow + 1)
        let availabelWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availabelWidth / Constants.itemsPerRow
        
        return CGSize(width: widthPerItem, height: Constants.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let id = "collectionviewitemcellid"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! CollectionViewItemCell
         
        let lll = [1,2,5,6,9,10]
        
        cell.NumLabel.text = String(itemsArray[indexPath.row])
        
        if lll.contains(where: { $0 = indexPath.row }) {
            cell.backgroundColor = .gray
        } else { cell.backgroundColor = .white}
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row == itemsArray.count - 1 && !isLoading else { return }
        
        loadMoreData()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard !isLoading else { return .zero }
        
        return CGSize(width: collectionView.bounds.size.width, height: Constants.footerHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter else { return UICollectionReusableView() }
        
        let aFooterView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "loadingresuableviewid",
            for: indexPath
        ) as! LoadingReusableView
        
        loadingView = aFooterView
        loadingView?.backgroundColor = UIColor.clear
        
        return aFooterView
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard elementKind == UICollectionView.elementKindSectionFooter else { return }
        
        loadingView?.activityIndicator.startAnimating()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        forElementOfKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard elementKind == UICollectionView.elementKindSectionFooter else { return }
        
        loadingView?.activityIndicator.stopAnimating()
    }
}

extension Array {
  func preLast() -> Element? {
      if self.count < 2 {
          return nil
      }
      let index = self.count - 2
      return self[index]
  }
}
