//
//  ThemesController.swift
//  short note
//
//  Created by ibrahim uysal on 4.04.2023.
//

import UIKit

private let reuseIdentifier = "ThemeCell"

protocol ThemesControllerDelegate: AnyObject {
    func updateTheme()
}

final class ThemesController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: ThemesControllerDelegate?
    
    private let label = makePaddingLabel(withText: "Change theme with double click")
    
    private lazy var switchh: UISwitch = {
        let switchh = makeSwitch(isOn: UDM.switchDoubleClick.getBool())
        switchh.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return switchh
    }()
    
    private lazy var themeCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        cv.register(ThemeCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return cv
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Selectors
    
    @objc private func switchChanged(sender: UISwitch) {
        UDM.switchDoubleClick.set(sender.isOn)
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)
        label.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor)?.darker()
        label.textColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor)
        
        view.addSubview(label)
        label.anchor(top: view.topAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 16,
                     paddingLeft: 24, paddingRight: 24,
                     height: 50)
        
        view.addSubview(switchh)
        switchh.centerY(inView: label)
        switchh.anchor(right: label.rightAnchor, paddingRight: 16)
        
        view.addSubview(themeCV)
        themeCV.anchor(top: label.bottomAnchor, left: view.leftAnchor,
                       bottom: view.bottomAnchor, right: view.rightAnchor,
                       paddingTop: 16)
    }
}

//MARK: - UICollectionViewDelegate/DataSource

extension ThemesController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ThemeManager.shared.themes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThemeCell
        let theme = ThemeManager.shared.themes[indexPath.row]
        cell.theme = Theme(backgroundColorHex: theme.backgroundColor,
                           backgroundColorBottomHex: theme.backgroundColorBottom,
                           tableViewColorHex: theme.tableViewColor,
                           index: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ThemeManager.shared.updateTheme(withIndex: indexPath.row)
        self.dismiss(animated: true) {
            self.delegate?.updateTheme()
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ThemesController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((view.bounds.width-32)), height: 99)
    }
}
