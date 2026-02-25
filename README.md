# 🎬 Movie App

Ứng dụng xem phim và đặt vé được xây dựng bằng Flutter, tích hợp TMDB API, Firebase và VNPay.

## 📱 Tính năng chính

### 🔐 Xác thực & Quản lý người dùng
- **Đăng nhập/Đăng ký** với Email & Password
- **Đăng nhập mạng xã hội** qua Google và Facebook
- **Quên mật khẩu** với chức năng gửi email reset
- **Cập nhật thông tin** cá nhân (tên hiển thị, ảnh đại diện)
- **Quản lý phiên đăng nhập** tự động với Firebase Auth

### 🎥 Khám phá phim
- **Trang chủ** hiển thị:
  - Phim đang chiếu (Now Playing)
  - Phim phổ biến (Popular)
  - Phim được đánh giá cao (Top Rated)
  - Phim sắp ra mắt (Upcoming)
- **Tìm kiếm phim** theo tên
- **Duyệt phim theo thể loại** (Action, Comedy, Drama, Horror, v.v.)
- **Chi tiết phim** đầy đủ:
  - Thông tin cơ bản (tên, mô tả, ngày phát hành, đánh giá)
  - Diễn viên và đoàn làm phim
  - Video trailer và teaser
  - Đánh giá từ người dùng
  - Nhà cung cấp xem phim (Watch Providers)

### 📺 Xem video
- **Trình phát video** tích hợp:
  - Hỗ trợ YouTube Player
  - Hỗ trợ Chewie Player cho video khác
  - Điều khiển phát/tạm dừng, tua, âm lượng
  - Chế độ toàn màn hình

### ⭐ Tương tác người dùng với TMDB
- **Đánh giá phim/TV show** (0.5 - 10.0 sao)
- **Thêm vào danh sách yêu thích** (Favorites)
- **Thêm vào danh sách xem sau** (Watchlist)
- **Xem lịch sử đánh giá** của bản thân
- **Quản lý danh sách** yêu thích và xem sau
- **Đồng bộ trạng thái** với tài khoản TMDB

### 🎟️ Đặt vé xem phim
- **Xem lịch chiếu** tự động từ Firebase Firestore
- **Chọn rạp chiếu phim** với thông tin chi tiết
- **Chọn ghế ngồi** trực quan:
  - Hiển thị sơ đồ ghế
  - Phân biệt ghế trống/đã đặt/đang chọn
  - Chọn nhiều ghế cùng lúc
- **Thanh toán qua VNPay**:
  - Tích hợp VNPay Sandbox
  - Bảo mật với HMAC-SHA512
  - WebView để xử lý thanh toán
- **Quản lý vé đã đặt**:
  - Xem danh sách vé trong Profile
  - Hiển thị mã QR cho mỗi vé
  - Thông tin chi tiết (phim, rạp, ghế, giờ chiếu)

### 👤 Trang cá nhân
- **Thông tin người dùng** (ảnh đại diện, tên, email)
- **Thống kê**:
  - Số lượng phim yêu thích
  - Số lượng phim đã đánh giá
- **Danh sách yêu thích** (My Watchlist)
- **Vé đã đặt** (My Tickets) với mã QR
- **Đăng xuất**

### 🎨 Giao diện
- **Onboarding Screen** giới thiệu ứng dụng
- **Splash Screen** khi khởi động
- **Bottom Navigation** điều hướng dễ dàng
- **Shimmer Loading** hiệu ứng tải mượt mà
- **Cached Images** tối ưu hiệu suất
- **Smooth Page Indicator** cho carousel
- **Rating Bar** trực quan

## 🛠️ Công nghệ sử dụng

### Framework & Ngôn ngữ
- **Flutter** (SDK ^3.9.2)
- **Dart**

### State Management
- **flutter_bloc** (^9.1.1) - Quản lý trạng thái
- **equatable** (^2.0.7) - So sánh đối tượng

### Backend & Database
- **Firebase Core** (^4.3.0)
- **Firebase Auth** (^6.1.3) - Xác thực người dùng
- **Cloud Firestore** (^6.1.1) - Database NoSQL
- **Firebase Storage** (^13.0.5) - Lưu trữ file

### API & Networking
- **http** (^1.6.0) - HTTP client
- **dio** (^5.9.0) - HTTP client nâng cao
- **TMDB API** - Dữ liệu phim và TV show

### Xác thực mạng xã hội
- **google_sign_in** (^7.2.0)
- **flutter_facebook_auth** (^7.1.2)

### Video Player
- **chewie** (^1.13.0)
- **video_player** (^2.10.1)
- **youtube_player_flutter** (^9.1.3)

### UI & UX
- **cached_network_image** (^3.4.1) - Cache ảnh
- **shimmer** (^3.0.0) - Hiệu ứng loading
- **smooth_page_indicator** (^2.0.1) - Indicator cho PageView
- **flutter_rating_bar** (^4.0.1) - Thanh đánh giá

### Thanh toán & QR
- **qr_flutter** (^4.1.0) - Tạo mã QR
- **crypto** (^3.0.3) - Mã hóa cho VNPay
- **webview_flutter** (^4.10.0) - WebView thanh toán

### Tiện ích
- **shared_preferences** (^2.5.4) - Lưu trữ local
- **flutter_dotenv** (^6.0.0) - Quản lý biến môi trường
- **intl** (^0.20.2) - Định dạng ngày tháng
- **url_launcher** (^6.3.0) - Mở URL

## 📁 Cấu trúc dự án

```
lib/
├── constrains/
│   ├── env/              # Biến môi trường
│   └── string/           # Constants và endpoints
├── modules/
│   ├── account/          # Quản lý tài khoản
│   ├── booking/          # Đặt vé
│   │   ├── model/        # Cinema, Showtime, Ticket
│   │   └── views/        # Màn hình đặt vé, chọn ghế, thanh toán
│   ├── browse/           # Duyệt phim
│   ├── home/             # Trang chủ
│   ├── login/            # Đăng nhập
│   │   ├── cubits/       # Auth Cubit & State
│   │   ├── model/        # User Model
│   │   └── views/        # Màn hình đăng nhập
│   ├── movie/            # Chi tiết phim
│   │   ├── model/        # TMDB Models (Movie, Credit, Review, Video, etc.)
│   │   └── views/        # Chi tiết, video player, danh sách theo thể loại
│   ├── profile/          # Trang cá nhân
│   ├── register/         # Đăng ký
│   ├── root/             # Root navigation
│   ├── search/           # Tìm kiếm
│   └── splashscreen/     # Splash & Onboarding
├── services/
│   ├── api/
│   │   ├── api_service.dart           # Base API service
│   │   └── firebase_auth_service.dart # Firebase Auth
│   ├── booking/
│   │   └── booking_service.dart       # Quản lý đặt vé
│   ├── payment/
│   │   └── vnpay_service.dart         # VNPay integration
│   └── tmdb/
│       ├── tmdb_auth_service.dart     # TMDB authentication
│       ├── tmdb_service.dart          # TMDB API calls
│       ├── tmdb_user_service.dart     # User interactions (rating, favorite, watchlist)
│       └── watch_list_service.dart    # Watchlist management
└── main.dart
```

## 🚀 Cài đặt và chạy

### Yêu cầu
- Flutter SDK ^3.9.2
- Dart SDK
- Android Studio / VS Code
- Firebase project
- TMDB API key

### Các bước cài đặt

1. **Clone repository**
```bash
git clone https://github.com/huudat31/movie.git
cd movie
```

2. **Cài đặt dependencies**
```bash
flutter pub get
```

3. **Cấu hình Firebase**
- Tạo project trên [Firebase Console](https://console.firebase.google.com/)
- Thêm ứng dụng Android/iOS
- Tải file `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
- Đặt vào thư mục tương ứng

4. **Cấu hình TMDB API**
- Đăng ký tài khoản tại [TMDB](https://www.themoviedb.org/)
- Lấy API key và Access Token
- Tạo file `assets/.env`:
```env
TMDB_API_KEY=your_api_key_here
TMDB_ACCESS_TOKEN=your_access_token_here
TMDB_BASE_URL=https://api.themoviedb.org/3
```

5. **Cấu hình VNPay**
- Sử dụng thông tin Sandbox trong `vnpay_service.dart`
- Hoặc đăng ký tài khoản VNPay merchant để lấy thông tin thật

6. **Chạy ứng dụng**
```bash
flutter run
```

## 🔑 Tính năng nổi bật

### 1. Tích hợp TMDB API đầy đủ
- Sử dụng TMDB API v3 với Bearer Token authentication
- Hỗ trợ đầy đủ các endpoint: movies, TV shows, search, genres, credits, videos, reviews
- Quản lý session và account states
- Đồng bộ rating, favorites, watchlist với tài khoản TMDB

### 2. Hệ thống đặt vé thông minh
- Tự động tạo lịch chiếu từ Firebase Firestore dựa trên phim "Now Playing"
- Quản lý ghế ngồi real-time
- Tích hợp thanh toán VNPay với bảo mật cao
- Tạo mã QR cho vé đã đặt

### 3. State Management với BLoC
- Sử dụng pattern BLoC/Cubit cho quản lý trạng thái
- Tách biệt business logic và UI
- Dễ dàng test và maintain

### 4. Xác thực đa nền tảng
- Firebase Authentication cho email/password
- Google Sign-In
- Facebook Login
- Quản lý session tự động

## 📸 Screenshots

*(Thêm screenshots của ứng dụng tại đây)*

## 🔐 Bảo mật

- Sử dụng HTTPS cho tất cả API calls
- Bearer Token authentication cho TMDB
- HMAC-SHA512 cho VNPay
- Firebase Security Rules cho Firestore
- Biến môi trường được lưu trong `.env` (không commit lên Git)

## 🐛 Known Issues

- VNPay return URL cần được cấu hình với server thực tế cho production
- Một số video trailer có thể không khả dụng do giới hạn vùng

## 🔮 Tính năng tương lai

- [ ] Hỗ trợ đa ngôn ngữ (i18n)
- [ ] Dark mode
- [ ] Thông báo push cho phim mới
- [ ] Chia sẻ phim lên mạng xã hội
- [ ] Xem lịch sử xem phim
- [ ] Gợi ý phim dựa trên sở thích

## 👨‍💻 Tác giả

Phát triển bởi [Tên của bạn]

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [The Movie Database (TMDB)](https://www.themoviedb.org/) - API dữ liệu phim
- [Firebase](https://firebase.google.com/) - Backend services
- [VNPay](https://vnpay.vn/) - Payment gateway
- [Flutter](https://flutter.dev/) - UI framework
