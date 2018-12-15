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

    // 聲音高低指針
    var indicatorView:UIView!
    
    // 各弦音名
    let tuningNames = [1:"E", 2:"B", 3:"G", 4:"D", 5:"A", 6:"E"]
    
    // 顯示各弦音名 Label
    var tuningLabels = [
        1 : UILabel(),
        2 : UILabel(),
        3 : UILabel(),
        4 : UILabel(),
        5 : UILabel(),
        6 : UILabel()
    ]
    
    // 各弦音名 Label 的 center 位置
    var tuningPosition:[Int:CGPoint]!
    
    // 各弦定義的音高頻率
    let tuningOriginFreq = [
        1 : 329.63,
        2 : 246.94,
        3 : 196.00,
        4 : 146.83,
        5 : 110.00,
        6 : 82.41
    ]
    
    // 區分前後弦用的頻率
    let tuningMiddleFreq = [
        1 : 350.0,
        2 : 288.285,
        3 : 221.47,
        4 : 171.415,
        5 : 128.415,
        6 : 96.205,
        7 : 76.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 全局設定
        self.view.backgroundColor = UIColor.black

        // 吉他琴頭圖片
        let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: fullSize.width, height: fullSize.width))
        myImageView.image = UIImage(named: "guitar")
        myImageView.center = CGPoint(x: fullSize.width * 0.5, y: fullSize.height * 0.5 - fullSize.width * 0.2)
        myImageView.alpha = 0.7
        self.view.addSubview(myImageView)

        // 設定各弦音名 Label 的 center 位置
        tuningPosition = [
            1: CGPoint(x: fullSize.width * 0.8, y: fullSize.height * 0.5 + fullSize.width * 0.1),
            2: CGPoint(x: fullSize.width * 0.8, y: fullSize.height * 0.5 - fullSize.width * 0.2),
            3: CGPoint(x: fullSize.width * 0.8, y: fullSize.height * 0.5 - fullSize.width * 0.5),
            4: CGPoint(x: fullSize.width * 0.2, y: fullSize.height * 0.5 - fullSize.width * 0.5),
            5: CGPoint(x: fullSize.width * 0.2, y: fullSize.height * 0.5 - fullSize.width * 0.2),
            6: CGPoint(x: fullSize.width * 0.2, y: fullSize.height * 0.5 + fullSize.width * 0.1)
        ]

        // 設定各弦音名 Label 的初始值
        for n in 1...6 {
            tuningLabels[n] = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            tuningLabels[n]!.textColor = UIColor.yellow
            tuningLabels[n]!.text = tuningNames[n]!
            tuningLabels[n]!.textAlignment = .center
            tuningLabels[n]!.font = UIFont(name: "Helvetica-Light", size: 96)
            tuningLabels[n]!.center = tuningPosition[n]!
            tuningLabels[n]!.isHidden = true
            self.view.addSubview(tuningLabels[n]!)
        }
        
        // 設定聲音高低指針的初始值
        indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 50))
        indicatorView.center = CGPoint(x: fullSize.width * 0.5, y: fullSize.height * 0.5 + fullSize.width * 0.5)
        indicatorView.backgroundColor = UIColor.green
        indicatorView.layer.cornerRadius = 5
        self.view.addSubview(indicatorView)
        
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

        // 定時器 根據自麥克風獲取的聲音 來更新 UI
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(ViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
    }

    @objc func updateUI() {
/*
         if tracker.amplitude > 0.1 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)
         }
*/

        if tracker.amplitude > 0.05 {
            let freq = tracker.frequency
            
            for n in 1...6 {
                tuningLabels[n]!.isHidden = true
            }
            
            var tuning = 1
            if freq < tuningMiddleFreq[6]! {
                tuning = 6
            } else if freq < tuningMiddleFreq[5]! {
                tuning = 5
            } else if freq < tuningMiddleFreq[4]! {
                tuning = 4
            } else if freq < tuningMiddleFreq[3]! {
                tuning = 3
            } else if freq < tuningMiddleFreq[2]! {
                tuning = 2
            } else {
                tuning = 1
            }
            
            tuningLabels[tuning]!.isHidden = false
            
            self.findDiff(tuning: tuning, freq: freq, frontFreq: tuningMiddleFreq[tuning + 1]!, backFreq: tuningMiddleFreq[tuning]!)
        }
    }

    // 動態顯示聲音高低指針 以表示目前與準確頻率的差距
    func findDiff(tuning:Int, freq:Double, frontFreq:Double, backFreq:Double) {
        var positionX = fullSize.width * 0.5
        var percentage = 0.0
        let diff = tuningOriginFreq[tuning]! - freq
        frequencyLabel.text = String(format:"%.1f", -1.0 * Float(diff))
        if diff > 0 {
            percentage = diff / (tuningOriginFreq[tuning]! - frontFreq)
        } else {
            percentage = diff / (backFreq - tuningOriginFreq[tuning]!)
        }
        positionX -= fullSize.width * 0.4 * CGFloat(percentage)
        
        var color:UIColor
        let absPercentage = fabsf(Float(percentage))
        if (absPercentage < 0.1) {
            color = UIColor.green
        } else if (absPercentage < 0.3) {
            color = UIColor.yellow
        } else if (absPercentage < 0.5) {
            color = UIColor.orange
        } else {
            color = UIColor.red
        }
        
        indicatorView.backgroundColor = color
        indicatorView.center = CGPoint(x: positionX, y: indicatorView.center.y)
    }

}

