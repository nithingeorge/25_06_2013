//
//  MaintenanceLogDetailNotesView.m
//  GreenVolts
//
//  Created by Shinu Mohan on 24/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MaintenanceLogDetailNotesView.h"
#import <QuartzCore/QuartzCore.h>

@interface MaintenanceLogDetailNotesView() 

-(void)createCustomNavigationView;
- (IBAction)logbackButtonTouched:(id)sender;   
@end
@implementation MaintenanceLogDetailNotesView
@synthesize detailtextView;
@synthesize delegate;
@synthesize componentid;
@synthesize currentNotes;
#pragma mark-initialisations
- (id)initWithFrame:(CGRect)frame andNotes:(NSString*)notes
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.currentNotes=notes;
        [self loadview];
        // Initialization code
    }
    return self;
}
#pragma mark-load views
-(void)loadview
{
    [self createCustomNavigationView];
    
    notesview=[[UIView alloc]initWithFrame:CGRectMake(0,45,320,330)];
   // notesview.backgroundColor=[UIColor lightGrayColor];
    notesview.backgroundColor=[UIColor colorWithRed:219/255.0f green:220/255.0f blue:223/255.0f alpha:1.0];
    [self addSubview:notesview];
    
    detailtextView = [[UITextView alloc] initWithFrame:CGRectMake(10,5,240,105)];
    detailtextView.clipsToBounds = YES;
    [detailtextView setFont:[UIFont boldSystemFontOfSize:14.0]];
    [detailtextView setTextAlignment:UITextAlignmentLeft];
    detailtextView.delegate = self;
    detailtextView.editable = YES;
 
    detailtextView.backgroundColor = [UIColor whiteColor];
    detailtextView.layer.borderWidth = 2.0f;
    detailtextView.layer.cornerRadius = 8; 
    detailtextView.layer.borderColor = [[UIColor grayColor] CGColor];
    detailtextView.text = self.currentNotes;
    
    //detailtextView.returnKeyType = UIReturnKeyDefault;
    //detailtextView.keyboardType = UIKeyboardTypeDefault; 
    detailtextView.scrollEnabled = YES;
    detailtextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [notesview addSubview:detailtextView]; 
    
     [detailtextView becomeFirstResponder];
    
    notessavebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [notessavebutton addTarget:self 
               action:@selector(notesSaveOnButtonClick)
               forControlEvents:UIControlEventTouchDown];
    [notessavebutton setTitle:@"Save" forState:UIControlStateNormal];
    notessavebutton.enabled = NO;
    notessavebutton.titleLabel.textColor=[UIColor whiteColor];
    notessavebutton.frame = CGRectMake(255,80,60,30);
    
    notessavebutton.backgroundColor = [UIColor clearColor];
    [notessavebutton setBackgroundImage:[UIImage imageNamed:@"button_subheader_generic_black.png" ]forState:UIControlStateNormal];
    [notesview addSubview:notessavebutton];

}

#pragma mark-custom methods

-(void)createCustomNavigationView
{
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    // navBar.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navpopover_cell_backround (2)"]];
    navBar.tintColor=[UIColor colorWithRed:1/255.f green:14/255.f blue:41/255.f alpha:1];

    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(5,5,80,30);
    button.backgroundColor=[UIColor clearColor];
    [button setBackgroundImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal]; 
    [button setTitle:@"Back" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(logbackButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:button]; 
    
    UILabel *logtitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(100,10,200,25)];
    logtitlelabel.backgroundColor = [UIColor clearColor];
    logtitlelabel.textColor = [UIColor whiteColor];
    logtitlelabel.text = @"Update Notes";
    [navBar addSubview:logtitlelabel];
    [self addSubview:navBar];
}

#pragma mark-button actions
- (IBAction)logbackButtonTouched:(id)sender
{
     [detailtextView resignFirstResponder];
    [UIView animateWithDuration:.35 delay:0.0 options:UIViewAnimationCurveEaseOut animations:
     ^{
         //self.center = CGPointMake(self.center.x + CGRectGetWidth(self.frame), self.frame.origin.y);         
         CGRect newRect = self.frame;
         newRect.origin.x += newRect.size.width;
         self.frame = newRect;
     } completion:^(BOOL finished) {
         if(self.delegate && [self.delegate respondsToSelector:@selector(backButtonTouched:)])
             [delegate backButtonTouched:self];
     }];
}


-(void)notesSaveOnButtonClick
{
   // [detailtextView resignFirstResponder];
    [UIView animateWithDuration:.35 delay:0.0 options:UIViewAnimationCurveEaseOut animations:
     ^{
         //self.center = CGPointMake(self.center.x + CGRectGetWidth(self.frame), self.frame.origin.y);         
         CGRect newRect = self.frame;
         newRect.origin.x += newRect.size.width;
         self.frame = newRect;
     } completion:^(BOOL finished) {
         [self removeFromSuperview];
     }];

    if(detailtextView.text)
    {
    textViewString = detailtextView.text;
    }
    
   if(self.delegate && [self.delegate respondsToSelector:@selector(logDetailNoteSaved: componentID:)]) 
  [self.delegate logDetailNoteSaved:textViewString componentID:componentid];
}

#pragma mark- textview delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    notessavebutton.enabled = YES;
    return YES;
    
}
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView
//{
//    return NO;
//}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    
//    if([text isEqualToString:@""])
//    {
//        
//        return YES;
//    }
//    
//    BOOL isNotExceed = YES;
//    int length = [textView.text length];
//    
//    if (length <140)
//        isNotExceed = YES;  
//    
//    else 
//    {
//        isNotExceed = NO;
//        //message
//        NSLog(@"exceeded");
//    }
//    
//    return isNotExceed;
//}
//


@end