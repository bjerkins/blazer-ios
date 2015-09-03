//
//  NetworkLabel.swift
//  Blazer
//
//  Created by Bjarki Sorens on 03/09/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import UIKit

class NetworkLabel: UILabel {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        self.font = UIFont(name: "Helvetica Neue", size: 17.0)
        self.textColor = UIColor(red: 228.0/255.0, green: 223.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        self.textAlignment = .Center
    }

}
