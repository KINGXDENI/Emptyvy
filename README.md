# Emptyvy 🎬

**Emptyvy** adalah aplikasi streaming Anime dan Donghua berbasis mobile yang dibangun menggunakan **Flutter**. Aplikasi ini menawarkan antarmuka modern (Dark Mode), navigasi yang mulus, dan pemutar video terintegrasi yang mendukung berbagai server streaming.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

## ✨ Fitur Utama

- **Multi-Content Support**: Pemisahan tab khusus untuk **Anime** (Jepang) dan **Donghua** (China).
- **Home Screen Dinamis**:
  - Menampilkan Anime/Donghua yang sedang tayang (_Ongoing_).
  - Menampilkan Anime/Donghua yang baru tamat (_Completed_).
- **Pencarian Cerdas (Smart Search)**: Pencarian kontekstual (Mencari Anime saat di tab Anime, dan Donghua saat di tab Donghua).
- **Infinite Scroll**: Memuat daftar konten secara otomatis saat layar digulir ke bawah (Pagination).
- **Detail Info**: Sinopsis, Rating, Genre, Studio, dan daftar episode lengkap.
- **Integrated Video Player**:
  - Menggunakan **WebView** untuk memutar video dari berbagai sumber (Vidhide, Filedon, dll).
  - Dukungan pemilihan kualitas (360p, 480p, 720p).
  - Navigasi Episode (Next/Prev) langsung dari player.
  - **Smart Source Selection**: Otomatis membedakan antara link embed langsung (Donghua) dan fetch via ID (Anime).
- **Dark Mode UI**: Desain antarmuka gelap yang nyaman di mata.

## 📸 Galeri Aplikasi (Screenshots)

Berikut adalah tampilan antarmuka Emptyvy dalam mode gelap:

| Home Screen | Detail Anime | Video Player | Pencarian |
|:---:|:---:|:---:|:---:|
| <img src="https://appwrite.dibohost.my.id/v1/storage/buckets/6926356c002d9ac02cc3/files/692637660006e29fa60d/view?project=69255f3d0030cb0bae67" width="200"> | <img src="https://appwrite.dibohost.my.id/v1/storage/buckets/6926356c002d9ac02cc3/files/69263770002bf8b49185/view?project=69255f3d0030cb0bae67" width="200"> | <img src="https://appwrite.dibohost.my.id/v1/storage/buckets/6926356c002d9ac02cc3/files/692637760020779253c0/view?project=69255f3d0030cb0bae67" width="200"> | <img src="https://appwrite.dibohost.my.id/v1/storage/buckets/6926356c002d9ac02cc3/files/6926377d00050be69e46/view?project=69255f3d0030cb0bae67" width="200"> |

## 🛠️ Teknologi & Library

- **Framework**: [Flutter](https://flutter.dev/)
- **Bahasa**: Dart
- **State Management**: `setState` (Native) & `FutureBuilder`
- **Dependencies**:
  - [`http`](https://pub.dev/packages/http): Untuk mengambil data dari API.
  - [`webview_flutter`](https://pub.dev/packages/webview_flutter): Untuk memutar video embed.

## 📂 Struktur Proyek

```text
lib/
├── models/               # Model data (Parsing JSON)
│   ├── anime_model.dart
│   ├── anime_detail_model.dart
│   ├── donghua_model.dart
│   ├── donghua_detail_model.dart
│   ├── episode_model.dart
│   ├── search_genre_model.dart
│   └── pagination_model.dart
├── screens/              # Halaman UI
│   ├── home_screen.dart
│   ├── detail_screen.dart
│   ├── donghua_detail_screen.dart
│   ├── player_screen.dart
│   ├── search_screen.dart
│   ├── see_all_screen.dart
│   └── donghua_see_all_screen.dart
├── services/             # Logika API (Fetch Data)
│   └── api_service.dart
└── main.dart             # Entry point
```

## 🚀 Instalasi & Menjalankan

Ikuti langkah-langkah ini untuk menjalankan proyek di mesin lokal Anda:

1.  **Clone Repository**

    ```bash
    git clone [https://github.com/username-anda/emptyvy.git](https://github.com/username-anda/emptyvy.git)
    cd emptyvy
    ```

2.  **Install Dependencies**

    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Android (Penting\!)**
    Aplikasi ini menggunakan `webview_flutter`, jadi pastikan konfigurasi berikut sudah benar:

    - **Min SDK Version**: Buka `android/app/build.gradle` dan ubah `minSdkVersion` menjadi **21**.

      ```gradle
      defaultConfig {
          // ...
          minSdkVersion 21
          // ...
      }
      ```

    - **Izin Internet**: Buka `android/app/src/main/AndroidManifest.xml` dan tambahkan izin internet:

      ```xml
      <manifest xmlns:android="[http://schemas.android.com/apk/res/android](http://schemas.android.com/apk/res/android)" package="com.example.emptyvy">
          <uses-permission android:name="android.permission.INTERNET"/>
          <application ...
      ```

4.  **Jalankan Aplikasi**
    Pastikan emulator atau device fisik terhubung.

    ```bash
    flutter run
    ```

## 🤝 Mari Berkolaborasi\! (Collaborate)

Proyek ini masih dalam tahap pengembangan awal dan kami sangat terbuka untuk kolaborasi. Jika Anda seorang developer Flutter, desainer UI/UX, atau sekadar ingin belajar, mari berkontribusi\!

Beberapa hal yang bisa dikembangkan:

- [ ] **Fitur Comic**: Mengimplementasikan tab Comic yang saat ini masih placeholder.
- [ ] **History & Bookmark**: Menyimpan riwayat tontonan dan anime favorit (menggunakan SQLite/Hive).
- [ ] **Peningkatan UI Player**: Menambahkan kontrol kustom untuk video player.
- [ ] **Search Filter**: Menambahkan filter berdasarkan Genre di pencarian.

Cara berkontribusi:

1.  **Fork** repository ini.
2.  Buat branch fitur baru (`git checkout -b fitur-keren-anda`).
3.  Commit perubahan Anda (`git commit -m 'Menambahkan fitur login'`).
4.  Push ke branch tersebut (`git push origin fitur-keren-anda`).
5.  Buat **Pull Request**.

## 👥 Authors

Project ini dikembangkan dengan ❤️ oleh:

| Nama                      | Peran          | GitHub                                                                                                                                            |
| :------------------------ | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Muh. Deni Setiawan**    | Lead Developer | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/KINGXDEN)       |
| **M Firas Rizaldiansyah** | Contributor    | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/username-teman) |

## 🙏 Ucapan Terima Kasih (Special Thanks)

Proyek ini tidak akan terwujud tanpa sumber daya luar biasa berikut:

- **[Sanka Vollerei](https://github.com/SankaVollerei)**: Terima kasih khusus atas penyediaan API publik yang memungkinkan aplikasi ini mengambil data Anime dan Donghua.
- **Otakudesu & Anichin**: Sebagai sumber data konten original.
- **Komunitas Flutter Indonesia**: Atas tutorial dan diskusinya yang bermanfaat.
- **Gemini AI**: Sebagai partner diskusi (coding assistant) dalam mempercepat proses pengembangan aplikasi ini.

## ⚠️ Disclaimer

Aplikasi ini dibuat semata-mata untuk tujuan **edukasi dan pembelajaran** pengembangan aplikasi mobile.

- **Emptyvy** tidak menghosting video apa pun di servernya sendiri.
- Semua konten disediakan oleh pihak ketiga yang tidak berafiliasi dengan pengembang aplikasi ini.
- Gunakan dengan bijak.

---
