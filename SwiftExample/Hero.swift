//
//  ViewController.swift
//  SwiftExample
//
//  Created by Jason Chen on 17/02/18.
//  Copyright © 2018 Jason Chen. All rights reserved.
//
class Hero {
    
    var id: Int
    var name: String?
    var powerRanking: Int
    
    init(id: Int, name: String?, powerRanking: Int){
        self.id = id
        self.name = name
        self.powerRanking = powerRanking
    }
}
