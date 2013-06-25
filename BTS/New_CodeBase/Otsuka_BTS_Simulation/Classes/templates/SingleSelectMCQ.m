    //
//  SingleSelectMCQ.m
//  Otsuka_BTS_Simulation
//
//  Created by administrator on 5/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SingleSelectMCQ.h"
#import "ShellViewController.h"

@interface SingleSelectMCQ ()

- (void) choiceSelected:(id) sender;

@end


@implementation SingleSelectMCQ

// Params for choice
static const float DEFAULT_X_POS_CHOICE = 33.0;
static const float DEFAULT_Y_POS_CHOICE = 275.0;
static const float DEFAULT_WIDTH_CHOICE = 833.0;
static const float DEFAULT_HEIGHT_CHOICE = 86.0;
static const float Y_DIFF_CHOICE = 4;

// Params for Line
static const float DEFAULT_WIDTH_LINE = 755.0;
static const float DEFAULT_HEIGHT_LINE = 0.0;
static const float X_DIFF_LINE = 2;
static const float Y_DIFF_LINE = 3;

/*
 
 <UIButton: 0x511a1b0; frame = (113 219; 748 92); opaque = NO; autoresize = RM+BM; layer = <CALayer: 0x510da20>>
 <UIView: 0x511a360; frame = (113 313; 755 8); autoresize = RM+BM; layer = <CALayer: 0x511a930>>
 */
@synthesize pageContent, options;
@synthesize titleText, questionText, decideBtn;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void) initActivity {
	decideBtn.enabled = NO;
	options = [[NSMutableDictionary alloc] init];
	pageContent = [[NSArray arrayWithArray:[[ShellViewController getInstance] getPageContent]] retain];
	//titleText.text = [[[pageContent objectAtIndex:0] objectAtIndex:1] objectForKey:@"title"];
	[questionText loadHTMLString:[[[pageContent objectAtIndex:0] objectAtIndex:3] objectForKey:@"instructions"] baseURL:[NSURL URLWithString:@""]];
	[titleText loadHTMLString:[[[pageContent objectAtIndex:0] objectAtIndex:1] objectForKey:@"title"] baseURL:[NSURL URLWithString:@""]];
	
	// To disable overscrolling
	UIScrollView *scrollView = nil;
	for(UIView *aView in questionText.subviews){
		if([aView isKindOfClass:[UIScrollView class] ]){
			scrollView = (UIScrollView *)aView;
			//scrollView.scrollEnabled = NO;
			scrollView.bounces = NO;
		}
	}
	// To remove black background while scrolling
	questionText.backgroundColor = [UIColor clearColor];
	questionText.opaque = NO;
	
	int choiceCount = [[[pageContent objectAtIndex:0] objectAtIndex:4] count];
	for (int i = 0; i<choiceCount; i++) {
		UIButton *choiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		choiceBtn.frame = CGRectMake(DEFAULT_X_POS_CHOICE, DEFAULT_Y_POS_CHOICE + ((DEFAULT_HEIGHT_CHOICE + Y_DIFF_CHOICE) * (float)i), DEFAULT_WIDTH_CHOICE, DEFAULT_HEIGHT_CHOICE);
		choiceBtn.tag = (i + 1);
		[choiceBtn addTarget:self action:@selector(choiceSelected:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
		[choiceBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"question_optBg_normal" ofType:@"png"]] forState:UIControlStateNormal];
		[choiceBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"question_optBg" ofType:@"png"]] forState:UIControlStateSelected];
		[options setObject:choiceBtn forKey:[[[[[pageContent objectAtIndex:0] objectAtIndex:4] objectAtIndex:i] objectAtIndex:0] objectForKey:@"id"]];
		        
        [self.view addSubview:choiceBtn];
       
        
		UIWebView *choiceText = [[UIWebView alloc] initWithFrame:CGRectMake(DEFAULT_X_POS_CHOICE - 10, DEFAULT_Y_POS_CHOICE + ((DEFAULT_HEIGHT_CHOICE + Y_DIFF_CHOICE) * (float)i), DEFAULT_WIDTH_CHOICE + 15, DEFAULT_HEIGHT_CHOICE)];
		[choiceText loadHTMLString:[[[[[pageContent objectAtIndex:0] objectAtIndex:4] objectAtIndex:i] objectAtIndex:2] objectForKey:@"choiceText"] baseURL:[NSURL URLWithString:@""]];
		choiceText.backgroundColor = [UIColor clearColor];
		choiceText.opaque = NO;
		choiceText.userInteractionEnabled = NO;
		[self.view addSubview:choiceText];
		[choiceText release];
		
		UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"line02" ofType:@"png"]]];
		line.frame = CGRectMake(choiceBtn.frame.origin.x - X_DIFF_LINE, choiceBtn.frame.origin.y + choiceBtn.frame.size.height + Y_DIFF_LINE, DEFAULT_WIDTH_LINE, DEFAULT_HEIGHT_LINE);
		[self.view addSubview:line];
		
		[line release];		
		[choiceBtn release];
	}
}

- (void) choiceSelected:(id) sender {
	UIButton *btn = (UIButton *) sender;
    
    NSString * test= [[[[[pageContent objectAtIndex:0] objectAtIndex:4] objectAtIndex:btn.tag-1] objectAtIndex:2] objectForKey:@"choiceText"];
    int ln=test.length; 

    if (ln==577)
    {
        test = @"<welcomeText style= font-family:Helvetica; font-size:12pt; line-height:18pt; text-align:justify; font-weight:normal; color:#333; display:block; margin:0 10px 10px><b>D</b>. Plan to use the meeting to fully identify and document all of Dr.Cardonza\u2019s concerns about prescribing your product, in addition to presenting information. Take time to anticipate his concerns. After all, he is very comfortable with the traditional methods for treating hyponatremia, having used them for his entire career, and naturally he will have some reservations.</welcomeText>";
        UIViewController *tmp =[[UIViewController alloc] init];
        tmp.view.frame=CGRectMake(0, 0, DEFAULT_WIDTH_CHOICE, 200);
        pop=[[UIPopoverController alloc] initWithContentViewController:tmp];
        UIWebView *choiceText = [[UIWebView alloc] initWithFrame:tmp.view.frame];
        [choiceText loadHTMLString:test baseURL:[NSURL URLWithString:@""]];
        choiceText.backgroundColor = [UIColor whiteColor];
        choiceText.opaque = NO;
        choiceText.userInteractionEnabled = NO;
        pop.popoverContentSize=CGSizeMake(DEFAULT_WIDTH_CHOICE, 200);
        [tmp.view addSubview:choiceText];
    
        [pop presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [tmp release];
        [choiceText release];
    }
    
    else if (ln==856)
    {
        test = @"<welcomeText style=font-family:Helvetica; font-size:12pt; line-height:18pt; text-align:justify; font-weight:normal; color:#333; display:block; margin:0 10px 10px><b>D</b>. \u201cI recognize that I need to work more closely with Pharmacy to educate them on appropriate candidates for Samsca.  If we get Pharmacy on board, and you are able to effectively treat hyponatremia with Samsca, how do you see it impacting the cardiology department\u2019s goals for patient treatment? We do not have any data on patient outcomes in hyponatremia.  What I\u2019d like to speak to you about is the availability of Samsca at your institution and its benefits. The benefits of Samsca include increasing serum sodium concentration in patients with dilutional hyponatremia, oral administration, and no requirement of administration in the ICU or CCU.\u201d </welcomeText>";
        UIViewController *tmp =[[UIViewController alloc] init];
        tmp.view.frame=CGRectMake(0, 0, DEFAULT_WIDTH_CHOICE, 200);
        pop=[[UIPopoverController alloc] initWithContentViewController:tmp];
        UIWebView *choiceText = [[UIWebView alloc] initWithFrame:tmp.view.frame];
        [choiceText loadHTMLString:test baseURL:[NSURL URLWithString:@""]];
        choiceText.backgroundColor = [UIColor whiteColor];
        choiceText.opaque = NO;
        choiceText.userInteractionEnabled = NO;
        pop.popoverContentSize=CGSizeMake(DEFAULT_WIDTH_CHOICE, 200);
        [tmp.view addSubview:choiceText];
        
        [pop presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [tmp release];
        [choiceText release];
    }
    
    else if (ln==830)
    {
        test = @"<welcomeText style= font-family:Helvetica; font-size:12pt; line-height:18pt; text-align:justify; font-weight:normal; color:#333; display:block; margin:0 10px 10px><b>B</b>. Tell Dr. Gomez that you will plan to meet with Michelle Hinley in Pharmacy.  It has been some time since your last meeting with her, which occurred during the formulary review process. At that time, she was resistant but ultimately agreed to allow access to Samsca for nephrology. You will work closely with Michelle, discussing the benefits and risks of prescribing Samsca for heart failure patients with hyponatremia, and providing pertinent information, such as clinical trial results.  Once Michelle understands the benefits of Samsca for use with hyponatremia in heart failure, she may be more supportive of its use. </welcomeText>";
        UIViewController *tmp =[[UIViewController alloc] init];
        tmp.view.frame=CGRectMake(0, 0, DEFAULT_WIDTH_CHOICE, 200);
        pop=[[UIPopoverController alloc] initWithContentViewController:tmp];
        UIWebView *choiceText = [[UIWebView alloc] initWithFrame:tmp.view.frame];
        [choiceText loadHTMLString:test baseURL:[NSURL URLWithString:@""]];
        choiceText.backgroundColor = [UIColor whiteColor];
        choiceText.opaque = NO;
        choiceText.userInteractionEnabled = NO;
        pop.popoverContentSize=CGSizeMake(DEFAULT_WIDTH_CHOICE, 200);
        [tmp.view addSubview:choiceText];
        
        [pop presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [tmp release];
        [choiceText release];
    }
    
    else if (ln==573)
    {
        test = @"<welcomeText style= font-family:Helvetica; font-size:12pt; line-height:18pt; text-align:justify; font-weight:normal; color:#333; display:block; margin:0 10px 10px><b>A</b>.As a hospitalist, I know you see SIADH, cirrhosis, and heart failure patients who present with hyponatremia.  I’d like to set a time to share more specifically with you about Samsca, and potentially also arrange a time to continue that conversation with Pharmacy or Dr. Rivers, a nephrologist who regularly prescribes Samsca. When would be a good time to meet again? </welcomeText>";
        UIViewController *tmp =[[UIViewController alloc] init];
        tmp.view.frame=CGRectMake(0, 0, DEFAULT_WIDTH_CHOICE, 100);
        pop=[[UIPopoverController alloc] initWithContentViewController:tmp];
        UIWebView *choiceText = [[UIWebView alloc] initWithFrame:tmp.view.frame];
        [choiceText loadHTMLString:test baseURL:[NSURL URLWithString:@""]];
        choiceText.backgroundColor = [UIColor whiteColor];
        choiceText.opaque = NO;
        choiceText.userInteractionEnabled = NO;
        pop.popoverContentSize=CGSizeMake(DEFAULT_WIDTH_CHOICE, 100);
        [tmp.view addSubview:choiceText];
        
        [pop presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [tmp release];
        [choiceText release];
    }
    
	int choiceCount = [[[pageContent objectAtIndex:0] objectAtIndex:4] count];
	for (int i = 1; i <= choiceCount; i++) {
		[[options objectForKey:[NSString stringWithFormat:@"%d", i]] setSelected:NO];
	}
	btn.selected = YES;
	decideBtn.enabled = YES;
}

- (IBAction) onDecide:(id) sender {
	if (!decideBtn.enabled) {
		return;
	}
	
	int choiceCount = [[[pageContent objectAtIndex:0] objectAtIndex:4] count];
	int i = 1;
	int j = 0;
	for (; i <= choiceCount; i++) {
		UIButton *btn = [options objectForKey:[NSString stringWithFormat:@"%d", i]];
		if (btn.selected) {
			break;
		};
	}
	
	
	NSMutableDictionary *kpiData = [[[NSMutableDictionary alloc] init] autorelease];
	NSArray *kpi = [NSArray arrayWithArray:[[[[pageContent objectAtIndex:0] objectAtIndex:4] objectAtIndex:(i-1)] objectAtIndex:3]];
	for (int j = 1; j < [kpi count]; j++) {
		//NSLog(@"kpiData >>> %@", [[kpi objectAtIndex:j] objectForKey:@"KPI"]);
		[kpiData setObject:[[[kpi objectAtIndex:j] objectForKey:@"attributes"] objectForKey:@"marks"] forKey:[[kpi objectAtIndex:j] objectForKey:@"KPI"]];
	}
	
	for (; j < choiceCount; j++) {
		//NSLog(@"isCorrect >>> %@", [[[[[pageContent objectAtIndex:0] objectAtIndex:4] objectAtIndex:j] objectAtIndex:1] objectForKey:@"isCorrect"]);
		
		if ([[[[[[pageContent objectAtIndex:0] objectAtIndex:4] objectAtIndex:j] objectAtIndex:1] objectForKey:@"isCorrect"] isEqual:@"YES"]) {
			NSArray *kpi = [NSArray arrayWithArray:[[[[pageContent objectAtIndex:0] objectAtIndex:4] objectAtIndex:j] objectAtIndex:3]];
			for (int k = 1; k < [kpi count]; k++) {
				//NSLog(@"kpiData >>> %@", [[kpi objectAtIndex:j] objectForKey:@"KPI"]);
				[kpiData setObject:[[[kpi objectAtIndex:k] objectForKey:@"attributes"] objectForKey:@"marks"] forKey:[NSString stringWithFormat:@"Max %@",[[kpi objectAtIndex:k] objectForKey:@"KPI"]]];
			}
			break;
		}
	}	
	
	NSMutableDictionary *decisionData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", (i-1)], @"ChoiceSelected", [NSString stringWithFormat:@"%d", j], @"CorrectChoice", nil];
    for (NSString *kpi in kpiData) {
        if (![[[kpi substringToIndex:4] lowercaseString] isEqualToString:@"max "]) {
            [decisionData setValue:[kpiData objectForKey:kpi] forKey:kpi];
        }
    }
   	//NSLog(@"userData >>>> %@", decisionData);
	[ShellViewController saveDecisionData:decisionData forID:[[[pageContent objectAtIndex:0] objectAtIndex:0] objectForKey:@"id"]];
	[ShellViewController updateKPIs:kpiData];
	//NSLog(@"branchTo = %@", [[[[[pageContent objectAtIndex:0] objectAtIndex:4] objectAtIndex:(i-1)] objectAtIndex:4] objectForKey:@"branchTo"]);
	[[ShellViewController getInstance] loadPageById:[[[[[pageContent objectAtIndex:0] objectAtIndex:4] objectAtIndex:(i-1)] objectAtIndex:4] objectForKey:@"branchTo"]];
}

- (void) nextPage {
	// Left empty to avoid going to next page through swipe gesture.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [pageContent release];
	[titleText release];
	[questionText release];
	[decideBtn release];
    [super dealloc];
	//[options release];
}


@end
