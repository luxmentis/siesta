//
//  AlamofireTransportProvider.swift
//  Siesta
//
//  Created by Paul on 2015/6/26.
//  Copyright © 2015 Bust Out Solutions. All rights reserved.
//

import Alamofire

/**
  Uses [Alamofire](https://github.com/Alamofire/Alamofire) for networking. This is Siesta’s default networking provider.
  
  You can create instances of this class with a custom
  [Alamofire.Manager](http://cocoadocs.org/docsets/Alamofire/1.3.0/Classes/Manager.html)
  (or, for convenience, a custom `NSURLSessionConfiguration`)
  in order to control caching, certificate validation rules, etc. For example, here is a `Service` that will not cache
  anything and will not use the cell network:
  
      class MyAPI: Service {
          init() {
              let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
              configuration.allowsCellularAccess = false
              super.init(
                  base: "http://foo.bar/vi",
                  transportProvider: AlamofireTransportProvider(configuration: configuration))
          }
      }
*/
public struct AlamofireTransportProvider: TransportProvider
    {
    public let manager: Manager
    
    public init(manager: Manager = Manager.sharedInstance)
        {
        self.manager = manager
        }
    
    public init(configuration: NSURLSessionConfiguration)
        {
        self.init(manager: Alamofire.Manager(configuration: configuration))
        }
    
    public func transportForRequest(request: NSURLRequest) -> RequestTransport
        {
        manager.startRequestsImmediately = false
        return AlamofireRequestTransport(manager.request(request))
        }
    }

internal class AlamofireRequestTransport: RequestTransport
    {
    internal var alamofireRequest: Alamofire.Request
    private(set) var isCancelled: Bool = false
    
    init(_ alamofireRequest: Alamofire.Request)
        {
        self.alamofireRequest = alamofireRequest
        }
    
    func start(response: (nsres: NSHTTPURLResponse?, body: NSData?, nserror: NSError?) -> Void)
        {
        alamofireRequest
            .response { response(nsres: $1, body: $2, nserror: $3) }
            .resume()
        }
    
    func cancel()
        {
        alamofireRequest.cancel()
        isCancelled = true
        }
    }