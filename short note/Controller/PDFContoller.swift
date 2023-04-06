//
//  PDFContoller.swift
//  short note
//
//  Created by ibrahim uysal on 6.04.2023.
//

import UIKit
import PDFKit

private let reuseIdentifier = "TagCell"

final class PDFContoller: UIViewController {
    
    //MARK: - Properties
    
    private var sn = ShortNote()
    private var noteArray = [Note]()
    var pdfData: Data?
    var tag: String?
    
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.blue
        button.setTitle("All", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(allButtonPressed), for: .touchUpInside)
        return button
    }()
    
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
    
    //MARK: - Selectors
    
    @objc private func allButtonPressed() {
        tag = nil
        noteArray = sn.normalNotes()
        handleCreate()
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .darkGray
        
        button.setHeight(height: 66)
        let stack = UIStackView(arrangedSubviews: [button, emojiCV])
        stack.axis = .vertical
        
        view.addSubview(stack)
        stack.fillSuperview()
    }
    
    private func findTags() {
        sortedTagDict = sn.findTags()
    }
    
    private func handleCreate() {
        DispatchQueue.main.async {
            let pdfData = self.generatePdfData()
            self.pdfData = pdfData
            
            let controller = PreviewController()
            controller.documentData = pdfData
            controller.modalPresentationStyle = .pageSheet
            self.present(controller, animated: true)
        }
    }
    
    private func generatePdfData() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Short Notes App",
            kCGPDFContextAuthor: "ibrahim uysal",
            kCGPDFContextTitle: "Short Notes"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 10, y: 10, width: 595.2, height: 841.8)
        let graphicsRenderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = graphicsRenderer.pdfData { (context) in
            context.beginPage()
            
            let initialCursor: CGFloat = 32
            
            var emoji =  "All"
            if let tag = tag { emoji = tag }
            
            var cursor = context.addCenteredText(fontSize: 32, weight: .bold,
                                                 text: "Short Notes \(emoji)",
                                                 cursor: initialCursor,
                                                 pdfSize: pageRect.size)
            
            cursor+=42
            
            cursor = addNotes(context: context, cursorY: cursor, pdfSize: pageRect.size)
           
        }
        return data
    }

    private func addNotes(context: UIGraphicsPDFRendererContext, cursorY: CGFloat, pdfSize: CGSize) -> CGFloat {
        var cursor = cursorY
        let leftMargin: CGFloat = 74

        for item in noteArray {
            if let note = item.note,
                let date = item.date?.getFormattedDate(format: UDM.selectedTimeFormat.getString()),
                let tag = item.label{
                
                cursor = addTag(tag: tag, context: context, cursorY: cursor, pdfSize: pdfSize)
                
                cursor = context.addSingleLineText(fontSize: 9, weight: .thin,
                                                   text: "\(date)", indent: leftMargin,
                                                   cursor: cursor, pdfSize: pdfSize,
                                                   annotation: nil, annotationColor: nil)
                cursor+=2
                
                cursor = context.addMultiLineText(fontSize: 12, weight: .thin,
                                                  text: "• \(note)\n", indent: leftMargin,
                                                  cursor: cursor, pdfSize: pdfSize)
                cursor+=2
            }
        }
        cursor+=8
        
        return cursor

    }
    
    private func addTag(tag: String, context: UIGraphicsPDFRendererContext, cursorY: CGFloat, pdfSize: CGSize) -> CGFloat {
        var cursor = cursorY
        let leftMargin: CGFloat = 74
        
        if self.tag == nil {
            cursor = context.addSingleLineText(fontSize: 14, weight: .bold, text:  "\(tag)",
                                               indent: leftMargin, cursor: cursor,
                                               pdfSize: pdfSize, annotation: .underline,
                                               annotationColor: .black)
            cursor+=6
        }
        return cursor
    }
}

//MARK: - UICollectionViewDelegate/DataSource

extension PDFContoller: UICollectionViewDataSource {
    
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
        tag = key
        noteArray = sn.filteredNormalNotes(tag: key)
        handleCreate()
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension PDFContoller: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((view.bounds.width)-32), height: 99)
    }
}
