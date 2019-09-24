
//  Magnetometer.m


#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import "Magnetometer.h"

@implementation Magnetometer

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (id) init {
    self = [super init];
    NSLog(@"Magnetometer");

    if (self) {
        self->_motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

RCT_REMAP_METHOD(isAvailable,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    return [self isAvailableWithResolver:resolve
                                rejecter:reject];
}

- (void) isAvailableWithResolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject {
    if([self->_motionManager isDeviceMotionAvailable])
    {
        /* Start the accelerometer if it is not active already */
        if([self->_motionManager isDeviceMotionActive] == NO)
        {
            resolve(@YES);
        } else {
            reject(@"-1", @"Magnetometer is not active", nil);
        }
    }
    else
    {
        reject(@"-1", @"Magnetometer is not available", nil);
    }
}

RCT_EXPORT_METHOD(setUpdateInterval:(double) interval) {
    NSLog(@"setUpdateInterval: %f", interval);
    double intervalInSeconds = interval / 1000;
    
    [self->_motionManager setDeviceMotionUpdateInterval:intervalInSeconds];
}

RCT_EXPORT_METHOD(getUpdateInterval:(RCTResponseSenderBlock) cb) {
    double interval = self->_motionManager.deviceMotionUpdateInterval;
    NSLog(@"getUpdateInterval: %f", interval);
    cb(@[[NSNull null], [NSNumber numberWithDouble:interval]]);
}

RCT_EXPORT_METHOD(getData:(RCTResponseSenderBlock) cb) {
    double x = self->_motionManager.deviceMotion.magneticField.field.x;
    double y = self->_motionManager.deviceMotion.magneticField.field.y;
    double z = self->_motionManager.deviceMotion.magneticField.field.z;
    double accuracy = self->_motionManager.deviceMotion.magneticField.accuracy;
    double timestamp = self->_motionManager.deviceMotion.timestamp;
    
    NSLog(@"getData: %f, %f, %f, %f, %f", x, y, z, accuracy, timestamp);
    
    cb(@[[NSNull null], @{
             @"x" : [NSNumber numberWithDouble:x],
             @"y" : [NSNumber numberWithDouble:y],
             @"z" : [NSNumber numberWithDouble:z],
             @"accuracy" : [NSNumber numberWithDouble:accuracy],
             @"timestamp" : [NSNumber numberWithDouble:timestamp]
             }]
       );
}

RCT_EXPORT_METHOD(startUpdates) {
    NSLog(@"startUpdates");
    [self->_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];
    
    /* Receive the magnetometer data on this block */
    [self->_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical
                                                              toQueue:[NSOperationQueue mainQueue]
                                                          withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
         double x = motion.magneticField.field.x;
         double y = motion.magneticField.field.y;
         double z = motion.magneticField.field.z;
         double accuracy = motion.magneticField.accuracy;
         double timestamp = motion.timestamp;
         NSLog(@"startMagnetometerUpdates: %f, %f, %f, %f, %f", x, y, z, accuracy, timestamp);
         
         [self sendEventWithName:@"Magnetometer" body:@{
                                                        @"x" : [NSNumber numberWithDouble:x],
                                                        @"y" : [NSNumber numberWithDouble:y],
                                                        @"z" : [NSNumber numberWithDouble:z],
                                                        @"accuracy" : [NSNumber numberWithDouble:accuracy],
                                                        @"timestamp" : [NSNumber numberWithDouble:timestamp]
                                                        }];
     }];

}

RCT_EXPORT_METHOD(stopUpdates) {
    NSLog(@"stopUpdates");
    [self->_motionManager stopDeviceMotionUpdates];
}

@end
