//
//  ClosureLeakTestViewController.swift
//  TSClosureLeakTestSample
//
//  Created by TAE SU LEE on 8/27/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit

class ClosureLeakTestViewController: UIViewController {
    // MARK: - Enum
    enum Scenario: String, CaseIterable {
        case storedClosure = "Stored Closure"
        case dispatchQueue = "DispatchQueue"
        case timer = "Timer"
        case notificationCenter = "NotificationCenter"
        case escaping = "Escaping Closure"
        case strongDataManagerCompletionHandler = "StrongDataManager Completion Handler"
    }
    
    // MARK: - Properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let scenarios = Scenario.allCases
    
    private var storedClosure: (() -> Void)?
    private var timer: Timer?
    private var strongDataManager: StrongDataManager?
    
    // MARK: - Lifecycle
    deinit {
        print("\(type(of: self)) deinit")
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Test Methods
    private func testStoredClosure() {
        print("Testing Stored Closure")
        // 메모리 누수 발생: self가 storedClosure를 강하게 참조하고, storedClosure가 self를 강하게 참조합니다.
        // 해결 방법: [weak self]를 사용하여 약한 참조로 변경합니다.
        storedClosure = { self.performHeavyTask() }
        // 수정된 버전:
        // storedClosure = { [weak self] in
        //     self?.performHeavyTask()
        // }
        storedClosure?()
        dismissAfterDelay()
    }
    
    private func testDispatchQueue() {
        print("Testing DispatchQueue")
        // 메모리 누수는 발생하지 않지만, 뷰 컨트롤러의 수명이 예상보다 길어질 수 있습니다.
        // 해결 방법: [weak self]를 사용하여 뷰 컨트롤러가 더 일찍 해제될 수 있게 합니다.
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.performHeavyTask()
        }
        // 수정된 버전:
        // DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
        //     self?.performHeavyTask()
        // }
        dismissAfterDelay()
    }
    
    private func testTimer() {
        print("Testing Timer")
        // 메모리 누수 발생: 타이머가 self를 강하게 참조하고, self가 타이머를 강하게 참조합니다.
        // 해결 방법: [weak self]를 사용하고, deinit에서 타이머를 무효화합니다.
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.performHeavyTask()
        }
        // 수정된 버전:
        // timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        //     self?.performHeavyTask()
        // }
        dismissAfterDelay()
    }
    
    private func testNotificationCenter() {
        print("Testing NotificationCenter")
        // 메모리 누수 발생: NotificationCenter가 옵저버(self)를 강하게 참조합니다.
        // 해결 방법: [weak self]를 사용하고, deinit에서 옵저버를 제거합니다.
        NotificationCenter.default.addObserver(forName: .NSSystemClockDidChange, object: nil, queue: .main) { _ in
            self.performHeavyTask()
        }
        // 수정된 버전:
        // NotificationCenter.default.addObserver(forName: .NSSystemClockDidChange, object: nil, queue: .main) { [weak self] _ in
        //     self?.performHeavyTask()
        // }
        dismissAfterDelay()
    }
    
    private func testEscapingClosure() {
        print("Testing Escaping Closure")
        // 잠재적 메모리 누수: 클로저가 self를 강하게 참조하고 있어, 클로저가 장기간 유지되면 문제가 될 수 있습니다.
        // 해결 방법: [weak self]를 사용합니다.
        performAsyncTask { result in
            self.handleResult(result)
        }
        // 수정된 버전:
        // performAsyncTask { [weak self] result in
        //     self?.handleResult(result)
        // }
        dismissAfterDelay()
    }
    
    private func testStrongDataManagerCompletionHandler() {
        print("Testing StrongDataManager Completion Handler")
        // 메모리 누수 발생: self가 manager를 강하게 참조하고, manager의 completionHandler가 self를 강하게 참조합니다.
        // 해결 방법: [weak self]를 사용하고, 사용 후 completionHandler를 nil로 설정합니다.
        let manager = StrongDataManager()
        self.strongDataManager = manager
        manager.setCompletionHandler {
            self.performHeavyTask()
        }
        // 수정된 버전:
        // manager.setCompletionHandler { [weak self] in
        //     self?.performHeavyTask()
        // }
        manager.completionHandler?()
        // manager.completionHandler = nil  // 사용 후 nil 설정
        dismissAfterDelay()
    }
    
    private func performAsyncTask(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 2)
            DispatchQueue.main.async {
                completion("Task completed")
            }
        }
    }
    
    private func performHeavyTask() {
        print("Heavy task performed by \(self)")
    }
    
    private func handleResult(_ result: String) {
        print("Handled result: \(result)")
    }
    
    private func dismissAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true) {
                print("ViewController dismissed")
            }
        }
    }
}

// MARK: - Setup
private extension ClosureLeakTestViewController {
    func setupViews() {
        title = "Closure Leak Test"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        addCloseButton()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ClosureLeakTestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenarios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = scenarios[indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch scenarios[indexPath.row] {
        case .storedClosure: testStoredClosure()
        case .dispatchQueue: testDispatchQueue()
        case .timer: testTimer()
        case .notificationCenter: testNotificationCenter()
        case .escaping: testEscapingClosure()
        case .strongDataManagerCompletionHandler: testStrongDataManagerCompletionHandler()
        }
    }
}

private class StrongDataManager {
    var completionHandler: (() -> Void)?
    
    func setCompletionHandler(completionHandler: @escaping () -> Void) {
        self.completionHandler = completionHandler
    }
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
}
