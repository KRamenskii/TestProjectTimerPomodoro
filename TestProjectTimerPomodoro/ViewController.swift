//
//  ViewController.swift
//  TestProjectTimerPomodoro
//
//  Created by Kirill on 26.09.2021.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var circlePath: UIBezierPath = {
        let circlePath = UIBezierPath(arcCenter: view.center, radius: ConstantsForAnimation.radius, startAngle: CoordinatesOfProgress.startAngle, endAngle: CoordinatesOfProgress.endAngle, clockwise: true)
        
        return circlePath
    }()
    
    private lazy var progressBar: CAShapeLayer = {
        let progressBar = CAShapeLayer()
        
        progressBar.path = circlePath.cgPath
        progressBar.lineWidth = ConstantsForAnimation.zona
        progressBar.strokeColor = UIColor.white.cgColor
        progressBar.fillColor = UIColor.clear.cgColor
        progressBar.strokeEnd = 0
        
        return progressBar
    }()
    
    private lazy var trackProgressBar: CAShapeLayer = {
        let trackProgressBar = CAShapeLayer()
        
        trackProgressBar.path = circlePath.cgPath
        trackProgressBar.fillColor = UIColor.clear.cgColor
        trackProgressBar.lineWidth = ConstantsForAnimation.zona
        trackProgressBar.strokeColor = ColorTimer.workTimeProgressBar.cgColor
        trackProgressBar.opacity = ConstantsForAnimation.alphaAnimationColor
        
        return trackProgressBar
    }()
        
    private lazy var tempTime: Int = {
        let tempTime = Int()
                
        return tempTime
    }()
    
    private lazy var timer: Timer = {
        let timer = Timer()
        
        return timer
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
                
        label.font = .systemFont(ofSize: Metric.labelTextsize, weight: .light)
        label.textColor = ColorTimer.labelButtonColor
        
        return label
    }()
    
    private lazy var button: UIButton = {
        var button = UIButton()
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.tintColor = ColorTimer.labelButtonColor
        button.setBackgroundImage(IconButton.playButton, for: .normal)
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHierarchy()
        setupLayout()
        setupView()
        startProject()
    }

    // MARK: - Settings
    
    private func setupHierarchy() {
        
        view.layer.addSublayer(trackProgressBar)
        view.layer.addSublayer(progressBar)
        view.addSubview(label)
        view.addSubview(button)
    }
    
    private func setupLayout() {
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Metric.buttonTopOfSet).isActive = true
        button.heightAnchor.constraint(equalToConstant: Metric.buttinHeight).isActive = true
        button.widthAnchor.constraint(equalToConstant: Metric.buttonWidth).isActive = true
    }
    
    private func setupView() {
        
        view.backgroundColor = .lightGray
    }
    
    // MARK: - Actions
    
    @objc private func buttonAction() {
        
        if trackProgressBar.strokeColor == ColorTimer.workTimeProgressBar.cgColor {
            
            switch button.backgroundImage(for: .normal) {
                
            case IconButton.playButton:
                button.setBackgroundImage(IconButton.stopButton, for: .normal)
                startTimer()
                createAnimation(ConstantsForAnimation.startAnimation)
                
            case IconButton.stopButton:
                button.setBackgroundImage(IconButton.playButton, for: .normal)
                timer.invalidate()
                createAnimation(ConstantsForAnimation.stopAnimation)
                tempTime = Time.workTime
                resetTimer(tempTime)
                
            default:
                break
            }
        } else {
            timer.invalidate()
            createAnimation(ConstantsForAnimation.stopAnimation)
            tempTime = Time.workTime
            button.setBackgroundImage(IconButton.playButton, for: .normal)
            trackProgressBar.strokeColor = ColorTimer.workTimeProgressBar.cgColor
            resetTimer(tempTime)
        }
    }

    @objc private func startTimer() {
        
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    @objc private func countdown() -> Int {
        
        let currentTime = tempTime - 1
        let seconds = currentTime % 60
        let minutes = Int(currentTime / 60)
        
        label.text = "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
        tempTime -= 1
        
        if trackProgressBar.strokeColor == ColorTimer.workTimeProgressBar.cgColor {
            if tempTime == 0 {
                tempTime = Time.relaxTime
                timer.invalidate()
                createAnimation(ConstantsForAnimation.stopAnimation)
                trackProgressBar.strokeColor = ColorTimer.relaxTimeProgressBar.cgColor
                
                resetTimer(tempTime)
                startTimer()
                createAnimation(ConstantsForAnimation.startAnimation)
            }
        } else {
            if tempTime == 0 {
                tempTime = Time.workTime
                timer.invalidate()
                createAnimation(ConstantsForAnimation.stopAnimation)
                trackProgressBar.strokeColor = ColorTimer.workTimeProgressBar.cgColor
                button.setBackgroundImage(IconButton.playButton, for: .normal)
                
                resetTimer(tempTime)
            }
        }
        
        return tempTime
    }
    
    // MARK: - Animation
    
    private func createAnimation(_ toValue: Int) {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.toValue = toValue
        animation.duration = Double(tempTime + 1)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        progressBar.add(animation, forKey: "animation")
    }
}

// MARK: - Constant

extension ViewController {
    
    enum ConstantsForAnimation {
        static let startAnimation: Int = 1
        static let stopAnimation: Int = 0
        static let radius: CGFloat = 75
        static let zona: CGFloat = radius * 2
        static let alphaAnimationColor: Float = 0.5
    }
    
    enum CoordinatesOfProgress {
        static let startAngle: Double = -(.pi / 2)
        static let endAngle: Double = .pi * 2
    }
    
    enum Time {
        static let workTime: Int = 1500 //1500 в секундах просто время
        static let relaxTime: Int = 300 //300
    }
    
    enum Metric {
                
        static let buttinHeight: CGFloat = 55
        static let buttonWidth: CGFloat = 55
        static let buttonTopOfSet: CGFloat = 20
        static let labelTextsize: CGFloat = 70
    }
    
    enum IconButton {
        static let playButton = UIImage(systemName: "play.fill")
        static let stopButton = UIImage(systemName: "stop.fill")
    }
    
    enum ColorTimer {
        static let workTimeProgressBar: UIColor = .systemRed
        static let relaxTimeProgressBar: UIColor = .systemGreen
        static let labelButtonColor: UIColor = .black
    }
}

// MARK: - Implementation of functions

extension ViewController {
    
    private func resetTimer(_ time: Int) {
        
        let seconds = time % 60
        let minutes = Int(time / 60)
        
        label.text = "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
    
    private func startProject() {
        
        let time = Time.workTime
        let seconds = time % 60
        let minutes = Int(time / 60)
        
        label.text = "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
        tempTime = time
    }
}

