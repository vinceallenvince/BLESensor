//
//  XYZMainViewController.m
//  BLESensor
//
//  Created by Vince Allen on 5/12/14.
//  Copyright (c) 2014 Vince Allen. All rights reserved.
//

#import "XYZMainViewController.h"
#import "XYZAppDelegate.h"

static const NSTimeInterval deviceMotionMin = 0.01;

@interface XYZMainViewController ()

@end

@implementation XYZMainViewController

@synthesize ble, sendRoll, sendPitch, sendYaw, sendGravX, sendGravY, sendGravZ, sendAccelX, sendAccelY, sendAccelZ, packageIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    [btnCalibrate setEnabled:false];
    
    [self disableSwitches];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BLE delegate

NSTimer *rssiTimer;

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    
    [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    [indConnecting stopAnimating];
    
    lblRSSI.text = @"---";
    //   lblAnalogIn.text = @"----";
    
    [rssiTimer invalidate];
    [btnCalibrate setEnabled:false];
    [self disableSwitches];
}

// When RSSI is changed, this will be called
-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    lblRSSI.text = rssi.stringValue;
}

-(void) readRSSITimer:(NSTimer *)timer
{
    [ble readRSSI];
}

// When disconnected, this will be called
-(void) bleDidConnect
{
    NSLog(@"->Connected");
    
    [indConnecting stopAnimating];
    
    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
    
    // start Motion Manager
    [self startSensorUpdates];
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3)
    {
        NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
        if (data[i] == 0x0A)
        {
                
        }
        else if (data[i] == 0x0B)
        {

        }
    }
}

#pragma mark - Actions

// Connect button will call to this
- (IBAction)btnScanForPeripherals:(id)sender
{
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
        
        [btnConnect setEnabled:false];
    [ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [indConnecting startAnimating];
}

-(void) connectionTimer:(NSTimer *)timer
{
    
    [self enableSwitches];
    
    [btnConnect setEnabled:true];
    [btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    [btnCalibrate setEnabled:true];
    
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
        [indConnecting stopAnimating];
    }
}

- (IBAction)btnCalibrate:(id)sender
{
    NSLog(@"sending...");
    
    UInt8 buf[3] = {0x21, 0x24, 0x00};
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    
}

- (void)startSensorUpdates
{
    
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = deviceMotionMin + delta * 1; // * some offset
    
    CMMotionManager *mManager = [(XYZAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    if ([mManager isDeviceMotionAvailable] == YES) {
        [mManager setDeviceMotionUpdateInterval:updateInterval];
        [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
            
            
            
            // attitude
            if (sendRoll && packageIndex == 0) {
                NSString *myRoll = [NSString stringWithFormat:@"%.3f", deviceMotion.attitude.roll];
                NSData *dataRoll = [self packageDataAsType:0x41 FromString:myRoll];
                [ble write:dataRoll];
            }
            
            if (sendPitch && packageIndex == 1) {
                NSString *myPitch = [NSString stringWithFormat:@"%.3f", deviceMotion.attitude.pitch];
                NSData *dataPitch = [self packageDataAsType:0x42 FromString:myPitch];
                [ble write:dataPitch];
            }
            
            if (sendYaw && packageIndex == 2) {
                NSString *myYaw = [NSString stringWithFormat:@"%.3f", deviceMotion.attitude.yaw];
                NSData *dataYaw = [self packageDataAsType:0x43 FromString:myYaw];
                [ble write:dataYaw];
            }
            
            // gravity
            if (sendGravX && packageIndex == 3) {
                NSString *myGravXString = [NSString stringWithFormat:@"%.3f", deviceMotion.gravity.x];
                NSData *dataX = [self packageDataAsType:0x44 FromString:myGravXString];
                [ble write:dataX];
            }
            
            if (sendGravY && packageIndex == 4) {
                NSString *myGravYString = [NSString stringWithFormat:@"%.3f", deviceMotion.gravity.y];
                NSData *dataY = [self packageDataAsType:0x45 FromString:myGravYString];
                [ble write:dataY];
            }
            
            if (sendGravZ && packageIndex == 5) {
                NSString *myGravZString = [NSString stringWithFormat:@"%.3f", deviceMotion.gravity.z];
                NSData *dataZ = [self packageDataAsType:0x46 FromString:myGravZString];
                [ble write:dataZ];
            }
            
            // userAcceleration
            if (sendAccelX && packageIndex == 6) {
                NSString *myAccelXString = [NSString stringWithFormat:@"%.3f", deviceMotion.userAcceleration.x];
                NSData *dataAccelX = [self packageDataAsType:0x47 FromString:myAccelXString];
                [ble write:dataAccelX];
            }
            
            if (sendAccelY && packageIndex == 7) {
                NSString *myAccelYString = [NSString stringWithFormat:@"%.3f", deviceMotion.userAcceleration.y];
                NSData *dataAccelY = [self packageDataAsType:0x48 FromString:myAccelYString];
                [ble write:dataAccelY];
            }
            
            if (sendAccelZ && packageIndex == 8) {
                NSString *myAccelZString = [NSString stringWithFormat:@"%.3f", deviceMotion.userAcceleration.z];
                NSData *dataAccelZ = [self packageDataAsType:0x49 FromString:myAccelZString];
                [ble write:dataAccelZ];
            }
            
            if (packageIndex < 9) {
                packageIndex++;
            } else {
                packageIndex = 0;
            }
        }];
    }
    
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

- (void)enableSwitches
{
    [switchRoll setEnabled:true];
    [switchPitch setEnabled:true];
    [switchYaw setEnabled:true];
    [switchGravX setEnabled:true];
    [switchGravY setEnabled:true];
    [switchGravZ setEnabled:true];
    [switchAccelX setEnabled:true];
    [switchAccelY setEnabled:true];
    [switchAccelZ setEnabled:true];
}

- (void)disableSwitches
{
    [switchRoll setEnabled:false];
    [switchPitch setEnabled:false];
    [switchYaw setEnabled:false];
    [switchGravX setEnabled:false];
    [switchGravY setEnabled:false];
    [switchGravZ setEnabled:false];
    [switchAccelX setEnabled:false];
    [switchAccelY setEnabled:false];
    [switchAccelZ setEnabled:false];
}

- (IBAction)switchRoll:(id)sender
{
    if (switchRoll.on) {
        sendRoll = true;
    } else {
        sendRoll = false;
    }
}

- (IBAction)switchPitch:(id)sender
{
    if (switchPitch.on) {
        sendPitch = true;
    } else {
        sendPitch = false;
    }
}

- (IBAction)switchYaw:(id)sender
{
    if (switchYaw.on) {
        sendYaw = true;
    } else {
        sendYaw = false;
    }
}

- (IBAction)switchGravX:(id)sender
{
    if (switchGravX.on) {
        sendGravX = true;
    } else {
        sendGravX = false;
    }
}

- (IBAction)switchGravY:(id)sender
{
    if (switchGravY.on) {
        sendGravY = true;
    } else {
        sendGravY = false;
    }
}

- (IBAction)switchGravZ:(id)sender
{
    if (switchGravZ.on) {
        sendGravZ = true;
    } else {
        sendGravZ = false;
    }
}

- (IBAction)switchAccelX:(id)sender
{
    if (switchAccelX.on) {
        sendAccelX = true;
    } else {
        sendAccelX = false;
    }
}

- (IBAction)switchAccelY:(id)sender
{
    if (switchAccelY.on) {
        sendAccelY = true;
    } else {
        sendAccelY = false;
    }
}

- (IBAction)switchAccelZ:(id)sender
{
    if (switchAccelZ.on) {
        sendAccelZ = true;
    } else {
        sendAccelZ = false;
    }
}

@end

