//
//  AsyncClosureViewController.swift
//  TSClosureLeakTestSample
//
//  Created by TAE SU LEE on 8/27/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit

class AsyncClosureViewController: UIViewController {
    private lazy var testSafeAsyncButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Safe Async Operation", for: .normal)
        button.addTarget(self, action: #selector(testSafeAsyncOperation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var testLeakyAsyncButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Leaky Async Operation", for: .normal)
        button.addTarget(self, action: #selector(testLeakyAsyncOperation), for: .touchUpInside)
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

    @objc private func testSafeAsyncOperation() {
        print("Testing Safe Async Operation")
        Task {
            await performSafeAsyncOperation()
            dismiss(animated: true)
        }
    }

    @objc private func testLeakyAsyncOperation() {
        print("Testing Leaky Async Operation")
        Task {
            await performLeakyAsyncOperation()
            dismiss(animated: true)
        }
    }

    private func performSafeAsyncOperation() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                print("Safe async operation completed")
                continuation.resume() // Correctly calling resume
            }
        }
        print("After safe async operation")
    }

    private func performLeakyAsyncOperation() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                print("Leaky async operation completed")
                // continuation.resume() is not called - potential leak
            }
        }
        print("This line will never be reached")
    }
}

// MARK: - Setup
private extension AsyncClosureViewController {
    func setupViews() {
        title = "Async Closure"
        view.backgroundColor = .systemBackground
        view.addSubview(testSafeAsyncButton)
        view.addSubview(testLeakyAsyncButton)
        addCloseButton()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            testSafeAsyncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testSafeAsyncButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            testLeakyAsyncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testLeakyAsyncButton.topAnchor.constraint(equalTo: testSafeAsyncButton.bottomAnchor, constant: 20)
        ])
    }
}
