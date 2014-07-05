//
//  MTDateComponentsPicker.m
//  FamilySearchMobile
//
//  Created by Adam Kirk on 10/12/12.
//  Copyright (c) 2012 FamilySearch. All rights reserved.
//

#import "MTDateComponentsPicker.h"
#import <NSDate+MTDates.h>


@interface MTDateComponentsPicker ()
@property (strong, nonatomic) NSDate *startOfYear;
@end


@implementation MTDateComponentsPicker

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setup];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
	}
}

- (void)setup {
	_startOfYear = [[NSDate date] mt_startOfCurrentYear];
	_minYear = 1;
	_maxYear = [_startOfYear mt_year];
	self.delegate	= self;
	self.dataSource	= self;
}

- (void)didMoveToWindow
{
	if (!_dateComponents) _dateComponents = [[NSDateComponents alloc] init];
}

- (void)setDateComponents:(NSDateComponents *)dateComponents
{
	_dateComponents = dateComponents;

	NSInteger day	= _dateComponents.day	== NSUndefinedDateComponent ? 0 : _dateComponents.day;
	NSInteger month = _dateComponents.month == NSUndefinedDateComponent ? 0 : _dateComponents.month;
	NSInteger year	= _dateComponents.year	== NSUndefinedDateComponent ? 0 : (_maxYear - _dateComponents.year + 1);

	[self selectRow:day		inComponent:0 animated:YES];
	[self selectRow:month	inComponent:1 animated:YES];
	[self selectRow:year	inComponent:2 animated:YES];
}



#pragma mark - Picker Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component == 0) {
		return 12 + 1;
	}
	else if (component == 1) {
		NSInteger row = 32;
		if (pickerView.numberOfComponents > 1)
			[pickerView selectedRowInComponent:1];
		if (row == 32) return row;
		return [[_startOfYear mt_dateMonthsAfter:(row - 1)] mt_daysInCurrentMonth] + 1;
	}
	else {
		return (_maxYear - _minYear) + 1;
	}
}




#pragma mark - Picker Delegate

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *string = @"?";
	if (component == 0) {
		if (row != 0)
			string = [[_startOfYear mt_dateMonthsAfter:(row - 1)] mt_stringFromDateWithFullMonth];
	}

	else if (component == 1) {
		if (row != 0)
			string = [NSString stringWithFormat:@"%d", row];
	}

	else {
		if (row != 0) {
			string = [NSString stringWithFormat:@"%d", (_maxYear - (row - 1))];
		}
	}

	return [[NSAttributedString alloc] initWithString:string attributes:self.titleAttributes];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (row == 0) {
		if (component == 0) [_dateComponents setMonth:NSUndefinedDateComponent];
		if (component == 1) [_dateComponents setDay:NSUndefinedDateComponent];
		if (component == 2) [_dateComponents setYear:NSUndefinedDateComponent];
		return;
	}

	if (component == 0) {
		[_dateComponents setMonth:row];
		if (_onChange) _onChange(_dateComponents);
	}

	else if (component == 1) {
		[_dateComponents setDay:row];
		if (_onChange) _onChange(_dateComponents);
	}

	else if (component == 2) {
		NSInteger year = _maxYear - row + 1;
		_startOfYear = [NSDate mt_dateFromYear:year month:1 day:1];
		[_dateComponents setYear:year];
		if (_onChange) _onChange(_dateComponents);
	}

	[pickerView reloadComponent:0]; // reload month, number of days could change with month or if leap year.
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	if (component == 0) {
		return 140.0;
	} else if (component == 1) {
		return 60.0;
	} else {
		return 60.0;
	}
}

@end
