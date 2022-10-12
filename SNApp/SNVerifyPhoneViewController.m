//
//  SNVerifyPhoneViewController.m
//  SNApp
//
//  Created by Force Close on 8/9/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNVerifyPhoneViewController.h"
#import "Preferences.h"
#import "SNAccountResourceManager.h"
#import "SNLoginController.h"
#import "SNConstans.h"
#import "UIColor+SNColors.h"

@implementation SNTextField

@dynamic delegate;

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(paste:)) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

-(void)deleteBackward{
    [super deleteBackward];
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDeleteBackward:)]) {
        [self.delegate textFieldDeleteBackward:self];
    }
}

@end

@interface SNVerifyPhoneViewController ()<SNTextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet SNTextField *firstNumber;
@property (strong, nonatomic) UIView *firstUnderlineView;
@property (weak, nonatomic) IBOutlet SNTextField *secondNumber;
@property (strong, nonatomic) UIView *secondUnderlineView;
@property (weak, nonatomic) IBOutlet SNTextField *thirdNumber;
@property (strong, nonatomic) UIView *thirdUnderlineView;
@property (weak, nonatomic) IBOutlet SNTextField *fourthNumber;
@property (strong, nonatomic) UIView *fourthUnderlineView;

@property (weak, nonatomic) IBOutlet UIView *numberContainer;

@property (weak, nonatomic) IBOutlet UILabel *instruccionLabel;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (getter=isRequesting) BOOL requesting;

@end

@implementation SNVerifyPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Underline views
    self.firstUnderlineView = [[UIView alloc] initWithFrame:CGRectMake(7, 40, 36, 2)];
    self.firstUnderlineView.backgroundColor = [UIColor gray500Color];
    [self.firstNumber addSubview:self.firstUnderlineView];
    
    self.secondUnderlineView = [[UIView alloc] initWithFrame:CGRectMake(7, 40, 36, 2)];
    self.secondUnderlineView.backgroundColor = [UIColor gray500Color];
    [self.secondNumber addSubview:self.secondUnderlineView];
    
    self.thirdUnderlineView = [[UIView alloc] initWithFrame:CGRectMake(7, 40, 36, 2)];
    self.thirdUnderlineView.backgroundColor = [UIColor gray500Color];
    [self.thirdNumber addSubview:self.thirdUnderlineView];
    
    self.fourthUnderlineView = [[UIView alloc] initWithFrame:CGRectMake(7, 40, 36, 2)];
    self.fourthUnderlineView.backgroundColor = [UIColor gray500Color];
    [self.fourthNumber addSubview:self.fourthUnderlineView];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //If an user has verified therefore move to personal data controller
    switch ([Preferences NavigationLoginPage]) {
        case SNNavigationLoginPagePersonalData:
            [self performSegueWithIdentifier:@"ToNameSI" sender:self];
            break;
        default:
            break;
    }
    //Keyboard
    [self registerForKeyboardNotifications];
    
    //Give focus
    [self.firstNumber becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    //Cancel request
    [[SNAccountResourceManager sharedManager] cancelLogin];
    
    //Keyboard
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Stop
    [self stopActivityIndicatorAnimation];
    
    if (self.firstNumber.isFirstResponder) {
        [self.firstNumber resignFirstResponder];
    }else if (self.secondNumber.isFirstResponder) {
        [self.secondNumber resignFirstResponder];
    }else if (self.thirdNumber.isFirstResponder) {
        [self.thirdNumber resignFirstResponder];
    }else{
        [self.fourthNumber resignFirstResponder];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

-(IBAction)done:(id)sender{
    if (self.isRequesting) {
        return;
    }
    NSString* code = [NSString stringWithFormat:@"%@%@%@%@",self.firstNumber.text,self.secondNumber.text,self.thirdNumber.text,self.fourthNumber.text];
    if ([code isEqualToString:self.activationCode]) {
        [self verificateCode];
    }
}

- (IBAction)firstEditingChanged:(UITextField *)sender {
    if (sender.text.length == 1) {
        self.firstUnderlineView.backgroundColor = [UIColor appMainColor];
        sender.layer.borderColor = [[UIColor whiteColor] CGColor];
        [sender resignFirstResponder];
        sender.userInteractionEnabled = NO;
        self.secondNumber.userInteractionEnabled = YES;
        [self.secondNumber becomeFirstResponder];
    }else if(sender.text.length ==0 ){
        sender.layer.borderColor = [[UIColor gray500Color] CGColor];
        self.firstUnderlineView.backgroundColor = [UIColor gray500Color];
    }
}

- (IBAction)secondEditingChanged:(UITextField *)sender {
    if (sender.text.length == 1) {
        self.secondUnderlineView.backgroundColor = [UIColor appMainColor];
        sender.layer.borderColor = [[UIColor whiteColor] CGColor];
        [sender resignFirstResponder];
        sender.userInteractionEnabled = NO;
        self.thirdNumber.userInteractionEnabled = YES;
        [self.thirdNumber becomeFirstResponder];
    }else if(sender.text.length ==0 ){
        self.secondUnderlineView.backgroundColor = [UIColor gray500Color];
        sender.layer.borderColor = [[UIColor gray500Color] CGColor];
    }
}

- (IBAction)thirdEditingChanged:(UITextField *)sender {
    if (sender.text.length == 1) {
        self.thirdUnderlineView.backgroundColor = [UIColor appMainColor];
        sender.layer.borderColor = [[UIColor whiteColor] CGColor];
        [sender resignFirstResponder];
        sender.userInteractionEnabled = NO;
        self.fourthNumber.userInteractionEnabled = YES;
        [self.fourthNumber becomeFirstResponder];
    }else if(sender.text.length ==0 ){
        self.thirdUnderlineView.backgroundColor = [UIColor gray500Color];
        sender.layer.borderColor = [[UIColor gray500Color] CGColor];
    }
}

- (IBAction)fourthEditingChanged:(UITextField *)sender {
    if (sender.text.length == 1) {
        self.fourthUnderlineView.backgroundColor = [UIColor appMainColor];
        sender.layer.borderColor = [[UIColor whiteColor] CGColor];
        [sender resignFirstResponder];
        [self verificateCode];
    }else if(sender.text.length ==0 ){
        sender.layer.borderColor = [[UIColor gray500Color] CGColor];
        self.fourthUnderlineView.backgroundColor = [UIColor gray500Color];
    }else{
        sender.text = [sender.text substringToIndex:1];
    }
}

-(void)verificateCode{
    [self.fourthNumber resignFirstResponder];
    self.fourthNumber.userInteractionEnabled = NO;
    
    NSString* code = [NSString stringWithFormat:@"%@%@%@%@",self.firstNumber.text,self.secondNumber.text,self.thirdNumber.text,self.fourthNumber.text];
    if ([code isEqualToString:self.activationCode]) {
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        if ([[numberFormatter numberFromString:self.accountExist] integerValue]==0) {
            [Preferences setNavigationLoginPage:SNNavigationLoginPagePersonalData];
            [Preferences setNavigationLoginNumberPhone:self.phoneNumber];
            [self performSegueWithIdentifier:@"ToNameSI" sender:self];
        }else if([[numberFormatter numberFromString:self.accountExist] integerValue]==1){
            [self getUserExistData];
        }
    }else{
        self.fourthNumber.userInteractionEnabled = YES;
        [self.fourthNumber becomeFirstResponder];
    }
}
-(void)getUserExistData{
    [self startActivityIndicatorAnimation];
    SNVerifyPhoneViewController* __weak weakSelf= self;
    [[SNAccountResourceManager sharedManager] loginWithPhone:self.phoneNumber cloudId:[Account cloudId] idAccount:[Account accountId] success:^(Account *account) {
        NSLog(@"%@",account);
        [weakSelf stopActivityIndicatorAnimation];
        [weakSelf setAccountState:account];
        [weakSelf dismissLogin];
    } failure:^(NSError *error) {
        [weakSelf stopActivityIndicatorAnimation];
        if ([error.domain isEqual:SNSERVICES_ERROR_DOMAIN]) {
            UIAlertController *alert;
            UIAlertAction *alertActionCancel;
            [weakSelf cancelLogin];
            switch (error.code) {
                case SNNoServer:{
                    alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app.error.no-server-connection", nil) message:NSLocalizedString(@"login.verification.alert.no server message", nil)  preferredStyle:UIAlertControllerStyleAlert];
                    alertActionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [weakSelf dismissLogin];
                    }];
                    [alert addAction:alertActionCancel];
                    [weakSelf presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case SNNoInternet:{
                    alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app.error.no-internet-connection", nil) message:NSLocalizedString(@"login.verification.alert.no internet message", nil)  preferredStyle:UIAlertControllerStyleAlert];
                    alertActionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [weakSelf dismissLogin];
                    }];
                    [alert addAction:alertActionCancel];
                    [weakSelf presentViewController:alert animated:YES completion:nil];
                    break;
                }
            }
        }
    }];
}

#pragma mark - Text field delegate

-(void)textFieldDeleteBackward:(UITextField *)textField{
    if (textField.text.length==0) {
        [textField resignFirstResponder];
        textField.userInteractionEnabled = NO;
        switch (textField.tag) {
            case 1:
                self.firstNumber.userInteractionEnabled = YES;
                self.firstNumber.text = @"";
                self.firstNumber.layer.borderColor = [[UIColor gray500Color] CGColor];
                self.firstUnderlineView.backgroundColor = [UIColor gray500Color];
                [self.firstNumber becomeFirstResponder];
                break;
            case 2:
                self.secondNumber.userInteractionEnabled = YES;
                self.secondNumber.text = @"";
                self.secondNumber.layer.borderColor = [[UIColor gray500Color] CGColor];
                self.secondUnderlineView.backgroundColor = [UIColor gray500Color];
                [self.secondNumber becomeFirstResponder];
                break;
            case 3:
                self.thirdNumber.userInteractionEnabled = YES;
                self.thirdNumber.text = @"";
                self.thirdNumber.layer.borderColor = [[UIColor gray500Color] CGColor];
                self.thirdUnderlineView.backgroundColor = [UIColor gray500Color];
                self.fourthUnderlineView.backgroundColor = [UIColor gray500Color];
                [self.thirdNumber becomeFirstResponder];
                break;
        }
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    UIViewController* controller = [segue destinationViewController];
    controller.hidesBottomBarWhenPushed = YES;
}

#pragma mark - Custom accessors

-(UIActivityIndicatorView *)activityIndicator{
    if (!_activityIndicator) {
        UIActivityIndicatorView* view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        view.frame = CGRectMake(self.view.bounds.size.width/2.f - 16.5f, self.numberContainer.frame.origin.y, 33, 33);
        view.hidesWhenStopped = YES;
        [self.scrollView addSubview:view];
        _activityIndicator = view;
    }
    return _activityIndicator;
}

#pragma mark - Helpers

-(void)setupView{
    //Scroll view
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    //Numbers
    self.firstNumber.layer.cornerRadius = 5;
    self.firstNumber.layer.borderColor = [[UIColor gray500Color] CGColor];
    self.firstNumber.layer.borderWidth = 4.f;
    self.firstNumber.tag = 0;
    self.secondNumber.layer.cornerRadius = 5;
    self.secondNumber.layer.borderColor = [[UIColor gray500Color] CGColor];
    self.secondNumber.layer.borderWidth = 4.f;
    self.secondNumber.tag = 1;
    self.secondNumber.userInteractionEnabled = NO;
    self.secondNumber.delegate = self;
    self.thirdNumber.layer.cornerRadius = 5;
    self.thirdNumber.layer.borderColor = [[UIColor gray500Color] CGColor];
    self.thirdNumber.layer.borderWidth = 4.f;
    self.thirdNumber.tag = 2;
    self.thirdNumber.userInteractionEnabled = NO;
    self.thirdNumber.delegate = self;
    self.fourthNumber.layer.cornerRadius = 5;
    self.fourthNumber.layer.borderColor = [[UIColor gray500Color] CGColor];
    self.fourthNumber.layer.borderWidth = 4.f;
    self.fourthNumber.tag = 3;
    self.fourthNumber.userInteractionEnabled = NO;
    self.fourthNumber.delegate = self;
    
    //Navigation bar
    self.navigationItem.title = [NSString stringWithFormat:@"+51 %@",self.phoneNumber];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //Right bar button
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"app.general.done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    rightItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //Texts
    self.instruccionLabel.text = NSLocalizedString(@"login.verification.instruction.ask for activation code", nil);
    
}

-(void)startActivityIndicatorAnimation{
    [self.activityIndicator startAnimating];
    self.numberContainer.hidden = YES;
    self.requesting = YES;
}

-(void)stopActivityIndicatorAnimation{
    [self.activityIndicator stopAnimating];
    self.numberContainer.hidden = NO;
    self.requesting = NO;
}

-(void)setAccountState:(Account*)account{
    [Preferences setUserIsLogin:@YES];
    [Preferences setUserIsGuest:@NO];
    
    if (![account.idAccount isEqualToNumber:@(-1)]) {
        [Account setAccountId:account.idAccount];
    }
    
    [Account setUsername:account.username];
    [Account setState:account.state];
}

-(void)dismissLogin{
    [[SNLoginController sharedController] dismissLogin];
}

-(void)cancelLogin{
    [[SNAccountResourceManager sharedManager] cancelLogin];
}
#pragma mark - Keyboard

-(void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)keyboardWillShown:(NSNotification*)aNotification{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGSize contentSize;
    contentSize.width =kbSize.width;
    contentSize.height = self.view.bounds.size.height - kbSize.height;
//    self.scrollView.contentSize = self.view.bounds.size;
    self.scrollView.contentSize = contentSize;
//    self.scrollView.contentSize = CGSizeZero;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;

    NSLog(@"h:%f w:%f",    self.scrollView.contentSize.height,    self.scrollView.contentSize.width);

    
    UITextField* activeField;
    if (self.firstNumber.isFirstResponder) {
        activeField = self.firstNumber;
    }else if (self.secondNumber.isFirstResponder) {
        activeField = self.secondNumber;
    }else if (self.thirdNumber.isFirstResponder) {
        activeField = self.thirdNumber;
    }else{
        activeField = self.fourthNumber;
    }
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.contentSize = CGSizeZero;
}

@end
