//
//  PDKDataReportViewController.m
//  PassiveDataKit
//
//  Created by Chris Karr on 6/25/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

#import "PassiveDataKit.h"

#import "PDKDataReportViewController.h"

@interface PDKDataReportViewController ()

@property UITableView * sourcesTable;
@property UIView * detailsView;
@property UIView * separatorView;
@property BOOL initialized;
@property BOOL tableInited;

@property NSArray * listeners;

@end

@implementation PDKDataReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initialized = NO;
    self.tableInited = NO;
    
    self.sourcesTable = [[UITableView alloc] initWithFrame:CGRectZero];
    self.sourcesTable.dataSource = self;
    self.sourcesTable.delegate = self;
    
    [self.view addSubview:self.sourcesTable];
    
    self.detailsView = [[UIView alloc] initWithFrame:CGRectZero];
    self.detailsView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.detailsView];
    
    self.separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.separatorView.backgroundColor = self.navigationController.navigationBar.barTintColor;
    
    self.separatorView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.separatorView.layer.shadowOpacity = 0.5;
    self.separatorView.layer.shadowRadius = 2.0f;
    self.separatorView.layer.shadowOffset = CGSizeMake(0, 0);
    self.separatorView.layer.masksToBounds = NO;
    
    [self.view addSubview:self.separatorView];
    
    self.listeners = [[PassiveDataKit sharedInstance] activeListeners];
}

- (void) loadVisualization:(NSString *) generator {
    UIView * visualization = nil;
    
    if (generator == nil) {
        UILabel * placeholder = [[UILabel alloc] initWithFrame:self.detailsView.bounds];
        
        placeholder.text = NSLocalizedStringFromTableInBundle(@"placeholder_select_generator", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
        
        placeholder.backgroundColor = [UIColor colorWithWhite:(0x42 / 255.0) alpha:1.0];
        placeholder.textColor = [UIColor whiteColor];
        placeholder.textAlignment = NSTextAlignmentCenter;
        
        visualization = placeholder;
    } else {
        Class generatorClass = NSClassFromString(generator);
        
        id generator = [generatorClass sharedInstance];
        
        if (generator != nil) {
            if ([generator respondsToSelector:@selector(visualizationForSize:)]) {
                visualization = [generator visualizationForSize:self.detailsView.bounds.size];
            }
        }

        if (visualization == nil) {
            UILabel * placeholder = [[UILabel alloc] initWithFrame:self.detailsView.bounds];
            
            placeholder.text = NSLocalizedStringFromTableInBundle(@"placeholder_unknown_generator", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);

            placeholder.backgroundColor = [UIColor colorWithWhite:(0x42 / 255.0) alpha:1.0];
            placeholder.textColor = [UIColor whiteColor];
            placeholder.textAlignment = NSTextAlignmentCenter;

            visualization = placeholder;
        }
    }
    
    NSArray * children = self.detailsView.subviews;
    
    for (UIView * child in children) {
        [child removeFromSuperview];
    }
    
    [self.detailsView addSubview:visualization];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"title_data_report", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.tableInited == NO) {
        [self.sourcesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.sourcesTable didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        self.tableInited = YES;
    }
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.view.frame;
    
    self.detailsView.frame = CGRectMake(0, 0, frame.size.width, (frame.size.height / 2) - 8);
    self.sourcesTable.frame = CGRectMake(0, (frame.size.height / 2) + 8, frame.size.width, (frame.size.height / 2) - 8);
    
    self.separatorView.frame = CGRectMake(0, (frame.size.height / 2) - 8, frame.size.width, 16);
    
    [self.view bringSubviewToFront:self.separatorView];
    
    if (self.initialized == NO) {
        [self loadVisualization:nil];
        
        self.initialized = YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listeners.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DataSourceCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DataSourceCell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    UIImage * gear = [UIImage imageNamed:@"Icon - Generator Settings" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    
    UIButton * settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setImage:gear forState:UIControlStateNormal];
    settingsButton.frame = CGRectMake(0, 0, 44, 44);
    settingsButton.tag = indexPath.row;
    
    [settingsButton addTarget:self action:@selector(tappedSettings:) forControlEvents:UIControlEventTouchUpInside];
   
    cell.accessoryView = settingsButton;
    
    cell.textLabel.text = [self titleForGenerator:self.listeners[indexPath.row]];
    
    return cell;
}

- (NSString *) titleForGenerator:(NSString *) key {
    if ([@"PDKEventsGenerator" isEqualToString:key]) {
        return NSLocalizedStringFromTableInBundle(@"name_generator_events", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
    } else if ([@"PDKMixpanelEventGenerator" isEqualToString:key]) {
        return NSLocalizedStringFromTableInBundle(@"name_generator_events_mixpanel", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
    } else {
        Class generatorClass = NSClassFromString(key);
        
        if (generatorClass != nil) {
            if ([generatorClass respondsToSelector:@selector(title)]) {
                return [generatorClass performSelector:@selector(title)];
            }
        }
    }
    
    return key;
}

- (UIViewController *) detailsControllerForGenerator:(NSString *) key {
    UIViewController * controller = nil;
    
    Class generatorClass = NSClassFromString(key);
    
    if (generatorClass != nil) {
        SEL details = NSSelectorFromString(@"detailsController");
        
        if ([generatorClass respondsToSelector:details]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            controller =  [generatorClass performSelector:details];
#pragma clang diagnostic pop
        }
    }
    return controller;
    
}

- (void) tappedSettings:(UIButton *) button {
    NSString * generator = self.listeners[button.tag];
    
    self.navigationItem.title = @"";
    
    UIViewController * controller = [self detailsControllerForGenerator:generator];
    
    if (controller != nil) {
        [self.navigationController pushViewController:controller animated:YES];
    } else {

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * generator = self.listeners[indexPath.row];
    
    NSString * title = [self titleForGenerator:generator];
    
    self.navigationItem.title = title;

    [self loadVisualization:generator];
}

@end
