//
//  XYZAppDelegate.h
//  BLESensor
//
//  Created by Vince Allen on 5/12/14.
//  Copyright (c) 2014 Vince Allen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface XYZAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) CMMotionManager *sharedManager;

@end
