# 今日待辦

一個以 Flutter 製作的待辦事項 App，可在網頁與 Android 上使用。這是用來逐步練習 Flutter、MVVM 架構與 Firebase 的專案。

## 線上測試

https://myfirstaitestapp.web.app/

> 網站會在推送至 `main` 後由 GitHub Actions 自動建置並部署到 Firebase Hosting。

## 目前功能

- 新增、完成與刪除待辦事項
- 拖曳調整待辦順序
- 點選待辦可編輯標題與詳細描述
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
   └─ todos/
      ├─ domain/models/          # Todo 資料模型
      ├─ data/repositories/      # 資料來源介面與實作
      └─ presentation/
         ├─ pages/               # 待辦清單頁、詳細編輯頁
         ├─ view_models/         # UI 狀態與操作邏輯
         └─ widgets/             # 可重用 UI 元件
```

目前待辦資料暫存在 App 記憶體。下一階段會加入 Firebase Authentication（Google、Email／密碼）與 Cloud Firestore，讓資料依帳號保存並跨裝置同步。

## 更新紀錄

### 2026-09-04

- 待辦事項新增詳細描述；可進入編輯頁修改標題與描述。
- 依 feature-first MVVM 重整資料夾，拆分清單頁、詳細編輯頁、ViewModel、資料模型與元件。
- 補上 Todo 更新行為的測試。

### 2026-08-28

- 建立 Flutter 待辦事項初版與拖曳排序功能。
- 建立 Firebase Hosting 的 GitHub Actions 自動部署流程。
