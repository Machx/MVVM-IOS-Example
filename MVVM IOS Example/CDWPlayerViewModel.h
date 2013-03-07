//
//  CDWPlayerViewModel.h
//  MVVM IOS Example
//
//  Created by Colin Wheeler on 3/4/13.
//  Copyright (c) 2013 Colin Wheeler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDWPlayerViewModel : NSObject

@property(nonatomic, retain) NSString *playerName;

@property(nonatomic, assign) double points;
@property(nonatomic, assign) double stepAmount;
@property(nonatomic, assign) double maxPoints;
@property(nonatomic, assign) double minPoints;

@property(nonatomic, readonly) NSUInteger maxPointUpdates;

-(IBAction)resetToDefaults:(id)sender;

-(IBAction)uploadData:(id)sender;

-(RACSignal *)forbiddenNameSignal;

-(RACSignal *)modelIsValidSignal;

@end
