//
//  PropertyClosureViewController.swift
//  TSClosureLeakTestSample
//
//  Created by TAE SU LEE on 8/26/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit

class PropertyClosureViewController: UIViewController {
    private lazy var testWithWeakSelfButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Test Global Closure [weak self]", for: .normal)
        button.addTarget(self, action: #selector(testWithWeakSelf), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var testWithStrongSelfButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Test Global Closure [strong self]", for: .normal)
        button.addTarget(self, action: #selector(testWithStrongSelf), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var testWithUnownedSelfButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Test Global Closure [unowned self]", for: .normal)
        button.addTarget(self, action: #selector(testWithUnownedSelf), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var weakCompletionHandler: (() -> Void)?
    private var strongCompletionHandler: (() -> Void)?
    private var unownedCompletionHandler: (() -> Void)?
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    @objc func testWithWeakSelf() {
        print("Testing Global Closure with [weak self]")
        weakCompletionHandler = { [weak self] in
            self?.printMessage("Global Closure [weak self]")
        }
        dismiss(animated: true) {
            self.weakCompletionHandler?()
        }
    }
    
    @objc func testWithStrongSelf() {
        print("Testing Global Closure with strong self")
        dismiss(animated: true)
        strongCompletionHandler = {
            self.printMessage("Global Closure [strong self]")
        }
        dismiss(animated: true) {
            self.strongCompletionHandler?()
        }
    }
    
    @objc func testWithUnownedSelf() {
        print("Testing Global Closure with [unowned self]")
        unownedCompletionHandler = { [unowned self] in
            self.printMessage("Global Closure [unowned self]")
        }
        dismiss(animated: true) {
            self.unownedCompletionHandler?()
        }
    }
    
    private func printMessage(_ context: String) {
        print("Closure executed (\(context)), self still exists")
    }
}

// MARK: - Setup
private extension PropertyClosureViewController {
    func setupViews() {
        title = "Property Closure"
        view.backgroundColor = .systemBackground
        view.addSubview(testWithWeakSelfButton)
        view.addSubview(testWithStrongSelfButton)
        view.addSubview(testWithUnownedSelfButton)
        addCloseButton()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            testWithWeakSelfButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testWithWeakSelfButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            testWithStrongSelfButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testWithStrongSelfButton.topAnchor.constraint(equalTo: testWithWeakSelfButton.bottomAnchor, constant: 20),
            
            testWithUnownedSelfButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testWithUnownedSelfButton.topAnchor.constraint(equalTo: testWithStrongSelfButton.bottomAnchor, constant: 20),
        ])
    }
}
