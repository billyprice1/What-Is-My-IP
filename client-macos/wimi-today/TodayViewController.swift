//
//  TodayViewController.swift
//  wimi-today
//
//  Created by David Gatti on 7/3/16.
//  Copyright © 2016 David Gatti. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {

    @IBOutlet weak var tfIP: NSTextField!
    @IBOutlet weak var tfTime: NSTextField!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override var nibName: String? {
        return "TodayViewController"
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        completionHandler(.NoData)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //
        //  Temporary Key to be removed
        //
        let apikeyD = defaults.objectForKey("apikey") as! String;
        let utf8str = apikeyD.dataUsingEncoding(NSUTF8StringEncoding);

        var API_KEY = "";

        if let base64 = utf8str?.base64EncodedDataWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        {
            API_KEY = "Basic " + String(data: base64, encoding: NSUTF8StringEncoding)!
        }
        //c50c4730387ed2eb512fbc94579f5e535c6721c22902904334e40582d2a53a11

        //
        //  Temporary URL
        //
        let urlD = defaults.objectForKey("url") as! String;
        let url = NSURL(string: urlD)

        //
        //  1. Create the request
        //
        let request = NSMutableURLRequest(URL: url!)

        //
        //  2. Set the Authorization header
        //
        request.setValue(API_KEY, forHTTPHeaderField: "Authorization");

        //
        //  3. Create the Connection session
        //
        let session = NSURLSession.sharedSession()

        //
        //  4. Handle the HTTP Response
        //
        let task = session.dataTaskWithRequest(request){(data, response, error) in

            if let httpResponse = response as? NSHTTPURLResponse
            {
                if(httpResponse.statusCode <= 200)
                {
                    //
                    //  1. Convert the buffer in to a string
                    //
                    let strResponse = NSString(data: data!, encoding: NSUTF8StringEncoding)

                    //
                    //  2. Split the string by the new line char
                    //
                    let arrResponse = strResponse?.componentsSeparatedByString("\n")

                    //
                    //  3. Convert the Unix timestamp string in to a Doubble
                    //
                    let unixtime = Double(arrResponse![1]);

                    //
                    //  4. Create a date based on the Unix timestamp
                    //
                    let date = NSDate(timeIntervalSince1970: unixtime!)

                    //
                    //  5. Format the date in to a human readable format 
                    //     while usign the user locale.
                    //
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = NSDateFormatterStyle.LongStyle
                    formatter.timeStyle = .MediumStyle

                    //
                    //  6. Create the final date time string
                    //
                    let dateString = formatter.stringFromDate(date)

                    //
                    //  -> Print out
                    //
                    print("IP: ", arrResponse![0])
                    print("Time: ", dateString)

                    //
                    //  -> UI display
                    //
                    dispatch_async(dispatch_get_main_queue(), {

                        self.tfIP.stringValue = arrResponse![0];
                        self.tfTime.stringValue = dateString;

                    })

                }
            }
        }

        //
        // 5. Make the HTTP request.
        //
        task.resume()

    }
}
