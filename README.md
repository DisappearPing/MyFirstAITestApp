# 今日待辦

一個以 Flutter 製作的待辦事項 App，可在網頁與 Android 上使用。支援訪客模式、Google／Email 帳號登入，以及以 Firebase 保存個人待辦資料。這是用來逐步練習 Flutter、feature-first MVVM 與 Firebase 的專案。

## 線上測試

https://myfirstaitestapp.web.app/

> 網站會在推送至 `main` 後由 GitHub Actions 自動建置並部署到 Firebase Hosting。

## 目前功能

- 新增、完成與刪除待辦事項
- 拖曳調整待辦順序
- 點選待辦可編輯標題與詳細描述
- 每個待辦可上傳 1 張圖片、預覽、更換與移除
- 訪客模式：不登入也能先使用待辦
- Google 登入與 Email／密碼註冊、登入
- 可將訪客帳號綁定為正式帳號，保留原本待辦
- Cloud Firestore 依使用者帳號保存待辦資料
- 會員中心、登入狀態保存與登出
- 響應式介面，可在 Web 與 Android 模擬器執行

## 開發指令

```powershell
flutter run
flutter test
flutter build web --release --base-href "/"
```

## 專案結構

```text
lib/
├─ app/                         # App 設定、主題與入口頁
└─ features/
   ├─ auth/                      # 訪客、登入、註冊與會員中心
   │  ├─ domain/models/           # 使用者資料模型
   │  ├─ data/repositories/       # Firebase Authentication 實作
   │  └─ presentation/            # 帳號頁與 ViewModel
   └─ todos/
      ├─ domain/models/           # Todo 資料模型
      ├─ data/repositories/       # Firestore 資料來源實作
      └─ presentation/
         ├─ pages/                # 待辦清單頁、詳細編輯頁
         ├─ view_models/          # UI 狀態與操作邏輯
         └─ widgets/              # 可重用 UI 元件
```

## Firebase 設定

- Firebase Authentication：啟用 Anonymous、Google 與 Email／Password 供應商。
- Cloud Firestore：待辦存放於 `users/{uid}/todos/{todoId}`，安全規則只允許使用者讀寫自己的資料。
- Cloud Storage：圖片存放於 `users/{uid}/todos/{todoId}/`，規則限制為帳號本人、圖片格式與 5 MB 以內。
- Android Google 登入：需在 Firebase Android App 設定加入 debug／release 簽署憑證的 SHA-1，並更新 `android/app/google-services.json`。

`lib/firebase_options.dart` 與 `android/app/google-services.json` 為 Firebase 用戶端設定檔，可提交至版本控制；它們不是伺服器私鑰或服務帳戶金鑰。

## 更新紀錄

### 2026-09-07

- 新增待辦圖片功能：可從相簿選圖、預覽、更換與移除。
- 圖片存放在 Firebase Storage，待辦文件只保存圖片路徑與網址。
- 新增 Storage 安全規則，限制使用者只能存取自己的圖片，並限制檔案格式與大小。

### 2026-09-05

- 接入 Firebase Authentication、Cloud Firestore 與 FlutterFire 設定。
- 加入訪客模式、Google 登入、Email／密碼註冊與登入；訪客可綁定正式帳號以保留待辦。
- 待辦改為依 Firebase 使用者帳號儲存並跨裝置同步。
- 新增會員中心、帳號資訊、登出與登入狀態保存。
- 調整 Android 與 Web 的返回行為；登入、註冊、會員頁與待辦首頁加入轉場。
- 改善 Google 帳號已綁定時的切換流程，避免重複綁定錯誤。

### 2026-09-04

- 改善網頁版的新增詳細待辦按鈕可見性；完成待辦時，詳細描述也會顯示刪除線。
- 待辦事項新增詳細描述；可進入編輯頁修改標題與描述。
- 依 feature-first MVVM 重整資料夾，拆分清單頁、詳細編輯頁、ViewModel、資料模型與元件。
- 補上 Todo 更新行為的測試。

### 2026-08-28

- 建立 Flutter 待辦事項初版與拖曳排序功能。
- 建立 Firebase Hosting 的 GitHub Actions 自動部署流程。
