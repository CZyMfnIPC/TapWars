//
//  P2PTapWarAdvViewController.m
//  P2PTapWarAdv
//
//  Created by Andrew Claus on 6/17/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "P2PTapWarAdvViewController.h"

@implementation P2PTapWarAdvViewController
@synthesize playerTapCountLabel;
@synthesize opponentTapCountLabel;
@synthesize startQuitButton;

//initialization
- (void)viewDidLoad {
	gameEnabled = NO;
	[self.view setBackgroundColor:[UIColor redColor]];
	
	handshakeSent = NO;
}

//initialize counters
-(void) initGame {
	playerTapCount = 0;
	opponentTapCount = 0;
	
	handshakeSent = NO;
}

#pragma mark -
#pragma mark Game Logic

//update the count labels
-(void) updateTapCountLabels {
	playerTapCountLabel.text =
	[NSString stringWithFormat:@"%d", (unsigned int)playerTapCount];
	opponentTapCountLabel.text =
	[NSString stringWithFormat:@"%d", (unsigned int)opponentTapCount];
}

//start a new game as a host
-(void) hostGame {
	[self initGame];
	NSMutableData *message = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
								 initForWritingWithMutableData:message];
	[archiver encodeBool:YES forKey:START_GAME_KEY];
	[archiver finishEncoding];
	NSError *sendErr = nil;
	[gkSession sendDataToAllPeers: message
					 withDataMode:GKSendDataReliable error:&sendErr];
	if (sendErr)
		NSLog (@"send greeting failed: %@", sendErr);
	
	gameEnabled = YES;
	// change state of startQuitButton
	startQuitButton.title = @"Quit";
	[message release];
	[archiver release];
	[self updateTapCountLabels];
	[self.view setBackgroundColor:[UIColor greenColor]];
}

//start a new game as a client
-(void) joinGame {
	[self initGame];
	gameEnabled = YES;
	startQuitButton.title = @"Quit";
	[self updateTapCountLabels];
	[self.view setBackgroundColor:[UIColor greenColor]];
}

//show end game alert based upon win or loss
-(void) showEndGameAlert {	

	BOOL playerWins = playerTapCount > opponentTapCount;
	
	if (playerTapCount == opponentTapCount) {
		UIAlertView *endGameAlert1 = [[UIAlertView alloc]
									 initWithTitle: @"TIE!"
									 message: @"You have tied your opponent!"
									 delegate:nil
									 cancelButtonTitle:@"OK"
									 otherButtonTitles:nil];
		[endGameAlert1 show];
		[endGameAlert1 release];
	}
	else {
		UIAlertView *endGameAlert2 = [[UIAlertView alloc]
								 initWithTitle: playerWins ? @"Victory!" : @"Defeat!"
								 message: playerWins ? @"Your thumbs have emerged supreme!":
								 @"Your thumbs have been laid low"
								 delegate:nil
								 cancelButtonTitle:@"OK"
								 otherButtonTitles:nil];
		[endGameAlert2 show];
		[endGameAlert2 release];
	}
}

//end the game
-(void) endGame {
	
	//disconnect from bluetooth
	opponentID = @"";
	startQuitButton.title = @"Find";
	[gkSession disconnectFromAllPeers];
	[self showEndGameAlert];
}

//when the view is tapped
-(IBAction) handleTapViewTapped {
	
	if (gameEnabled) {
		
		playerTapCount++;
		[self updateTapCountLabels];
	
		//did player win?
		BOOL playerWins = playerTapCount >= WINNING_TAP_COUNT;
		
		// send tap count to peer
		NSMutableData *message = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver =
		[[NSKeyedArchiver alloc] initForWritingWithMutableData:message];
		[archiver encodeInt:playerTapCount forKey: TAP_COUNT_KEY];
		[archiver finishEncoding];
		GKSendDataMode sendMode =
		playerWins ? GKSendDataReliable : GKSendDataUnreliable;
		[gkSession sendDataToAllPeers: message withDataMode:sendMode error:NULL];
		
		[archiver release];
		[message release];
				
		//if this was our winning tap
		if (playerWins)	[self initiateHandshake]; //initiate the handshake
	}
}

//when find button is tapped
-(IBAction) handleStartQuitTapped { 
	if (!opponentID || [opponentID  isEqual: @""]) {
		actingAsHost = YES; 
		GKPeerPickerController *peerPickerController = [[GKPeerPickerController alloc] init]; 
		peerPickerController.delegate = self; 
		peerPickerController.connectionTypesMask = GKPeerPickerConnectionTypeNearby; 
		[peerPickerController show];
	}
}

#pragma mark -
#pragma mark Find peers

//peer picker setup
-(GKSession*) peerPickerController: (GKPeerPickerController*) controller 
		  sessionForConnectionType: (GKPeerPickerConnectionType) type {
	if (!gkSession) {
		gkSession = [[GKSession alloc]
					 initWithSessionID:nil
					 displayName:nil
					 sessionMode:GKSessionModePeer];
		gkSession.delegate = self;
	}
	return gkSession;
}

//peer picker selected
- (void)peerPickerController:(GKPeerPickerController *)picker
			  didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
	NSLog ( @"connected to peer %@", peerID);
}

//peer picker cancelled
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
	NSLog ( @"peer picker cancelled");
}

#pragma mark -
#pragma mark Handshake

//initiate the handshake when the game is over on this peer
//there is a chance that both peers will send an initiate at the same time
//this function will disable the user interface, send a final state on this peer (1), and wait for a response
- (void)initiateHandshake {
	
	//we are sending a handshake on this client
	handshakeSent = YES;
	
	//disable game
	gameEnabled = NO;
	[self.view setBackgroundColor:[UIColor redColor]];
	
	NSMutableData *message = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
								 initForWritingWithMutableData:message];
	
	/* already sent final tap reliably
	//attach our final player tap count
	[archiver encodeInt:playerTapCount forKey: TAP_COUNT_KEY];
	*/
	
	//attach request for a response handshake
	[archiver encodeBool:YES forKey:INIT_SHAKE_KEY];
	[archiver finishEncoding];
	NSError *sendErr = nil;
	
	//send reliable message
	[gkSession sendDataToAllPeers: message
					 withDataMode:GKSendDataReliable error:&sendErr];
	if (sendErr)
		NSLog (@"send end_game failed: %@", sendErr);
	
	[message release];
	[archiver release];
}

//respond to a handshake on only one peer
//this will disable the user interface, send a final state of this peer (2), then terminate the game on peer (2).
- (void)respondHandshake {
	
	//only respond if we did not send a handshake or we are not the server.
	//let the client have priority if both peers send a handshake
	if (!handshakeSent || !actingAsHost) {
		
		//disable game
		gameEnabled = NO;
		[self.view setBackgroundColor:[UIColor redColor]];
		
		//attach final player tap count
		NSMutableData *message = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
									 initForWritingWithMutableData:message];
		[archiver encodeInt:playerTapCount forKey: TAP_COUNT_KEY];
		
		//attach terminate handshake response
		[archiver encodeBool:YES forKey:RESPOND_SHAKE_KEY];
		[archiver finishEncoding];
		NSError *sendErr = nil;
		
		//send reliable message
		[gkSession sendDataToAllPeers: message
						 withDataMode:GKSendDataReliable error:&sendErr];
		if (sendErr)
			NSLog (@"send end_game failed: %@", sendErr);
		
		[message release];
		[archiver release];
		
		//end the game on this peer
		[self endGame];
	}
}

//both peers have sent their final state to the other, and peer (2) is already terminated.
//this will terminate the game on peer (1).
- (void)terminateHandshake {
	
	//end the game on this peer
	[self endGame];
}

#pragma mark -
#pragma mark Bluetooth connection

//conntection request recieved from peer
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	actingAsHost = NO;
}

//change state to connected
- (void)session:(GKSession *)session peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state {
    switch (state) 
    { 
        case GKPeerStateConnected: 
			[session setDataReceiveHandler: self withContext: nil]; 
			opponentID = peerID;
			actingAsHost ? [self hostGame] : [self joinGame];
			break; 
    } 
}

//connection failed, log error
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog (@"session:connectionWithPeerFailed:withError:");	
}

//session failed, log error
- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog (@"session:didFailWithError:");		
}

//recieve data
- (void) receiveData: (NSData*) data fromPeer: (NSString*) peerID
		   inSession: (GKSession*) session context: (void*) context {
	NSKeyedUnarchiver *unarchiver =
	[[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	if ([unarchiver containsValueForKey:TAP_COUNT_KEY]) {
		opponentTapCount = [unarchiver decodeIntForKey:TAP_COUNT_KEY];
		[self updateTapCountLabels];
	}
	if ([unarchiver containsValueForKey:INIT_SHAKE_KEY]) {
		[self respondHandshake];
	}
	if ([unarchiver containsValueForKey:RESPOND_SHAKE_KEY]) {
		[self terminateHandshake];
	}
	if ([unarchiver containsValueForKey:START_GAME_KEY]) {
		[self joinGame];
	}
	[unarchiver release];
}

#pragma mark -
#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.playerTapCountLabel = nil;
	self.opponentTapCountLabel = nil;
	self.startQuitButton = nil;
	opponentID = nil;
	gkSession = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	[playerTapCountLabel release];
	[startQuitButton release];
	[opponentID release];
	[gkSession release];
    [super dealloc];
}

@end
