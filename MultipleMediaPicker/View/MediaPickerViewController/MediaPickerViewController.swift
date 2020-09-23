//
//  MediaPickerController.swift
//  MultipleMediaPicker
//
//  Created by Vitaliy Bulavkin on 23.09.2020.
//  Copyright © 2020 Vitaliy Bulavkin. All rights reserved.
//

import UIKit
import Photos

open class MediaPickerViewController: UIViewController {
    
    // MARK: Properties

    open lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(MediaPickerCell.self)
        
        return collectionView
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = self.minimumLineSpacing
        flowLayout.minimumInteritemSpacing = self.minimumInteritemSpacing
        flowLayout.scrollDirection = .vertical
        
        return flowLayout
    }()
    
    private lazy var closeButton: UIButton = {
        let closeButton = UIButton()
        let bundle = Bundle(for: type(of: self))
        let closeImage = UIImage(named: "close", in: bundle, with: nil)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        return closeButton
    }()
    
    private let imageManager = PHCachingImageManager()
    private let imageRequestOptions = PHImageRequestOptions()
    
    public var assetCollectionsType: PHAssetCollectionType = .smartAlbum
    public var assetCollectionsSubtype: PHAssetCollectionSubtype = .albumRegular
    public var mediaImageViewerType: MediaImageViewerType = .singleImage

    public var sectionInset: UIEdgeInsets = .init(top: 0, left: 44, bottom: 0, right: 28)
    public var minimumInteritemSpacing: CGFloat = 22
    public var minimumLineSpacing: CGFloat = 22
    
    public var itemMaxWidth: CGFloat = 160
    public var itemMaxHeight: CGFloat = 231
    public var numberOfItemsInRow: Int = 2
    
    private var assetCollection: [PHAssetCollection] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public weak var delegate: MediaPickerViewControllerDelegate?
    
    // MARK: Dependencies
    
    public let mediaService = AssetsMediaPickerService()
    
    // MARK: Override
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        imageRequestOptions.resizeMode = .none
        
        setupNavigationBar()
        setupLayout()
        getAssetCollections()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isModal {
            navigationController?.navigationBar.isHidden = true
            return
        }
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: Private
    
    private func setupNavigationBar() {
        if isModal {
            navigationController?.navigationBar.isHidden = true
            setupCloseButtonLayout()
        } else {
            navigationController?.navigationBar.isHidden = false
        }
    }
    
    private func setupCloseButtonLayout() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        closeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
    }
    
    private func getAssetCollections() {
        PHPhotoLibrary.requestAuthorization{[weak self] status in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                switch status {
                case .authorized:
                    let assetCollectionFetchResult = self.mediaService.fetchAssetCollections(with: self.assetCollectionsType, subtype: .albumRegular)
                    assetCollectionFetchResult.enumerateObjects { (collection, _, _) in
                        let assets = PHAsset.fetchAssets(in: collection, options: nil)
                        if assets.count != 0 {
                            self.assetCollection.append(collection)
                        }
                    }
                case .denied, .restricted, .limited, .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    open func setupLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
         if !isModal {
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
         } else {
            collectionView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20).isActive = true
         }
    }
    
    @objc
    private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MediaPickerViewController: UICollectionViewDataSource {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCollection.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaPickerCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        let collection = assetCollection[indexPath.row]
        let asset = PHAsset.fetchAssets(in: collection, options: nil).lastObject
        
        if let asset = asset {
            cell.representedAssetIdentifier = asset.localIdentifier
            imageManager.requestImage(for: asset, targetSize: cell.photoImageView.bounds.size, contentMode: .aspectFill, options: imageRequestOptions, resultHandler: { image, _ in
                // UIKit may have recycled this cell by the handler's activation time.
                // Set the cell's thumbnail image only if it's still showing the same asset.
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    DispatchQueue.main.async {
                        cell.thumbnailImage = image
                    }
                }
            })
            imageManager.startCachingImages(for: [asset],
                                            targetSize: cell.photoImageView.bounds.size, contentMode: .aspectFill, options: imageRequestOptions)
            imageManager.stopCachingImages(for: [asset],
                                           targetSize: cell.photoImageView.bounds.size, contentMode: .aspectFill, options: imageRequestOptions)
        }
        
        cell.configure(with: collection)
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat = (view.bounds.width - sectionInset.left - sectionInset.right - minimumInteritemSpacing * (CGFloat(numberOfItemsInRow - 1))) / CGFloat(numberOfItemsInRow)
        let itemHeight: CGFloat = itemWidth * (itemMaxHeight / itemMaxWidth)
        
        return .init(width: itemWidth, height: itemHeight)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collection = assetCollection[indexPath.row]
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        
        let mediaListVC = MediaListViewController()
        mediaListVC.delegate = self
        mediaListVC.assets = assets
        mediaListVC.mediaImageViewerType = mediaImageViewerType
        
        navigationController?.pushViewController(mediaListVC, animated: true)
    }
}

extension MediaPickerViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
    }
}

extension MediaPickerViewController: MediaListViewControllerDelegate {
    open func downloadMedia(assets: [PHAsset]) {
        delegate?.didSelectMedia(items: assets)
        if isModal {
            self.dismiss(animated: true, completion: nil)
            return
        }
        if let viewControllers = self.navigationController?.viewControllers {
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }
}
