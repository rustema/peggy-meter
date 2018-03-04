//
//  PDKPedometerSensor.m
//  PassiveDataKit
//
//  Created by Chris Karr on 6/26/17.
//  Copyright © 2017 Audacious Software. All rights reserved.
//

@import CoreMotion;
#import <sqlite3.h>

#import "PDKPedometerGenerator.h"

#define DATABASE_VERSION @"PDKPedometerGenerator.DATABASE_VERSION"
#define CURRENT_DATABASE_VERSION @(1)

NSString * const PDKPedometerStart = @"interval-start"; //!OCLINT
NSString * const PDKPedometerEnd = @"interval-end"; //!OCLINT
NSString * const PDKPedometerStepCount = @"step-count"; //!OCLINT
NSString * const PDKPedometerDistance = @"distance"; //!OCLINT
NSString * const PDKPedometerAveragePace = @"average-pace"; //!OCLINT
NSString * const PDKPedometerCurrentPace = @"current-pace"; //!OCLINT
NSString * const PDKPedometerCurrentCadence = @"current-cadence"; //!OCLINT
NSString * const PDKPedometerFloorsAscended = @"floors-ascended"; //!OCLINT
NSString * const PDKPedometerFloorsDescended = @"floors-descended"; //!OCLINT

@interface PDKPedometerGenerator()

@property NSMutableArray * listeners;
@property NSDictionary * lastOptions;
@property CMPedometer * pedometer;

@property sqlite3 * database;

@end

#define GENERATOR_ID @"pdk-pedometer"

static PDKPedometerGenerator * sharedObject = nil;

@implementation PDKPedometerGenerator

+ (PDKPedometerGenerator *) sharedInstance {
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super allocWithZone:nil] init];
    });
    
    return sharedObject;
}

+ (id) allocWithZone:(NSZone *) zone { //!OCLINT
    return [self sharedInstance];
}

- (id) init {
    if (self = [super init]) {
        self.listeners = [NSMutableArray array];
        self.pedometer = [[CMPedometer alloc] init];
        
        self.database = [self openDatabase];
    }
    
    return self;
}

- (NSString *) databasePath {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString * documentsPath = paths[0];
    
    NSString * dbPath = [documentsPath stringByAppendingPathComponent:@"pdk-pedometer.sqlite3"];
    
    return dbPath;
}

- (sqlite3 *) openDatabase {
    NSString * dbPath = [self databasePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath] == NO)
    {
        sqlite3 * database = NULL;
        
        const char * path = [dbPath UTF8String];
        
        int retVal = sqlite3_open_v2(path, &database, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE|SQLITE_OPEN_FILEPROTECTION_NONE, NULL);
        
        if (retVal == SQLITE_OK) {
            char * error;
            
            const char * createStatement = "CREATE TABLE IF NOT EXISTS pedometer_data (id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp REAL, interval_start REAL, interval_end REAL, step_count REAL, distance REAL, average_pace REAL, current_pace REAL, current_cadence REAL, floors_ascended REAL, floors_descended REAL)";
            
            if (sqlite3_exec(database, createStatement, NULL, NULL, &error) != SQLITE_OK) { //!OCLINT

            }
            
            sqlite3_close(database);
        }
    }
    
    const char * dbpath = [dbPath UTF8String];
    
    sqlite3 * database = NULL;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        
        NSNumber * dbVersion = [defaults valueForKey:DATABASE_VERSION];
        
        if (dbVersion == nil) {
            dbVersion = @(0);
        }
        
        BOOL updated = NO;
        char * error = NULL;

        switch (dbVersion.integerValue) {
            case 0:
                if (sqlite3_exec(database, "ALTER TABLE pedometer_data ADD COLUMN today_start REAL", NULL, NULL, &error) != SQLITE_OK) { //!OCLINT

                } else {
                    NSLog(@"DB 0 ERROR: %s", error);
                }
                
                updated = YES;
            default:
                break;
        }
        
        if (updated) {
            [defaults setValue:CURRENT_DATABASE_VERSION forKey:DATABASE_VERSION];
        }
        
        return database;
    } else {
        NSLog(@"UNABLE TO OPEN DATABASE");
    }
    
    return NULL;
}

- (void) addListener:(id<PDKDataListener>)listener options:(NSDictionary *) options {
    if ([self.listeners containsObject:listener] == NO) {
        [self.listeners addObject:listener];
    }
    
    [self.pedometer stopPedometerEventUpdates]; //!OCLINT

    if (self.listeners.count > 0) {
//        [self.pedometer startPedometerEventUpdatesWithHandler:^(CMPedometerEvent * _Nullable pedometerEvent, NSError * _Nullable error) {
//            // NSLog(@"EVENT RECV: %@", pedometerEvent);
//            // NSLog(@"EVENT ERROR: %@", error);
//
//            if (error != nil) {
//                [self displayError:error];
//            }
//        }];
        
        [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            if (error == nil) {
                NSDate * now = [NSDate date];
                
                NSMutableDictionary * data = [NSMutableDictionary dictionary];
                
                data[PDKPedometerStart] = [NSNumber numberWithFloat:pedometerData.startDate.timeIntervalSince1970];
                data[PDKPedometerEnd] = [NSNumber numberWithFloat:pedometerData.endDate.timeIntervalSince1970];
                data[PDKPedometerStepCount] = pedometerData.numberOfSteps;
                data[PDKPedometerDistance] = pedometerData.distance;
                data[PDKPedometerAveragePace] = pedometerData.averageActivePace; //!OCLINT
                data[PDKPedometerCurrentPace] = pedometerData.currentPace;
                data[PDKPedometerCurrentCadence] = pedometerData.currentCadence;

                data[PDKPedometerFloorsAscended] = pedometerData.floorsAscended;
                data[PDKPedometerFloorsDescended] = pedometerData.floorsDescended;

                sqlite3_stmt * stmt;
                
                NSString * insert = @"INSERT INTO pedometer_data (timestamp, interval_start, interval_end, step_count, distance, average_pace, current_pace, current_cadence, floors_ascended, floors_descended, today_start) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
                
                NSDate * todayStart = [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
                
                int retVal = sqlite3_prepare_v2(self.database, [insert UTF8String], -1, &stmt, NULL);
                
                if (retVal == SQLITE_OK) {
                    sqlite3_bind_double(stmt, 1, now.timeIntervalSince1970);
                    sqlite3_bind_double(stmt, 2, pedometerData.startDate.timeIntervalSince1970);
                    sqlite3_bind_double(stmt, 3, pedometerData.endDate.timeIntervalSince1970);
                    sqlite3_bind_double(stmt, 4, pedometerData.numberOfSteps.doubleValue);
                    sqlite3_bind_double(stmt, 5, pedometerData.distance.doubleValue);
                    sqlite3_bind_double(stmt, 6, pedometerData.averageActivePace.doubleValue); //!OCLINT
                    sqlite3_bind_double(stmt, 7, pedometerData.currentPace.doubleValue);
                    sqlite3_bind_double(stmt, 8, pedometerData.currentCadence.doubleValue);
                    sqlite3_bind_double(stmt, 9, pedometerData.floorsAscended.doubleValue);
                    sqlite3_bind_double(stmt, 10, pedometerData.floorsDescended.doubleValue);
                    sqlite3_bind_double(stmt, 11, todayStart.timeIntervalSince1970);

                    int retVal = sqlite3_step(stmt);
                    
                    if (SQLITE_DONE == retVal) {
                        NSLog(@"INSERT SUCCESSFUL");
                    } else {
                        NSLog(@"Error while inserting data. %d '%s'", retVal, sqlite3_errmsg(self.database));
                    }
                    
                    sqlite3_finalize(stmt);
                } else {
                    NSLog(@"CANNOT OPEN DATABASE: %d", retVal);
                }
                
                [[PassiveDataKit sharedInstance] receivedData:data forGenerator:PDKPedometer];
            } else {
                [self displayError:error];
            }
        }];
    }
}

- (void) removeListener:(id<PDKDataListener>)listener {
    [self.listeners removeObject:listener];
    
    if (self.listeners.count == 0) {
//      [self.pedometer stopPedometerEventUpdates];
        [self.pedometer stopPedometerUpdates];
    }
}

- (void) displayError:(NSError *) error {
    if (error == nil) {
        return;
    }
    
    if (error.code == CMErrorDeviceRequiresMovement) {
        NSLog(@"CMErrorDeviceRequiresMovement");
    } else if (error.code == CMErrorInvalidAction) {
        NSLog(@"CMErrorInvalidAction");
    } else if (error.code == CMErrorInvalidParameter) {
        NSLog(@"CMErrorInvalidParameter");
    } else if (error.code == CMErrorMotionActivityNotAuthorized) {
        NSLog(@"CMErrorMotionActivityNotAuthorized");
    } else if (error.code == CMErrorMotionActivityNotAvailable) {
        NSLog(@"CMErrorMotionActivityNotAvailable");
    } else if (error.code == CMErrorMotionActivityNotEntitled) {
        NSLog(@"CMErrorMotionActivityNotEntitled");
    } else if (error.code == CMErrorNotAuthorized) {
        NSLog(@"CMErrorNotAuthorized");
    } else if (error.code == CMErrorNotAvailable) {
        NSLog(@"CMErrorNotAvailable");
    } else if (error.code == CMErrorNotEntitled) {
        NSLog(@"CMErrorNotEntitled");
    } else if (error.code == CMErrorTrueNorthNotAvailable) {
        NSLog(@"CMErrorTrueNorthNotAvailable");
    } else if (error.code == CMErrorUnknown) {
        NSLog(@"CMErrorUnknown");
    }
}

- (NSString *) generatorId {
    return GENERATOR_ID;
}

- (CGFloat) stepsBetweenStart:(NSTimeInterval) start end:(NSTimeInterval) end {
    CGFloat totalSteps = 0;

    NSTimeInterval firstStart = 0;
    CGFloat lastSteps = 0;

    sqlite3_stmt * statement = NULL;
    
    NSString * querySQL = @"SELECT P.interval_start, P.step_count FROM pedometer_data P WHERE (P.interval_end >= ? AND P.interval_end <= ?) ORDER BY P.interval_end";
    
    int retVal = sqlite3_prepare_v2(self.database, [querySQL UTF8String], -1, &statement, NULL);

    if (retVal == SQLITE_OK)
    {
        sqlite3_bind_double(statement, 1, start);
        sqlite3_bind_double(statement, 2, end);
        
        NSTimeInterval lastStart = 0;

        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSTimeInterval intervalStart = sqlite3_column_double(statement, 0);
            CGFloat steps = sqlite3_column_double(statement, 1);
            
            if (intervalStart != lastStart) {
                totalSteps += lastSteps;
                
                lastStart = intervalStart;
                
                if (firstStart == 0) {
                    firstStart = intervalStart;
                }
            }
            
            lastSteps = steps;
        }
        
        sqlite3_finalize(statement);
    }

    totalSteps += lastSteps;

    if (firstStart > 0 && firstStart < start) {
        querySQL = @"SELECT P.interval_start, P.step_count FROM pedometer_data P WHERE (P.interval_end <= ?) ORDER BY P.interval_end DESC LIMIT 1";

        retVal = sqlite3_prepare_v2(self.database, [querySQL UTF8String], -1, &statement, NULL);

        if (retVal == SQLITE_OK)
        {
            sqlite3_bind_double(statement, 1, start);
            
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                CGFloat steps = sqlite3_column_double(statement, 1);

                totalSteps -= steps;
            }
            
            sqlite3_finalize(statement);
        }
    }
    
    return totalSteps;
}

@end
