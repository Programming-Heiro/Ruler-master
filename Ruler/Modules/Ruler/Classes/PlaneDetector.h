//
//  PlaneDetector.h
//  Ruler
//
//  Created by 刘友 on 2019/3/13.
//  Copyright © 2019 刘友. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface PlaneDetector : NSObject

+ (SCNVector4)detectPlaneWithPoints:(NSArray <NSValue* >*)points;


@end
