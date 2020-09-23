//
//  ViewController.swift
//  MultipleMediaPickerExamples
//
//  Created by Vitaliy on 22.09.2020.
//

import UIKit
import MultipleMediaPicker
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showPickerAction(_ sender: Any) {
        let mediaPickerViewController = MediaPickerViewController()
        mediaPickerViewController.delegate = self
        mediaPickerViewController.mediaImageViewerType = .singleImage
        mediaPickerViewController.assetCollectionsType = .smartAlbum
        mediaPickerViewController.assetCollectionsSubtype = .albumRegular
        
        let navigationController = UINavigationController(rootViewController: mediaPickerViewController)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = .black
        navigationController.navigationBar.tintColor = .white
        navigationController.modalPresentationStyle = .overFullScreen
        
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
}

extension ViewController: MediaPickerViewControllerDelegate {
    func didSelectMedia(items: [PHAsset]) {
        print("selected media: \(items.count)")
    }
}

