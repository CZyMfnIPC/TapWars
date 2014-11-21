//
//  P2PTapWarAdvViewController.h
//  P2PTapWarAdv
//
//  Created by Andrew Claus on 6/17/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

//protocol keys
#define START_GAME_KEY @"startgame"
#define END_GAME_KEY @"endgame"
#define TAP_COUNT_KEY @"taps"

//handshake
#define INIT_SHAKE_KEY @"initshake"
#define RESPOND_SHAKE_KEY @"respondshake"
#define TERM_SHAKE_KEY @"termshake"

#define WINNING_TAP_COUNT 10

@interface P2PTapWarAdvViewController : UIViewController 
<GKPeerPickerControllerDelegate, GKSessionDelegate> {

	//declare variables
	UILabel *playerTapCountLabel;
	UILabel *opponentTapCountLabel;
	UIBarButtonItem *startQuitButton;
	
	//
	NSString *opponentID;
	BOOL actingAsHost;
	GKSession *gkSession;
	UInt32 playerTapCount;
	UInt32 opponentTapCount;
	BOOL gameEnabled;
	BOOL handshakeSent;
}

//outlets
@property (nonatomic, retain) IBOutlet UILabel *playerTapCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *opponentTapCountLabel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *startQuitButton;

- (IBAction)handleStartQuitTapped; //button tapped
- (IBAction)handleTapViewTapped; //play field tapped

@end

