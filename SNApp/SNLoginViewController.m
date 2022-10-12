//
//  SNLoginViewController.m
//  SNApp
//
//  Created by Force Close on 8/9/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNLoginViewController.h"
#import "Preferences.h"
#import "UIColor+SNColors.h"
#import "SNResponseServerResourceManager.h"
#import "SNConstans.h"
#import "SNLoginController.h"
#import "SNVerifyPhoneViewController.h"

@interface SNLoginViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UILabel *instruccionLabel;

@property (strong, nonatomic) UIView *underlineView;

@property (strong, nonatomic)NSString *numberPhone;
@property (strong, nonatomic)NSString *activationCode;
@property (strong, nonatomic)NSString *accountExist;

@property (strong,nonatomic)UIActivityIndicatorView* activityIndicatorView;
@property (getter=isRequesting) BOOL requesting;

@end

@implementation SNLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Undeline view
    self.underlineView = [[UIView alloc] initWithFrame:CGRectMake(15, self.numberTextField.frame.size.height - 2, self.view.frame.size.width - 30, 2)];
    self.underlineView.backgroundColor = [UIColor gray500Color];
    [self.numberTextField addSubview:self.underlineView];
    
    //Number phone
    if (![[Preferences NavigationLoginNumberPhone] isEqualToString:@""]) {
        self.numberTextField.text = [Preferences NavigationLoginNumberPhone];
        self.underlineView.backgroundColor = [UIColor appMainColor];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //If an user has verified therefore move to personal data controller
    switch ([Preferences NavigationLoginPage]) {
        case SNNavigationLoginPagePersonalData:
            [self performSegueWithIdentifier:@"ToVerifySI" sender:self];
            break;
        default:
            break;
    }
    
    //Keyboard
    [self registerForKeyboardNotifications];

    //Give focus
    [self.numberTextField becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    if (self.numberTextField.isFirstResponder) {
        [self.numberTextField resignFirstResponder];
    }
    
    //Keyboard
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    
    //Hide keyboard
    [self.numberTextField resignFirstResponder];
    
    //Validate number phone
    if (![self validateNumber]) {
        [self.numberTextField becomeFirstResponder];
        return;
    }
    
    //Ask a verification of number
    NSString* numberPhoneWithFormat = [NSString stringWithFormat:@"+51 %@",self.numberPhone];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"login.number.alert.confirmation-title", nil) message:[NSString stringWithFormat:NSLocalizedString(@"login.number.alert.confirmation-message.%@\n Is the number above correct?", @"{phone number entered}\n Is the number above correct?"),numberPhoneWithFormat] preferredStyle:UIAlertControllerStyleAlert];
    SNLoginViewController* __weak weakSelf= self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //Save number phone
        [weakSelf setNavigationLoginNumber];
        
        //Request for activation code
        [weakSelf getActivationCode];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf.numberTextField becomeFirstResponder];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)cancel:(id)sender{
    //Hide keyboard
    [self.numberTextField resignFirstResponder];

    //Cancel request
    [[SNResponseServerResourceManager sharedManager] cancelAuthenticationPhone];
    
    //Dismiss
    [[SNLoginController sharedController] dismissLogin];
}

- (IBAction)editingChange:(id)sender {
    //Dismiss anything error if there is.
    [self dismissError];
    
    if (self.numberTextField.text.length==0) {
        self.underlineView.backgroundColor = [UIColor gray500Color];
    }else{
        self.underlineView.backgroundColor = [UIColor appMainColor];
    }
}

-(void)getActivationCode{
    //Start animation
    [self startActivityIndicatorAnimation];
    
    SNLoginViewController* __weak weakSelf= self;
    //Start request
    [[SNResponseServerResourceManager sharedManager] authenticatePhone:self.numberPhone success:^(ResponseServer *response) {
        //Stop animation
        [weakSelf stopActivityIndicatorAnimation];
        
        //Get activation code
        weakSelf.activationCode = response.validationKey;
        NSLog(@"\n\nACTIVATION CODE:%@\n\n",self.activationCode);
        
        //Get whether the account exist
        weakSelf.accountExist = response.response;
        
        //Move to validation code
        [weakSelf performSegueWithIdentifier:@"ToVerifySI" sender:self];
        
    } failure:^(NSError *error) {
        //Stop animation
        [weakSelf stopActivityIndicatorAnimation];
        
        //Cancel request
        [weakSelf cancelAuthenticationPhone];
        
        NSString* title ;
        NSString* message ;
        UIAlertAction *okAction ;
        
        if ([error.domain isEqualToString:SNSERVICES_ERROR_DOMAIN]) {
            switch (error.code) {
                case SNNoInternet:
                    title = NSLocalizedString(@"app.error.no-internet-connection", nil);
                    message = NSLocalizedString(@"login.number.alert.no internet message", nil);
                    okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
                    break;
                case SNNoServer:
                    title = NSLocalizedString(@"app.error.no-server-connection", nil);
                    message = NSLocalizedString(@"login.number.alert.no server message", nil);
                    okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                    }];
                    break;
            }
        }
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:okAction];
        
        [weakSelf presentViewController:alert animated:YES completion:nil];
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SNVerifyPhoneViewController* controller = [segue destinationViewController];
    controller.accountExist = self.accountExist;
    controller.phoneNumber = self.numberPhone;
    controller.activationCode = self.activationCode;
}


#pragma mark - Custom accessors

-(UIActivityIndicatorView *)activityIndicatorView{
    if (!_activityIndicatorView) {
        UIActivityIndicatorView* view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        view.frame = CGRectMake(self.view.bounds.size.width/2.f - 16.5f, self.numberTextField.frame.origin.y, 33, 33);
        view.hidesWhenStopped = YES;
        [self.scrollView addSubview:view];
        _activityIndicatorView = view;
    }
    return _activityIndicatorView;
}

#pragma mark - Helpers

-(void)setupView{
    //Right bar button
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"app.general.done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    rightItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //Left bar button
    UIBarButtonItem* leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrowIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    leftItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //Back button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title =@"";
    self.navigationItem.backBarButtonItem = backButton;
    
    //Texts
    self.instruccionLabel.text = NSLocalizedString(@"login.number.instruccion.ask for number", nil);
    self.numberTextField.text =@"";
    self.numberTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"login.number.textfield-number.placeholder.Your number", nil) attributes:@{NSForegroundColorAttributeName: [UIColor gray500Color]}];
    
    //Error image
    self.numberTextField.leftViewMode = UITextFieldViewModeNever;
    self.numberTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"errorIcon"]];
    
    //Scroll view
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    //Navigation bar
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setOpaque:NO];
    [self.navigationController.navigationBar setTranslucent:YES];
    
}

-(BOOL)validateNumber{
    if (self.numberTextField.text.length == 9) {
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^9[0-9]{8}" options:NSRegularExpressionCaseInsensitive error:nil];
       NSUInteger matches = [regex numberOfMatchesInString:self.numberTextField.text options:0 range:NSMakeRange(0, 9)];
        if (matches == 1) {
            self.numberPhone = self.numberTextField.text;
            return true;
        }else{
            self.numberPhone = @"";
            [self showError];
            return false;
        }
    }else{
        self.numberPhone = @"";
        [self showError];
        return false;
    }
}

-(void)showError{
    self.numberTextField.leftViewMode = UITextFieldViewModeAlways;
}

-(void)dismissError{
    self.numberTextField.leftViewMode = UITextFieldViewModeNever;
}

-(void)startActivityIndicatorAnimation{
    [self.activityIndicatorView startAnimating];
    self.numberTextField.hidden = YES;
    self.requesting = YES;
}

-(void)stopActivityIndicatorAnimation{
    [self.activityIndicatorView stopAnimating];
    self.numberTextField.hidden = NO;
    self.requesting = NO;
}
-(void)setNavigationLoginNumber{
    [Preferences setNavigationLoginNumberPhone:self.numberPhone];
}
-(void)cancelAuthenticationPhone{
    [[SNResponseServerResourceManager sharedManager] cancelAuthenticationPhone];
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
    
    UITextField* activeField;
    if (self.numberTextField.isFirstResponder) {
        activeField = self.numberTextField;
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
