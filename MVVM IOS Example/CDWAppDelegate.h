//
//  CDWAppDelegate.h
//  MVVM IOS Example
//
//  Created by Colin Wheeler on 3/4/13.
//  Copyright (c) 2013 Colin Wheeler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDWViewController;

@interface CDWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CDWViewController *viewController;

@end
