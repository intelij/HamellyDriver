//
//  PipeLine.swift
//  Gofer
//
//  Created by bowshul sheik rahaman on 31/01/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation

struct PipeEvent {
    var id : Int?
    var name : String?
    var dataAction : (Any?)->()
}
class PipeAdapter{
    private init(){}
    private static var events = [PipeEvent]()
    static func createEvent(key : PipeLineKey,action : @escaping ()->())->Int{
        return PipeLine.createEvent(withName: key.rawValue, action: action)
    }
    static func createEvent(withName name : String ,dataAction  action: @escaping (Any?)->()) -> Int{
        PipeAdapter.events.append(PipeEvent(id : PipeAdapter.events.count,name: name, dataAction: action))
        return PipeAdapter.events.last?.id ?? -1
    }
    static func fireEvent(withKey key : PipeLineKey) -> Bool{
        return PipeLine.fireEvent(withName: key.rawValue)
    }
    static func fireEvent(_ name : String,data : Any?) -> Bool{
        let _events = PipeAdapter.events.filter({$0.name == name})
        for event in _events{
            guard event.name != nil else {return false}
            event.dataAction(data)
        }
        return true
    }
   static func deleteEvent(withName name : String)->Bool{
        let _events = PipeAdapter.events.filter({$0.name == name})
        for event in _events{
            guard let id = event.id else{return false}
            PipeAdapter.events.remove(at: id)
        }
        return true
    }
    static func deleteEvent(withID id : Int)->Bool{
        let event = PipeAdapter.events.filter({$0.id == id}).first
        guard let index = PipeAdapter.events.index(where: { (_event) -> Bool in
            return _event.id == event?.id
        }) else {return false}
        PipeAdapter.events.remove(at: index)
        return true
    }
}
class PipeLine{
    
    private init(){}
    struct Event {
        var id : Int?
        var name : String?
        var action : ()->()
    }
    
    private static var events = [Event]()
    static func createEvent(key : PipeLineKey,action : @escaping ()->())->Int{
        return PipeLine.createEvent(withName: key.rawValue, action: action)
    }
    static func createEvent(withName name : String ,action : @escaping ()->()) -> Int{
        PipeLine.events.append(Event(id : PipeLine.events.count,name: name, action: action))
        return PipeLine.events.last?.id ?? -1
    }
    static func fireEvent(withKey key : PipeLineKey) -> Bool{
        return PipeLine.fireEvent(withName: key.rawValue)
    }
    static func fireEvent(withName name : String)-> Bool{
        let _events = PipeLine.events.filter({$0.name == name})
        for event in _events{
            guard event.name != nil else {return false}
            event.action()
        }
        return true
    }
    static func deleteEvent(withName name : String)->Bool{
        let _events = PipeLine.events.filter({$0.name == name})
        for event in _events{
            guard let id = event.id else{return false}
            PipeLine.events.remove(at: id)
        }
        return true
    }
    static func deleteEvent(withID id : Int)->Bool{
        let event = PipeLine.events.filter({$0.id == id}).first
        guard let index = PipeLine.events.index(where: { (_event) -> Bool in
            return _event.id == event?.id
        }) else {return false}
        PipeLine.events.remove(at: index)
        return true
    }
}
