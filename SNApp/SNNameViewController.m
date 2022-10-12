//
//  SNNameViewController.m
//  SNApp
//
//  Created by Force Close on 8/10/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNNameViewController.h"
#import "Preferences.h"
#import "UIColor+SNColors.h"
#import "SNAccountResourceManager.h"
#import "SNConstans.h"
#import "Account.h"
#import "SNLoginController.h"
#import "SNVerifyPhoneViewController.h"

@interface SNNameViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *instruccion1;
@property (weak, nonatomic) IBOutlet UILabel *instruccion2;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) UIView *nameUnderlineView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) UIView *usernameUnderlineView;

@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;

@property (getter=isRequesting) BOOL requesting;

@property(getter=isUsernameEditable) BOOL usernameEditable;

@end

@implementation SNNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveData:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.usernameEditable = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Underline views
    self.nameUnderlineView = [[UIView alloc] initWithFrame:CGRectMake(15, self.nameTextField.bounds.size.height -2 , self.view.bounds.size.width - 30 , 2)];
    self.nameUnderlineView.backgroundColor = [UIColor gray500Color];
    [self.nameTextField addSubview:self.nameUnderlineView];
    
    self.usernameUnderlineView = [[UIView alloc] initWithFrame:CGRectMake(15, self.usernameTextField.bounds.size.height -2 , self.view.bounds.size.width - 30 , 2)];
    self.usernameUnderlineView.backgroundColor = [UIColor gray500Color];
    [self.usernameTextField addSubview:self.usernameUnderlineView];

    //Data
    [self restoreData];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Keyboard
    [self registerForKeyboardNotifications];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    //Keyboard and app background
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.nameTextField.isFirstResponder) {
        [self.nameTextField resignFirstResponder];
    }else if(self.usernameTextField.isFirstResponder) {
        [self.usernameTextField resignFirstResponder];
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
    
    if (![self validateTextField]) {
        return;
    }
    if (self.nameTextField.isFirstResponder) {
        [self.nameTextField resignFirstResponder];
    }
    if (self.usernameTextField.isFirstResponder) {
        [self.usernameTextField resignFirstResponder];
    }
    
    [self submitUserData];
}

-(void)submitUserData{
    [self startActivityIndicatorAnimation];
    SNNameViewController* __weak weakSelf= self;
    
    //Cancel any previous request
    [[SNAccountResourceManager sharedManager] cancelValidateUsername];
    
    //Make request
    [[SNAccountResourceManager sharedManager] validateUsername:self.usernameTextField.text success:^(ResponseServer *response) {
        if ([response.response isEqualToString:@"0"]) {
            [[SNAccountResourceManager sharedManager] loginWithName:self.nameTextField.text username:self.usernameTextField.text cloudId:[Preferences UserCloudId] phoneNumber:self.numberPhone idAccount:[Account accountId] success:^(Account *account) {
                
                if ([account.idAccount isEqualToNumber:@(-1)]) {
                    [weakSelf showErrorOnTextField:weakSelf.usernameTextField];
                    [weakSelf.usernameTextField becomeFirstResponder];
                }else{
                    //Account data
                    [weakSelf setAccountData:account];
                    
                    account.name = weakSelf.nameTextField.text;
                    
                    NSLog(@"\n\n ACCOUNT STATE:%@",account.state);
                    [weakSelf verifyAccount];
                    
                    [weakSelf performSegueWithIdentifier:@"ToGrettingsSI" sender:self];
                }
                [weakSelf stopActivityIndicatorAnimation];
            } failure:^(NSError *error) {
                [weakSelf failureWithError:error];
            }];
        }else{
            [weakSelf showErrorOnTextField:weakSelf.usernameTextField];
            [weakSelf.usernameTextField becomeFirstResponder];
            [weakSelf stopActivityIndicatorAnimation];
        }
    } failure:^(NSError *error) {
        [weakSelf failureWithError:error];
    }];
}

-(void)failureWithError:(NSError*)error{
    [self saveData:nil];
    [self stopActivityIndicatorAnimation];
    
    if ([error.domain isEqual:SNSERVICES_ERROR_DOMAIN]) {
        UIAlertController *alert;
        UIAlertAction *alertActionCancel;
        [self cancelLogin];
        switch (error.code) {
            case SNNoServer:{
                alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app.error.no-server-connection", nil) message:NSLocalizedString(@"login.name.alert.no server message", nil)  preferredStyle:UIAlertControllerStyleAlert];
                alertActionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self dismissLogin];
                }];
                [alert addAction:alertActionCancel];
                [self presentViewController:alert animated:YES completion:nil];
                break;
            }
            case SNNoInternet:{
                alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app.error.no-internet-connection", nil) message:NSLocalizedString(@"login.name.alert.no internet message", nil)  preferredStyle:UIAlertControllerStyleAlert];
                alertActionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self dismissLogin];
                }];
                [alert addAction:alertActionCancel];
                [self presentViewController:alert animated:YES completion:nil];
                break;
            }
        }
    }
}

- (IBAction)nameEditingChanged:(UITextField *)sender {
    if (sender.text.length==0) {
        self.nameUnderlineView.backgroundColor = [UIColor gray500Color];
    }else{
        self.nameUnderlineView.backgroundColor = [UIColor appMainColor];
        [self dismissErrorOnTextField:self.nameTextField];
    }
    
    if (self.isUsernameEditable) {
        NSString* text = [self processUsername:sender.text];
        if (text.length == 0) {
            self.usernameUnderlineView.backgroundColor = [UIColor gray500Color];
        }else{
            [self dismissErrorOnTextField:self.usernameTextField];
            self.usernameUnderlineView.backgroundColor = [UIColor appMainColor];
        }
        [self setUsernameTEXT:text];
    }
}

- (IBAction)usernameEditingChanged:(UITextField *)sender {
    if (sender.text.length==0) {
        self.nameUnderlineView.backgroundColor = [UIColor gray500Color];
    }else{
        self.nameUnderlineView.backgroundColor = [UIColor appMainColor];
        [self validateUsername:sender.text];
    }
}

-(void)saveData:(NSNotification*)notification{
    [Preferences setNavigationLoginName:self.nameTextField.text];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    UIViewController* controlller = [segue destinationViewController];
    controlller.hidesBottomBarWhenPushed = YES;
}


#pragma mark - Text field delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
            [textField resignFirstResponder];
            [self.usernameTextField becomeFirstResponder];
            break;
        case 1:
            [textField resignFirstResponder];
            [self.nameTextField becomeFirstResponder];
            break;
    }
    return NO;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    switch (textField.tag) {
        case 0:
            
            break;
        case 1:{
            self.usernameEditable = NO;
            if ([string isEqualToString:@""]) {
                NSString* newText = [self processUsername:[self.usernameTextField.text substringToIndex:self.usernameTextField.text.length-1]];
                [self setUsernameTEXT:newText];
                if (self.usernameTextField.text.length == 0) {
                    self.usernameUnderlineView.backgroundColor = [UIColor gray500Color];
                }else{
                    [self dismissErrorOnTextField:self.usernameTextField];
                    self.usernameUnderlineView.backgroundColor = [UIColor appMainColor];
                }
            }
            NSString* newText = [self processUsername:string];
            [self setUsernameTEXT:[NSString stringWithFormat:@"%@%@",self.usernameTextField.text,newText]];
            if (self.usernameTextField.text.length == 0) {
                self.usernameUnderlineView.backgroundColor = [UIColor gray500Color];
            }else{
                [self dismissErrorOnTextField:self.usernameTextField];
                self.usernameUnderlineView.backgroundColor = [UIColor appMainColor];
            }
            return NO;
        }
    }
    return YES;
}

#pragma mark - Custom accessors

-(UIActivityIndicatorView *)activityIndicator{
    if (!_activityIndicator) {
        UIActivityIndicatorView* view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        view.frame = CGRectMake(self.view.bounds.size.width/2.f - 16.5f, self.instruccion1.frame.origin.y, 33, 33);
        view.hidesWhenStopped = YES;
        [self.scrollView addSubview:view];
        _activityIndicator = view;
    }
    return _activityIndicator;
}

#pragma mark - Helpers

-(void)setupView{
    //Navigation bar
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    //Right bar button
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"app.general.done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    rightItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //Texts
    self.instruccion1.text = NSLocalizedString(@"login.name.instruction.ask for name", nil);
    self.instruccion2.text = NSLocalizedString(@"login.name.instuccion.ask for username", nil);
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"login.name.textfield-name.placeholder.Your name", nil) attributes:@{NSForegroundColorAttributeName: [UIColor gray500Color]}];
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"login.name.textfield-username.placeholder.Your username", nil) attributes:@{NSForegroundColorAttributeName : [UIColor gray500Color]}];

    //Text fields
    self.nameTextField.tag =0;
    self.nameTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"errorIcon"]];
    self.nameTextField.leftViewMode = UITextFieldViewModeNever;
    self.usernameTextField.tag =1;
    self.usernameTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"errorIcon"]];
    self.usernameTextField.leftViewMode = UITextFieldViewModeNever;
    
    //Scroll view
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    
}

-(void)restoreData{
    switch ([Preferences NavigationLoginPage]) {
        case SNNavigationLoginPagePersonalData:
            self.numberPhone = [Preferences NavigationLoginNumberPhone];
            self.nameTextField.text = [Preferences NavigationLoginName];
            [self setUsernameTEXT:[self processUsername:[Preferences NavigationLoginName]]];
            break;
        default:
            self.nameTextField.text = [[UIDevice currentDevice] name];
            [self setUsernameTEXT:[self processUsername:[[UIDevice currentDevice] name]]];
            break;
    }
    if (self.nameTextField.text.length == 0) {
        self.nameUnderlineView.backgroundColor = [UIColor gray500Color];
    }else{
        self.nameUnderlineView.backgroundColor = [UIColor appMainColor];
    }
    if (self.usernameTextField.text.length == 0) {
        self.usernameUnderlineView.backgroundColor = [UIColor gray500Color];
    }else{
        self.usernameUnderlineView.backgroundColor = [UIColor appMainColor];
    }
}

-(NSString*)processUsername:(NSString*)text{
    NSString* username= [text lowercaseString];
    NSRange permitedRange;
    NSMutableCharacterSet* characterSet = [[NSMutableCharacterSet alloc] init];
    permitedRange.location = (unsigned int)'a';
    permitedRange.length = 26;
    [characterSet addCharactersInRange:permitedRange];
    
    permitedRange.location = (unsigned int)'0';
    permitedRange.length = 10;
    [characterSet addCharactersInRange:permitedRange];
    
    permitedRange.location = 8;
    permitedRange.length =1;
    [characterSet addCharactersInRange:permitedRange];
    
    [characterSet addCharactersInString:@"_"];
    
    NSCharacterSet* characterSetF = [characterSet invertedSet];
    
    NSArray* array = [username componentsSeparatedByCharactersInSet:characterSetF];
    NSMutableString* newUsername = [NSMutableString string];
    for (NSString* string in array) {
        [newUsername appendString:string];
    }
    if (newUsername.length>20) {
        return [newUsername substringToIndex:20];
    }else{
        return newUsername;
    }
}

-(BOOL)validateTextField{
    BOOL returnValue =  YES;
    if (self.nameTextField.text.length == 0) {
        [self showErrorOnTextField:self.nameTextField];
        [self.nameTextField becomeFirstResponder];
        returnValue = NO;
    }
    if (self.usernameTextField.text.length == 0) {
        [self showErrorOnTextField:self.usernameTextField];
        [self.usernameTextField becomeFirstResponder];
        returnValue = NO;
    }
    return  returnValue;
}

-(void)showErrorOnTextField:(UITextField*)textField{
    textField.leftViewMode = UITextFieldViewModeAlways;
}

-(void)dismissErrorOnTextField:(UITextField*)textField{
    textField.leftViewMode = UITextFieldViewModeNever;
}

-(void)startActivityIndicatorAnimation{
    [self.activityIndicator startAnimating];
    self.instruccion1.hidden = YES;
    self.instruccion2.hidden = YES;
    self.nameTextField.hidden = YES;
    self.usernameTextField.hidden = YES;
    self.requesting = YES;
}

-(void)stopActivityIndicatorAnimation{
    [self.activityIndicator stopAnimating];
    self.instruccion1.hidden = NO;
    self.instruccion2.hidden = NO;
    self.nameTextField.hidden = NO;
    self.usernameTextField.hidden = NO;
    self.requesting = NO;
}

-(void)setAccountData:(Account*)account{
    [Preferences setUserIsLogin:@YES];
    [Preferences setUserIsGuest:@NO];
    if (![account.idAccount isEqualToNumber:@(-2)]) {
        [Account setAccountId:account.idAccount];
    }
    [Account setUsername:account.username];
    [Account setState:account.state];
}

-(void)verifyAccount{
    [[SNLoginController sharedController] verifyAccount];
}

-(void)cancelLogin{
    [[SNAccountResourceManager sharedManager] cancelLogin];
}

-(void)dismissLogin{
    [[SNLoginController sharedController] dismissLogin];
}

-(void)validateUsername:(NSString*)username{
    //Cancel any previous request
//    [[SNAccountResourceManager sharedManager] cancelValidateUsername];
    
    NSLog(@"%@",username);
    
    //Make request
    SNNameViewController* __weak weakSelf = self;
    [[SNAccountResourceManager sharedManager] validateUsername:username success:^(ResponseServer *response) {
        NSLog(@"%@ : %@",username , response.response);
        if ([response.response isEqualToString:@"1"]) {
            [self showErrorOnTextField:self.usernameTextField];
        }
    } failure:^(NSError *error) {
        if ([error.domain isEqual:SNSERVICES_ERROR_DOMAIN]) {
            UIAlertController *alert;
            UIAlertAction *alertActionCancel;
            [weakSelf cancelLogin];
            switch (error.code) {
                case SNNoServer:{
                    alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app.error.no-server-connection", nil) message:NSLocalizedString(@"login.name.alert.no server message", nil)  preferredStyle:UIAlertControllerStyleAlert];
                    alertActionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [weakSelf dismissLogin];
                    }];
                    [alert addAction:alertActionCancel];
                    [weakSelf presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case SNNoInternet:{
                    alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app.error.no-internet-connection", nil) message:NSLocalizedString(@"login.name.alert.no internet message", nil)  preferredStyle:UIAlertControllerStyleAlert];
                    alertActionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
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

-(void)setUsernameTEXT:(NSString*)string{
    [self.usernameTextField setText:string];
    [self validateUsername:string];
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
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    
    UITextField* activeField;
    if (self.nameTextField.isFirstResponder) {
        activeField = self.nameTextField;
    }
    
    if (self.usernameTextField.isFirstResponder) {
        activeField = self.usernameTextField;
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
