//
//  ViewController.swift
//  GuitarTuner
//
//  Created by joe feng on 2018/12/11.
//  Copyright © 2018年 Feng. All rights reserved.
//

import AudioKit
import UIKit

class ViewController: UIViewController {
    
    // 螢幕尺寸
    let fullSize = UIScreen.main.bounds.size
    
    // 聲音頻率
    private var frequencyLabel: UILabel!
    
    // AudioKit
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 全局設定
        self.view.backgroundColor = UIColor.black

        // 顯示頻率文字
        frequencyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 80))
        frequencyLabel.textColor = UIColor.white
        frequencyLabel.text = "110"
        frequencyLabel.font = UIFont(name: "Helvetica-Light", size: 48)
        frequencyLabel.textAlignment = .center
        frequencyLabel.center = CGPoint(x: fullSize.width * 0.5, y: fullSize.height * 0.5 + fullSize.width * 0.7)
        self.view.addSubview(frequencyLabel)
        
        // AudioKit
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 啟動 AudioKit
        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }

        // 定時器 自麥克風獲取聲音
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(ViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
    }
    
    @objc func updateUI() {
        if tracker.amplitude > 0.1 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)
        }

    }
}

