//
//  PreviewController.swift
//  short note
//
//  Created by ibrahim uysal on 6.04.2023.
//

import UIKit
import PDFKit

final class PreviewController: UIViewController {
    
    //MARK: - Properties
    
    public var documentData: Data?
    private let pdfView = PDFView()
    private let shareButton = UIButton()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
    
    override func viewDidLayoutSubviews() {
        shareButton.addGradientLayer()
    }
    
    //MARK: - Selectors
    
    @objc private func handleShare() {
        if let dt = documentData {
            let vc = UIActivityViewController(
              activityItems: [dt],
              applicationActivities: []
            )
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                vc.popoverPresentationController?.sourceView = self.view
                vc.modalPresentationStyle = .pageSheet
            }
            
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: - Helpers
    
    private func style() {
        
        if let data = documentData {
            pdfView.translatesAutoresizingMaskIntoConstraints = false
            pdfView.autoScales = true
            pdfView.pageBreakMargins = UIEdgeInsets.init(top: 20, left: 8, bottom: 32, right: 8)
            pdfView.document = PDFDocument(data: data)
            pdfView.backgroundColor = UIColor(hex: ThemeManager.shared.currentTheme.cellColor) ?? .white
        }
        
        shareButton.setHeight(height: 50)
        shareButton.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        
        if let tintColor = UIColor(hex: ThemeManager.shared.currentTheme.textColor) {
            shareButton.setImage(image: Images.share?.withTintColor(tintColor), width: 20, height: 20)
        }
    }
    
    private func layout() {
        let stack = UIStackView(arrangedSubviews: [pdfView, shareButton])
        stack.axis = .vertical
        
        view.addSubview(stack)
        stack.fillSuperview()
    }
}
