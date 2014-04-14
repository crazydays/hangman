//
//  ScanViewController.m
//  Hangman
//
//  Created by Aaron Day on 4/3/14.
//  Copyright (c) 2014 Aaron Day. All rights reserved.
//

#import "GameViewController.h"
#import "NotificationCentralManagerDelegate.h"
#import "NotificationPeripheralDelegate.h"

#import "ScanViewController.h"

NSString* const kPeripheralTableViewCellId = @"PeripheralTableViewCellId";

@interface PeripheralTableViewCell : UITableViewCell

@property IBOutlet UILabel *name;
@property IBOutlet UILabel *identifer;

@end

@implementation PeripheralTableViewCell
@end


@interface ScanViewController ()

@property IBOutlet UIButton *scanButton;
@property IBOutlet UIActivityIndicatorView *busyIndicator;
@property IBOutlet UITableView *gamesTableView;

@property NSMutableArray *games;

@property CBCentralManager *centralManager;
@property NotificationCentralManagerDelegate *centralManagerDelegate;
@property NotificationPeripheralDelegate *peripheralDelegate;
@property BOOL scanning;

@end

@implementation ScanViewController

- (id) initWithCoder:(NSCoder*)decoder
{
    if (self = [super initWithCoder:decoder]) {
        [self setupGames];
        [self setupNotifications];
        [self setupBluetoothLE];
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateScanButton];
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (self.scanning) {
        [self stopScan];
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Setup

- (void) setupGames
{
    self.games = [NSMutableArray array];
}

- (void) setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centralManagerAvailable:) name:kCentralManagerAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centralManagerUnavailable:) name:kCentralManagerUnavailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralDiscovered:) name:kPeripheralDiscovered object:nil];
}

- (void) setupBluetoothLE
{
    self.peripheralDelegate = [[NotificationPeripheralDelegate alloc] init];
    self.centralManagerDelegate = [[NotificationCentralManagerDelegate alloc] init];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self.centralManagerDelegate queue:nil];
}

#pragma mark -
#pragma mark Views

- (void) updateScanButton
{
    self.scanButton.enabled = self.centralManager.state == CBCentralManagerStatePoweredOn;
    [self.scanButton setTitle:(self.scanning ? @"Stop Scan" : @"Start Scan") forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Notifications

- (void) centralManagerAvailable:(NSNotification*)notification
{
    [self updateScanButton];
}

- (void) centralManagerUnavailable:(NSNotification*)notification
{
    [self updateScanButton];
}

- (void) peripheralDiscovered:(NSNotification*)notification
{
    CBPeripheral *peripheral = notification.object;
    
    if (![self.games containsObject:peripheral]) {
        NSLog(@"Adding game: %@", peripheral);
        peripheral.delegate = self.peripheralDelegate;
        [self.games addObject:peripheral];
        [self.gamesTableView reloadData];
    }
}

#pragma mark -
#pragma mark State

- (IBAction) toggleScan:(id)sender
{
    if (self.scanning) {
        [self stopScan];
    } else {
        [self startScan];
    }
    
    [self updateScanButton];
}

- (void) startScan
{
    self.scanning = YES;
    [self.busyIndicator startAnimating];
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void) stopScan
{
    self.scanning = NO;
    [self.busyIndicator stopAnimating];
    [self.centralManager stopScan];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.gamesTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral *peripheral = self.games[indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    GameViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:kGameViewControllerIdentifier];
    viewController.centralManager = self.centralManager;
    viewController.peripheral = peripheral;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.games.count;
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    CBPeripheral *peripheral = self.games[indexPath.row];

    PeripheralTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPeripheralTableViewCellId];
    cell.name.text = peripheral.name;
    cell.identifer.text = [peripheral.identifier UUIDString];
    
    return cell;
}

@end
