//
//  WCHTableView.h
//  TaskView
//
//  Created by William Henderson on 12/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WCHTableView : NSTableView {
	BOOL handlesDeleteKey;
	BOOL handlesReturnKey;
	BOOL shouldDisappearWhenKeyOut;
	IBOutlet WCHTableView *nextTable;
	IBOutlet WCHTableView *previousTable;
	float collapsabile_width;
}
- (void)keyDown:(NSEvent*)event_;
-(void)collapseMe;
- (void)animateSplitView:(NSView*)theView open:(bool)shouldOpen;
@property(assign, readwrite) BOOL handlesDeleteKey;
@property(assign, readwrite) BOOL handlesReturnKey;
@property(assign, readwrite) BOOL shouldDisappearWhenKeyOut;


@end
