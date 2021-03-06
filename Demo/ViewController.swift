//
//  ViewController.swift
//  Demo
//
//  Created by K.Kawakami on 2018/01/20.
//  Copyright © 2018年 Kentaro Kawakami. All rights reserved.
//

import UIKit
import KKImageViewer

final class HeaderView: UIView {
    
    private lazy var button: UIButton = self.createUIButton()
    var tapped: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        
        addSubview(button)
    }
    
    override func updateConstraints() {
        
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUIButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: .normal)
        button.addTarget(self,
                         action: #selector(buttonTapped),
                         for: .touchUpInside)
        return button
    }
    
    @objc
    func buttonTapped() {
        tapped?()
    }
}

extension UIImageView: DisplaceableView { }

class ViewController: UIViewController {
    
    private let items = [#imageLiteral(resourceName: "cat_1"), #imageLiteral(resourceName: "cat_2"), #imageLiteral(resourceName: "cat_3"), #imageLiteral(resourceName: "cat_4")]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let headerView = HeaderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell else {
            fatalError()
        }
        
        cell.image.image = items[indexPath.row]
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var option = ImageViewerOption()
        option.doubleTapZoomScale = 3.5
        option.displacementTransitionStyle = .springBounce(0.3)
        option.overlayBlurOpacity = 0.0
        
        let imageViewer = ImageViewerController(
            startIndex: indexPath.row,
            itemDataSource: self,
            displacedViewsDataSource: self,
            option: option
        )
        
        imageViewer.headerView = headerView
        imageViewer.headerViewHeight = 50
        
        headerView.tapped = {
            imageViewer.close(completion: nil)
        }
        present(imageViewer, animated: false, completion: nil)
    }
}

extension ViewController: ImageViewerDataSource {
    func numberOfItems() -> Int {
        return items.count
    }
    
    func providedImageViewerItem(at index: Int) -> ImageViewerItem {
        return ImageViewerItem.image { block in
            block(self.items[index])
        }
    }
}

extension ViewController: DisplacedViewsDataSource {
    func provideDisplacementItem(at index: Int) -> DisplaceableView? {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? CollectionViewCell else {
            return nil
        }
        return cell.image
    }
}
