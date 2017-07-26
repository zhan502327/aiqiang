//
//  PersonalInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by zhandb on 2017/5/19.
//  Copyright © 2017年 zhandb. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "PersonalTableViewCell.h"
#import "PersonalInfoTool.h"
#import "UserInfoModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "ASBirthSelectSheet.h"
#import "AddressPickerView.h"

#define PickViewWidth (CGRectGetWidth(_contentView.frame)-40)/3

@interface PersonalInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AddressPickerViewDelegate>

@property (nonatomic, weak) TPKeyboardAvoidingTableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UserInfoModel *userModel;

@property (nonatomic, strong) UIImage *iconImage;

@property (nonatomic, weak) AddressPickerView * addressPickerView;
@end

@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadData];
    [self addAGesutreRecognizerForYourView];
    
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"个人信息";
    
}

- (void)loadData{
    NSDictionary *dic = @{@"uid":User_ID,@"get_uid":User_ID};
    
    [PersonalInfoTool userInfoWithSuccessBlockWithPram:dic successBlock:^(UserInfoModel *model) {
        self.userModel = model;
        
        [self.tableView reloadData];
    } errorBlock:^(NSError *error) {
        
    }];
}

- (void)addAGesutreRecognizerForYourView

{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.cancelsTouchesInView = NO;
    
    [self.tableView addGestureRecognizer:gestureRecognizer];
}


- (void)hideView:(UITapGestureRecognizer *)recognizer

{
    [self.view endEditing:YES];
    [self.addressPickerView hide];

}


- (AddressPickerView *)addressPickerView{
    if (!_addressPickerView) {
        AddressPickerView *view = [[AddressPickerView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT , SCREEN_WIDTH, 215)];
        
        view.delegate = self;
        // 关闭默认支持打开上次的结果
        view.backgroundColor = [UIColor redColor];

        view.isAutoOpenLast = YES;
        [self.view addSubview:view];
        _addressPickerView = view;
    }
    return _addressPickerView;
}

#pragma mark - AddressPickerViewDelegate
- (void)cancelBtnClick{
    NSLog(@"点击了取消按钮");
    [self.addressPickerView hide];

}
- (void)sureBtnClickReturnProvince:(NSString *)province City:(NSString *)city Area:(NSString *)area{
    
    self.userModel.address = [NSString stringWithFormat:@"%@%@%@",province,city,area];
    [self.tableView reloadData];
    [self.addressPickerView hide];
}



- (NSArray *)dataSource{
    if (_dataSource == nil) {
        NSArray *array = @[@[@"头像",@"昵称",@"性别",@"生日",@"爱抢号"],@[@"故乡",@"所在地"],@[@"我的二维码"]];
        _dataSource = array;
    }
    return _dataSource;
}

-(UITableView *)tableView{
    if (_tableView == nil) {
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc]init];
        tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
        tableView.backgroundColor = ColorTableViewBg;
        tableView.tableFooterView = [[UIView alloc] init];
        tableView.scrollEnabled=NO;
        tableView.dataSource=self;
        tableView.delegate=self;
        [self.view addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

#pragma mark - tableView delegate and tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 0;
    }
    return [self.dataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DBCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PersonalTableViewCell *cell = [PersonalTableViewCell normalTableViewCellWithTableView:tableView];
    cell.titleLabel.text = self.dataSource[indexPath.section][indexPath.row];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.type = @"UIImageView";
            cell.iconimageView.layer.masksToBounds = YES;
            cell.iconimageView.layer.cornerRadius = 15;
            if (self.iconImage) {
                cell.iconimageView.image = self.iconImage;
            }else{
                [cell.iconimageView  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",www,self.userModel.headimg]]];

            }
            return cell;
        }
        
        if (indexPath.row == 1) {
            cell.type = @"UITextField";
            cell.textField.text = self.userModel.nickname;
            [cell.textField addTarget:self action:@selector(textFieldChangeText:) forControlEvents:UIControlEventEditingChanged];
            return cell;
        }
        
        if (indexPath.row == 2) {
            cell.type = @"UILabel";
            if ([self.userModel.sex isEqualToString:@"1"]) {
                cell.resultLabel.text = @"男";
            }else if ([self.userModel.sex isEqualToString:@"2"]){
                cell.resultLabel.text = @"女";
            }else{
                cell.resultLabel.text = @"";
            }
            return cell;
        }
        
        if (indexPath.row == 3) {
            cell.type = @"UILabel";
            cell.resultLabel.text = self.userModel.birthdy;
            return cell;
        }
        
        if (indexPath.row == 4) {
            cell.type = @"UILabel";
            cell.resultLabel.text = self.userModel.aq_id;
            return cell;
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.type = @"UILabel";
            cell.resultLabel.text = self.userModel.address;
            return cell;
        }
        
        if (indexPath.row == 1) {
            cell.type = @"UILabel";
            cell.resultLabel.text = self.userModel.location;
            return cell;
        }
    }
    
    if (indexPath.section == 2) {
        cell.type = @"UIImageView";
        cell.iconimageView.image = [UIImage imageNamed:@"QR_Code"];
        return cell;
    }
    return nil;
}

- (void)textFieldChangeText:(UITextField *)textField{
    
    self.userModel.nickname = textField.text;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {//头像
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择文件来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"照相机",@"本地相册", nil];
            [sheet showInView:self.view];
        }
        
        if (indexPath.row == 3) {//生日
            
            
            ASBirthSelectSheet *datesheet = [[ASBirthSelectSheet alloc] initWithFrame:self.view.bounds];
            if (self.userModel.birthdy.length == 0) {
                self.userModel.birthdy = [self getCurrentTimes];
            }
            datesheet.selectDate = self.userModel.birthdy;
            
            datesheet.GetSelectDate = ^(NSString *dateStr) {
                self.userModel.birthdy = dateStr;
                [self.tableView reloadData];
            };
            [self.view addSubview:datesheet];
        }
    }
    
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {//地区

//            [self.blackview addSubview:self.addressPickerView];
            [self.addressPickerView show];
            [self.view bringSubviewToFront:self.addressPickerView];
            
        }
    }
}

//获取当前的时间

- (NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}

//HeaderInSection  &&  FooterInSection

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor clearColor];
    return backView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0000001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{

    if (section == 2) {
        UIView *backView = [[UIView alloc]init];
        backView.backgroundColor = [UIColor clearColor];
        
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(20, 10, SCREEN_WIDTH - 40, 40);
        [button setTitle:@"确认修改" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = UIColorFromRGB(@"d9343c");
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(configPersonalData) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 5;
        [backView addSubview:button];
        return backView;
    }else{
        UIView *backView = [[UIView alloc]init];
        backView.backgroundColor = [UIColor clearColor];
        return backView;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return 80;
    }else{
        return 10;
    }
}

- (void)configPersonalData{
    
    
    
    NSDictionary *dic = @{@"uid":User_ID,@"nickname":self.userModel.nickname,@"sex":self.userModel.sex,@"address":self.userModel.address,@"birthdy":self.userModel.birthdy};
    [PersonalInfoTool configUserInfoWithParam:dic successBlock:^(NSString *msg) {
        
        [self showHint:msg];
        
    } errorBlock:^(NSError *error) {
        [self showHint:@"网络错误"];
    }];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.navigationBar.barTintColor = [UIColor colorWithRed:0.900 green:0.216 blue:0.205 alpha:1.000];
    imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    [imagePicker.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor]}];
    switch (buttonIndex) {
        case 0://照相机
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        case 1://本地相簿
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.iconImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self.tableView reloadData];
    //网络请求
    [[NetworkManager new] networkWithURL:[NSString stringWithFormat:@"%@/api.php/User/changeHeadimg", www] pic:[info objectForKey:@"UIImagePickerControllerEditedImage"] parameter:@{@"uid": User_ID} success:^(id obj) {
        [self showHint:obj[@"msg"]];
    } fail:^(NSError *error) {
        [self showHint:@"网络错误"];
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
