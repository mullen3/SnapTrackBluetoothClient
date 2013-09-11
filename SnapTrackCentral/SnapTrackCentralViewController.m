//
//  SnapTrackCentralViewController.m
//  SnapTrackCentral
//
//  Created by Sanka, Dheeraj on 8/29/13.
//  Copyright (c) 2013 Sanka, Dheeraj. All rights reserved.
//

#import "SnapTrackCentralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ModalViewController.h"
#import "EmployeeCollection.h"

#define CHARACTERISTIC_NAME_UUID_STRING @"C54C3B19-64AC-423A-8282-09BA48CDB28C"
#define SNAPTRACK_SERVICE_UUID_STRING @"7D12"


@interface SnapTrackCentralViewController () <CBCentralManagerDelegate,CBPeripheralDelegate, UITableViewDelegate, ModalViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextView   *textview;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;
@property (strong,nonatomic)  EmployeeCollection    *employeeCollection;
@property (strong,nonatomic)  NSDate                *startTime;
@property (nonatomic) BOOL                          isCheckedIn;

@end

@implementation SnapTrackCentralViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Start up the CBCentralManager
    self.view.backgroundColor = [UIColor yellowColor];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL" message:@"Dee dee doo doo." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    */
    // And somewhere to store the incoming data
    self.employeeCollection = [[EmployeeCollection alloc]init];
    self.isCheckedIn = NO;
    _data = [[NSMutableData alloc] init];
    self.employeeTableView.dataSource = self.employeeCollection;
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

    self.isCheckedIn = YES;
    Employee *employee = [[Employee alloc] init];
    employee.name = stringFromData;
    [employee checkIn];
    
    [self.employeeCollection addEmployee:employee];
    [self.employeeTableView reloadData];    

    _startTime = [[NSDate alloc] init];
    [self showModalWithFormat:@"Hi %@"];
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL" message:alertString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[alert show];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"peripheral disconnected");
      
    
    //NSString *alertString = [NSString stringWithFormat:@" %@ checked out after %f seconds",_employeeNames[0],timeWorked];
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL" message:alertString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[alert show];
    if(self.isCheckedIn){
        self.isCheckedIn = NO;
        [[self.employeeCollection.employees objectAtIndex:0] checkOut];
        [self showModalWithFormat:@"Bye %@"];
        
        NSDate *endTime = [[NSDate alloc] init];
    }
    [self scan];
}

- (void)showModalWithFormat:(NSString *)formatString {
    ModalViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"checkInModal"];
    [modalViewController setDelegate:self];
    
    // check whether the viewController is already being presented dismiss if so
    if ([modalViewController isEqual:self.presentedViewController]) {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
       //[self presentModalViewController:modalViewController animated:NO];
    [self presentViewController:modalViewController animated:NO completion:NULL];
    NSString *labelText = [NSString stringWithFormat:formatString, [[self.employeeCollection.employees objectAtIndex:0] name]];
    modalViewController.label.text = labelText;
    modalViewController.view.superview.bounds = CGRectMake(0, 0, 320, 320);
}

- (void)hideModal {
    UIViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"checkInModal"];
    // only dismiss if modalViewController is currently being presented
    if (![modalViewController isEqual:self.presentedViewController]) {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
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

#pragma mark
// all of the tableview stuff down here



- (IBAction)tappedOnView:(id)sender {
}
@end
