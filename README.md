# 📖 Aplikasi Buku Masak (Recipe App)

Aplikasi mobile katalog resep masakan berbasis **Flutter** yang dikembangkan sebagai proyek UAS mata kuliah Mobile Computing. Aplikasi ini mendukung pengelolaan resep secara lokal maupun pencarian resep dari internet, dengan sistem autentikasi multi-user berbasis penyimpanan lokal.

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 🔐 **Login & Register** | Sistem autentikasi lokal dengan persistensi sesi (tidak perlu login ulang setelah keluar) |
| 📋 **Katalog Resep** | 8 resep masakan Indonesia bawaan (Nasi Goreng, Bakso, Rendang, dll.) |
| 🔍 **Pencarian Cerdas** | Cari resep berdasarkan **nama masakan** atau **nama bahan** secara real-time |
| 🌐 **Cari Online** | Integrasi API TheMealDB untuk mencari resep internasional dari internet |
| ❤️ **Favorit** | Tandai resep favorit, resep online bisa disimpan ke lokal |
| 📸 **Tambah Resep** | Buat resep sendiri lengkap dengan foto dari kamera HP |
| 🛒 **Daftar Belanja** | Kelola daftar bahan yang perlu dibeli |
| 👤 **Multi-User** | Setiap akun memiliki data resep yang terpisah |
| 🔑 **Hak Akses Admin** | Akun admin dapat melihat seluruh data dari semua pengguna |

---

## 🛠️ Tech Stack

- **Framework:** Flutter SDK (Dart)
- **State Management:** Provider (`ChangeNotifier` + `Consumer`)
- **Database Lokal:** Hive & Hive Flutter (NoSQL Key-Value Store)
- **Networking:** `http` package (REST API Client)
- **Kamera & Galeri:** `image_picker`
- **Penyimpanan File:** `path_provider`
- **UUID Generator:** `uuid`

---

## 📁 Struktur Proyek

```
lib/
├── main.dart                    # Entry point aplikasi, inisialisasi Hive & Provider
├── models/
│   ├── recipe.dart              # Model data resep
│   ├── ingredient.dart          # Model data bahan masakan
│   ├── user.dart                # Model data pengguna
│   └── shopping_item.dart       # Model data daftar belanja
├── providers/
│   ├── recipe_provider.dart     # State management resep (CRUD, search, filter)
│   ├── auth_provider.dart       # State management autentikasi & sesi
│   └── shopping_provider.dart   # State management daftar belanja
├── screens/
│   ├── login_screen.dart        # Halaman login
│   ├── register_screen.dart     # Halaman registrasi
│   ├── main_screen.dart         # Scaffold utama dengan Bottom Navigation Bar
│   ├── home_screen.dart         # Beranda: katalog & pencarian resep
│   ├── recipe_hub_screen.dart   # Tab hub (Resep Saya + Favorit)
│   ├── my_recipes_screen.dart   # Daftar resep milik user
│   ├── favorite_recipes_screen.dart  # Daftar resep favorit
│   ├── recipe_detail_screen.dart     # Detail resep
│   ├── add_edit_recipe_screen.dart   # Form tambah/edit resep
│   ├── search_by_ingredient_screen.dart # Pencarian berdasarkan bahan
│   ├── shopping_list_screen.dart     # Halaman daftar belanja
│   └── profile_screen.dart      # Halaman profil & logout
├── services/
│   └── api_service.dart         # Service untuk koneksi TheMealDB API
├── utils/
│   └── image_utils.dart         # Utilitas konversi gambar (Base64, dll.)
└── widgets/
    ├── recipe_card.dart          # Widget kartu resep (reusable)
    └── recipe_image.dart         # Widget gambar cerdas (auto-detect: asset/file/network)
```

---

## 🚀 Cara Menjalankan Proyek

### Prasyarat
- Flutter SDK (versi 3.x ke atas)
- Android Studio / VS Code dengan plugin Flutter & Dart
- Emulator Android atau HP Android fisik (API level 21+)

### Langkah-Langkah

**1. Clone repository ini:**
```bash
git clone https://github.com/Umar1hamzah/MobileComputing_Uas.git
cd MobileComputing_Uas
```

**2. Install dependencies:**
```bash
flutter pub get
```

**3. Jalankan aplikasi:**
```bash
# Di HP Android (pastikan USB Debugging aktif)
flutter run

# Build APK untuk distribusi
flutter build apk --release
```

> Hasil APK release akan tersimpan di:
> `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 Cara Menggunakan Aplikasi

1. **Buka aplikasi** → Daftarkan akun baru melalui halaman **Register**
2. **Login** → Masukkan email dan password yang sudah didaftarkan
3. **Beranda (Home)** → Lihat seluruh katalog resep dan gunakan fitur pencarian
4. **Cari Resep Online** → Aktifkan toggle "Cari Online (API)" dan ketik nama masakan lalu tekan Enter
5. **Tambah Resep** → Tekan tombol **+** di pojok kanan bawah, isi form dan ambil foto makanan
6. **Favorit** → Tekan ikon ❤️ pada kartu resep untuk menandai favorit

### Akun Admin (Opsional)
Saat register, masukkan kode admin berikut di field "Kode Admin" untuk mendapatkan akses penuh:
```
AKUADMINKAUHAMA
```

---

## 🗄️ Arsitektur Database (Hive Schema)

### Box `recipes`
Menyimpan semua data resep dengan key berupa `id` unik.

### Box `usersBox`
Menyimpan data akun pengguna dengan key berupa `email`.

### Box `session`
Menyimpan email dari sesi pengguna yang sedang aktif. Memungkinkan fitur auto-login (tidak perlu login ulang setelah menutup aplikasi).

### Box `shopping_list`
Menyimpan daftar item belanja pengguna.

---

## 🔐 Hak Izin Android

Izin berikut telah dikonfigurasi pada `AndroidManifest.xml`:
- `INTERNET` — Akses jaringan untuk API resep online
- `CAMERA` — Mengambil foto makanan menggunakan kamera
- `READ_EXTERNAL_STORAGE` & `WRITE_EXTERNAL_STORAGE` — Akses penyimpanan file gambar

---

## 🌐 API Eksternal

Aplikasi ini menggunakan **TheMealDB API** (gratis & tanpa autentikasi) untuk fitur pencarian resep online:
- **Base URL:** `https://www.themealdb.com/api/json/v1/1/`
- **Endpoint Pencarian:** `search.php?s={keyword}`

---

## 👨‍💻 Developer

| Nama | NIM |
|---|---|
| Umar Hamzah | 24110400023|

**Mata Kuliah:** Mobile Computing — UAS
