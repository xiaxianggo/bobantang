//
//  BRSDirectionViewController.m
//  bobantang
//
//  Created by Xia Xiang on 9/7/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//
#import "SVProgressHUD.h"
#import "BRSDirectionViewController.h"
#import "BBTDirectionHeaderView.h"

@interface BRSDirectionViewController() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) CGFloat smallModeY;
@property (nonatomic) CGFloat bigModeY;

@property (strong, nonatomic) BRSMapMetaDataManager *dataManager;
@property (strong, nonatomic) BBTDirectionsManager *directionManager;

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) BBTDirectionHeaderView *directionHeaderView;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *searchResult;
@property (weak, nonatomic) UITextField *currentTextField;

@property (nonatomic) BOOL allowCircleEditing;
@end

@implementation  BRSDirectionViewController



// designated initializer
- (id)initWithDataManager:(BRSMapMetaDataManager *)dataManager directionManager:(BBTDirectionsManager *)directionManager;
{
    self = [super init];
    if (self) {
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        self.smallModeY = appFrame.size.height - 67.0f;
        self.bigModeY = 0.0f;
        
        self.dataManager = dataManager;
        self.directionManager = directionManager;
        self.searchResult = [[NSMutableArray alloc] init];
        
        NSLog(@"direction manager%@", self.directionManager);

        if ([self.directionManager alreadyHaveDirections]) {
            self.editMode = NO;
        } else {
            self.editMode = YES;
        }
    }
    
    return self;
}

- (void)loadView
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    self.view = ({
        UIView *view = [[UIView alloc] initWithFrame:appFrame];
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        view;
    });

    self.containerView = ({
        UIView *view = [[UIView alloc] initWithFrame:appFrame];
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        view;
    });
    
    self.directionHeaderView = ({
        BBTDirectionHeaderView *header = [[BBTDirectionHeaderView alloc] init];
        header.frame = CGRectMake(0.0f, 0.0f, appFrame.size.width, appFrame.size.height - self.bigModeY);
        header.startTextField.delegate = self;
        header.startTextField.clearsOnBeginEditing = NO;
        header.startTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        header.endTextField.delegate = self;
        header.endTextField.clearsOnBeginEditing = NO;
        header.endTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [header.routeButton addTarget:self action:@selector(routeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [header.hideDownArrowButton addTarget:self action:@selector(hideDirectionVC) forControlEvents:UIControlEventTouchUpInside];
        header;
    });
    
    [self.containerView addSubview:self.directionHeaderView];
    
    //CGFloat headerHeight = 96.0f;
    //CGFloat bodyHeight = appFrame.size.height - headerHeight;
    self.tableView = ({
        UITableView *tableView = self.directionHeaderView.tableView;
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView;
    });
    
    [self.view addSubview:self.containerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetDirectionResponse:)
                                                 name:kBBTDirectionDidGetResponse
                                               object:self.directionManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name: UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [super viewWillAppear:animated];
    self.allowCircleEditing = YES;
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didGetDirectionResponse:(NSNotification *)notification
{
    self.editMode = NO;
    [self updateUI];
}

- (void)updateUI
{
    [self updateRouteButton];
    self.directionHeaderView.startTextField.text = self.directionManager.sourcePlace.title;
    self.directionHeaderView.endTextField.text = self.directionManager.destnationPlace.title;
    self.directionHeaderView.distanceLabel.text = [self.directionManager distanceAndTravelTimeString];
    if (self.editMode) {
        [self.directionHeaderView.routeButton setImage:[UIImage imageNamed:@"checkMarkbutton"] forState:UIControlStateNormal];
        self.directionHeaderView.startTextField.enabled = YES;
        self.directionHeaderView.startTextField.background = [UIImage imageNamed:@"underDash"];
        self.directionHeaderView.endTextField.enabled = YES;
        self.directionHeaderView.endTextField.background = [UIImage imageNamed:@"underDash"];
    } else {
        [self.directionHeaderView.routeButton setImage:[UIImage imageNamed:@"trashcanButton"] forState:UIControlStateNormal];
        self.directionHeaderView.startTextField.enabled = NO;
        self.directionHeaderView.startTextField.background = nil;
        self.directionHeaderView.endTextField.enabled = NO;
        self.directionHeaderView.endTextField.background = nil;

    }
    [self.tableView reloadData];
}

- (void)updateRouteButton
{
    if ([self.directionManager readToDirect]) {
        self.directionHeaderView.routeButton.enabled = YES;
    } else {
        self.directionHeaderView.routeButton.enabled = NO;
    }
}

#define HIDE_BUTTON_PADDING 23.0f
- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    //int width = MAX(keyboardSize.height,keyboardSize.width);
    
    CGPoint center = self.directionHeaderView.hideDownArrowButton.center;
    center.y = self.view.frame.size.height - height - HIDE_BUTTON_PADDING;
    self.directionHeaderView.hideDownArrowButton.center = center;
    
    CGRect frame = self.directionHeaderView.tableView.frame;
    frame.size.height = self.view.frame.size.height - height - 64.0f;
    self.directionHeaderView.tableView.frame = frame;
}

# pragma mark Search 
- (void)updateSearchResultForKeyword:(NSString *) keyword
{
    [self.searchResult removeAllObjects];
    NSArray *places = self.dataManager.flatMapMetaData;
    for (BRSPlace *place in places) {
        NSRange range = [place.title rangeOfString:keyword options:NSCaseInsensitiveSearch];
        
        if (range.location != NSNotFound) {
            [self.searchResult addObject:place];
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"123");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.currentTextField == self.directionHeaderView.startTextField) {
        self.directionManager.sourcePlace = self.searchResult[indexPath.row];
        [self updateUI];
        if (!self.directionManager.destnationPlace) {
            [self.directionHeaderView.endTextField becomeFirstResponder];
            return;
        }
    } else {
        self.directionManager.destnationPlace = self.searchResult[indexPath.row];
        [self updateUI];
        if (!self.directionManager.sourcePlace) {
            [self.directionHeaderView.startTextField becomeFirstResponder];
            return;
        }
    }
    if ([self.directionManager readToDirect]) {
        [self routeButtonTapped];
    }
}

#pragma mark - UItableViewDataSouce
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"directionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    cell.textLabel.text = ((BRSPlace *)self.searchResult[indexPath.row]).title;
    cell.detailTextLabel.text = ((BRSPlace *)self.searchResult[indexPath.row]).type;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResult count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

# pragma mark - Route
- (void)routeButtonTapped
{
    if (self.editMode) {//check mark button
        [SVProgressHUD show];
        [self.directionManager directionStart];
        self.editMode = NO;
        [self updateUI];
        [self changeToSmallMode];
        // TODO : add a progress HUD
    } else {//trash can button
        [SVProgressHUD dismiss];
        [self.directionManager clearDirectionData];
        [self hideDirectionVC];
    }
}

- (void)hideDirectionVC
{
    [SVProgressHUD dismiss];
    self.allowCircleEditing = NO;
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate directionVCDidDismiss:self];
    }];
}

- (void)sButton
{
    if (self.fullMode) {
        [self changeToBigMode];
    } else {
        [self changeToSmallMode];
    }
}

#pragma mark - UITextfieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /* note UITextField has a bug on iOS 7. This method will not be called after 
     autocompliton by The Chinede input method, so I have to use the  Notification method to up date the tableview*/
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self changeToBigMode];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.directionHeaderView.startTextField) {
        NSLog(@"start field hit return");
        if (!self.endPlace && self.allowCircleEditing) {
            [textField resignFirstResponder];
            [self updateUI];
            [self.directionHeaderView.endTextField becomeFirstResponder];
            return YES;
        }
    } else {
        if (!self.startPlace && self.allowCircleEditing) {
            [textField resignFirstResponder];
            [self updateUI];
            [self.directionHeaderView.startTextField becomeFirstResponder];
            return YES;
        }
        NSLog(@"end field hit return");
    }
    
    if ([self.directionManager readToDirect]) {
        [self routeButtonTapped];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES; //end editing
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextField = textField;
    if (textField == self.directionHeaderView.startTextField) {
        NSLog(@"start field begin editing");
    } else {
        NSLog(@"end field begin editing");
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.directionHeaderView.startTextField) {
        NSLog(@"start field end editing");
        if (!self.directionManager.sourcePlace) {
            if ([self.searchResult count] > 0) {
                self.directionManager.sourcePlace = self.searchResult.firstObject;
                [self updateUI];
            }
        }
        if (!self.directionManager.destnationPlace && self.allowCircleEditing) {
            [self.directionHeaderView.endTextField becomeFirstResponder];
            return;
        }
    } else {
        NSLog(@"end field end editing");
        if (!self.directionManager.destnationPlace && self.allowCircleEditing) {
            if ([self.searchResult count] > 0) {
                self.directionManager.destnationPlace = self.searchResult.firstObject;
                [self updateUI];
            }
        }
        if (!self.directionManager.sourcePlace && self.allowCircleEditing) {
            [self.directionHeaderView.startTextField becomeFirstResponder];
            return;
        }
    }
    [self updateUI];
}

- (void)textChanged:(NSNotification *)notif
{
    UITextField *editTextField = (UITextField *)notif.object;
    if (editTextField.markedTextRange == nil) {
        [self updateSearchResultForKeyword:editTextField.text];
        [self.tableView reloadData];
    } else {
        /* if the input method has not commit the input characters, 
         the markedTextRange should be nil. Just ignore this case. */
        return;
    }
}

- (void)performSpringAnimation
{
    CGFloat targetY = self.fullMode ? self.bigModeY : self.smallModeY;
    CGFloat delta = fabsf(self.view.frame.origin.y - targetY);
    CGFloat factor = delta / self.view.frame.size.height;
    CGFloat duration = 0.8f * factor;
    CGFloat velocity = 0.5f * factor;
    
    [UIView animateWithDuration:duration
                          delay:0.0f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:velocity
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = targetY;
                         self.view.frame = frame;
                     }
                     completion:^(BOOL finised) {
                         if (self.fullMode) {
                             [self.delegate directionVCdidEnterBigMode:self];
                        } else {
                             [self.delegate directionVCdidEnterSmallMode:self];
                         }
                     }];
}

- (void)changeToSmallMode
{
    self.fullMode = NO;
    [self.currentTextField resignFirstResponder];
    [self performSpringAnimation];
    NSLog(@"to small");
    
}

- (void)changeToBigMode
{
    if (self.editMode) {
        if (!self.fullMode) {
            self.fullMode = YES;
            [self performSpringAnimation];
            NSLog(@"to big");
        }
    }
}

@end
