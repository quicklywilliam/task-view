//
//  tasks.m
//  TaskView
//
//  Created by William Henderson on 11/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TasksController.h"
NSString *calPrefix = @"@";

@implementation TasksController
-(id) init {
	[super init];
	theContexts = [[NSMutableArray alloc] init];
	self.getTasks;
//uncomment to observe internal modifications
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTasks:)
//	name:CalTasksChangedNotification object:[CalCalendarStore defaultCalendarStore]];
	return self;
}
- (void)awakeFromNib {
	NSSortDescriptor* taskSortDescriptor = [[[NSSortDescriptor alloc] initWithKey: @"isCompleted" ascending: YES] autorelease];
	[tasksTable setTarget:self];
	[tasksTable setDoubleAction:@selector(doDoubleClick:)];
	[tasksTable setSortDescriptors:[NSArray arrayWithObject:taskSortDescriptor]];
	[tasksTable reloadData];
	[tasksTable setHandlesDeleteKey:YES];
	[tasksTable setHandlesReturnKey:YES];
	[subTasksTable setShouldDisappearWhenKeyOut:YES];
	[subTasksTable collapseMe];
}
- (IBAction)doDoubleClick:(id)sender {
	if([sender clickedRow] == -1){
		[theTasksController insert:self];
	}
	else {
		[tasksTable editColumn:[sender clickedColumn] row:[sender clickedRow] withEvent:nil select:YES];
	}
}

-(void) getTasks {
	[theContexts addObject:allTasks];
	for (CalCalendar *cal in [[CalCalendarStore defaultCalendarStore] calendars]) {
		if([cal.title hasPrefix:calPrefix]){
			Context *newContext = [[Context alloc] initWithCalendar:cal]
			[theContexts addObject:newContext];
			[allTasks addObjectsFromArray:[newContext _theTasks]];
		}
	}
	return;
}
@end
