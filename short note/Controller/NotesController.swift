//
//  NotesController.swift
//  short note
//
//  Created by ibrahim uysal on 4.04.2023.
//

import UIKit

private let reuseIdentifier = "NoteCell"

final class NotesController: UITableViewController {
    
    //MARK: - Properties
    
    private let tag: String
    private var sn = ShortNote()
    private var tempArray: [Int] = [] {
        didSet { tableView.reloadData() }
    }
    
    //MARK: - Lifecycle
    
    init(tag: String) {
        self.tag = tag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sn.loadItems()
        configureUI()
        findNotes()
    }
    
    //MARK: - Helpers
    
    private func findNotes() {
        for i in 0..<sn.itemArray.count {
            guard let label = sn.itemArray[i].label else { return }
            if sn.itemArray[i].isHiddenn == 0 && sn.itemArray[i].isDeletedd == 0 && label ==  tag {
                tempArray.append(i)
            }
        }
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        
        tableView.tableFooterView = UIView()
        tableView.register(ExampleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

//MARK: - UITableViewDataSource

extension NotesController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExampleCell
        let note = sn.itemArray[tempArray[indexPath.row]]
        cell.note = note
        return cell
    }
}

//MARK: - UITableViewDelegate

extension NotesController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
