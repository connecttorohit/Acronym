//
//  AcronymViewController.m
//  Acronym
//
//  Created by Rohit Kumar on 4/20/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import "AcronymViewController.h"
#import "AcronymResult.h"
#include <MBProgressHUD/MBProgressHUD.h>
#include <AFNetworking/AFNetworking.h>

NSString *const AcronymRepoURL = @"http://www.nactem.ac.uk/software/acromine/dictionary.py?";

@interface AcronymViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *acronymTextField;
@property (nonatomic, strong) IBOutlet UITableView *acronymResultTableView;
@property (nonatomic, strong) AcronymResult *result;

@end

@implementation AcronymViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self resetContent];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)resetContent
{
	[self.acronymResultTableView setHidden:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self resetContent];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// Textfield is disabled till user enters atleast one character.
	// Dismiss Keyboard on return
	[textField resignFirstResponder];
	if(![textField.text isEqualToString:@""]){
		
		[self fetchMeaningsForAcronym:textField.text];
	}
	
	return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.result.meanings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *reuseIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	
	AcronymMeaning *meaning = [self.result.meanings objectAtIndex:indexPath.row];
	cell.textLabel.text = meaning.meaning;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Used since %ld with %ld occurrences",(long)meaning.since, (long)meaning.frequency];
	
	return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	static NSString *headerIdentifier = @"Header";
	UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
	
	headerView.textLabel.text = [NSString stringWithFormat:@"Meanings for, %@",self.acronymTextField.text];
	
	return headerView;
}

- (void)fetchMeaningsForAcronym:(NSString *)acronymText
{
	NSDictionary *requestParameters = @{@"sf": acronymText};
	
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
	sessionManager.responseSerializer.acceptableContentTypes = nil;
	
	[sessionManager GET:AcronymRepoURL
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
						    NSString *message = [NSString stringWithFormat:@"Sorry..!! We couldn't find any meaning for \"%@\". Please try different text.",self.acronymTextField.text];
						    [self displayErrorWithTtile:@"No Results" message:message];
					    }
					    
				    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
					    [MBProgressHUD hideHUDForView:self.view animated:YES];
					    [self displayErrorWithTtile:nil message:[error localizedDescription]];
				    }];
}

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

- (AcronymResult *)parseResponse:(id)response
{
	AcronymResult *result = [[AcronymResult alloc] init];
	result.meanings = [NSMutableArray array];
	if ([response isKindOfClass:[NSArray class]] && [response count])
	{
		[response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			NSDictionary *content = obj;
			result.shortForm = [content objectForKey:@"sf"];
			NSArray *longFormObjects = [content objectForKey:@"lfs"];
			[longFormObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				NSDictionary *longFormContent = obj;
				AcronymMeaning *longForm = [[AcronymMeaning alloc] init];
				longForm.meaning = [longFormContent objectForKey:@"lf"];
				longForm.since = [[longFormContent objectForKey:@"since"] integerValue];
				longForm.frequency = [[longFormContent objectForKey:@"freq"] integerValue];
				[result.meanings addObject:longForm];
			}];
		}];
	}
	return result;
}

@end
