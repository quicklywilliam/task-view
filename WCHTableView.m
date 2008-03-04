//
//  WCHTableView.m
//  TaskView
//
//  Created by William Henderson on 12/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "WCHTableView.h"


@implementation WCHTableView
@synthesize handlesDeleteKey;
@synthesize handlesReturnKey;
@synthesize shouldDisappearWhenKeyOut;

-(id)init {
	[super init];
	handlesDeleteKey = NO;
	handlesReturnKey = NO;
	shouldDisappearWhenKeyOut = NO;
	collapsabile_width = 160;
	return self;
}
-(void)collapseMe{
	if(shouldDisappearWhenKeyOut) {
		[[[self enclosingScrollView] superview] 
		 setPosition:[[[self enclosingScrollView] superview] maxPossiblePositionOfDividerAtIndex:1] //make this a more useful value...
		 ofDividerAtIndex:1];
//		[self animateSplitView:[self enclosingScrollView] open:NO];
	}	
}
-(BOOL)becomeFirstResponder {
	if(nextTable)	{
		nextTable.collapseMe;
	}
	return YES;
}
- (void)keyDown:(NSEvent*)event_ {
	NSString *eventCharacters = [event_ characters];
	if ([eventCharacters length]) {
		switch ([eventCharacters characterAtIndex:0]) {
			case NSDeleteFunctionKey:
			case NSDeleteCharFunctionKey:
			case 13:{
				if(handlesReturnKey) {
					[self editColumn:1 row:[self selectedRow] withEvent:nil select:YES];
				}
				break;
			}
			case NSLeftArrowFunctionKey: {
				if(previousTable) {
					[[self window] makeFirstResponder:previousTable];
				}
				break;
			}
			case NSRightArrowFunctionKey: {
				if(nextTable) {
					if([nextTable numberOfRows] > 0){
						if([nextTable shouldDisappearWhenKeyOut]){
							
	//						[self animateSplitView:[nextTable enclosingScrollView] open:YES];
							[[[nextTable enclosingScrollView] superview] 
							 setPosition:([[[self enclosingScrollView] superview] minPossiblePositionOfDividerAtIndex:1] + 4000000) //make this a more useful value...
							 ofDividerAtIndex:1];
						}
					   [[self window] makeFirstResponder:nextTable];
					}
				}
				break;
			}
			case NSDeleteCharacter: {//this code due to http://rentzsch.com/cocoa/NSTableViewCocoaBindingsDeleteKey
				if(handlesDeleteKey){
					NSArray *columns = [self tableColumns];
					unsigned columnIndex = 0, columnCount = [columns count];
					NSDictionary *valueBindingDict = nil;
					for (; !valueBindingDict && columnIndex < columnCount; ++columnIndex) {
						valueBindingDict = [[columns objectAtIndex:columnIndex] infoForBinding:@"value"];
					}
					if (valueBindingDict && [[valueBindingDict objectForKey:@"NSObservedObject"] isKindOfClass:[NSArrayController class]]) {
						//	Found a column bound to an array controller.
						[[valueBindingDict objectForKey:@"NSObservedObject"] remove:self];
					} else {
						[super keyDown:event_];
					}
				}
				else{
					[super keyDown:event_];
				}
			} break;
			default:
				//				NSLog([NSString stringWithFormat:@"%d",[eventCharacters characterAtIndex:0]]);
				[super keyDown:event_];
				break;
		}
	}
}

@end
