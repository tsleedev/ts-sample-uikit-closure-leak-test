//
//  AdvancedLeakTestViewController.swift
//  TSClosureLeakTestSample
//
//  Created by TAE SU LEE on 8/26/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit
import RxSwift
import Combine

import UIKit
import RxSwift
import Combine

class AdvancedLeakTestViewController: UIViewController {
    // MARK: - Enum
    enum Scenario: String, CaseIterable {
        case strongDelegate = "Strong Delegate"
        case rxSwift = "RxSwift Observable"
        case combine = "Combine Publisher"
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
    
    private var strongDataManager: StrongDataManager?
    private var disposeBag: DisposeBag?
    private var cancellables: Set<AnyCancellable>?
    
    // MARK: - Lifecycle
    deinit {
        print("\(type(of: self)) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Test Methods
    private func testStrongDelegate() {
        print("Testing Strong Delegate")
        // 메모리 누수 발생: self가 manager를 강하게 참조하고, manager가 delegate(self)를 강하게 참조합니다.
        // 해결 방법: StrongDataManager에서 delegate를 weak 참조로 선언합니다.
        let manager = StrongDataManager()
        self.strongDataManager = manager
        manager.delegate = self
        manager.updateData()
        dismiss(animated: true)
    }
    
    private func testRxSwift() {
        print("Testing RxSwift Observable")
        // 메모리 누수 발생: 구독이 self를 강하게 참조하고, self가 disposeBag을 통해 구독을 강하게 참조합니다.
        // 해결 방법: [weak self]를 사용하고, 필요 없어진 구독은 즉시 dispose 합니다.
        let disposeBag = DisposeBag()
        self.disposeBag = disposeBag
        
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.handleRxEvent()
            })
            .disposed(by: disposeBag)
        // 수정된 버전:
        // Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        //     .subscribe(onNext: { [weak self] _ in
        //         self?.handleRxEvent()
        //     })
        //     .disposed(by: disposeBag)
        
        dismiss(animated: true)
    }
    
    private func testCombine() {
        print("Testing Combine Publisher")
        // 메모리 누수 발생: 구독이 self를 강하게 참조하고, self가 cancellables를 통해 구독을 강하게 참조합니다.
        // 해결 방법: [weak self]를 사용하고, 필요 없어진 구독은 즉시 cancel 합니다.
        var cancellables = Set<AnyCancellable>()
        self.cancellables = cancellables
        
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.handleCombineEvent()
            }
            .store(in: &cancellables)
        // 수정된 버전:
        // Timer.publish(every: 1.0, on: .main, in: .common)
        //     .autoconnect()
        //     .sink { [weak self] _ in
        //         self?.handleCombineEvent()
        //     }
        //     .store(in: &cancellables)
        
        dismiss(animated: true)
    }
    
    private func handleRxEvent() {
        print("RxSwift event received")
    }
    
    private func handleCombineEvent() {
        print("Combine event received")
    }
}

// MARK: - Setup
private extension AdvancedLeakTestViewController {
    func setupViews() {
        title = "Advanced Leak Test"
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
extension AdvancedLeakTestViewController: UITableViewDataSource, UITableViewDelegate {
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
        case .strongDelegate: testStrongDelegate()
        case .rxSwift: testRxSwift()
        case .combine: testCombine()
        }
    }
}

// MARK: - StrongDataManager and Delegate
extension AdvancedLeakTestViewController: DataManagerDelegate {
    func dataManagerDidUpdateData() {
        print("ViewController: Received data update notification")
    }
}

private class StrongDataManager {
    weak var delegate: DataManagerDelegate?
    
    func updateData() {
        print("StrongDataManager: Data updated")
        delegate?.dataManagerDidUpdateData()
    }
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
}

private protocol DataManagerDelegate: AnyObject {
    func dataManagerDidUpdateData()
}
