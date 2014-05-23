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
#import "XYZFuncQueue.h"

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
    IBOutlet UILabel *labelRoll;
    IBOutlet UILabel *labelPitch;
    IBOutlet UILabel *labelYaw;
    IBOutlet UILabel *labelGravityX;
    IBOutlet UILabel *labelGravityY;
    IBOutlet UILabel *labelGravityZ;
    IBOutlet UILabel *labelAccelX;
    IBOutlet UILabel *labelAccelY;
    IBOutlet UILabel *labelAccelZ;
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

//
@property (strong, nonatomic) NSMutableArray *records;
@property (strong, nonatomic) NSMutableArray *q;
- (void)spliceObj:(XYZFuncQueue *)input IntoQ:(NSMutableArray *)q;

@end