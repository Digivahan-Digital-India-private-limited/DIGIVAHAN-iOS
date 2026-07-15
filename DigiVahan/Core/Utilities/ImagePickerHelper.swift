//
//  ImagePickerHelper.swift
//  DigiVahan
//
//  Created by Mr Ash on 07/06/26.
//

import UIKit
import PhotosUI

class ImagePickerHelper: NSObject {

    static let shared = ImagePickerHelper()

    private var completion: ((UIImage?) -> Void)?
    private weak var viewController: UIViewController?

    func showImagePicker(
        from vc: UIViewController,
        completion: @escaping (UIImage?) -> Void
    ) {

        self.viewController = vc
        self.completion = completion

        let alert = UIAlertController(
            title: "Select Image",
            message: "Please select or capture an image to upload at your profile.",
            preferredStyle: .actionSheet
        )

        // Camera
        alert.addAction(UIAlertAction(title: "📷 Take Photo", style: .default) { _ in
            self.openCamera()
        })

        // Gallery
        alert.addAction(UIAlertAction(title: "🖼 Choose from Photos", style: .default) { _ in
            self.openGallery()
        })

        // Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = vc.view
            popover.sourceRect = CGRect(
                x: vc.view.bounds.midX,
                y: vc.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        vc.present(alert, animated: true)
    }

    private func openCamera() {

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self

        viewController?.present(picker, animated: true)
    }

    private func openGallery() {

        if #available(iOS 14, *) {

            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .images

            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self

            viewController?.present(picker, animated: true)

        } else {

            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self

            viewController?.present(picker, animated: true)
        }
    }
    
    
    func openCameraDirectly(
        from vc: UIViewController,
        completion: @escaping (UIImage?) -> Void
    ) {

        self.viewController = vc
        self.completion = completion

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            completion(nil)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.cameraCaptureMode = .photo

        vc.present(picker, animated: true)
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension ImagePickerHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true)

        let image = info[.originalImage] as? UIImage
        completion?(image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        picker.dismiss(animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

@available(iOS 14, *)
extension ImagePickerHelper: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        guard let item = results.first?.itemProvider else {
            completion?(nil)
            return
        }

        if item.canLoadObject(ofClass: UIImage.self) {

            item.loadObject(ofClass: UIImage.self) { image, error in

                DispatchQueue.main.async {
                    self.completion?(image as? UIImage)
                }
            }
        }
    }
}   
