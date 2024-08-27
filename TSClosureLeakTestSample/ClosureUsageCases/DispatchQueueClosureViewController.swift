//
//  DispatchQueueClosureViewController.swift
//  TSClosureLeakTestSample
//
//  Created by TAE SU LEE on 8/26/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit

class DispatchQueueClosureViewController: UIViewController {
    private lazy var testWithWeakSelfButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Test DispatchQueue [weak self]", for: .normal)
        button.addTarget(self, action: #selector(testWithWeakSelf), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var testWithStrongSelfButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Test DispatchQueue [strong self]", for: .normal)
        button.addTarget(self, action: #selector(testWithStrongSelf), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var testWithPropertyClosureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Test Property Closure (Potential Leak)", for: .normal)
        button.addTarget(self, action: #selector(testWithPropertyClosure), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let mainQueue = DispatchQueue.main
    private let globalQueue = DispatchQueue.global(qos: .background)
    private let customQueue = DispatchQueue(label: "com.example.customQueue")
    
    // Property closure that can potentially cause a leak
    private var propertyClosure: (() -> Void)?
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    @objc func testWithWeakSelf() {
        print("Starting DispatchQueue test with [weak self]")
        dismiss(animated: true)
        
        mainQueue.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.printMessage(queue: "main")
        }
        
        globalQueue.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.printMessage(queue: "global")
        }
        
        customQueue.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.printMessage(queue: "custom")
        }
    }
    
    @objc func testWithStrongSelf() {
        print("Starting DispatchQueue test with [strong self]")
        dismiss(animated: true)
        
        mainQueue.asyncAfter(deadline: .now() + 1) {
            self.printMessage(queue: "main")
        }
        
        globalQueue.asyncAfter(deadline: .now() + 2) {
            self.printMessage(queue: "global")
        }
        
        customQueue.asyncAfter(deadline: .now() + 3) {
            self.printMessage(queue: "custom")
        }
    }
    
    @objc func testWithPropertyClosure() {
        print("Starting DispatchQueue test with property closure (Potential Leak)")
        
        // This can cause a retain cycle
        propertyClosure = {
            self.printMessage(queue: "property")
        }
        
        // 안전한 버전 (순환 참조 위험 없음)
//        propertyClosure = { [weak self] in
//            self?.printMessage(queue: "property")
//        }
        
        customQueue.asyncAfter(deadline: .now() + 2) {
            self.propertyClosure?()
        }
        
        dismiss(animated: true)
    }
    
    private func printMessage(queue: String) {
        print("DispatchQueue (\(queue)) task executed, self still exists")
    }
}

// MARK: - Setup
private extension DispatchQueueClosureViewController {
    func setupViews() {
        title = "DispatchQueue Closure"
        view.backgroundColor = .systemBackground
        view.addSubview(testWithWeakSelfButton)
        view.addSubview(testWithStrongSelfButton)
        view.addSubview(testWithPropertyClosureButton)
        addCloseButton()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            testWithWeakSelfButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testWithWeakSelfButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            testWithStrongSelfButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testWithStrongSelfButton.topAnchor.constraint(equalTo: testWithWeakSelfButton.bottomAnchor, constant: 20),
            
            testWithPropertyClosureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testWithPropertyClosureButton.topAnchor.constraint(equalTo: testWithStrongSelfButton.bottomAnchor, constant: 20)
        ])
    }
}
