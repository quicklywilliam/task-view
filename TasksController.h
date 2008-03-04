//
//  tasks.h
//  TaskView
//
//  Created by William Henderson on 11/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Context.h"
#import "WCHTableView.h"

@interface TasksController : NSObject {
	CalCalendarStore *myCalCalendarStore;
	NSMutableArray *theContexts;
	NSMutableArray *theProjects;
	IBOutlet NSArrayController *theTasksController;
	IBOutlet WCHTableView *tasksTable;
	IBOutlet WCHTableView *contextsTable;
	IBOutlet WCHTableView *subTasksTable;
}
//- (NSMutableArray *) theTasks;
//- (NSMutableArray *) theContexts;
//- (NSMutableArray *) theProjects;

-(void)getTasks;
@end
