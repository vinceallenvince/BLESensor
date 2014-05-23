//
//  XYZFuncQueue.m
//  SerialFunc
//
//  Created by Vince Allen on 5/20/14.
//  Copyright (c) 2014 Vince Allen. All rights reserved.
//

#import "XYZFuncQueue.h"
#import <CoreMotion/CMDeviceMotion.h>

@implementation XYZFuncQueue

@synthesize myName, myVal, myOrder, myType, myData, myLabel, enabled;

- (id)init
{
    return [self initWithName:@"myName" Val:@"myVal" Order:0 Type:0x41 Data:nil Label:nil];
}

- (id)initWithName:(NSString *)myName_ Val:(NSString *)myVal_ Order:(int)myOrder_ Type:(UInt8)myType_ Data:(NSData *)myData_ Label:(UILabel *)myLabel_
{
    self = [super init];
    if (self) {
        self.myName = myName_;
        self.myVal = myVal_;
        self.myOrder = myOrder_;
        self.myType = myType_;
        self.myData = myData_;
        self.myLabel = myLabel_;
        self.enabled = false;
    }
    return self;
}

- (BOOL)toggleInputState
{
    if (self.enabled) {
        self.enabled = false;
    } else {
       self.enabled = true;
    }
    return self.enabled;
}

- (NSData *)sendDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    // create a buffer with w extra space
    UInt8 buf[0];
    NSData *dataMot = [[NSData alloc] initWithBytes:buf length:0];
    
    if ([myName isEqual:@"roll"]) {
        NSString *myMot = [NSString stringWithFormat:@"%.3f", deviceMotion.attitude.roll];
        myLabel.text = myMot;
        dataMot = [self packageDataAsType:myType FromString:myMot];
    }
    if ([myName isEqual:@"pitch"]) {
        NSString *myMot = [NSString stringWithFormat:@"%.3f", deviceMotion.attitude.pitch];
        myLabel.text = myMot;
        dataMot = [self packageDataAsType:myType FromString:myMot];
    }
    if ([myName isEqual:@"yaw"]) {
        NSString *myMot = [NSString stringWithFormat:@"%.3f", deviceMotion.attitude.yaw];
        myLabel.text = myMot;
        dataMot = [self packageDataAsType:myType FromString:myMot];
    }
    if ([myName isEqual:@"gravityX"]) {
        NSString *myMot = [NSString stringWithFormat:@"%.3f", deviceMotion.gravity.x];
        myLabel.text = myMot;
        dataMot = [self packageDataAsType:myType FromString:myMot];
    }
    if ([myName isEqual:@"gravityY"]) {
        NSString *myMot = [NSString stringWithFormat:@"%.3f", deviceMotion.gravity.y];
        myLabel.text = myMot;
        dataMot = [self packageDataAsType:myType FromString:myMot];
    }
    if ([myName isEqual:@"gravityZ"]) {
        NSString *myMot = [NSString stringWithFormat:@"%.3f", deviceMotion.gravity.z];
        myLabel.text = myMot;
        dataMot = [self packageDataAsType:myType FromString:myMot];
    }
    if ([myName isEqual:@"accelX"]) {
        NSString *myMot = [NSString stringWithFormat:@"%.3f", deviceMotion.userAcceleration.x];
        myLabel.text = myMot;
        dataMot = [self packageDataAsType:myType FromString:myMot];
    }
    if ([myName isEqual:@"accelY"]) {
        NSString *myMot = [NSString stringWithFormat:@"%.3f", deviceMotion.userAcceleration.y];
        myLabel.text = myMot;
        dataMot = [self packageDataAsType:myType FromString:myMot];
    }
    if ([myName isEqual:@"accelZ"]) {
        NSString *myMot = [NSString stringWithFormat:@"%.3f", deviceMotion.userAcceleration.z];
        myLabel.text = myMot;
        dataMot = [self packageDataAsType:myType FromString:myMot];
    }
    return dataMot;
}

- (NSData *)packageDataAsType:(UInt8)type FromString:(NSString *)str
{
    // Explode string into an array
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[str length] + 1];
    for (int i = 0; i < [str length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%c", [str characterAtIndex:i]];
        [characters addObject:ichar];
    }
    
    // create a buffer with w extra space
    UInt8 buf[[characters count] + 3];
    
    // first char is '!'
    buf[0] = 0x21;
    
    // second char is type
    buf[1] = type;
    
    // fill the buffer with char's ascii code
    for (int i = 0; i < [characters count]; i++) {
        buf[i + 2] = [characters[i] characterAtIndex:0];
    }
    
    // end the buffer with null
    buf[[characters count] + 2] = 0x00;
    
    // create data object
    NSData *data = [[NSData alloc] initWithBytes:buf length:[characters count] + 3];
    
    return data;
    
}

@end

