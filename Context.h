//
//  Context.h
//  TaskView
//
//  Created by William Henderson on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Task.h"

@interface Context : NSObject {
	IBOutlet NSMutableArray *_theTasks;
	NSString *title;
	NSImage *theIcon;
	NSString *uid;
}
-(id)initWithCalendar:(CalCalendar *) cal;
-(CalCalendar *) getAssociatedCalendar;
-(NSString *)displayTitle;
-(NSImage *)displayImage;
-(CalTask *)findTaskWithUid:(NSString *)uid;
-(void)addTask:(CalTask *)task;
-(void)updateTask:(CalTask *)newTask;
-(void) updateTasks:(NSNotification *) notification;
-(void) addTaskAsObserver:(CalTask *)task;
-(void) removeTaskAsObserver:(CalTask *)task;
@property(copy, readwrite) NSString *title;
@property(copy, readwrite) NSString *uid;
@property(assign, readwrite) NSMutableArray *_theTasks;

@end
