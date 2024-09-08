//
//  PhotoLibraryPickerProtocol.swift
//  MySwiftSpeedUpTools
//
//  Created by Elankumaran Tharsan on 22/07/2021.
//

import PhotosUI
import MobileCoreServices
import UIKit

@available(iOS 14, *)
/// This protocol for iOS 14 and more
protocol PhotoLibraryPickerProtocol: PHPickerViewControllerDelegate {
    var libraryPickerSelectionLimit: Int { get }
    
    func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void)
    func showPhotoPicker(viewController: UIViewController, status: PHAuthorizationStatus)
    func requestAndShowPhotoPicker(viewController: UIViewController)
    func didFinishSelectImagesPicker(_ images: [UIImage])
}

@available(iOS 14, *)
extension PhotoLibraryPickerProtocol {
    
    func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                handler(status)
            }
        }
    }
    
    /// If you called this method Dispatch in main queue
    func showPhotoPicker(viewController: UIViewController, status: PHAuthorizationStatus) {
        switch status {
        case .authorized, .limited:
            var config = PHPickerConfiguration()
            config.selectionLimit = self.libraryPickerSelectionLimit
            config.filter = PHPickerFilter.images

            let pickerViewController = PHPickerViewController(configuration: config)
            pickerViewController.delegate = self
            viewController.present(pickerViewController, animated: true, completion: nil)
        case .denied:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }
    
    func requestAndShowPhotoPicker(viewController: UIViewController) {
        requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.showPhotoPicker(viewController: viewController, status: status)
            }
        }
    }
}

@available(iOS 14, *)
extension PhotoLibraryPickerProtocol {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        // SOURCE : https://christianselig.com/2020/09/phpickerviewcontroller-efficiently/
        let dispatchQueue = DispatchQueue(label: "fr.geev.app.AlbumImageQueue")
        var selectedImageDatas = [Data?](repeating: nil, count: results.count)
        var totalConversionsCompleted = 0

        for (index, result) in results.enumerated() {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, error) in
                guard let url = url else {
                    dispatchQueue.sync { totalConversionsCompleted += 1 }
                    return
                }
                
                let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
                
                guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
                    dispatchQueue.sync { totalConversionsCompleted += 1 }
                    return
                }
                
                let downsampleOptions = [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceThumbnailMaxPixelSize: 2_000,
                ] as CFDictionary

                guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else {
                    dispatchQueue.sync { totalConversionsCompleted += 1 }
                    return
                }

                let data = NSMutableData()
                
                guard let imageDestination = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil) else {
                    dispatchQueue.sync { totalConversionsCompleted += 1 }
                    return
                }
                
                // Don't compress PNGs
                let isPNG: Bool = {
                    guard let utType = cgImage.utType else { return false }
                    return (utType as String) == UTType.png.identifier
                }()

                let destinationProperties = [
                    kCGImageDestinationLossyCompressionQuality: isPNG ? 1.0 : 0.75
                ] as CFDictionary

                CGImageDestinationAddImage(imageDestination, cgImage, destinationProperties)
                CGImageDestinationFinalize(imageDestination)
                
                dispatchQueue.sync {
                    selectedImageDatas[index] = data as Data
                    totalConversionsCompleted += 1
                    
                    // if is last
                    if totalConversionsCompleted == selectedImageDatas.count {
                        DispatchQueue.main.async {
                            self.didFinishSelectImagesPicker(selectedImageDatas
                                                                .compactMap { $0 }
                                                                .compactMap { UIImage(data: $0)})
                        }
                    }
                }
            }
        }
    }
    
}
