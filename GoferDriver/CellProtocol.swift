//
//  MainProtocols.swift
//  GoferDriver
//
//  Created by trioangle on 10/05/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import Foundation

protocol ProjectModal {
    
}

protocol ProjectCell {
    associatedtype myCell
    var identifier : String{get}
}

extension UICollectionView{
    func generate<T:ProjectCell>(_ cell : T,forIndex index : IndexPath) -> T.myCell{
        return self.dequeueReusableCell(withReuseIdentifier: cell.identifier, for: index) as! T.myCell
    }
    func registerNib<T : ProjectCell>(_ cell : T){
        self.register(UINib(nibName: cell.identifier, bundle: nil),
                      forCellWithReuseIdentifier: cell.identifier)
    }
}
extension UITableView{
    func generate<T:ProjectCell>(_ cell : T,forIndex index : IndexPath) -> T.myCell{
        return self.dequeueReusableCell(withIdentifier: cell.identifier, for: index) as! T.myCell
    }
}
