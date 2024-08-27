//
//  MainViewController.swift
//  TSClosureLeakTestSample
//
//  Created by TAE SU LEE on 8/23/24.
//  Copyright © 2024 https://github.com/tsleedev/. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Enums
    private enum Section: Int, CaseIterable {
        case closureLearning
        case closureUsageCases
        case leakScenarios
        
        var title: String {
            switch self {
            case .closureLearning: return "Closure Learning"
            case .closureUsageCases: return "Closure Usage Cases"
            case .leakScenarios: return "Leak Scenarios"
            }
        }
    }
    
    private enum ClosureLearning: String, CaseIterable {
        case closureCaptureList = "Closure Capture List"
    }
    
    private enum ClosureUsageCases: String, CaseIterable {
        case parameterClosure = "Parameter Closure"
        case propertyClosure = "Property Closure"
        case dispatchQueueClosure = "DispatchQueue Closure"
        case asyncClosure = "Async Closure"
    }
    
    private enum LeakScenario: String, CaseIterable {
        case closureLeakTest = " Closure Leak Test"
        case advancedLeakTest = "Advanced Leak Test"
    }

    // MARK: - Views
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    // MARK: - Lifecycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        view.backgroundColor = .systemBackground
        self.title = "Closure Memory Management"
    }

    // MARK: - Setup
    private func setupViews() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        switch sectionType {
        case .closureLearning:
            return ClosureLearning.allCases.count
        case .closureUsageCases:
            return ClosureUsageCases.allCases.count
        case .leakScenarios:
            return LeakScenario.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        guard let section = Section(rawValue: indexPath.section) else {
            return cell
        }
        
        switch section {
        case .closureLearning:
            cell.textLabel?.text = ClosureLearning.allCases[indexPath.row].rawValue
        case .closureUsageCases:
            cell.textLabel?.text = ClosureUsageCases.allCases[indexPath.row].rawValue
        case .leakScenarios:
            cell.textLabel?.text = LeakScenario.allCases[indexPath.row].rawValue
        }
        
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController: UIViewController
        
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        
        switch section {
        case .closureLearning:
            let selectedType = ClosureLearning.allCases[indexPath.row]
            switch selectedType {
            case .closureCaptureList:
                viewController = ClosureCaptureListViewController()
            }
        case .closureUsageCases:
            let selectedType = ClosureUsageCases.allCases[indexPath.row]
            switch selectedType {
            case .parameterClosure:
                viewController = ParameterClosureViewController()
            case .propertyClosure:
                viewController = PropertyClosureViewController()
            case .dispatchQueueClosure:
                viewController = DispatchQueueClosureViewController()
            case .asyncClosure:
                viewController = AsyncClosureViewController()
            }
        case .leakScenarios:
            let selectedScenario = LeakScenario.allCases[indexPath.row]
            switch selectedScenario {
            case .closureLeakTest:
                viewController = ClosureLeakTestViewController()
            case .advancedLeakTest:
                viewController = AdvancedLeakTestViewController()
            }
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}
