# *--dart-define* trong Flutter và sức mạnh của nó

## 1. Intro

Xin chào, nếu các bạn đã theo dõi series 3 bài trước của mình là:

- [GitHub - vanle57/flutter-flavor: Guide to flavoring a Flutter app](https://github.com/vanle57/flutter-flavor)

- [GitHub - vanle57/flutter-customize-run: Guild to customize Run and Debug in flutter using VSCode](https://github.com/vanle57/flutter-customize-run)

- [GitHub - vanle57/flutter-method-channel: Write code for specific platform by MethodChannel.](https://github.com/vanle57/flutter-method-channel)

Các bạn chắc hẳn sẽ cảm thấy việc config Flutter Flavor quá phức tạp. Vậy nên ở bài này mình sẽ hướng dẫn cho các bạn 1 cách khác để config, nó sẽ giúp mình giảm được vô số bước. Bắt đầu thôi!

## 2. Chuẩn bị

- IDE:
  
  - Visual Studio Code version 1.67.0
  
  - Android Studio Chipmunk 2021.2.1
  
  - XCode version 13.3.1

- Flutter SDK version 2.10.5

## 3. Khái niệm

`--dart-define` là 1 tham số để pass vào câu lệnh `flutter build` hoặc `flutter run`. Nó sẽ giúp chúng ta chuyển tiếp các biến môi trường. 

Điều đó có nghĩa là bạn có thể custom code của mình với bất kỳ giá trị nào bạn truyền qua tham số này. Quá là hay phải không nào? Điều này khiến mình ngay lập tức nghĩ đến việc define các biến khác nhau cho flavor thay vì config khùng điên như ở [bài trước](https://github.com/vanle57/flutter-flavor) của mình. 

## 4. Cú pháp

Trước khi đi vào ứng dụng cho flavor, mình sẽ demo nhỏ nhỏ để các bạn nắm được cách làm việc với `--dart-define` nha!

- Bước 1: Chúng ta sẽ xây dựng 1 ứng dụng có UI đơn giản như sau:

![1](https://github.com/vanle57/flutter-dart-define/blob/main/images/1.png)

- Bước 2: Các bạn define lớp `EnvironmentConfig`:
  
  ```dart
  class EnvironmentConfig {
    static const APP_NAME =
        String.fromEnvironment('APP_NAME', defaultValue: 'awesomeApp');
    static const APP_SUFFIX = String.fromEnvironment('APP_SUFFIX');
  }
  ```

***Giải thích 1 chút:*** 

 - Chúng ta có thể truy cập các biến *dart define* thông qua hàm `fromEnvirontment(name, defaultValue)`. ***name*** sẽ là tên biến được define sau câu lệnh `--dart-define= `, nếu như `fromEnvirontment` không thể tìm thấy biến nào như vậy thì nó sẽ trả về ***defaultValue***.

 - Bạn sẽ **bắt buộc phải khai báo biến là `const`**, bởi vì hàm `fromEnvironment` chỉ đảm bảo hoạt động khi các biến đó là hằng số.
  
  > Còn vì sao có thêm `static` phía trước? Bạn chỉ cần gõ `const` không thôi là hiểu rõ! Ahihi!


- Bước 3:  Sử dụng lớp `EnviromentConfig`:

Tới đây, mình sẽ gán 2 biến `APP_NAME` và `APP_SUFIX` vào trên UI:

```
Text(
   'APP_NAME: ${EnvironmentConfig.APP_NAME}',
    style: Theme.of(context).textTheme.subtitle1,
),
Text(
   'APP_SUFFIX: ${EnvironmentConfig.APP_SUFFIX}',
    style: Theme.of(context).textTheme.subtitle1,
),
```

- Bước 4: Run và xem kết quả thôi nào!

Câu lệnh run như sau:

`flutter run --dart-define=APP_NAME=demo --dart-define=APP_SUFFIX=.dev `

![2](https://github.com/vanle57/flutter-dart-define/blob/main/images/2.png)

## 5. Ứng dụng vào Flutter Flavor

Nếu chưa biết Flutter Flavor là gì, bạn có thể tham khảo qua [bài viết này](https://github.com/vanle57/flutter-flavor) của mình.

Còn đã biết rồi thì bắt tay vào công việc thôi nào! Ý tưởng ở đây là mình sẽ config app có tên và suffix khác nhau cho mỗi flavor nhé!

### 5.1. Cấu hình cho Android

- Bước 1: Định nghĩa và đọc các biến dart define:

Bạn vào file `android/app/build.gradle` và thêm đoạn code này vào:

```kotlin
// 1
def dartEnvironmentVariables = [
    APP_NAME: 'awesomeApp',
    APP_SUFFIX: null
];
// 2
if (project.hasProperty('dart-defines')) {
    // 3    
    dartEnvironmentVariables = dartEnvironmentVariables + project.property('dart-defines')
            .split(',')
            .collectEntries { entry ->
                // 4
                def pair = new String(entry.decodeBase64(), 'UTF-8').split('=')
                [(pair.first()): pair.last()]
            }
}
```

***Giải thích code:***

1. Chúng ta define các biến dart define theo dạng **key-value**. **Key** này sẽ giống nhau ở cả *iOS, Android và Flutter*. Còn **value** định nghĩa các giá trị default.

2. Flutter sẽ pass các biến dart define trong các thuộc tính của project với key là ***dart-defines***

3. Chuyển đổi string từ `dart-defines` thành Map.

4. Flutter Tool sẽ pass tất cả các Dart Defines như 1 string với dấu phẩy, ví dụ:
   
   - Ở Flutter 1.17: `APP_NAME=awesomeApp1,APP_SUFFIX=.dev`
   
   - Ở Flutter 1.20: `APP_NAME%3Dawesome1,APP_SUFFIX%3D.dev`
   
   - Ở Flutter 2.2: `REVGSU5FRVhBTVBMRV9BUFBfTkFNRT1hd2Vzb21lMg==,REVGSU5FRVhBTVBMRV9BUFBfU1VGRklYPS5kZXY=`
   
   Ở mỗi version thì có cách mã hoá khác nhau, ở đây vì mình sử dụng Flutter 2.16 mã hoá base64 như ở Flutter 2.2 nên mình sẽ phải giải mã base 64 ngược lại.
- Bước 2: Thay đổi app name và application id suffix
  
  - Bạn tiếp tục vào file `android/app/build.gradle` và sửa ở phần `defaultConfig` như sau:
  
  ```kotlin
  defaultConfig {
          // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
          applicationId "com.example.demo_dart_define"
          minSdkVersion flutter.minSdkVersion
          targetSdkVersion flutter.targetSdkVersion
          versionCode flutterVersionCode.toInteger()
          versionName flutterVersionName
          // NOTE: ADD THESE LINES
          applicationIdSuffix dartEnvironmentVariables.APP_SUFFIX
          resValue "string", "app_name", dartEnvironmentVariables.APP_NAME
  }
  ```
  
  - Bạn vào `android/app/src/main/AndroidManifest.xml` để gán `app_name` vào application label
  
  ```xml
  <application
          android:label="@string/app_name"
          android:name="${applicationName}"
          android:icon="@mipmap/ic_launcher">
  ```

- Bước 3: Bây giờ run và xem kết quả thôi. Câu lệnh như trên nhé!

`flutter run --dart-define=APP_NAME=demo --dart-define=APP_SUFFIX=.dev`

![3](https://github.com/vanle57/flutter-dart-define/blob/main/images/3.png)

![4](https://github.com/vanle57/flutter-dart-define/blob/main/images/4.png)

App name đã được thay đổi!

### 5.2. Cấu hình cho iOS

> Bạn vẫn phải thực hiện trên XCode nha!

- Bước 1: Bạn tạo file `Define-defaults.xcconfig` để define các cặp key-value tương tự như ở bước 1 của Android. 
  
  - Click chuột phải vào `Runner/Flutter` chọn *New File*, nhập "con"" vào ô filter chọn *Next* và đặt tên tương ứng.
  
  ![5](https://github.com/vanle57/flutter-dart-define/blob/main/images/5.png)
  
  - Bạn định nghĩa vào đó như sau:
  
  ```swift
  APP_NAME=awesomeApp
  APP_SUFFIX=
  ```

- Bước 2: import file đó vào `Debug.xcconfig` và `Release.xcconfig`

```swift
#include "Generated.xcconfig"
#include "Define-defaults.xcconfig"
#include "Define.xcconfig"
```

***Giải thích:*** `Define-defaults.xcconfig` là file bạn đã tạo ở bước 1 còn `Define.xcconfig` để ghi các biến dar define sẽ là file được tạo ra trong quá trình biên dịch.

- Bước 3: Thay đổi app name và app bundle identifier trong file `Info.plist`

![6](https://github.com/vanle57/flutter-dart-define/blob/main/images/6.png)

- Bước 4: Chỉnh sửa scheme để đọc các biến dart define và ghi vào file `Define.xcconfig`
  
  - Click vào Scheme `Runner` -> Edit Scheme. Sau đó dưới tab `Build` chọn *Pre-actions* -> click dấu `+` chọn *New Run Script Action*
  
  ![7](https://github.com/vanle57/flutter-dart-define/blob/main/images/7.png)
  
  ![7](https://github.com/vanle57/flutter-dart-define/blob/main/images/8.png)
  
  - Tiếp theo, chúng ta sẽ viết đoạn code thực hiện việc đọc các biến dart define và ghi vào file `Define.xcconfig`.  Đoạn code này sẽ được biên dịch trước khi XCode build app. Tương tự như Android là vẫn phải giải mã base64 nha:
  
  ```ruby
  function entry_decode() { echo "${*}" | base64 --decode; }
  
  IFS=',' read -r -a define_items <<< "$DART_DEFINES"
  
  for index in "${!define_items[@]}"
  do
      define_items[$index]=$(entry_decode "${define_items[$index]}");
  done
  
  printf "%s\n" "${define_items[@]}"|grep '^APP_' > ${SRCROOT}/Flutter/Define.xcconfig
  ```
  
  - Nhớ chọn *Provide build settings from* là **Runner** nhoé! Nếu không thì các bạn sẽ gặp lỗi đấy.
  
  ![9](https://github.com/vanle57/flutter-dart-define/blob/main/images/9.png)

- Bước 5: Run và xem kết quả thôi. Vẫn dùng câu lệnh trên kia nhé!

`flutter run --dart-define=APP_NAME=demo --dart-define=APP_SUFFIX=.dev`

![10](https://github.com/vanle57/flutter-dart-define/blob/main/images/10.png)

![11](https://github.com/vanle57/flutter-dart-define/blob/main/images/11.png)

***Lưu ý:*** Đoạn code trên sẽ giúp bạn tự generate ra file `Define.xcconfig` khi bạn chạy câu lệnh có `flutter run --dart-define=APP_...` nhưng điều gì sẽ xảy ra nếu bạn chỉ chạy lệnh `flutter run` hoặc các biến dart define không chứa chữ "APP"? Bạn nghĩ nó sẽ lấy giá trị trong `Define-defaults.xcconfig` phải không? Không đâu! Bạn sẽ gặp lỗi như vậy:

![12](https://github.com/vanle57/flutter-dart-define/blob/main/images/12.png)

Theo mình thấy thì điều này khá khó chịu. Vậy nên mình đề xuất các bạn hãy tạo luôn file `Define.xcconfig` để nếu có không pass các biến dart define thì chương trình vẫn chạy trơn tru.

## 6. Mở rộng thêm tính năng Customize Debug and Run của Visual Studio Code

Có lẽ sẽ có bạn thắc mắc rằng "Không lẽ mỗi lần build bắt buộc phải build bằng command sao?" Hoặc rằng "Nếu các biến dart define đó dài hay cần nhiều biến thì chẳng phải quá tốn công sao?"

> Bây giờ sẽ là lúc mình giúp bạn trả lời câu hỏi đó!

Nếu các bạn chưa biết về Customize Debug and Run của Visual Studio Code thì tham khảo qua bài viết ở [link này](https://github.com/vanle57/flutter-customize-run) của mình. Còn nếu biết rồi thì chúng ta bắt đầu thôi!

- Bạn vào tab `Run and Debug` và click vào  *create a launch.json file* -> chọn **Debbuger** là *Dart&Flutter* nhé!.

![13](https://github.com/vanle57/flutter-dart-define/blob/main/images/13.png)

- Vào file `.vscode/launch.json`, tạo 3 configurations tương ứng với 3 flavor là **dev**, **staging** và **product**.

```json
{
     "name": "dev",
     "request": "launch",
     "type": "dart",
     "args": ["--dart-define", "APP_NAME=[dev]demo", "--dart-define", "APP_SUFFIX=.dev"]
},
{
     "name": "staging",
     "request": "launch",
     "type": "dart",
     "args": ["--dart-define", "APP_NAME=[stg]demo", "--dart-define", "APP_SUFFIX=.stg"]
},
{
     "name": "prod",
     "request": "launch",
     "type": "dart",
     "args": ["--dart-define", "APP_NAME=demo"]
},
```

- Run lên và xem kết quả thôi! Bạn có thể chọn flavor nào để build tuỳ thích nhé!

![13](https://github.com/vanle57/flutter-dart-define/blob/main/images/14.png)

**Kết quả:** 

![15](https://github.com/vanle57/flutter-dart-define/blob/main/images/15.png)

#### [Demo source code](https://github.com/vanle57/flutter-dart-define/tree/main/demo%20source%20code/demo_dart_define)

## 7. Tạm kết

Qua bài này bạn đã biết:

- Khái niệm và cách làm việc với `--dart-define` trong Flutter

- Ứng dụng `--dart-define` vào Flutter flavor

- Mở rộng tính năng của `Customize Run and Debug`

Nếu các bạn đã từng theo dõi các bài viết trước của mình thì sẽ nhận ra có 1 cái liên quan đến Flutter flavor mà mình chưa nói đến, đó là cái api url khác nhau cho từng flavor. Câu trả lời đấy mình để dành cho các bạn trả lời đấy! Nếu muốn biết đáp án thì các bạn có thể liên hệ mình.

Xin cảm ơn các bạn và hẹn gặp lại!

#### Tài liệu tham khảo:

- [Flutter 1.17 — no more Flavors, no more iOS Schemas. Command argument that changes everything | Denis Beketsky](https://itnext.io/flutter-1-17-no-more-flavors-no-more-ios-schemas-command-argument-that-solves-everything-8b145ed4285d)

- [Using --dart-define in Flutter - Dart Code - Dart & Flutter support for Visual Studio Code](https://dartcode.org/docs/using-dart-define-in-flutter/)

- [How to setup dart define for keys and screts on android | Gildásio Filho](https://medium.com/flutter-community/how-to-setup-dart-define-for-keys-and-secrets-on-android-and-ios-in-flutter-apps-4f28a10c4b6c?source=rss----86fb29d7cc6a---4)
