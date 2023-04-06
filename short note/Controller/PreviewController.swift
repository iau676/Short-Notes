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
    private lazy var shareButton:  UIButton = {
        let button = UIButton()
        button.setHeight(height: 50)
        button.backgroundColor = Colors.blue
        button.setImage(image: Images.share, width: 20, height: 20)
        button.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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
    
    private func configureUI() {
        view.backgroundColor = .darkGray
        
        if let data = documentData {
            pdfView.translatesAutoresizingMaskIntoConstraints = false
            pdfView.autoScales = true
            pdfView.pageBreakMargins = UIEdgeInsets.init(top: 20, left: 8, bottom: 32, right: 8)
            pdfView.document = PDFDocument(data: data)
        }
        
        let stack = UIStackView(arrangedSubviews: [pdfView, shareButton])
        stack.axis = .vertical
        
        view.addSubview(stack)
        stack.fillSuperview()
    }
}
