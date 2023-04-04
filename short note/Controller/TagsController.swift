//
//  TagsController.swift
//  short note
//
//  Created by ibrahim uysal on 4.04.2023.
//

import UIKit

private let reuseIdentifier = "TagsCell"

class TagsController: UITableViewController {
    
    //MARK: - Properties
    
    private var sn = ShortNote()
    private var tagDict = [String: Int]()
    private var sortedTagDict = [Dictionary<String, Int>.Element]() {
        didSet { tableView.reloadData() }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sn.loadItems()
        configureUI()
        findTags()
    }
    
    //MARK: - Helpers
    
    private func findTags() {
        for i in 0..<sn.itemArray.count {
            guard let label = sn.itemArray[i].label else { return }
            if sn.itemArray[i].isHiddenn == 0 && sn.itemArray[i].isDeletedd == 0 && label.count > 0 {
                tagDict.updateValue((tagDict[label] ?? 0)+1, forKey: label)
                sortedTagDict = tagDict.sorted{$0.value > $1.value}
            }
        }
    }
    
    private func configureUI() {
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 66
        tableView.dataSource = self
        tableView.delegate = self
    }
}

//MARK: - UITableViewDataSource

extension TagsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedTagDict.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let key = Array(sortedTagDict)[indexPath.row].key
        let value = Array(sortedTagDict)[indexPath.row].value
        cell.textLabel?.text = "\(key) (\(value))"
        cell.textLabel?.textAlignment = .center
        
        return cell
    }
}

//MARK: - UITableViewDelegate

extension TagsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let key = Array(sortedTagDict)[indexPath.row].key
        let controller = NotesController(tag: key)
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true)
    }
}
