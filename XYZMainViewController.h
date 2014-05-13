//
//  TableViewController.h
//  SimpleControl
//
//  Created by Cheong on 7/11/12.
//  Copyright (c) 2012 RedBearLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CMMotionManager.h>
#import "BLE.h"

@interface XYZMainViewController : UIViewController <BLEDelegate>
{
    IBOutlet UIButton *btnConnect;
    IBOutlet UIButton *btnTest;
    IBOutlet UIActivityIndicatorView *indConnecting;
    IBOutlet UILabel *lblRSSI;
}

@property (strong, nonatomic) BLE *ble;

@end