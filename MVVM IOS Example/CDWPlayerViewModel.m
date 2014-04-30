//
//  CDWPlayerViewModel.m
//  MVVM IOS Example
//
//  Created by Colin Wheeler on 3/4/13.
//  Copyright (c) 2013 Colin Wheeler. All rights reserved.
//

#import "CDWPlayerViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface CDWPlayerViewModel ()
@property(nonatomic, retain) NSArray *forbiddenNames;
@property(nonatomic, readwrite) NSUInteger maxPointUpdates;
@end

@implementation CDWPlayerViewModel

-(id)init {
	self = [super init];
	if(!self) return nil;
	
	_playerName = @"Colin";
	_points = 100.0;
	_stepAmount = 1.0;
	_maxPoints = 10000.0;
	_minPoints = 0.0;

	_maxPointUpdates = 10;
	
	//I guess we'll go with the ned flanders bad words
	//change this to whatever you want
	_forbiddenNames = @[ @"dag nabbit",
					  @"darn",
					  @"poop"
					  ];

	return self;
}

-(IBAction)resetToDefaults:(id)sender {
	self.playerName = @"Colin";
	self.points = 100.0;
	self.stepAmount = 1.0;
	self.maxPoints = 10000.0;
	self.minPoints = 0.0;
	self.maxPointUpdates = 10;
	self.forbiddenNames = @[ @"dag nabbit",
						  @"darn",
						  @"poop"
						  ];
}

-(IBAction)uploadData:(id)sender {
	//using with @strongify(self) this makes sure that self isn't retained in the blocks
	//this is declared int libextobjc's EXTScope.h file
	@weakify(self);
    
	[[RACScheduler scheduler] schedule:^{
		sleep(1);
		//pretend we are uploading to a server on a backround thread...
		//dont ever put sleep in your code
		//upload player & points...
		
		[[RACScheduler mainThreadScheduler] schedule:^{
			//this creates a reference to weak self ( @weakify(self); )
			//makes sure self isn't retained
            //TODO: shouldn't reference a UI element in the view model. probably need an upload signal signal
			@strongify(self);
			NSString *msg = [NSString stringWithFormat:@"Updated %@ with %.0f points",self.playerName,self.points];
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Successfull" message:msg delegate:nil
												  cancelButtonTitle:@"ok" otherButtonTitles:nil];
			[alert show];
		}];
	}];
}

-(RACSignal *)forbiddenNameSignal {
	@weakify(self);
	return [RACObserve(self,playerName) filter:^BOOL(NSString *newName) {
		@strongify(self);
		return [self.forbiddenNames containsObject:newName];
	}];
}

-(RACSignal *)modelIsValidSignal {
	@weakify(self);
	return [RACSignal
			combineLatest:@[ RACObserve(self,playerName), RACObserve(self,points) ]
			reduce:^id(NSString *name, NSNumber *playerPoints){
				@strongify(self);
				return @((name.length > 0) &&
				(![self.forbiddenNames containsObject:name]) &&
				(playerPoints.doubleValue >= self.minPoints));
			}];
}

@end
