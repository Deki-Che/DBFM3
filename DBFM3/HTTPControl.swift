
import UIKit
import Alamofire

// 定义HTTP协议
protocol HTTPProtocol {
    // 定义个方法接受参数，类型是anyobject
    func didReceiveResults(results: AnyObject)
}

class HTTPControl: NSObject {
    // 定义代理
    var delegate:HTTPProtocol?
    // 接受网址，回调代理方法，传回数据
    func onSearch(url: String) {
        
        Alamofire.request(.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { response -> Void in
            if let json = response.result.value {
                self.delegate?.didReceiveResults(json)
            }
        }
        
    }
        
}


