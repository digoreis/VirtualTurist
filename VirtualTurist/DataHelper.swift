//
//  DataHelper.swift
//  UdacityOnTheMap
//
//  Created by apple on 22/10/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import Foundation

infix operator <- : AdditionPrecedence
infix operator <<< : AdditionPrecedence
infix operator <<- : AdditionPrecedence


func <- <T : Mappable>( left: inout [T]?, right : Any?) {
    guard let values = right as? [Any] else {left = nil; return}
    left = values.flatMap{ $0 as? NSDictionary }.flatMap { T(json : $0) }
}

func <- <T>( left: inout T?, right : Any?) {
    guard let value = right as? T else {left = nil; return}
    left = value
}

func <- <T : Mappable>( left: inout T?, right : Any?) {
    guard let value = right as? NSDictionary else {left = nil; return}
    left = T(json : value)
}

func <- ( left: inout Bool, right : Any?){
    guard let value = right as? Bool else {left = false; return}
    left = value
}

func <- ( left: inout Date?, right : (Any?,DateFormatter)){
    let dateFormatter = right.1
    guard let stringDate = right.0 as? String,let value = dateFormatter.date(from: stringDate) else {left = nil; return}
    left = value
}

func <<- (left: inout NSDictionary? , right : Data?) {
    guard let data = right?.subdata(in: 5..<(right?.count ?? 0)),
        let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? NSDictionary else { left = nil; return }
    left = json
}

func <<< (left: inout NSDictionary? , right : Data?) {
    guard let data = right,
    let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? NSDictionary else { left = nil; return }
    left = json
}

protocol Mappable {
    init(json : NSDictionary)
}
    
