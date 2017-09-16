//
//  WorkProgressView.swift
//  Pictograph
//
//  Created by Adam on 9/16/17.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Foundation

protocol WorkProgressViewDelegate: class {
    func workProgressViewDidCancelWork(_ completion: (() -> Void)?)
}

class WorkProgressView: PictographModalView {
    /// Displays a new hidden image view in a new uiwindow
    ///
    /// - Parameter delegate: delegate for any actions
    /// - Returns: the window (which needs to be retained), and the view
    static func createInWindow(from delegate: WorkProgressViewDelegate) -> (window: UIWindow, view: WorkProgressView) {
        let view = WorkProgressView(frame: .zero)
        view.delegate = delegate
        return PictographModalView.createViewInWindow(viewToShow: view)
    }
    
    // MARK: - Subviews
    
    fileprivate lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Progress"
        $0.font = UIFont.systemFont(ofSize: 24)
        return $0
    }(UILabel(frame: .zero))
    
    lazy var progressView: UIProgressView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIProgressView(frame: .zero))
    
    fileprivate lazy var cancelWorkButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.setTitleColor(UIColor.blue.withAlphaComponent(0.5), for: .highlighted)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.blue.cgColor
        return $0
    }(UIButton(frame: .zero))
    
    // MARK: - Properties
    
    weak var delegate: WorkProgressViewDelegate?
    
    /// Adds all subviews to self and sets up the constraints. Does not start animation
    override func setUpSubviewConstraints() {
        super.setUpSubviewConstraints()
        
        //Title label
        self.addSubview(self.titleLabel)
        self.titleLabel.centerXAnchor.constraint(equalTo: self.popupView.centerXAnchor).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: self.popupView.topAnchor, constant: 10).isActive = true
        
        self.addSubview(self.progressView)
        self.progressView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10).isActive = true
        self.progressView.leftAnchor.constraint(equalTo: self.popupView.leftAnchor, constant: 10).isActive = true
        self.progressView.rightAnchor.constraint(equalTo: self.popupView.rightAnchor, constant: -10).isActive = true
        self.progressView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        //Cancel button
        self.addSubview(self.cancelWorkButton)
        self.cancelWorkButton.topAnchor.constraint(equalTo: self.progressView.bottomAnchor, constant: 20).isActive = true
        self.cancelWorkButton.leadingAnchor.constraint(equalTo: self.progressView.leadingAnchor).isActive = true
        self.cancelWorkButton.trailingAnchor.constraint(equalTo: self.popupView.centerXAnchor, constant: -10).isActive = true
        self.cancelWorkButton.bottomAnchor.constraint(equalTo: self.popupView.bottomAnchor, constant: -20).isActive = true
        self.cancelWorkButton.addTarget(self, action: #selector(self.cancelWorkTapped), for: .touchUpInside)
    }
    
    @objc func cancelWorkTapped() {
        self.delegate?.workProgressViewDidCancelWork(nil)
    }
}
