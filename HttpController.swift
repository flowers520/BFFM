//
//  HttpController.swift
//  BFFM
//
//  Created by jim on 15/10/26.
//  Copyright © 2015年 jim. All rights reserved.
//

import UIKit

protocol HttpProtocol{
    //定义一个方法接受一个字典 
    func didRecieveResults(resultes: NSDictionary)
}

class HttpController: NSObject {
    //定义一个可选代理
    var delegate: HttpProtocol?
    
    //定义一个方法运过来获取网络数据，接收参数为网址
    func onSearch(url: String){
        //定义一个NSURL
        let nsUrl: NSURL = NSURL(string: url)!
        //定义一个NSURLRequest
        let request: NSURLRequest = NSURLRequest(URL: nsUrl)
        //异步获取数据
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:
            {(response: NSURLResponse?, data: NSData?, error: NSError?)->Void in
                // 由于我们获取的数据是json 格式， 所以我们可以将其转化为字典。                
                let jsonResult: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                //将数据传回给代理
                self.delegate!.didRecieveResults(jsonResult)
        })
             }
    

}
