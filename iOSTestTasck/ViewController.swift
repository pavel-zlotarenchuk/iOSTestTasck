//
//  ViewController.swift
//  iOSTestTasck
//
//  Created by Mac on 23.03.18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import CoreData
import AFNetworking
import MessageUI

import FacebookLogin
import FBSDKLoginKit

import SwiftyJSON

class ViewController: UIViewController {
    var modelArray = [String]()
    var modelEvent = [EventItem]()
    let url : String = "http://projects.gmoby.org/web/index.php/api/trips?from_date=2016-01-01&to_date=2018-03-01";
    
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.blue
        return refreshControl
    }()
    
    lazy var loginButton = LoginButton(readPermissions: [ .publicProfile ])
    var facebookLoginVisible = false
    var dict : [String : AnyObject]!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var facebookButton: UIBarButtonItem!
    @IBOutlet weak var getFriendsButton: UIBarButtonItem!
    @IBOutlet weak var postLogs: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.addSubview(self.refreshControl)
        //        loadJson()
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(){
        selectDB()
    }
    
    func loadJson(){
        var manager : AFHTTPSessionManager
        manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: ["application/json", "text/html"]) as? Set<String>
        
        manager.get(url, parameters: nil, progress: nil, success: { (task, data) in
            if let json = data as? Dictionary<String, Any?> , let list = json["data"] as? Array<Dictionary<String, Any>>{
                //print(list)
                for item in list{
                    var fromCityJson = item["from_city"] as! [String : Any]
                    let fromCity = City(highlight: fromCityJson["highlight"] as! Int, id: fromCityJson["id"] as! Int, name: fromCityJson["name"] as! String)
                    var toCityJson = item["to_city"] as! [String : Any]
                    let toCity = City(highlight: toCityJson["highlight"] as! Int, id: toCityJson["id"] as! Int, name: toCityJson["name"] as! String)
                    print(fromCityJson)
                    let eventItem = EventItem(id: item["id"] as! Int,
                                              fromCity: fromCity,
                                              fromDate: item["from_date"] as! String,
                                              fromTime: item["from_time"] as! String,
                                              fromInfo: item["from_info"] as! String,
                                              toCity: toCity,
                                              toDate: item["to_date"] as! String,
                                              toTime: item["to_time"] as! String,
                                              toInfo: item["to_info"] as! String,
                                              info: item["info"] as! String,
                                              price: item["price"] as! Int,
                                              busId: item["bus_id"] as! Int,
                                              reservationCount: item["reservation_count"] as! Int)
                    self.modelEvent.append(eventItem)
                    self.modelArray.append(" \(eventItem.id) | \(eventItem.fromCity.name) | \(eventItem.toCity.name) | \(eventItem.toDate)")
                    self.saveCoreData(id: Int32(eventItem.id),
                                      fromHighlight: Int32(eventItem.fromCity.highlight), fromId: Int32(eventItem.fromCity.id), fromName: eventItem.fromCity.name, fromDate: eventItem.fromDate, fromTime: eventItem.fromTime, fromInfo: eventItem.fromInfo,
                                      toHighlight: Int32(eventItem.toCity.highlight), toId: Int32(eventItem.toCity.id), toName: eventItem.toCity.name, toDate: eventItem.toDate, toTime: eventItem.fromTime, toInfo: eventItem.toInfo,
                                      info: eventItem.info, price: Int32(eventItem.price), busId: Int32(eventItem.busId), reservationCount: Int32(eventItem.reservationCount))
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
                
            }
        }, failure: { (task, error) in
            print(error)
        })
        DDLogInfo("loadJson complite")
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadJson()
    }
    
    func saveCoreData(id : Int32, fromHighlight : Int32, fromId : Int32, fromName : String, fromDate : String, fromTime : String, fromInfo : String,
                      toHighlight : Int32, toId : Int32, toName : String, toDate : String, toTime : String, toInfo : String,
                      info : String, price : Int32, busId : Int32, reservationCount : Int32){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: "Event", into: context) as! Event
        
        newEntity.id = id
        
        newEntity.from_highlight = fromHighlight
        newEntity.from_id = fromId
        newEntity.from_name = fromName
        newEntity.from_date = fromDate
        newEntity.from_time = fromTime
        newEntity.from_info = fromInfo
        
        newEntity.to_highlight = toHighlight
        newEntity.to_id = toId
        newEntity.to_name = toName
        newEntity.to_date = toDate
        newEntity.to_time = toTime
        newEntity.to_info = toInfo
        
        newEntity.info = info
        newEntity.price = price
        newEntity.bus_id = busId
        newEntity.reservation_count = reservationCount
        
        do {
            try context.save()
        } catch {
            print("Error save in core data")
        }
        
        DDLogInfo("saveCoreData complite")
    }
    
    func selectDB(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        fetchRequest.fetchLimit = 10
        var fetchedEntities = [Event]()
        do {
            fetchedEntities = try context.fetch(fetchRequest) as! [Event]
        } catch {
            print("Error load in core data")
        }
        if fetchedEntities.count > 0 {
            for item in fetchedEntities{
                let fromCity = City(highlight: Int(item.from_highlight), id: Int(item.from_id), name: item.from_name!)
                let toCity = City(highlight: Int(item.to_highlight), id: Int(item.to_id), name: item.to_name!)
                let eventItem = EventItem(id: Int(item.id),
                                          fromCity: fromCity,
                                          fromDate: item.from_date!,
                                          fromTime: item.from_time!,
                                          fromInfo: item.from_info!,
                                          toCity: toCity,
                                          toDate: item.to_date!,
                                          toTime: item.to_time!,
                                          toInfo: item.to_info!,
                                          info: item.info!,
                                          price: Int(item.price),
                                          busId: Int(item.bus_id),
                                          reservationCount: Int(item.reservation_count))
                
                self.modelEvent.append(eventItem)
                self.modelArray.append(" \(eventItem.id) | \(eventItem.fromCity.name) | \(eventItem.toCity.name) | \(eventItem.toDate)")
            }
            self.tableView.reloadData()
        } else {
            loadJson()
        }
        DDLogInfo("selectDB complite")
    }
    
    @IBAction func facebookButtonAction(_ sender: Any) {
        if facebookLoginVisible {
            loginButton.removeFromSuperview()
            facebookLoginVisible = false
        } else {
            loginButton.center = view.center
            //adding it to view
            view.addSubview(loginButton)
            facebookLoginVisible = true
        }
    }
    
    @IBAction func getFriendsButtonAction(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .userPosts], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                self.getFBPosts()
            }
        }
    }
    
    @IBAction func postLogsAction(_ sender: Any) {
        sendFeedbackEmail()
    }
    
    //function is fetching the user data
    func getFBPosts(){
        if((FBSDKAccessToken.current()) != nil){
            modelArray.removeAll()
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "posts"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    let json = JSON(self.dict)
                    let postsJSONArray = json["posts"]
                    let dataJSONArray = postsJSONArray["data"]
                    for messageJSON in dataJSONArray {
                        if (messageJSON.1["message"].string != nil){
                            print(messageJSON.1["message"].stringValue)
                            self.modelArray.append(messageJSON.1["message"].stringValue)
                        }
                    }
                    print(self.modelArray.count)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
        DDLogInfo("getFBPosts complite")
    }
    
    
}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! InfoCell
        cell.infoLabel?.text = modelArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewControlerTwo = ViewControlerTwo.initFromStoryBoard() as! ViewControlerTwo
        viewControlerTwo.indexData = indexPath.row
        viewControlerTwo.item = modelEvent[indexPath.row]
        
        self.navigationController?.pushViewController(viewControlerTwo, animated: true)
    }
    
    // MARK: - Sender message logs
    func sendFeedbackEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["pavel.zlotarenchuk@gmail.com"])
            
            var attachmentData = Data()
            
            for logFileData in CocoaLumberjackLoger.getLogFileDataArray() {
                attachmentData.append(logFileData)
            }
            
            let nsObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
            let version = nsObject as? String
            let build = Bundle.main.infoDictionary?["CFBundleVersion"]  as? String
            let logFileName = "iOSTestTasck\(version ?? "1.0")(\(build ?? "1.0")).log"
            
            mail.addAttachmentData(attachmentData, mimeType: "text/plain", fileName: logFileName)
            
            present(mail, animated: true)
        } else {
            print("MailComposerError")
        }
    }
    
    //    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        <#code#>
    //    }
}

extension ViewController : MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    }
}
