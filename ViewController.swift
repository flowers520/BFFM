//
//  ViewController.swift
//  BFFM
//
//  Created by jim on 15/10/26.
//  Copyright © 2015年 jim. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HttpProtocol, Channelprotocol {

    //ImageView控件 歌曲封面
    @IBOutlet  var iv: UIImageView!
    //TableView控件 歌曲列表
    @IBOutlet  var tv: UITableView!
    //ProgressView控件 播放进度条
    @IBOutlet  var progressView: UIProgressView!
    //Label控件 播放时间
    @IBOutlet  var playTime: UILabel!
    
    //播放按钮
    @IBOutlet var btnPlay: UIImageView!
    //敲击手势
    @IBOutlet var tap:UITapGestureRecognizer!
    
    // 用于获取网络数据
    var eHttp: HttpController = HttpController()
    
    //接收歌曲列表的数组
    var tableData: NSArray = NSArray()
    //接受频道列表的数组
    var channelData: NSArray = NSArray()
    //申请一个字典用来缓存
    //var imageCache = NSDictionary()
    var imageCache = [String:UIImage]()

    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController();
    
    //申明一个定时器
    var timer: NSTimer?
    
   //响应敲击手势方法
    @IBAction func onTap(sender: UITapGestureRecognizer)
    {
        if sender.view == btnPlay{
            /*
            如果当前手势的注册对象是btnPlay
            隐藏btnPlay
            播放歌曲
            取消btnPlay的手势注册
            将手势注册给iv
            */
            btnPlay!.hidden = true
            audioPlayer.play()
            btnPlay!.removeGestureRecognizer(tap!)
            iv!.addGestureRecognizer(tap!)
        }else if sender.view == iv{
            /*
            如果当前手势注册对象是iv
            显示btnPlay
            暂停歌曲播放
            取消iv的手势注册
            将手势注册给btnPlay
            */
            btnPlay!.hidden = false
            audioPlayer.pause()
            btnPlay!.addGestureRecognizer(tap!)
            iv!.removeGestureRecognizer(tap!)
        }
    }
    //试图跳转执行的方法
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //跳转的目标对象为ChannelController类型
        let channelC: ChannelController = segue.destinationViewController as! ChannelController
        //设置跳转对象的代理
        channelC.delegate = self
        //为跳转对象填充频道列表数据
        channelC.channelData = self.channelData
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        eHttp.delegate = self
        eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        
        //将tap手势注册给iv
        iv!.addGestureRecognizer(tap!)
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //获取标示为"douban"的cell
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "douban")
        //获取cell的数据
        let rowData:NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        //设置标题
        cell.textLabel?.text = rowData["title"] as? String
        //设置详情
        cell.detailTextLabel?.text = rowData["artist"] as? String
        //获取图片地址
        let url = rowData["picture"] as? String
        //设置缩略图的默认图
        cell.imageView?.image = UIImage(named: "detail.png")
        //通过图片地址去缓存中取图片
        let image = self.imageCache[url!] 
        if image == nil {
            //如果缓存中没有
            //定义NSURL
            let imgURL: NSURL = NSURL(string: url!)!
            //定义NSURLRequest
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            //异步获取图片
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                //将图片数据赋予一个UIImage
                let img = UIImage(data: data!)
                //设置缩略图
                cell.imageView?.image = img
                // 将图片加入缓存
                self.imageCache[url!]  = img
            })
        }
        else{
            //如果缓存中有，直接取
            cell.imageView?.image = image!
        }
        //返回cell
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("在ViewController中选择了第\(indexPath.row)行")
        //获取选中行的数据
        let rowData: NSDictionary =  self.tableData[indexPath.row] as! NSDictionary
        //获取改行中的图片地址
        let imgUrl: String = rowData["picture"] as! String
        // 设置封面图片
        onSetImage(imgUrl)
        //获取歌曲文件地址
        let audioUrl: String = rowData["url"] as! String
        //播放音乐
        onSetAudio(audioUrl)
        print("在tableView的didSelectRowAtIndexPath中播放音乐")
    }

    //设置cell的显示动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //设置cell的显示动画为3D缩放
        //xy方向缩放的初始值为0.1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        //设置动画时间为0.25秒，xy方向缩放的最终值为1
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    func didRecieveResults(resultes: NSDictionary) {
        //如果数据的song关键字部位nil
        if (resultes["song"] != nil){
            //填充tableData
            self.tableData = resultes["song"] as! NSArray
            //刷新tv的数据
            self.tv!.reloadData()
            //获取第一首歌的歌曲地址和缩略图地址
            let firDict: NSDictionary = self.tableData[0] as! NSDictionary
            //获取歌曲文件地址
            let audioUrl: String = firDict["url"] as! String
            //播放歌曲
            onSetAudio(audioUrl)
            print("在didReciteveResults中音乐地址：\(audioUrl)")
            let imgUrl: String = firDict["picture"] as! String
            print("在didReciteveResults中图片地址：\(imgUrl)")
            onSetImage(imgUrl)
        }
        else if (resultes["channels"] != nil){
            //如果数据的song关键字的value不为nil，获取的就是频道数据
            self.channelData = resultes["channels"] as! NSArray
        }
    }
    
    //遵循ChannelProtocol协议所需要实现的方法
    func onChangeChannel(channel_id: String) {
        //拼凑频道歌曲数据网络地址
        let url: String = "http://douban.fm/j/mine/playlist?type=n&\(channel_id)&from=mainsite"
        //获取数据
        eHttp.onSearch(url)
    }
    //设置歌曲的封面
    func onSetImage(url: String)
    {
        let image = self.imageCache[url] 
        if image == nil{
            let imgURL: NSURL = NSURL(string: url)!
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
        
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                    let img = UIImage(data: data!)
                    self.iv!.image = img
                    self.imageCache[url]=img
                })
        }
            else
            {
                // 如果缓存中有，直接取
                self.iv!.image = image
            }
    }
    
    // 播放歌曲
    func onSetAudio(url: String)
    {
        //暂停当前歌曲的播放
        self.audioPlayer.stop()
        //获取歌曲文件
        self.audioPlayer.contentURL = NSURL(string: url)
       // print("在onSetAudio中的url为\(url)")
        //播放歌曲
        self.audioPlayer.play()
        print("在onsetAudio中播放音乐")
        
        //先停掉计时器
        timer?.invalidate()
        //将计时器归零
        playTime!.text = "00:00"
        //开启计时器
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4 ,target: self, selector: "onUpdate", userInfo: nil,
            repeats: true)
        
        //btnPlay 移除tap手势
        btnPlay!.removeGestureRecognizer(tap!)
        //iv重新注册tap手势
        iv!.addGestureRecognizer(tap!)
        //隐藏btnPlay
        btnPlay!.hidden = true
    }
    
    //计时器更新
    func onUpdate()
    {
        //返回播放器当前的播放时间
        let c = audioPlayer.currentPlaybackTime
       // print("当前时间\(c)")
        if c>0.0{
            //歌曲的总时间
            let t = audioPlayer.duration
           // print("歌曲中时间为\(t)")
            //歌曲播放时间的百分比
            let p = CFloat(c/t)
           // print("此时的歌曲时间百分比为\(p)")
            //通过百分比设置进度条
            progressView.setProgress(p, animated: true)
            
            //一个小的算法，来实现00：00这种格式的播放时间
            let all: Int = Int(c)
            let m: Int = all % 60
            let f: Int = Int(all / 60)
            var time: String = ""
            //分钟
            if f<10{
                time = "0\(f)"
            }
            else{
                time = "\(f)"
            }
            //秒钟+分钟
            if m<10{
                time += ":0\(m)"
            }else{
                time += ":\(m)"
            }
            //更新时间
            playTime!.text = time
        }
    }
}

