//
//  SnapTrackCentralViewController.m
//  SnapTrackCentral
//
//  Created by Sanka, Dheeraj on 8/29/13.
//  Copyright (c) 2013 Sanka, Dheeraj. All rights reserved.
//

#import "SnapTrackCentralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define CHARACTERISTIC_NAME_UUID_STRING @"C54C3B19-64AC-423A-8282-09BA48CDB28C"
#define SNAPTRACK_SERVICE_UUID_STRING @"7D12"

@interface SnapTrackCentralViewController () <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong, nonatomic) IBOutlet UITextView   *textview;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;
@property (strong,nonatomic)  NSString              *employeeName;
@property (strong,nonatomic)  NSDate                *startTime;

@end

@implementation SnapTrackCentralViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Start up the CBCentralManager
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL" message:@"Dee dee doo doo." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    */
    // And somewhere to store the incoming data
    _data = [[NSMutableData alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SNAPTRACK_SERVICE_UUID_STRING]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...
    
    // ... so start scanning
    [self scan];
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    /*// Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) {
        return;
    }
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    if (RSSI.integerValue < -35) {
        return;
    }*/
    
    
    
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanup];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Stop scanning
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    // Clear the data that we may already have
    [self.data setLength:0];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SNAPTRACK_SERVICE_UUID_STRING]]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"service discovered");
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:SNAPTRACK_SERVICE_UUID_STRING]] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"characteristic discovered");
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
       if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_NAME_UUID_STRING]]) {
           NSLog(@"found characteristic we are looking for");
            [peripheral readValueForCharacteristic:characteristic];
            // If it is, subscribe to it
           // [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        
        // We have, so show the data,
        [self.textview setText:[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];
        
        // Cancel our subscription to the characteristic
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        // and disconnect from the peripehral
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
    // Otherwise, just add the data on to what we already have
    [self.data appendData:characteristic.value];
    
    // Log it
    NSLog(@"Received: %@", stringFromData);
    
    _employeeName = stringFromData;
    
    NSString *alertString = [NSString stringWithFormat:@" %@ checked in",_employeeName];
    _startTime = [[NSDate alloc] init];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL" message:alertString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"peripheral disconnected");
    
    NSDate *endTime = [[NSDate alloc] init];
    
    NSTimeInterval timeWorked = [endTime timeIntervalSinceDate:_startTime];
    
    NSString *alertString = [NSString stringWithFormat:@" %@ checked out after %f seconds",_employeeName,timeWorked];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL" message:alertString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [self scan];
}

- (void)cleanup
{
    // Don't do anything if we're not connected
    if (!self.discoveredPeripheral.isConnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_NAME_UUID_STRING]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}


@end
