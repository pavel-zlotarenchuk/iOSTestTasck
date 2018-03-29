//
//  ViewControlerTwo.swift
//  iOSTestTasck
//
//  Created by Mac on 23.03.18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import UIKit

class ViewControlerTwo: UIViewController {
    var indexData : Int = 0
    var item : EventItem? = nil
    
    @IBOutlet weak var ladelText: UILabel!
    static func initFromStoryBoard() -> UIViewController{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewControlerTwo")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let strongItem = item{
            ladelText.text = """
            Id: \(strongItem.id)
            
            From city: \(strongItem.fromCity.name)
            To city: \(strongItem.toCity.name)
            Info: \(strongItem.info)
            
            Departure date: \(strongItem.fromDate)
            Departure time: \(strongItem.fromTime)
            Additional Information: \(strongItem.fromInfo)
            
            Arrival date: \(strongItem.toDate)
            Arrival time: \(strongItem.toTime)
            Additional Information: \(strongItem.fromInfo)
            
            Price: \(strongItem.price)
            Number bus: \(strongItem.busId)
            Reservation count: \(strongItem.reservationCount)
            """
        }
    }
}
