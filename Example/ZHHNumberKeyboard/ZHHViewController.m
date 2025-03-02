//
//  ZHHViewController.m
//  ZHHNumberKeyboard
//
//  Created by 桃色三岁 on 03/02/2025.
//  Copyright (c) 2025 桃色三岁. All rights reserved.
//

#import "ZHHViewController.h"
#import "ZHHNumberKeyboard.h"

@interface ZHHViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) ZHHNumberKeyboard *numberKeyboard;

@end

@implementation ZHHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textField.frame = CGRectMake(100, 100, 200, 40);
    ZHHNumberKeyboard *numberKeyboard = [[ZHHNumberKeyboard alloc] init];
    numberKeyboard.keyboardType = ZHHNumberKeyboardTypeIDCard;
    self.textField.delegate = self;
    self.textField.inputView = numberKeyboard;
    [self.textField reloadInputViews];
    self.numberKeyboard = numberKeyboard;
    [self.numberKeyboard keyboardInputDidChange:@""];
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}


/// 设置自定义键盘后，delegate 不会被调用？
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"=== %@", [textField.text stringByReplacingCharactersInRange:range withString:string]);

    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self.numberKeyboard keyboardInputDidChange:textField.text];
}


- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = UIColor.whiteColor;
        _textField.backgroundColor = UIColor.orangeColor;
        _textField.layer.cornerRadius = 10;
        [self.view addSubview:_textField];
    }
    return _textField;
}

@end

