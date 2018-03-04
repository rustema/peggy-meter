//
//  PDKLocationGeneratorViewController.m
//  PassiveDataKit
//
//  Created by Chris Karr on 6/28/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

@import CoreLocation;

#import "PDKLocationGeneratorViewController.h"
#import "PDKLocationGenerator.h"

@interface PDKLocationGeneratorViewController ()

@property UIView * detailsView;
@property UITableView * parametersView;
@property UIView * separator;

@end

@implementation PDKLocationGeneratorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailsView = [[UIView alloc] init];
    
    [self.view addSubview:self.detailsView];
    
    self.parametersView = [[UITableView alloc] init];
    self.parametersView.dataSource = self;
    self.parametersView.delegate = self;

    [self.view addSubview:self.parametersView];
    
    self.separator = [[UIView alloc] init];
    self.separator.backgroundColor = self.navigationController.navigationBar.barTintColor;
    self.separator.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
    self.separator.layer.shadowOpacity = 0.5;
    self.separator.layer.shadowRadius = 2.0;
    self.separator.layer.shadowOffset = CGSizeMake(0, 0);

    [self.view addSubview:self.separator];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGSize size = self.view.bounds.size;
    
    CGFloat panelHeight = (size.height - 16) / 2;
    
    self.detailsView.frame = CGRectMake(0, 0, self.view.bounds.size.width, panelHeight);
    self.separator.frame = CGRectMake(0, panelHeight, self.view.bounds.size.width, 16);
    self.parametersView.frame = CGRectMake(0, panelHeight + 16, self.view.bounds.size.width, panelHeight);
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"name_generator_location", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.parametersView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    [self tableView:self.parametersView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.parametersView) {
        return 2;
    }
    
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.parametersView) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DataSourceCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DataSourceCell"];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"title_pdk_generator_description", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
            cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"subtitle_pdk_generator_description", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"title_pdk_location_generator_accuracy", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
            cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"subtitle_pdk_location_generator_accuracy", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
        }
        
        return cell;
    }
    
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DataOptionCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DataOptionCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString * mode = [defaults valueForKey:PDKLocationAccuracyMode];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"pdk_title_location_accuracy_best", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
        cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"pdk_subtitle_location_accuracy_best", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
        
        if (mode == nil || [PDKLocationAccuracyModeBest isEqualToString:mode]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"pdk_title_accuracy_location_randomized", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
        cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"pdk_subtitle_accuracy_location_randomized", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);

        if ([PDKLocationAccuracyModeRandomized isEqualToString:mode]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"pdk_title_accuracy_location_user_provided", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
        cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"pdk_subtitle_accuracy_location_user_provided", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);

        if ([PDKLocationAccuracyModeUserProvided isEqualToString:mode]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"pdk_title_accuracy_location_disabled", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
        cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"pdk_subtitle_accuracy_location_disabled", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);

        if ([PDKLocationAccuracyModeDisabled isEqualToString:mode]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.parametersView) {
        NSArray * children = self.detailsView.subviews;
        
        for (UIView * child in children) {
            [child removeFromSuperview];
        }
        
        if (indexPath.row == 0) {
            NSString * path = [[NSBundle mainBundle] pathForResource:@"pdk_location_description" ofType:@"html"];
            
            if (path == nil) {
                UILabel * warningLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                warningLabel.backgroundColor = [UIColor blackColor];
                
                NSString * message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"warning_pdk_missing_resource", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil), @"pdk_location_description.html"];
                
                UIFont * font = [UIFont fontWithName:@"Menlo-Bold" size:16];
                
                CGRect titleRect = [message boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 16, 1000)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{ NSFontAttributeName: font }
                                                         context:nil];
                
                warningLabel.frame = CGRectMake(8, 8, self.view.frame.size.width - 16, titleRect.size.height);
                warningLabel.text = message;
                warningLabel.font = font;
                warningLabel.textColor = [UIColor colorWithRed:0 green:1.0 blue:0 alpha:1.0];
                warningLabel.textAlignment = NSTextAlignmentLeft;
                warningLabel.numberOfLines = 0;
                
                [self.detailsView addSubview:warningLabel];
            } else {
                WKWebView * webView = [[WKWebView alloc] initWithFrame:self.detailsView.bounds];
                webView.navigationDelegate = self;
                [webView loadFileURL:[NSURL fileURLWithPath:path] allowingReadAccessToURL:[NSURL fileURLWithPath:path]];
                
                [self.detailsView addSubview:webView];
            }
        } else if (indexPath.row == 1) {
            UITableView * settingsTable = [[UITableView alloc] initWithFrame:self.detailsView.bounds];
            
            settingsTable.delegate = self;
            settingsTable.dataSource = self;
            
            [self.detailsView addSubview:settingsTable];
        }
    } else {
        NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
        
        if (indexPath.row == 0) {
            [defaults setValue:PDKLocationAccuracyModeBest forKey:PDKLocationAccuracyMode];
            
            [[PDKLocationGenerator sharedInstance] refresh:nil];
        } else if (indexPath.row == 1) {
            [defaults setValue:PDKLocationAccuracyModeRandomized forKey:PDKLocationAccuracyMode];

            NSString * title = NSLocalizedStringFromTableInBundle(@"pdk_title_specify_location_random", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
            NSString * message = NSLocalizedStringFromTableInBundle(@"pdk_message_specify_location_random", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
            NSString * placeholder = NSLocalizedStringFromTableInBundle(@"pdk_placeholder_distance_meters", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
            NSString * buttonTitle = NSLocalizedStringFromTableInBundle(@"pdk_button_title_specify_location_random", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:title
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = placeholder;
                textField.keyboardType = UIKeyboardTypeNumberPad;
                
                textField.text = [[defaults valueForKey:PDKLocationAccuracyModeUserProvidedDistance] description];
            }];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:buttonTitle
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      UITextField * distanceField = alert.textFields[0];
                                                                      
                                                                      NSNumber * distance = [NSNumber numberWithDouble:[distanceField.text doubleValue]];
                                                                      
                                                                      [defaults setValue:distance forKey:PDKLocationAccuracyModeUserProvidedDistance];
                                                                      [defaults synchronize];

                                                                  
                                                                      [[PDKLocationGenerator sharedInstance] refresh:nil];
                                                                  }];
            [alert addAction:defaultAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else if (indexPath.row == 2) {
            [defaults setValue:PDKLocationAccuracyModeUserProvided forKey:PDKLocationAccuracyMode];

            NSString * title = NSLocalizedStringFromTableInBundle(@"pdk_title_specify_location_geocode", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
            NSString * message = NSLocalizedStringFromTableInBundle(@"pdk_message_specify_location_geocode", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
            NSString * placeholder = NSLocalizedStringFromTableInBundle(@"pdk_placeholder_location_name", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
            NSString * buttonTitle = NSLocalizedStringFromTableInBundle(@"pdk_button_title_specify_location_geocode", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:title
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = placeholder;
                textField.keyboardType = UIKeyboardTypeAlphabet;
                textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            }];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:buttonTitle
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      UITextField * locationField = alert.textFields[0];

                                                                      CLGeocoder * geocoder = [[CLGeocoder alloc] init];
                                                                      
                                                                      [geocoder geocodeAddressString:locationField.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                                                                          if (placemarks.count > 0) {
                                                                              CLLocation * place = placemarks[0].location;
                                                                              
                                                                              [defaults setValue:[NSNumber numberWithDouble:place.coordinate.latitude] forKey:PDKLocationAccuracyModeUserProvidedLatitude];
                                                                              [defaults setValue:[NSNumber numberWithDouble:place.coordinate.longitude] forKey:PDKLocationAccuracyModeUserProvidedLongitude];
                                                                              
                                                                              [defaults setValue:PDKLocationAccuracyModeUserProvided forKey:PDKLocationAccuracyMode];

                                                                              [defaults synchronize];

                                                                              [[PDKLocationGenerator sharedInstance] refresh:place];
                                                                          }
                                                                      }];
                                                                  }];
            [alert addAction:defaultAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else if (indexPath.row == 3) {
            [defaults setValue:PDKLocationAccuracyModeDisabled forKey:PDKLocationAccuracyMode];
        }
        
        [defaults synchronize];
        
        [tableView reloadData];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


@end
