//
//  ClosureCaptureListViewController.swift
//  TSClosureLeakTestSample
//
//  Created by TAE SU LEE on 8/27/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit

class ClosureCaptureListViewController: UIViewController {
    private lazy var valueTypeButton = self.createButton(title: "Test Value Type Capture", action: #selector(testValueTypeCapture))
    private lazy var referenceTypeButton = self.createButton(title: "Test Reference Type Capture", action: #selector(testReferenceTypeCapture))
    private lazy var strongReferenceButton = self.createButton(title: "Test Strong Reference", action: #selector(testStrongReference))
    private lazy var weakReferenceButton = self.createButton(title: "Test Weak Reference", action: #selector(testWeakReference))
    
    private var someInt = 0
    private var someObject = SomeClass()
    private var storedClosure: (() -> Void)?
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc private func testValueTypeCapture() {
        someInt = 0
        
        // 캡처 리스트 없이 캡처
        let closureWithoutCapture = {
            print("Without capture list - Current value: \(self.someInt)")
        }
        
        // 캡처 리스트로 캡처
        let closureWithCapture = { [someInt] in
            print("With capture list - Captured value: \(someInt)")
        }
        
        someInt = 10
        closureWithoutCapture()
        closureWithCapture()
        // 출력:
        // Without capture list - Current value: 10
        // With capture list - Captured value: 0
    }
    
    @objc private func testReferenceTypeCapture() {
        someObject.value = 0
        
        // 캡처 리스트 없이 캡처
        let closureWithoutCapture = {
            print("Without capture list - Current value: \(self.someObject.value)")
        }
        
        // 캡처 리스트로 캡처
        let closureWithCapture = { [someObject] in
            print("With capture list - Captured value: \(someObject.value)")
        }
        
        someObject.value = 10
        closureWithoutCapture()
        closureWithCapture()
        // 출력:
        // Without capture list - Current value: 10
        // With capture list - Captured value: 10
    }
    
    @objc private func testStrongReference() {
        // 강한 참조 - 메모리 누수 가능성
        storedClosure = {
            self.someInt += 1
            print("Strong reference - someInt: \(self.someInt)")
        }
        storedClosure?()
        print("Press close button to check if deinit is called")
    }
    
    @objc private func testWeakReference() {
        // 약한 참조 - 메모리 누수 방지
        storedClosure = { [weak self] in
            guard let self = self else {
                print("Self is nil, closure captured weak reference")
                return
            }
            self.someInt += 1
            print("Weak reference - someInt: \(self.someInt)")
        }
        storedClosure?()
        print("Press close button to check if deinit is called")
    }
}

// MARK: - Setup
private extension ClosureCaptureListViewController {
    func setupViews() {
        title = "Closure Capture List"
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView(arrangedSubviews: [
            valueTypeButton,
            referenceTypeButton,
            strongReferenceButton,
            weakReferenceButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        addCloseButton()
    }
    
    func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}

private class SomeClass {
    var value: Int = 0
}
