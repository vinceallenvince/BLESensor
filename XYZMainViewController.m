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

@synthesize ble;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    [btnTest setEnabled:false];
    
    
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
    [btnTest setEnabled:true];
    
    [btnConnect setEnabled:true];
    [btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    
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

- (IBAction)btnTest:(id)sender
{
    NSLog(@"sending...");
    
    UInt8 buf[6] = {0x26, 0x2d, 0, 0x2e, 9, 2}; // begin all buffers w '&' (0x26)
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:6];
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
            
            
            // gravity
            NSString *myGravXString = [NSString stringWithFormat:@"%.3f", deviceMotion.gravity.x];
            NSString *myGravYString = [NSString stringWithFormat:@"%.3f", deviceMotion.gravity.y];
            NSString *myGravZString = [NSString stringWithFormat:@"%.3f", deviceMotion.gravity.z];
            
            //NSLog(myGravZString);
            
            NSData *dataX = [self packageDataAsType:0x41 FromString:myGravXString];
            [ble write:dataX];
            
            NSData *dataY = [self packageDataAsType:0x42 FromString:myGravYString];
            [ble write:dataY];
            
            NSData *dataZ = [self packageDataAsType:0x43 FromString:myGravZString];
            [ble write:dataZ];
            
            
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



@end

