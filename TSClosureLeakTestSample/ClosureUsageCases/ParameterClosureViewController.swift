//
//  ParameterClosureViewController.swift
//  TSClosureLeakTestSample
//
//  Created by TAE SU LEE on 8/26/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit

class ParameterClosureViewController: UIViewController {
    private lazy var testEscapingWeakButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Escaping [weak self]", for: .normal)
        button.addTarget(self, action: #selector(testEscapingWeak), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var testEscapingStrongButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Escaping strong self", for: .normal)
        button.addTarget(self, action: #selector(testEscapingStrong), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var testNonEscapingWeakButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Non-Escaping [weak self]", for: .normal)
        button.addTarget(self, action: #selector(testNonEscapingWeak), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var testNonEscapingStrongButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Non-Escaping strong self", for: .normal)
        button.addTarget(self, action: #selector(testNonEscapingStrong), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    @objc private func testEscapingWeak() {
        print("Testing Escaping Closure with [weak self]")
        performAsyncTask { [weak self] result in
            guard let self = self else {
                print("Self is nil in escaping [weak self] closure")
                return
            }
            self.handleResult(result, context: "Escaping [weak self]")
        }
        dismiss(animated: true)
    }
    
    @objc private func testEscapingStrong() {
        print("Testing Escaping Closure with strong self")
        performAsyncTask { result in
            self.handleResult(result, context: "Escaping strong self")
        }
        dismiss(animated: true)
    }
    
    @objc private func testNonEscapingWeak() {
        print("Testing Non-Escaping Closure with [weak self]")
        performSyncTask { [weak self] result in
            guard let self = self else {
                print("Self is nil in non-escaping [weak self] closure")
                return
            }
            self.handleResult(result, context: "Non-Escaping [weak self]")
        }
        dismiss(animated: true)
    }
    
    @objc private func testNonEscapingStrong() {
        print("Testing Non-Escaping Closure with strong self")
        performSyncTask { result in
            self.handleResult(result, context: "Non-Escaping strong self")
        }
        dismiss(animated: true)
    }
    
    private func performAsyncTask(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 2)
            DispatchQueue.main.async {
                completion("Async Task Completed")
            }
        }
    }
    
    private func performSyncTask(completion: (String) -> Void) {
        let result = "Sync Task Completed"
        completion(result)
    }
    
    private func handleResult(_ result: String, context: String) {
        print("Result (\(context)): \(result)")
    }
}

// MARK: - Setup
private extension ParameterClosureViewController {
    func setupViews() {
        title = "Parameter Closure"
        view.backgroundColor = .systemBackground
        view.addSubview(testEscapingWeakButton)
        view.addSubview(testEscapingStrongButton)
        view.addSubview(testNonEscapingWeakButton)
        view.addSubview(testNonEscapingStrongButton)
        addCloseButton()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            testEscapingWeakButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testEscapingWeakButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            
            testEscapingStrongButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testEscapingStrongButton.topAnchor.constraint(equalTo: testEscapingWeakButton.bottomAnchor, constant: 20),
            
            testNonEscapingWeakButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testNonEscapingWeakButton.topAnchor.constraint(equalTo: testEscapingStrongButton.bottomAnchor, constant: 20),
            
            testNonEscapingStrongButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testNonEscapingStrongButton.topAnchor.constraint(equalTo: testNonEscapingWeakButton.bottomAnchor, constant: 20)
        ])
    }
}
