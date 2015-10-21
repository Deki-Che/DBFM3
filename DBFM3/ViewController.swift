//
//  ViewController.swift
//  DBFM3
//
//  Created by Deki on 15/10/19.
//  Copyright © 2015年 Deki. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MediaPlayer


class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, HTTPProtocol, ChannelProtocol {

    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var v1: EkoImage!
    
    // 网罗操作类的实例
    var eHttp:HTTPControl = HTTPControl()
    // 定义变量接受频道歌曲数据
    var tableData = [JSON]()
    // 定义频道数据
    var channelData = [JSON]()
    // 定义图片缓存字典
    var imageCache = Dictionary<String, UIImage >()
    // 申明一个媒体播放器的实例
    var audioPlayer :MPMoviePlayerController = MPMoviePlayerController()
    
    
    // 中间三个按钮
    @IBOutlet weak var btnPlay: EcoButton!
    @IBOutlet weak var btnPre: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    // 播放按钮顺序
    @IBOutlet weak var btnOrder:orderButton!
    
    // 当前播放第几首的歌曲
    var currentIndex:Int = 0
    
    
    // 声明一个计时器
    var timer:NSTimer?
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var progress: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        v1.onRatation()
        self.tv.delegate = self
        self.tv.dataSource = self
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        bg.addSubview(blurEffectView)
        // 为网络实例设置代理
        self.eHttp.delegate = self
        
        // 获取频道
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        
        // 默认获取频道为0 的歌曲数据
        eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
        
        // 让tableview背景透明
        tv.backgroundColor = UIColor.clearColor()
        
        // 监听按钮点击
        btnPlay.addTarget(self, action: "onPlay:", forControlEvents: UIControlEvents.TouchUpInside)
        btnNext.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnPre.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnOrder.addTarget(self, action: "onOrder:", forControlEvents: .TouchUpInside)
        
        // 监听： 播放结束通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playFinish", name: MPMoviePlayerPlaybackDidFinishNotification, object: audioPlayer)
        
    }
    var isAutoFinish:Bool = true
    // 认为结束 1 上一首下一首 2 点中cell时 3在频道列表选择歌曲时
    func playFinish() {
        if isAutoFinish {
            switch (btnOrder.order) {
        case 1:
            // 顺序播放
            currentIndex++
            if currentIndex > self.tableData.count - 1 {
                currentIndex = 0
            }
            onSelectRows(currentIndex)
        case 2:
            // 随机播放
            currentIndex = random() % (self.tableData.count)
            onSelectRows(currentIndex)
        case 3:
            // 单曲循环
            onSelectRows(currentIndex)
        default:
            print("FUCK")
        }

        } else {
            isAutoFinish = true
        }
                
    }
    
    func onOrder(btn:orderButton) {
        var message:String = ""
        switch (btn.order) {
        case 1:
            message = "顺序播放"
        case 2:
            message = "随机播放"
        case 3:
            message = "单曲循环"
        default:
            message = "播放出错"
        }
        self.successNotice(message)
        
    }
    
    // 上一首下一首
    // 问题： 设置播放顺序以后，上下首歌曲，不能使用随机播放，函数缺少 order 的判断
    func onClick(btn:UIButton) {
        // 设置isAutoFinish
        isAutoFinish = false
        if btn == btnNext {
            ++currentIndex
            if currentIndex > self.tableData.count - 1 {
                currentIndex = 0
            }
        }
        if btn == btnPre {
                --currentIndex
                if currentIndex < 0 {
                    currentIndex = self.tableData.count - 1
                }
        }
        onSelectRows(currentIndex)
    }
    
    func onPlay(btn:EcoButton) {
        if btn.isPlay {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
    }
    
    // 选中了哪一首歌曲
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        isAutoFinish = false
        onSelectRows(indexPath.row)
    }
    
    // 选中了哪一行
    func onSelectRows(index: Int) {
        // 构建一个indexPath
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        // 选中的效果
        tv.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        //  获取数据
        let dataRow: JSON = self.tableData[index]
        let imageUrl = dataRow["picture"].string
        onSetImage(imageUrl!)
        
        // 获取音乐的文件地址
        let url = dataRow["url"].string!
        // 播放音乐
        onSetAudio(url)
        
        
    }
    
    // 设置歌曲的封面及背景
    func onSetImage(url:String) {
        onGetCachImg(url, imageView: self.bg)
        onGetCachImg(url, imageView: self.v1)
    }
    // 播放 Music 方法
    func  onSetAudio(url:String ) {
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
        
        btnPlay.onPlay()
        
        isAutoFinish = true
        // 设置计时器， 先停掉计时器
        timer?.invalidate()
        // 计时器归零
        self.playTime.text = "00:00"
        // 启动计时器
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "OnUpdata", userInfo: nil, repeats: true)
        
    }
    // 计时器更新方法
    func OnUpdata() {
        // 获取当前播放时间
        let c = audioPlayer.currentPlaybackTime
        if c > 0.0 {
            // 歌曲总时间
            let t = audioPlayer.duration
            // 计算百分比
            let pro :CGFloat = CGFloat(c/t)
            // 计算进度条的宽度
            self.progress.frame.size.width = self.view.frame.size.width * pro
            //a 这是一个算法实现 时间显示格式央视的 播放时间
            let all:Int = (Int)(c)
            let m :Int = all % 60
            let f :Int = Int(all / 60)
            var time :String = ""
            if f < 10 {
                time = "0\(f):"
            } else {
                time = "\(f)"
            }
            
            if m < 10 {
                time  += "0\(m)"
            } else {
                time += "\(m)"
            }
            // 更新文本标签
            playTime.text = time
        }
        
    
    }
    
    // 图片缓存方法
    func onGetCachImg(url:String, imageView:UIImageView) {
        // 在缓存中获取图片
        let image  = self.imageCache[url]
        
        if image == nil {
            // 没有图片，我们就从网络获取
            Alamofire.request(.GET, url).response(completionHandler: { (_, _, data, error) -> Void in
                let img = UIImage(data: data!)
                imageView.image = img
                
                self.imageCache[url] = img
            })
            
        } else {
            // 如果缓存中有，直接使用
            imageView.image = image!
        }
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 获取跳转目标
        let channelC:ChannelTableViewController = segue.destinationViewController as! ChannelTableViewController
        // 设置代理
        channelC.delegate = self
        // 传输频道列表数据
        channelC.channelData = self.channelData
    }
    
    // 频道列表协议的回调
    func onChangeChannel(channel_id: String) {
        // 拼凑频道里歌曲的数据url
        // http://douban.fm/j/mine/playlist?type=n&channel=  0 &from=mainsite
        let url :String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        eHttp.onSearch(url)
    }
    
    // 网络请求协议的方法
    func didReceiveResults(results: AnyObject) {
        print("接受到的参数： \(results)")
        
        let json = JSON(results)
        if let channel = json["channels"].array {
            self.channelData  = channel
            
        } else if let song = json["song"].array {
            isAutoFinish = false
            self.tableData = song
            print(self.tableData[0]["artist"].string)
            self.tv.reloadData()
            // 设置第一首歌的图片及背景
            onSelectRows(0)

        }
            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // cell动画代码
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tv.dequeueReusableCellWithIdentifier("douban", forIndexPath: indexPath)
        
        let rowData:JSON = tableData[indexPath.row]
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["artist"].string
        cell.imageView?.image = UIImage(named: "tx3")
        //封面网址
        let url = rowData["picture"].string
        // 获取图片
        onGetCachImg(url!, imageView: cell.imageView!)
        
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
        
    }
    
    override func viewWillAppear(animated: Bool) {
        v1.onRatation()
    }


}

