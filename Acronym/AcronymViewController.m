//
//  AcronymViewController.m
//  Acronym
//
//  Created by Rohit Kumar on 4/20/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import "AcronymViewController.h"
#import "AcronymResult.h"
#import "AcronymVariationViewController.h"
#import "AcronymConstants.h"
#include <MBProgressHUD/MBProgressHUD.h>
#include <AFNetworking/AFNetworking.h>

@interface AcronymViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *acronymTextField;
@property (nonatomic, strong) IBOutlet UITableView *acronymResultTableView;

//Store the response for Acronym
@property (nonatomic, strong) AcronymResult *result;
// Only alphabet characters are allowed to enter in textfield. below set has the disallowed characters
@property (nonatomic, strong) NSCharacterSet *disallowedCharacters;

@end

@implementation AcronymViewController

#pragma mark- Life cycle methods

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self resetContent];
	self.disallowedCharacters = [[NSCharacterSet letterCharacterSet] invertedSet];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - Text Field Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self resetContent];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// Textfield is disabled till user enters atleast one character.
	// Dismiss Keyboard on return
	[textField resignFirstResponder];
	if(![textField.text isEqualToString:@""])
	{
		[self fetchMeaningsForAcronym:textField.text];
	}
	
	return YES;
}

/*
 * Delegate Method to check the validity of user entered text.
 * It checks for below 2 conditions
 * 1. accept return key.
 * 2. accept only alphabets.
 */

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return (([string rangeOfString: @"\n"].location == NSNotFound) && ([string rangeOfCharacterFromSet:self.disallowedCharacters].location == NSNotFound));
}

#pragma mark - Table View DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.result.meanings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *reuseIdentifier = acronymTableViewCellIdentifier;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	
	AcronymMeaning *meaning = [self.result.meanings objectAtIndex:indexPath.row];
	cell.textLabel.text = meaning.meaning;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Used since %ld with %ld occurrences",(long)meaning.since, (long)meaning.frequency];
	
	return cell;
}

#pragma mark - Table View Delegate Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSString *headerIdentifier = acronymTableViewHeaderIdentifier;
	UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
	
	headerView.textLabel.text = [NSString stringWithFormat:@"Meanings for, %@",self.acronymTextField.text];
	
	return headerView;
}

#pragma mark - Web Service Call
// GET Request is made to http://www.nactem.ac.uk/software/acromine/dictionary.py URL
// Request Structure @{@"sf": acronym_Text}

- (void)fetchMeaningsForAcronym:(NSString *)acronymText
{
	NSDictionary *requestParameters = @{acronymShortForm: acronymText};
	
	//Display HUD till web service call is in progress.
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
	sessionManager.responseSerializer.acceptableContentTypes = nil;
	
	[sessionManager GET:acronymRepoURL
				 parameters:requestParameters
				   progress:nil
				    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
					    [MBProgressHUD hideHUDForView:self.view animated:YES];
					    self.result = [self parseResponse:responseObject];
					    if ([self.result.meanings count])
					    {
						    [self.acronymResultTableView setHidden:NO];
						    [self.acronymResultTableView reloadData];
					    }
					    else
					    {
						    //Show No Results error.
						    NSString *message = [NSString stringWithFormat:@"Sorry..!! We couldn't find any meaning for \"%@\". Please try different text.",self.acronymTextField.text];
						    [self displayErrorWithTtile:@"No Results" message:message];
					    }
					    
				    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
					    //Show Error Alert
					    [MBProgressHUD hideHUDForView:self.view animated:YES];
					    [self displayErrorWithTtile:nil message:[error localizedDescription]];
				    }];
}

#pragma mark - Response Parser
//Response Structure:
/*************************************************************************************************************************************************************
 
 {
 lfs =     (
 {
 freq = 15;
 lf = "person trade-off";
 since = 1997;
 vars =             (
 {
 freq = 10;
 lf = "person trade-off";
 since = 1998;
 },
 {
 freq = 2;
 lf = "person tradeoff";
 since = 2004;
 },
 );
 },
 {
 freq = 2;
 lf = "The paratympanic organ";
 since = 1994;
 vars =             (
 {
 freq = 2;
 lf = "The paratympanic organ";
 since = 1994;
 }
 );
 }
 );
 sf = PTO;
 }
 
 **************************************************************************************************************************************************************/

- (AcronymResult *)parseResponse:(id)response
{
	AcronymResult *result = [[AcronymResult alloc] init];
	result.meanings = [NSMutableArray array];
	if ([response isKindOfClass:[NSArray class]] && [response count])
	{
		[response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			NSDictionary *content = obj;
			result.shortForm = [content objectForKey:acronymShortForm];
			NSArray *longFormObjects = [content objectForKey:acronymLongForms];
			[longFormObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				NSDictionary *longFormContent = obj;
				AcronymMeaning *longForm = [[AcronymMeaning alloc] init];
				longForm.meaning = [longFormContent objectForKey:acronymLongForm];
				longForm.since = [[longFormContent objectForKey:acronymSince] integerValue];
				longForm.frequency = [[longFormContent objectForKey:acronymFrequency] integerValue];
				NSMutableArray *variationArray = [self getVariations:[longFormContent objectForKey:acronymVariations]];
				longForm.variations = variationArray;
				[result.meanings addObject:longForm];
			}];
		}];
	}
	
	return result;
}

//Parse the variations in response.

- (NSMutableArray *)getVariations:(NSMutableArray *)crudeResponse
{
	NSMutableArray *variationArray = [NSMutableArray array];
	[crudeResponse enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		NSDictionary *content = obj;
		AcronymMeaning *variationLongForm = [[AcronymMeaning alloc] init];
		variationLongForm.meaning = [content objectForKey:acronymLongForm];
		variationLongForm.since = [[content objectForKey:acronymSince] integerValue];
		variationLongForm.frequency = [[content objectForKey:acronymFrequency] integerValue];
		[variationArray addObject:variationLongForm];
	}];
	
	return variationArray;
}

#pragma mark - Error Handling

- (void)displayErrorWithTtile:(NSString *)title message:(NSString *)errorMessage
{
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
								       message:errorMessage
								preferredStyle:UIAlertControllerStyleAlert];
 
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
							      handler:^(UIAlertAction * action) {}];
 
	[alert addAction:defaultAction];
	[self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Helper Methods

- (void)resetContent
{
	[self.acronymResultTableView setHidden:YES];
}

#pragma mark - Navigation Handling

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
	
	if ([segue.identifier isEqualToString:acronymVariationSegueIdentifier])
	{
		NSIndexPath *indexPath = [self.acronymResultTableView indexPathForSelectedRow];
		AcronymVariationViewController *variationViewController = [segue destinationViewController];
		variationViewController.meaning = [self.result.meanings objectAtIndex:indexPath.row];
	}
	
}

@end
