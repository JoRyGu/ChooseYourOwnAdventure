//
//  PageController.swift
//  ChooseYourOwnAdventure
//
//  Created by Josh Gude on 2/16/20.
//  Copyright © 2020 Josh Gude. All rights reserved.
//

import UIKit

// MARK: - Extensions

extension NSAttributedString {
    var stringRange: NSRange {
        return NSMakeRange(0, self.length)
    }
}

extension Story {
    var attributedText: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self.text)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: attributedString.stringRange)
        
        return attributedString
    }
}

extension Page {
    func story(attributed: Bool) -> NSAttributedString {
        if attributed {
            return story.attributedText
        } else {
            return NSAttributedString(string: story.text)
        }
    }
}

// MARK: - Start of Class

class PageController: UIViewController {
    
    var page: Page?
    let soundEffectsPlayer = SoundEffectsPlayer()
    
    // MARK: - User Interface Properties
    
    lazy var artworkView: UIImageView = {
        let view = UIImageView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = self.page?.story.artwork
        
        return view
    }()
    
    lazy var storyLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var firstChoiceButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    
    let secondChoiceButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    
    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(page: Page) {
        self.page = page
        
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        if let page = page {
            storyLabel.attributedText = page.story(attributed: true)
            
            if let firstChoice = page.firstChoice {
                firstChoiceButton.setTitle(firstChoice.title, for: .normal)
                firstChoiceButton.addTarget(self, action: #selector(PageController.loadFirstChoice), for: .touchUpInside)
            } else {
                firstChoiceButton.setTitle("Play Again", for: .normal)
                firstChoiceButton.addTarget(self, action: #selector(PageController.restartStory), for: .touchUpInside)
            }
            
            if let secondChoice = page.secondChoice {
                secondChoiceButton.setTitle(secondChoice.title, for: .normal)
                secondChoiceButton.addTarget(self, action: #selector(PageController.loadSecondChoice), for: .touchUpInside)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setUpArtwork()
        setUpStoryText()
        setUpStoryButtons()
    }
    
    // MARK: - Helper Methods

    func setUpArtwork() -> Void {
        view.addSubview(artworkView)
        
        NSLayoutConstraint.activate([
            artworkView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            artworkView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            artworkView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            artworkView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
    
    func setUpStoryText() -> Void {
        view.addSubview(storyLabel)
        
        NSLayoutConstraint.activate([
            storyLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            storyLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            storyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -48.0)
        ])
    }
    
    func setUpStoryButtons() -> Void {
        view.addSubview(firstChoiceButton)
        view.addSubview(secondChoiceButton)
        
        NSLayoutConstraint.activate([
            firstChoiceButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            firstChoiceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80.0),
            secondChoiceButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            secondChoiceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32.0)
        ])
    }
    
    @objc func loadFirstChoice() -> Void {
        if let page = page, let firstChoice = page.firstChoice {
            let nextPage = firstChoice.page
            let pageController = PageController(page: nextPage)
            
            soundEffectsPlayer.playSound(for: firstChoice.page.story)
            
            navigationController?.pushViewController(pageController, animated: true)
        }
    }
    
    @objc func loadSecondChoice() -> Void {
        if let page = page, let secondChoice = page.secondChoice {
            let nextPage = secondChoice.page
            let pageController = PageController(page: nextPage)
            
            soundEffectsPlayer.playSound(for: secondChoice.page.story)
            
            navigationController?.pushViewController(pageController, animated: true)
        }
    }
    
    @objc func restartStory() -> Void {
        navigationController?.popToRootViewController(animated: true)
    }
}
