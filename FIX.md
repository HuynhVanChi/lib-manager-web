- Bỏ nút xoá khỏi cột `hành động`, Liên quan tới lịch sử không được xoá để bảo vệ tính toàn vẹn dữ liệu.
- Làm cho danh sách bảng sát mép, không có nằm trong một khung padding hay gì hết, tham khảo trang Độc giả và các trang khác. (Cả 2 tab Mượn trả với Vi phạm)

# Cơ chế phạt
- Trả muộn phạt 5000đ/ngày, không vượt quá giá tiền. (Tiền phạt tự động tăng dần theo thời gian. VD: Trễ ngày đầu phạt 5000đ, để tới 10 ngày thì phạt 50000đ)
- Mất sách phạt tiền sách + 20000đ. (Không stack tính tiền trả muộn vào nếu báo mất)
- Hỏng sách nhẹ phạt phạt 20% tiền sách, tối thiểu 15000đ.
- Hỏng nặng phạt 80% tiền sách.
- LƯU Ý: Khi Stack 2 loại Trễ + Hỏng thì số tiền phạt không quá tiền phạt mất sách.

# Tab Mượn trả sách
- Chuyển cách sắp xếp thành sắp theo phiếu mới nhất tới cũ nhất (từ trên xuống).
- Thẻ trạng thái trong cột trạng thái căn giữa.
- Chuyển cột `Mã phiếu` thành `ID`.
- Bảng quá nhiều cột, thiếu nút hành động nhanh ở cột hành động.
  + Gộp cột `Tên sách` và `Mã sách` thành `Sách mượn` trong đó hiển thị Tên sách ở trên, mã sách ở dưới.
  + Gộp cột `Ngày mượn` và `Ngày phải trả` thành `Thòi hạn mượn` trong đó hiển thị ngày mượn ở trên, ngày trả ở dưới, ngày mượn chỉ hiển thị ngày, ngày trả hiển thị theo cú pháp `Hạn: <Ngày>`.
  + Gộp cột `Ngày trả` VÀO cột `Trạng thái`, khi trạng thái là đã trả thì hiển thị theo thiết kế trạng thái `Đã trả - <Ngày trả thực>`. Trạng thái `Quá hạn` thiết kế lại thành dạng tự động chuyển từ `Đang mượn` sang `Quá hạn` và trạng thái này không có trong dropdown chỉnh sửa mà được đại diện bởi trạng thái `Đang mượn`.
  + Thêm 1 cột `Tác vụ` chứa 2 nút `Trả` và `Mất`, khi bấm sẽ mở modal tương ứng. Thiết kế nút full màu xanh và đỏ, hiệu ứng giống nút tạo phiéu mượn (khi hover có shadow, glow chỉ là màu theo màu nút thay vì màu tím). Khi trạng thái là `Đã trả` hoặc `báo mất` thì 2 nút này chuyển xám và không bấm được. 
  + Cột `Hành động` cho căn giữa và làm cho bộ nút căn giữa.

## Tạo phiếu mượn
- Breadcrum thiêu icon cho phần gốc.
- Input `Chọn độc giả` không tìm kiếm được độc giả.
- Input `Ngày hạn mượn` chuyển thành `Thời hạn mượn`, thay đổi thiết kế thành 2 input: số để nhập số và dạng thời gian Ngày hoặc Tháng và tối đa là 3 tháng. Cho chiều ngang vừa đủ, không ép ngang 100%. Nên thiết kế thêm preset (7 ngày, 14 ngày, 1 tháng,....) khi bấm sẽ tự động điền lên. Lưu ý bỏ dòng chữ xám ở dưới. Ở title `Thời hạn mượn` note thêm tối đa 3 tháng.

## Xem phiếu mượn
- Breadcrumb thiếu icon cho phần gốc.
- `Trạng thái phiếu`, `Hiện trạng sách` ép không cho xuống dòng.
- Chia phần thông tin ở trên thành 2 cột hẳn hoi, đường ngăn cách phải thẳng 1 đường từ trên xuống

## Chỉnh sửa phiếu mượn
- Breadcrumb thiếu icon cho phần gốc.
- Dòng độc giả và sách mượn không cho focus, làm mờ chữ trong input đó đi.
- Input `Hạn phải trả` giữ nguyên dạng Date Picker.
- Loại bỏ nút `Xác nhận trả sách` ở trên banner.
- Chỉnh bảng Quy định phạt vi phạm lại với thiết kế mới.

---

# Tab Vi phạm & Phí phạt
- Chuyển cách sắp xếp theo từ mới nhất tới cũ nhất (từ trên xuống).
- Thẻ trạng thái trong cột trạng thái căn giữa. 
- Chỉnh sửa cột:
  + Cột `Độc giả` giống ở trên.
  + Cột `Tên sách` thành `Sách mượn` và thiết kế giống ở trên.
  + Gộp cột `Ngày đóng` vào cột trạng thái, cột trạng thái khi ở trạng thái `Đã đóng` thì sẽ theo cấu trúc `Đã đóng - <Ngày đóng>`. 
  + Bỏ nút `Sửa` ở cột `Hành động` vì phiếu phạt tự động tính tiền nên không có vụ chỉnh sửa.
  + Thêm nút `Thu tiền` cho hành động thu tiền phạt, khi bấm vào sẽ mở modal thu tiền gồm thông tin tên, sách, tiền phạt ở dạng xem vì đã cơ chế phạt đã được tự động tạo số tiền theo quy tắc, tiếp theo là mục miễn giảm theo các mốc 100%, 50%, 20%, thủ thư sẽ xem xét có miễn giảm hay không, cơ chế hoạt động của miễn giảm là áp dụng lên tổng số tiền bị phạt của phiếu mượn đó. Thiết kế nút màu xanh lá có icon và title, hiệu ứng giống có shadow, glow, motion giống nút primary, chỉ khác màu.
  + Thêm nút `Hoàn tác` ở cột `Hành động`chỉ xuất hiện khi phiếu phạt đã ở trạng thái đã đóng hoặc đã miễn giảm, khi bấm sẽ hiện modal xác nhận và yêu cầu nhập lý do hoàn tác, khi bấm xác nhận sẽ chuyển trạng thái phiếu phạt đó về trạng thái chưa đóng, nhớ ghi log cho hành vi này vào nhật ký hệ thống. (Thay thế vị trí của nút `Thu tiền` chứ không nằm ngoài )
  + Cột `Hành động` cho căn giữa và làm cho bộ nút căn giữa.