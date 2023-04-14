//
//  TagsController.swift
//  short note
//
//  Created by ibrahim uysal on 4.04.2023.
//

import UIKit

private let reuseIdentifier = "TagCell"

protocol TagsControllerDelegate : AnyObject {
    func updateCV()
}

final class TagsController: UIViewController {
    
    //MARK: - Properties
    
    private var sn = ShortNote()
    private var tagDict = [String: Int]()
    private var sortedTagDict = [Dictionary<String, Int>.Element]() {
        didSet { emojiCV.reloadData() }
    }
    
    private let emojiCV = makeCollectionView()
    private let placeholderView = PlaceholderView()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sn.loadItems()
        style()
        layout()
        findTags()
    }
    
    //MARK: - Helpers
    
    private func style() {
        emojiCV.delegate = self
        emojiCV.dataSource = self
        emojiCV.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        emojiCV.register(TagCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    private func layout() {
        view.addSubview(emojiCV)
        emojiCV.fillSuperview()
        
        view.addSubview(placeholderView)
        placeholderView.centerX(inView: view)
        placeholderView.centerY(inView: view)
    }
    
    private func findTags() {
        sortedTagDict = sn.findTags()
    }
    
    private func updatePlaceholderViewVisibility() {
        placeholderView.isHidden = sortedTagDict.count > 0
    }
}

//MARK: - UICollectionViewDelegate/DataSource

extension TagsController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        updatePlaceholderViewVisibility()
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
        controller.delegate = self
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension TagsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((view.bounds.width)-32), height: 99)
    }
}

//MARK: - TagsControllerDelegate

extension TagsController: TagsControllerDelegate {
    func updateCV() {
        findTags()
    }
}
