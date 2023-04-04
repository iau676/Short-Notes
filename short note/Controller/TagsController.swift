//
//  TagsController.swift
//  short note
//
//  Created by ibrahim uysal on 4.04.2023.
//

import UIKit

private let reuseIdentifier = "TagCell"

final class TagsController: UIViewController {
    
    //MARK: - Properties
    
    private var sn = ShortNote()
    private var tagDict = [String: Int]()
    private var sortedTagDict = [Dictionary<String, Int>.Element]() {
        didSet { emojiCV.reloadData() }
    }
    
    private lazy var emojiCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        cv.register(TagCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return cv
    }()
    
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
        view.addSubview(emojiCV)
        emojiCV.fillSuperview()
    }
}

//MARK: - UICollectionViewDelegate/DataSource

extension TagsController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedTagDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        let key = Array(sortedTagDict)[indexPath.row].key
        let value = Array(sortedTagDict)[indexPath.row].value
        cell.emojiLabel.text = key
        cell.countLabel.text = "\(value)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let key = Array(sortedTagDict)[indexPath.row].key
        let controller = NotesController(tag: key)
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension TagsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((view.bounds.width)/3), height: ((view.bounds.width)/3))
    }
}
