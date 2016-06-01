//
//  ChannelController.swift
//  BFFM
//
//  Created by jim on 15/10/26.
//  Copyright © 2015年 jim. All rights reserved.
//

import UIKit

protocol Channelprotocol
{
    //实现一个方法接收回传的频道id参数
    func onChangeChannel(channel_id: String)
}


class ChannelController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    //TableView控件 频道列表
    @IBOutlet weak var tv: UITableView!
    
    //遵循ChannelProtocol协议的代理
    var delegate: Channelprotocol?
    //频道列表数据
    var channelData: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    //tableview的行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    //设置cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "channel")
        //获取到选中的行的数据
        let rowData: NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        //设置tableView的标题
        cell.textLabel?.text = rowData["name"] as? String
        return cell
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
    
    // 选中具体数据的行
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("在ChannelController中选择了第\(indexPath.row)")
        let rowData: NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        //获取选择频道的ID
        let channel_id: AnyObject = rowData["channel_id"]! as AnyObject
        //讲anyobject转为string
        let channel: String = "channel=\(channel_id)"
        // 讲频道id 传回给主界面
        delegate?.onChangeChannel(channel)
        //关闭当前界面
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
