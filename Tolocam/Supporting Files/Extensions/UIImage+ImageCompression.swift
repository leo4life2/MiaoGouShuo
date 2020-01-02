//
//  UIImage + ImageCompression.swift
//  Tolocam
//
//  Created by Leo on 2018/9/23.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

extension UIImage {
    var uncompressedPNGData:      Data { return self.pngData()!                          }
    var highestQualityJPEGNSData: Data { return self.jpegData(compressionQuality: 1.0)!  }
    var highQualityJPEGNSData:    Data { return self.jpegData(compressionQuality: 0.75)! }
    var mediumQualityJPEGNSData:  Data { return self.jpegData(compressionQuality: 0.5)!  }
    var lowQualityJPEGNSData:     Data { return self.jpegData(compressionQuality: 0.25)! }
    var lowestQualityJPEGNSData:  Data { return self.jpegData(compressionQuality: 0.0)!  }
}
