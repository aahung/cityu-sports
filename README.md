# CityU Sport Facility [![Build Status](https://travis-ci.org/Aahung/cityu-sports.svg?branch=master)](https://travis-ci.org/Aahung/cityu-sports)
unofficial cityu sport facility booking app for iOS, [Android version here](https://github.com/Aahung/cityu-sports-android).

## Important Announcement

**On 07 Dec, 2015**. as a concern  sent from City University of Hong Kong:

> VPSA, Dean of Students and Director of SDS are concerning the security of
this kind of app because it's possible that the apps may store the username
and password and perform any action on behalf of any user in any of CityU’s
Enterprise Systems.

My intention on this App is only to provide a better booking experience for CityU students and staffs. I have not done or tried to store any usernames or passwords or users. This project is competely open source and directly built then published without adding any lines of codes. 

However, to avoid any unhappiness likely to happen to me, I will no longer make **CityU Sport Facility** App available on App Store. I will also publish an update to disable the functions to App Store in the comming weeks. 
I am sorry for any inconvenience for current users. This project will be only for technical discussion from now on. 

**R.I.P.**

[See full announcement](https://blog.xinhong.me/two-cityu-apps-took-down-from-app-store-liang-kuan-cityu-ying-yong-xia-jia-tong-zhi.html)

## Install
[<s>Link</s>]()

## Screenshots
[Screenshots](https://github.com/Aahung/cityu-sports/tree/master/screenshots)

## Acknowledgements
license file may found in [here](CityU-Sport-Facility/licenses) or Setting -> USports -> Ackowledgements on your iPhone / iPad

* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* [HTMLReader](https://github.com/nolanw/HTMLReader)
* [icons8](http://icons8.com)
* [MBProgressHUD](https://github.com/jdg/MBProgressHUD)
* [SIAlertView](https://github.com/Sumi-Interactive/SIAlertView)

## Change log

### 1.1.4 (34)
- Tap on tab bar trigger refreshing
- Update dependencies

### 1.1.3 (33)
- Minor UI changes
- Tested with Xcode 7

### 1.1.2 (30)
- Fixed a bug in iOS 9 which will cause back button disappear

### 1.1.1 (29)
- Optimize UI
- Fixed the bug may not detect the result of deleting booking correctly

### 1.1 (27)
- Optimize UI, slimmer font
- Add view and edit action after add to calendar
- Add share button

### 1.0.3 (25)
- Fixed the bug in iOS 7 causes back button("< Welcome") appears in the navigation bar after log in. 

### 1.0.2 (23, 24)
- Display the error message when fail to get session

### 1.0.1 (22)
- Add edit button in manage page
- Add more icons in setting page

### 1.0.1 (21) 
- Fixed the bug causing crash when refresh after 00:00

### 1.0.1 (20) 
- Add different icons for week days.

### 1.0.1 (19)
- UI Redesigned
- Improved stability
- Fixed some bugs,
- iOS 7 is supported.

### 1.0.0
- Internal version, skipped

### 0.1.2 (15) 
- Suddenly the delete function doesn't work, after I recompile the exact same code and it works. 
- In addition, I optimised some codes.

### 0.1.2 (14)
- Deal with the unexpected url when requesting availability (court)

### 0.1.2 (13)
- Reset locale to en_US to avoid failure to add calendar events on system language other than English.
