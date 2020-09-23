//
//  MediaImageViewerViewController.swift
//  MultipleMediaPicker
//
//  Created by Vitaliy Bulavkin on 23.09.2020.
//  Copyright © 2020 Vitaliy Bulavkin. All rights reserved.
//

import UIKit
import Photos

open class MediaImageViewerViewController: UIViewController {
    
    // MARK: Properties

    open lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        return collectionView
    }()
    
    private lazy var flowLayout: CenterCarouselLayout = {
        let flowLayout = CenterCarouselLayout()
        flowLayout.itemSize = thumbnailSize
        
        return flowLayout
    }()
    
    private let imageManager = PHCachingImageManager()
    private let imageRequestOptions = PHImageRequestOptions()
    
    private lazy var thumbnailSize: CGSize = {
        switch self.mediaImageViewerType {
        case .list:
            return .init(width: view.bounds.width * 0.8, height: view.bounds.height * 0.8)
        case .singleImage:
            return .init(width: view.bounds.width, height: view.bounds.height * 0.8)
        }
    }()
    
    private var previousPreheatRect: CGRect = .zero
    private var alreadyCachedRects: [CGFloat] = []
    private var lastMidX: CGFloat = 0

    var assets: [PHAsset] = []
    var selectedAssets: [PHAsset] = []

    var assetStartedIndex: Int = 0
    var mediaImageViewerType: MediaImageViewerType = .singleImage
    
    weak var delegate: MediaImageViewerDelegate?
    
    // MARK: Override
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        lastMidX = view.bounds.width / 2
        view.backgroundColor = .black
        imageRequestOptions.resizeMode = .none
        imageManager.stopCachingImagesForAllAssets()
        setupCollectionLayout()
        setupCollectionView()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCachedAssets()
        
        if self.mediaImageViewerType == .list {
            collectionView.scrollToItem(at: IndexPath(item: assetStartedIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Private
    
    private func setupCollectionLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MediaImageCell.self)
    }
    
    private func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        let nextAssetMidX = lastMidX + view.bounds.width
        if (collectionView.contentOffset.x >= nextAssetMidX / 2 && !self.alreadyCachedRects.contains(nextAssetMidX)) || self.alreadyCachedRects.isEmpty {
            let sortedIndexPaths = collectionView.indexPathsForVisibleItems.sorted()
            if let lastIndexPath = sortedIndexPaths.last {
                let addedAssets = assets[lastIndexPath.row]
                if self.alreadyCachedRects.isEmpty {
                    self.alreadyCachedRects.append(lastMidX)
                    if let firstIndexPath = sortedIndexPaths.first {
                        let firstAsset = assets[firstIndexPath.row]
                        imageManager.startCachingImages(for: [firstAsset],
                                                        targetSize: thumbnailSize,
                                                        contentMode: .aspectFill,
                                                        options: imageRequestOptions)
                        imageManager.stopCachingImages(for: [firstAsset],
                                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: imageRequestOptions)
                    }
                    imageManager.startCachingImages(for: [addedAssets],
                                                    targetSize: thumbnailSize,
                                                    contentMode: .aspectFill,
                                                    options: imageRequestOptions)
                } else {
                    self.alreadyCachedRects.append(nextAssetMidX)
                    let asset = assets[lastIndexPath.row]
                    let previousAsset = assets[lastIndexPath.row - 1]
                    imageManager.startCachingImages(for: [asset],
                                                    targetSize: thumbnailSize,
                                                    contentMode: .aspectFill,
                                                    options: imageRequestOptions)
                    imageManager.stopCachingImages(for: [previousAsset],
                                                    targetSize: thumbnailSize,
                                                    contentMode: .aspectFill,
                                                    options: imageRequestOptions)
                    lastMidX = nextAssetMidX
                }
            }
        }
    }
}

extension MediaImageViewerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaImageCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        let asset = assets[indexPath.row]
        
        cell.onSelected = {[weak self] in
            guard let `self` = self else { return }
            let isSelected: Bool = self.selectedAssets.contains(asset)
            !isSelected ? self.selectedAssets.append(asset) : self.selectedAssets.removeObject(asset)
            
            self.collectionView.reloadItems(at: [indexPath])
            
            !isSelected ? self.delegate?.selectImageAt(index: self.mediaImageViewerType == .list ? indexPath.row : self.assetStartedIndex) : self.delegate?.deselectImageAt(index: self.mediaImageViewerType == .list ? indexPath.row : self.assetStartedIndex)
        }
        
        selectedAssets.contains(asset) ? cell.setSelectedPhotoButton() : cell.setDeselectedPhotoButton()
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: imageRequestOptions, resultHandler: { image, _ in
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                DispatchQueue.main.async {
                    cell.thumbnailImage = image
                }
            }
        })
        
        return cell
    }
}
  
