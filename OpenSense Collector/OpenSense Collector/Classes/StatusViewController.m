//
//  StatusViewController.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "StatusViewController.h"
#import "OpenSense.h"
@interface StatusViewController ()

@end

@implementation StatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        entriesCount = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batchesUpdated:) name:kOpenSenseBatchSavedNotification object:nil];
}

- (void)batchesUpdated:(NSNotification*)notification
{
    entriesCount++;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelStorage.text = [NSString stringWithFormat:@"%ld entries", entriesCount];
    });
}

- (void)updateTime:(id)sender
{
    // Calculate interval
    NSDate *start = [[OpenSense sharedInstance] startTime];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:start];
    
    // Format to hours/minutes/seconds
    long seconds = (long)interval % 60;
    interval /= 60;
    long minutes = (long)interval % 60;
    long hours = interval / 60;
    
    self.labelTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleCollecting:(id)sender
{
    if ([OpenSense sharedInstance].isRunning)
    {
        [[OpenSense sharedInstance] stopCollector];
        [self.runningView setHidden:YES];
        [self.pausedView setHidden:NO];
        
        // Stop timer
        [elapsedTimer invalidate];
        elapsedTimer = nil;
    }
    else
    {
        if ([[OpenSense sharedInstance] startCollector]) {
            [self.runningView setHidden:NO];
            [self.pausedView setHidden:YES];
            
            // Start timer to update label
            elapsedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
