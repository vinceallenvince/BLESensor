//
//  XYZFuncQueue.h
//  SerialFunc
//
//  Created by Vince Allen on 5/20/14.
//  Copyright (c) 2014 Vince Allen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XYZFuncQueue : NSObject

@property (strong, nonatomic) NSString *myName;
@property (strong, nonatomic) NSString *myVal;
@property (strong, nonatomic) NSData *myData;
@property UInt8 myType;
@property BOOL enabled;
@property int myOrder;
@property (strong, nonatomic) UILabel *myLabel;

- (id)initWithName:(NSString *)myName_ Val:(NSString *)myVal_ Order:(int)myOrder_ Type:(UInt8)myType_ Data:(NSData *)myData_ Label:(UILabel *)myLabel_;
- (BOOL)toggleInputState;
- (NSData *)sendDeviceMotion:(NSObject *)deviceMotion;
- (NSData *)packageDataAsType:(UInt8)type FromString:(NSString *)str;

@end


