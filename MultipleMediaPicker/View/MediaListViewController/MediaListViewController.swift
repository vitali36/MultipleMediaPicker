//
//  MediaListViewController.swift
//  MultipleMediaPicker
//
//  Created by Vitaliy Bulavkin on 23.09.2020.
//  Copyright © 2020 Vitaliy Bulavkin. All rights reserved.
//

import UIKit
import Photos
import AVKit

open class MediaListViewController: UIViewController {
    
    // MARK: Properties
    
    open lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        return collectionView
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
        flowLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .vertical
        
        return flowLayout
    }()
    
    private lazy var loadMediaView: LoadMediaView = {
        let mediaView: LoadMediaView = LoadMediaView.fromNib()
        mediaView.onTapped = {[weak self] in
            guard let `self` = self else { return }
            self.delegate?.downloadMedia(assets: self.selectedAssets)
        }
        return mediaView
    }()
    
    private let imageRequestOptions = PHImageRequestOptions()
    private let imageManager = PHCachingImageManager()
    
    private var selectedAssets: [PHAsset] = []
    private lazy var thumbnailSize: CGSize = {
        let itemWidth: CGFloat = (view.bounds.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (CGFloat(numberOfItemsInRow - 1))) / CGFloat(numberOfItemsInRow)
        
        return .init(width: itemWidth, height: itemWidth)
    }()
    private var previousPreheatRect = CGRect.zero
    
    open weak var delegate: MediaListViewControllerDelegate?
    
    open var assets: PHFetchResult<PHAsset>!
    open var numberOfItemsInRow: Int = 4
    open var mediaImageViewerType: MediaImageViewerType = .singleImage
    
    // MARK: Override
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
        imageRequestOptions.resizeMode = .none
        view.backgroundColor = .black

        setupLayout()
        setupCollectionView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCachedAssets()
    }
    
    // MARK: Private
    
    private func setupLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        loadMediaView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadMediaView)
        
        loadMediaView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loadMediaView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        loadMediaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        loadMediaView.heightAnchor.constraint(equalToConstant: 103).isActive = true
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: loadMediaView.topAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(MediaItemCell.self)
    }
    
    private func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    /// - Tag: UpdateAssets
    private func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The window you prepare ahead of time is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in assets.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in assets.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: imageRequestOptions)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: imageRequestOptions)
        // Store the computed rectangle for future comparison.
        previousPreheatRect = preheatRect
    }
    
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    private func playVideo(videoAsset: PHAsset) {
        guard (videoAsset.mediaType == .video) else {
            print("Not a valid video media type")
            return
        }
        let options = PHVideoRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .automatic
        
        PHCachingImageManager().requestPlayerItem(forVideo: videoAsset, options: options) { (playerItem, args) in
            DispatchQueue.main.async {
                let player = AVPlayer(playerItem: playerItem)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
        }
    }
}

extension MediaListViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaItemCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        let asset = assets[indexPath.row]
        
        cell.onSelected = {[weak self] in
            guard let `self` = self else { return }
            self.selectedAssets.contains(asset) ? self.selectedAssets.removeObject(asset) : self.selectedAssets.append(asset)
            self.collectionView.reloadItems(at: [indexPath])
            self.loadMediaView.setMedia(count: self.selectedAssets.count)
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
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if assets[indexPath.row].mediaType == .video {
            playVideo(videoAsset: assets[indexPath.row])
            return
        }
        let mediaImageViewerViewController = MediaImageViewerViewController()
        
        var assetsArray: [PHAsset] = []
        self.assets.enumerateObjects { (asset, _, _) in
            assetsArray.append(asset)
        }
        
        mediaImageViewerViewController.assets = mediaImageViewerType == .list ? assetsArray : [assetsArray[indexPath.row]]
        mediaImageViewerViewController.assetStartedIndex = indexPath.row
        mediaImageViewerViewController.mediaImageViewerType = mediaImageViewerType
        mediaImageViewerViewController.selectedAssets = selectedAssets
        mediaImageViewerViewController.delegate = self
        
        navigationController?.pushViewController(mediaImageViewerViewController, animated: true)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
}

extension MediaListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return thumbnailSize
    }
}

extension MediaListViewController: MediaImageViewerDelegate {
    public func selectImageAt(index: Int) {
        self.selectedAssets.append(assets[index])
        self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        self.loadMediaView.setMedia(count: self.selectedAssets.count)
    }
    
    public func deselectImageAt(index: Int) {
        self.selectedAssets.removeObject(assets[index])
        self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        self.loadMediaView.setMedia(count: self.selectedAssets.count)
    }
}
