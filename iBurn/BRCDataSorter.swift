//
//  BRCDataSorter.swift
//  iBurn
//
//  Created by Christopher Ballinger on 8/11/15.
//  Copyright (c) 2015 Burning Man Earth. All rights reserved.
//

import UIKit
import YapDatabase

public class BRCDataSorterOptions {
    open var showExpiredEvents: Bool
    open var showFutureEvents: Bool
    /** Default true. Puts expired events at bottom. */
    open var sortEventsWithExpiration: Bool
    open var now: Date
    public init () {
        showExpiredEvents = false
        showFutureEvents = false
        sortEventsWithExpiration = true
        now = Date()
        /* DATE TESTING
        #if DEBUG
        now = NSDate.brc_testDate()
        #endif
         */
    }
}

/**
 * For "smart sorting" big arrays of BRCDataObjects into events, art, and camps.
 * Used by Nearby and Favorites screen.
 */
public class BRCDataSorter: NSObject {
    open static func sortDataObjects(
        _ objects: [BRCDataObject],
        options: BRCDataSorterOptions?,
        completionQueue: DispatchQueue?,
        callbackBlock: @escaping (_ events: [BRCEventObject],
        _ art: [BRCArtObject], _ camps: [BRCCampObject]) -> (Void)) {
            let queue = completionQueue ?? DispatchQueue.main
            let opt = options ?? BRCDataSorterOptions()
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: { () -> Void in
                var events: [BRCEventObject] = []
                var art: [BRCArtObject] = []
                var camps: [BRCCampObject] = []
                for object in objects {
                    if let event = object as? BRCEventObject {
                        events.append(event)
                    }
                    if let artObject = object as? BRCArtObject {
                        art.append(artObject)
                    }
                    if let camp = object as? BRCCampObject {
                        camps.append(camp)
                    }
                }
                if !opt.showExpiredEvents {
                    events = events.filter { !$0.hasEnded(opt.now) }
                }
                if !opt.showFutureEvents {
                    events = events.filter { $0.isStartingSoon(opt.now) }
                }
                if opt.sortEventsWithExpiration {
                    var expiredEvents = events.filter { $0.hasEnded(opt.now) }
                    var nonExpired = events.filter { !$0.hasEnded(opt.now) }
                    expiredEvents.sort {
                        $0.startDate.timeIntervalSinceNow < $1.startDate.timeIntervalSinceNow
                    }
                    nonExpired.sort {
                        $0.startDate.timeIntervalSinceNow < $1.startDate.timeIntervalSinceNow
                    }
                    events = nonExpired + expiredEvents
                } else {
                    events.sort {
                        $0.startDate.timeIntervalSinceNow < $1.startDate.timeIntervalSinceNow
                    }
                }
                camps.sort { $0.title < $1.title }
                art.sort { $0.title < $1.title }
                queue.async(execute: { () -> Void in
                    callbackBlock(events, art, camps)
                })
            });
            
    }
}
