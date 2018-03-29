//
//  EventItem.swift
//  iOSTestTasck
//
//  Created by Mac on 3/26/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation

class EventItem{
    var id : Int
    var fromCity : City
    var fromDate : String
    var fromTime : String
    var fromInfo : String
    var toCity : City
    var toDate : String
    var toTime : String
    var toInfo : String
    var info : String
    var price : Int
    var busId : Int
    var reservationCount : Int
    
    init (id : Int, fromCity : City, fromDate : String, fromTime : String, fromInfo : String, toCity : City, toDate : String, toTime : String, toInfo : String, info : String, price : Int, busId : Int, reservationCount : Int){
        self.id = id
        self.fromCity = fromCity
        self.fromDate = fromDate
        self.fromTime = fromTime
        self.fromInfo = fromInfo
        self.toCity = toCity
        self.toDate = toDate
        self.toTime = toTime
        self.toInfo = toInfo
        self.info = info
        self.price = price
        self.busId = busId
        self.reservationCount = reservationCount
    }
}
