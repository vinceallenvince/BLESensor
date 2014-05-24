//
//  XYZMainViewController.m
//  BLESensor
//
//  Created by Vince Allen on 5/12/14.
//  Copyright (c) 2014 Vince Allen. All rights reserved.
//

#import "XYZMainViewController.h"
#import "XYZAppDelegate.h"
#import "XYZFuncQueue.h"

static const NSTimeInterval deviceMotionMin = 0.01;

@interface XYZMainViewController ()

@end

@implementation XYZMainViewController

@synthesize records, q, ble, sendRoll, sendPitch, sendYaw, sendGravX, sendGravY, sendGravZ, sendAccelX, sendAccelY, sendAccelZ, packageIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    [btnCalibrate setEnabled:false];
    [btnAction setEnabled:false];
    
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
    [btnAction setEnabled:false];
    [self resetSwitches];
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
    [btnAction setEnabled:false];
    [ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [indConnecting startAnimating];
}

-(void) connectionTimer:(NSTimer *)timer
{
    
    records = [NSMutableArray arrayWithCapacity:3];
    q = [NSMutableArray arrayWithCapacity:3];
    
    [records addObject:[[XYZFuncQueue alloc] initWithName:@"roll" Val:@"0" Order:0 Type:0x41 Data:nil Label:labelRoll]];
    [records addObject:[[XYZFuncQueue alloc] initWithName:@"pitch" Val:@"0" Order:1 Type:0x42 Data:nil Label:labelPitch]];
    [records addObject:[[XYZFuncQueue alloc] initWithName:@"yaw" Val:@"0" Order:2 Type:0x43 Data:nil Label:labelYaw]];
    [records addObject:[[XYZFuncQueue alloc] initWithName:@"gravityX" Val:@"0" Order:3 Type:0x44 Data:nil Label:labelGravityX]];
    [records addObject:[[XYZFuncQueue alloc] initWithName:@"gravityY" Val:@"0" Order:4 Type:0x45 Data:nil Label:labelGravityY]];
    [records addObject:[[XYZFuncQueue alloc] initWithName:@"gravityZ" Val:@"0" Order:5 Type:0x46 Data:nil Label:labelGravityZ]];
    [records addObject:[[XYZFuncQueue alloc] initWithName:@"accelX" Val:@"0" Order:6 Type:0x47 Data:nil Label:labelAccelX]];
    [records addObject:[[XYZFuncQueue alloc] initWithName:@"accelY" Val:@"0" Order:7 Type:0x48 Data:nil Label:labelAccelY]];
    [records addObject:[[XYZFuncQueue alloc] initWithName:@"accelZ" Val:@"0" Order:8 Type:0x49 Data:nil Label:labelAccelZ]];
    
    [self enableSwitches];
    
    [btnConnect setEnabled:true];
    [btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    [btnCalibrate setEnabled:true];
    [btnAction setEnabled:true];
    
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
    NSLog(@"calibrate...");
    
    UInt8 buf[3] = {0x21, 0x24, 0x00};
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    
}

- (IBAction)btnAction:(id)sender
{
    NSLog(@"action!");
    
    UInt8 buf[3] = {0x21, 0x23, 0x00};
    
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
            
            for (XYZFuncQueue *input in records) {
                if (input.enabled) { // if enabled
                    if (![q containsObject:input]) { // if not already queued
                        [self spliceObj:input IntoQ:q];
                    }
                } else { // if not enabled, remove from q
                    [q removeObjectIdenticalTo:input];
                }
            }
            
            if (q.count > 0) {
                [ble write:[q[0] sendDeviceMotion: deviceMotion]]; // sendDeviceMotion from first queued obj
                [q removeObjectAtIndex:0]; // remove it
            }
        }];
    }
    
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

- (void)resetSwitches
{
    [switchRoll setOn:false animated:true];
    [switchPitch setOn:false animated:true];
    [switchYaw setOn:false animated:true];
    [switchGravX setOn:false animated:true];
    [switchGravY setOn:false animated:true];
    [switchGravZ setOn:false animated:true];
    [switchAccelX setOn:false animated:true];
    [switchAccelY setOn:false animated:true];
    [switchAccelZ setOn:false animated:true];
}

- (IBAction)switchRoll:(id)sender
{
    [records[0] toggleInputState];
}

- (IBAction)switchPitch:(id)sender
{
    [records[1] toggleInputState];
}

- (IBAction)switchYaw:(id)sender
{
    [records[2] toggleInputState];
}

- (IBAction)switchGravX:(id)sender
{
    [records[3] toggleInputState];
}

- (IBAction)switchGravY:(id)sender
{
    [records[4] toggleInputState];
}

- (IBAction)switchGravZ:(id)sender
{
    [records[5] toggleInputState];
}

- (IBAction)switchAccelX:(id)sender
{
    [records[6] toggleInputState];
}

- (IBAction)switchAccelY:(id)sender
{
    [records[7] toggleInputState];
}

- (IBAction)switchAccelZ:(id)sender
{
    [records[8] toggleInputState];
}

- (void)spliceObj:(XYZFuncQueue *)input IntoQ:(NSMutableArray *)queue
{
    int i = 0;
    for (XYZFuncQueue *qdObj in queue) {
        if (i > 0 && qdObj.myOrder == input.myOrder + 1) {
            [queue insertObject:input atIndex:i];
            return;
        }
        i++;
    }
    [queue addObject: input];
}

@end

