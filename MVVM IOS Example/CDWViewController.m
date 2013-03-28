//
//  CDWViewController.m
//  MVVM IOS Example
//
//  Created by Colin Wheeler on 3/4/13.
//  Copyright (c) 2013 Colin Wheeler. All rights reserved.
//

#import "CDWViewController.h"
#import "CDWPlayerViewModel.h"
#import <libextobjc/EXTScope.h>

@interface CDWViewController ()
@property(nonatomic,retain) CDWPlayerViewModel *viewModel;
@property(weak) IBOutlet UITextField *nameField;
@property(weak) IBOutlet UILabel *scoreField;
@property(weak) IBOutlet UIStepper *scoreStepper;
@property(weak) IBOutlet UIButton *uploadButton;

@property(assign) NSUInteger scoreUpdates;
@end

static NSUInteger const kMaxUploads = 5;

@implementation CDWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Create the View Model
	self.viewModel = [CDWPlayerViewModel new];
	
	@weakify(self);
	
	//Start Binding our properties
	RAC(self.nameField.text) = [RACAbleWithStart(self.viewModel.playerName) distinctUntilChanged];
	
	[[self.nameField.rac_textSignal distinctUntilChanged] subscribeNext:^(NSString *x) {
		@strongify(self);
		self.viewModel.playerName = x;
	}];
	
	//the score property is a double, RC gives us updates as NSNumber which we just call
	//stringValue on and bind that to the scorefield text
	RAC(self.scoreField.text) = [RACAbleWithStart(self.viewModel.points) map:^id(NSNumber *value) {
		return [value stringValue];
	}];
	
	//Setup bind the steppers values
	self.scoreStepper.value = self.viewModel.points;
	RAC(self.scoreStepper.stepValue) = RACAbleWithStart(self.viewModel.stepAmount);
	RAC(self.scoreStepper.maximumValue) = RACAbleWithStart(self.viewModel.maxPoints);
	RAC(self.scoreStepper.minimumValue) = RACAbleWithStart(self.viewModel.minPoints);
	//bind the hidden field to a signal keeping track if
	//we've updated less than a certain number times as the view model specifies
	RAC(self.scoreStepper.hidden) = [RACAble(self.scoreUpdates) map:^id(NSNumber *x) {
		@strongify(self);
		return @(x.intValue >= self.viewModel.maxPointUpdates);
	}];
	
	//only take the maxPointUpdates number of score updates
	[[RACAble(self.scoreStepper.value) take:self.viewModel.maxPointUpdates] subscribeNext:^(id newPoints) {
		@strongify(self);
		self.viewModel.points = [newPoints doubleValue];
		self.scoreUpdates++;
	}];
	
	//this signal should only trigger if we have "bad words" in our name
	[self.viewModel.forbiddenNameSignal subscribeNext:^(NSString *name) {
		@strongify(self);
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forbidden Name!"
														message:[NSString stringWithFormat:@"The name %@ has been forbidden!",name]
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil];
		[alert show];
		self.viewModel.playerName = @"";
	}];
	
	//let the upload(save) button only be enabled when the view model says its valid
	RAC(self.uploadButton.enabled) = self.viewModel.modelIsValidSignal;
	
	//set the control action for our button to be the ViewModels action method
	[self.uploadButton addTarget:self.viewModel
						  action:@selector(uploadData:)
				forControlEvents:UIControlEventTouchUpInside];
	
	//we can subscribe to the same thing in multiple locations
	//here we skip the first 4 signals and take only 1 update
	//and then disable/hide certain UI elements as our app
	//only allows 5 updates
	[[[[self.uploadButton rac_signalForControlEvents:UIControlEventTouchUpInside]
	   skip:(kMaxUploads - 1)] take:1] subscribeNext:^(id x) {
		@strongify(self);
		self.nameField.enabled = NO;
		self.scoreStepper.hidden = YES;
		self.uploadButton.hidden = YES;
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
