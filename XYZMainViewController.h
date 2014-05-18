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
    IBOutlet UIButton *btnCalibrate;
    IBOutlet UISwitch *switchRoll;
    IBOutlet UISwitch *switchPitch;
    IBOutlet UISwitch *switchYaw;
    IBOutlet UISwitch *switchGravX;
    IBOutlet UISwitch *switchGravY;
    IBOutlet UISwitch *switchGravZ;
    IBOutlet UISwitch *switchAccelX;
    IBOutlet UISwitch *switchAccelY;
    IBOutlet UISwitch *switchAccelZ;
    IBOutlet UIActivityIndicatorView *indConnecting;
    IBOutlet UILabel *lblRSSI;
}

@property (strong, nonatomic) BLE *ble;
@property BOOL sendRoll;
@property BOOL sendPitch;
@property BOOL sendYaw;
@property BOOL sendGravX;
@property BOOL sendGravY;
@property BOOL sendGravZ;
@property BOOL sendAccelX;
@property BOOL sendAccelY;
@property BOOL sendAccelZ;
@property int packageIndex;

- (NSData *)packageDataAsType:(UInt8)type FromString:(NSString *)str;

@end