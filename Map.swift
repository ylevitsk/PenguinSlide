import UIKit

class Map {
    
    let width: Int, height: Int
    var entities = [Entity]()

    init(width: Int, height: Int) {

        self.width = width
        self.height = height
    }
    
    convenience init(image: UIImage) {
        
        //create image context
        let width = Int(CGImageGetWidth(image.CGImage))
        let height = Int(CGImageGetHeight(image.CGImage))
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let byteCount = bytesPerRow * height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let context = CGBitmapContextCreate(nil, UInt(width), UInt(height), 8, UInt(bytesPerRow), colorSpace, info)
        let data = UnsafePointer<UInt8>(CGBitmapContextGetData(context))
        
        //draw image into context
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        CGContextDrawImage(context, rect, image.CGImage)
        
        //enumerate pixels to generate tiles
        self.init(width: width, height: height)
       /* for i in 0 ..< width * height {
            
            //get color components
            let offset = i * bytesPerPixel
            let alpha = data[offset]
            let red = data[offset + 1]
            let green = data[offset + 2]
            let blue = data[offset + 3]
            
            //convert color to tile type
            let tile = tiles[i]
            if red == 0 && green == 0 && blue == 0 {
                tile.type = .Floor
            } else if red == 0 && green == 255 && blue == 0 {
                //entities.append(Entity(type: .Tree, x: Float(tile.x) + 0.5, y: Float(tile.y) + 0.5))
                tile.type = .Floor
            } else if red == 0 && green == 0 && blue == 255 {
                entities.append(Entity(type: .Player, x: Float(tile.x) + 0.5, y: Float(tile.y) + 0.5))
                tile.type = .Floor
            } else if red == 255 && green == 0 && blue == 0 {
                entities.append((Entity(type: .Finish, x: Float(tile.x) + 0.5, y: Float(tile.y) + 0.5)))
                tile.type = .Wall
            }
        }*/
        entities.append(Entity(type: .Player, x: Float(450) + 0.5, y: Float(2550) + 0.5))
        entities.append(Entity(type: .Finish, x: Float(0) + 0.5, y: Float(400) + 0.5))
    }
}