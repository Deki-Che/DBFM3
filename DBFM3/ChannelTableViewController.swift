//
//  ChannelTableViewController.swift
//  DBFM3
//
//  Created by Deki on 15/10/20.
//  Copyright © 2015年 Deki. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ChannelProtocol {
    // 回调方法将id传回到代理
    func  onChangeChannel(channel_id: String)
}

class ChannelTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tv: UITableView!
    
    // 申明代理
    var delegate:ChannelProtocol?
    // 频道列表数据
    var channelData = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let backButton:UIButton  = UIButton(type: UIButtonType.System)
//        backButton.frame = CGRectMake(10, 30, 40, 20)
//        backButton.setTitle("back", forState: UIControlState.Normal)
//        backButton.addTarget(self, action: "backHead", forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(backButton)
        
        view.alpha = 0.8
        
        self.tv.delegate = self
        self.tv.dataSource = self

    }
    
    //选中具体频道，返回主界面，将频道id传回
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 获取行数据
        let rewData:JSON = self.channelData[indexPath.row]
        //获取选中频道的id
        let channel_id:String = rewData["channel_id"].stringValue
        // 回传给主界面
        self.delegate?.onChangeChannel(channel_id)
        // 关闭当前界面
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 设置cell动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // cell动画代码
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.6) { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tv.dequeueReusableCellWithIdentifier("pindao", forIndexPath: indexPath)
        let rowData :JSON = self.channelData[indexPath.row]
        cell.textLabel?.text = rowData["name"].string
        
        return cell
    }

    

}
