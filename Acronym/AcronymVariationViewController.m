//
//  AcronymVariationViewController.m
//  Acronym
//
//  Created by Rohit Kumar on 4/28/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import "AcronymVariationViewController.h"
#import "AcronymConstants.h"

@interface AcronymVariationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *variationsTableView;
@property (nonatomic, weak) IBOutlet UILabel *noResultLabel;

@end

@implementation AcronymVariationViewController

#pragma mark- Life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	//If Variations are present in response, display them in table view
	//else display No Results in label.
	if ([self.meaning.variations count])
	{
		[self.variationsTableView setHidden:NO];
		self.noResultLabel = nil;
	}
	else
	{
		[self.noResultLabel setHidden:NO];
		[self.noResultLabel setText: [NSString stringWithFormat:@"We couldn't find any variations for %@",self.meaning.meaning]];
		self.variationsTableView = nil;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.meaning.variations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *reuseIdentifier = acronymVariationTableViewCellIdentifier;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	
	AcronymMeaning *meaning = [self.meaning.variations objectAtIndex:indexPath.row];
	cell.textLabel.text = meaning.meaning;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Used since %ld with %ld occurrances",(long)meaning.since, (long)meaning.frequency];
	
	return cell;
}

#pragma mark - Table View Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSString *headerIdentifier = acronymVariationTableViewHeaderIdentifier;
	UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
	
	headerView.textLabel.text = [NSString stringWithFormat:@"Variations of %@",self.meaning.meaning];
	
	return headerView;
}

@end
