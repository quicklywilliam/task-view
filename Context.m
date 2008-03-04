//
//  Context.m
//  TaskView
//
//  Created by William Henderson on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Context.h"


@implementation Context
@synthesize title;
@synthesize uid;
@synthesize _theTasks;


-(id) initWithCalendar:(CalCalendar *) cal {
	[super init];
	
	NSPredicate *predicate = [CalCalendarStore taskPredicateWithCalendars:[NSArray arrayWithObject:cal]];
	self.title = cal.title;
	self.uid = cal.uid;
	NSString* imageName = [[NSBundle mainBundle]
							   pathForResource:self.title ofType:@"png"];
	theIcon = [[NSImage alloc] initWithContentsOfFile:imageName];
	self._theTasks = [[[CalCalendarStore defaultCalendarStore] tasksWithPredicate:predicate] mutableCopy];
	for(CalTask *task in self._theTasks){
		[self addTaskAsObserver:task];
	}
	[self addObserver:self forKeyPath:@"theTasks"
			  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
			  context:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTasks:)
												 name:CalTasksChangedExternallyNotification object:[CalCalendarStore defaultCalendarStore]];
	return self;
}
-(void) addTaskAsObserver:(CalTask *)task {
	[task addObserver:self forKeyPath:@"isCompleted"
			  options:(0)
			  context:NULL];
	[task addObserver:self forKeyPath:@"title"
			  options:(0)
			  context:NULL];
	[task addObserver:self forKeyPath:@"dueDate"
			  options:(0)
			  context:NULL];
}
-(void) removeTaskAsObserver:(CalTask *)task {
	[task removeObserver:self forKeyPath:@"isCompleted"];
	[task removeObserver:self forKeyPath:@"title"];
	[task removeObserver:self forKeyPath:@"dueDate"];
}

-(void) updateTasks:(NSNotification *) notification {
    NSArray *deletedTasks = [[notification userInfo] valueForKey:CalDeletedRecordsKey];
	//again, we want to prevent notification for these events...
	[self removeObserver:self forKeyPath:@"theTasks"];
    if (deletedTasks){
		for(NSString *theUid in deletedTasks) {
			CalTask* task = [self findTaskWithUid:theUid];
			if(task) {
				[self removeTaskAsObserver:task];
				[[self mutableArrayValueForKey:@"theTasks"] removeObject:task];
			}
		}
    }
	
    NSArray *insertedTasks = [[notification userInfo] valueForKey:CalInsertedRecordsKey];
    if (insertedTasks){
		for(NSString *theUid in insertedTasks) {
			CalTask *task = [[CalCalendarStore defaultCalendarStore] taskWithUID:theUid];
			if([task.calendar.title isEqualToString:self.title]) {
				[self addTask:task];
			}
		}
    }
	
    NSArray *updatedTasks = [[notification userInfo] valueForKey:CalUpdatedRecordsKey];
    if (updatedTasks){
		for(NSString *theUid in updatedTasks) {
			CalTask *task = [[CalCalendarStore defaultCalendarStore] taskWithUID:theUid];
			if([task.calendar.title isEqualToString:self.title]) {
				[self updateTask:task];
			}
		}
    }
	[self addObserver:self forKeyPath:@"theTasks"
			  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
			  context:NULL];
	
	return;
}
-(CalCalendar *) getAssociatedCalendar {
	return [[CalCalendarStore defaultCalendarStore] calendarWithUID:self.uid];
}
-(NSString *) displayTitle {
	return [self.title substringFromIndex:1];	
}
-(NSImage *)displayImage {
	return theIcon;
}

-(void)updateTask:(CalTask *)newTask {
	for(CalTask *task in self._theTasks) {
		if([task.uid isEqualToString:newTask.uid]) {
			[self removeTaskAsObserver:task];
			[[self mutableArrayValueForKey:@"theTasks"] replaceObjectAtIndex:[self._theTasks indexOfObject:task] withObject:newTask];
			[self addTaskAsObserver:newTask];
		}
	}
	return;
}

-(void)addTask:(CalTask *)task {
	[[self mutableArrayValueForKey:@"theTasks"] addObject:task];
	[self addTaskAsObserver:task];
	return;
}

-(CalTask *)findTaskWithUid:(NSString *)theUid {
	for(CalTask *task in self._theTasks) {
		if([task.uid isEqualToString:theUid]) {
			return task;
		}
	}
	return nil;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([object isKindOfClass:[CalTask class]] && 
	([keyPath isEqualToString:@"isCompleted"] || [keyPath isEqualToString:@"title"] || [keyPath isEqualToString:@"dueDate"])){ 
		NSError *taskSavingError;
		NSLog(@"keypath is %@", keyPath);
		NSLog(@"the date is %@", [object dueDate]);
		//we have to remove the notification and then add it again to prevent an infinite loop when we save...
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:CalEventsChangedExternallyNotification object:[CalCalendarStore defaultCalendarStore]];
		if ([[CalCalendarStore defaultCalendarStore] saveTask:[object copy] error:&taskSavingError] == NO){
			NSAlert *alertPanel = [NSAlert alertWithError:taskSavingError];
			(void) [alertPanel runModal];
		}

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTasks:) 
													 name:CalEventsChangedExternallyNotification object:[CalCalendarStore defaultCalendarStore]];
	}
	else if([object isKindOfClass:[Context class]]){
		//make sure we unobserve and ovbserve and stuff
		NSLog(@"thenew is is=%@", [change valueForKey:NSKeyValueChangeNewKey]);
		NSLog(@"theold is is=%@", [change valueForKey:NSKeyValueChangeOldKey]);
		NSLog(@"thetype is is=%@", keyPath);
		NSLog(@"thechange is is=%@", change);
		NSLog(@"the context is is=%@", context);
		NSLog(@"theobject is is=%@", object);
		NSError *taskSavingError;
		
		//we have to remove the notification and then add it again to prevent an infinite loop when we save...
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:CalEventsChangedExternallyNotification object:[CalCalendarStore defaultCalendarStore]];
		id oldTasks = [change valueForKey:NSKeyValueChangeOldKey];
		if(oldTasks){
			for(CalTask *task in oldTasks) {
				[self removeTaskAsObserver:task];
				if ([[CalCalendarStore defaultCalendarStore] removeTask:task error:&taskSavingError] == NO){
					NSAlert *alertPanel = [NSAlert alertWithError:taskSavingError];
					(void) [alertPanel runModal];
				}
			}
		}
		id newTasks = [change valueForKey:NSKeyValueChangeNewKey];
		if(newTasks){
			for(CalTask *task in newTasks) {
				[task setCalendar:[self getAssociatedCalendar]];
				if ([[CalCalendarStore defaultCalendarStore] saveTask:task error:&taskSavingError] == NO){
					NSAlert *alertPanel = [NSAlert alertWithError:taskSavingError];
					(void) [alertPanel runModal];
				}
				[self addTaskAsObserver:task];
			}
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTasks:) 
													 name:CalEventsChangedExternallyNotification object:[CalCalendarStore defaultCalendarStore]];
	}
}
@end
