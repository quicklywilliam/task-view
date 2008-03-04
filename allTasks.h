//
//  allTasks.h
//  TaskView
//
//  Created by William Henderson on 12/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface allTasks : NSObject {
	IBOutlet NSMutableArray *_theTasks;
	NSString *displayTitle;
	NSImage *theIcon;
	NSString *uid;
}

@end
