# Quản lý bệnh án bệnh nhân sử dụng Hyperledger Fabric

## Các chức năng có trong dự án

- Đăng ký/đăng nhập User
- Thêm thông tin bệnh nhân
- Chỉnh sửa thông tin bệnh nhân
- Tìm kiếm thông tin bệnh nhân
- Thêm hồ sơ bệnh án (Private data)
- Tải file (File tải lên được mã hoá vào IPFS)
- Đọc file từ IPFS

## Cài đặt

- Cài đặt phiên bản docker mới nhất
- Cài đặt phiên bản NodeJS v18.x
- Cài đặt phiên bản Go mới nhất (ở dự án này đang sử dụng Go v19.0)

## Các sử dụng

### Fabric Network setup:

Chọn phiên bản Fabric Binary and CA:
Theo mặc định, phiên bản Fabric Binary là 2.5.3 và phiên bản CA là 1.5.6. Bạn có thể thay đổi phiên bản Fabric và CA cần thiết trong network/local > start.sh.

**Khởi chạy mạng**

1. Mở một cửa số terminal mới
2. Đi đến thư mục network > local bằng lệnh `cd network/local`
3. Chạy lệnh `./init.sh`. Tệp này chứa các lệnh để cấp quyền truy cập đọc/ghi vào thư mục gốc của dự án. Chỉ sử dụng lệnh này cho lần chạy đầu tiên. Sau đó khởi động mạng bằng lệnh `./start.sh`.

Nếu bạn gặp bất kỳ lỗi nào khi khởi động mạng lần đầu tiên, hãy dừng tất cả các docker bằng lệnh `./network.sh down` và khởi động lại bằng lệnh `./start.sh`

- Mở tệp chaincode > collections_config.json file để cấu hình chính sách chia sẻ dữ liệu riêng tư (private) giữa các tổ chức (orgs).
- Để tắt mạng, hãy chạy lệnh `./network.sh down`

### Node.js Server Application:

1. Mở một cửa sổ terminal mới
2. ĐI đến thư mục **server-api** bằng lệnh `cd server-api`
3. Chạy lệnh `npm install`
4. Chạy lệnh `npm start`

### IPFS service:

1. Mở một cửa sổ terminal mới
2. ĐI đến thư mục **helia-server** bằng lệnh `cd server-api`
3. Chạy lệnh `npm install`
4. Chạy lệnh `npm start`

### Client Application:

1. Mở một cửa sổ terminal mới
2. ĐI đến thư mục **client-ui** bằng lệnh `cd server-api`
3. Chạy lệnh `npm install`
4. Chạy lệnh `npm start`

Ứng dụng sẽ được chạy tại [http://localhost:5173/](http://localhost:5173/)
