//
//  InfoViewController.swift
//  GuitarTuner
//
//  Created by joe feng on 2018/12/13.
//  Copyright © 2018年 Feng. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    let fullSize :CGSize = UIScreen.main.bounds.size
    var myTableView :UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .orange
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.title = "關於"
        
        let backBtn = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.setLeftBarButton(backBtn, animated: true)
        
        // 建立 UITableView
        myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: fullSize.width, height: fullSize.height - 64), style: .grouped)
        myTableView.contentInsetAdjustmentBehavior = .never
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.allowsSelection = true
        myTableView.backgroundColor = UIColor.black
        myTableView.separatorColor = UIColor.init(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
        self.view.addSubview(myTableView)
        
    }
    
    
    // MARK: Button actions
    
    @objc func backAction() {
        self.dismiss(animated: true, completion:nil)
    }
    
    @objc func goFB() {
        let requestUrl = URL(string: "https://www.facebook.com/swiftgogogo")
        UIApplication.shared.open(requestUrl!)
    }
    
    @objc func goIconSource() {
        let requestUrl = URL(string: "https://www.flaticon.com/free-icon/plectrum_1002085")
        UIApplication.shared.open(requestUrl!)
    }
    
    @objc func goAudioKit() {
        let requestUrl = URL(string: "https://audiokit.io/")
        UIApplication.shared.open(requestUrl!)
    }
    
    // MARK: UITableViewDelegate methods
    
    // 必須實作的方法：每一組有幾個 cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    // 必須實作的方法：每個 cell 要顯示的內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        let button = UIButton(frame: CGRect(x: 15, y: 0, width: fullSize.width, height: 40))
        button.backgroundColor = UIColor.black
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentHorizontalAlignment = .left
        
        if indexPath.section == 0 {
            button.addTarget(self, action: #selector(InfoViewController.goFB), for: .touchUpInside)
            button.setTitle("在 Facebook 上與我們聯絡", for: .normal)
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                button.addTarget(self, action: #selector(InfoViewController.goIconSource), for: .touchUpInside)
                button.setTitle("FLATICON", for: .normal)
            } else {
                button.addTarget(self, action: #selector(InfoViewController.goAudioKit), for: .touchUpInside)
                button.setTitle("AudioKit", for: .normal)
            }
        }
        
        cell.backgroundColor = .black
        cell.contentView.addSubview(button)
        
        return cell
    }
    
    // 點選 cell 後執行的動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // 有幾組 section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // 每個 section 的標題
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = "來源"
        if section == 0 {
            title = "支援"
        }
        
        return title
    }
    
}
