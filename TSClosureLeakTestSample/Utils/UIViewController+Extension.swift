//
//  UIViewController+Extension.swift
//  TSClosureLeakTestSample
//
//  Created by TAE SU LEE on 8/26/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit

extension UIViewController {
    func addCloseButton() {
        let closeButtonImage = UIImage(systemName: "xmark")
        let closeButton = UIBarButtonItem(image: closeButtonImage, style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
