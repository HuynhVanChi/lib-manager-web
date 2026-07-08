document.addEventListener("DOMContentLoaded", function () {
    // Các phần tử DOM của Form nhập/sửa
    const copyForm = document.getElementById("copyForm");
    const copyFormCard = document.getElementById("copyFormCard");
    const copyFormHeader = document.getElementById("copyFormHeader");
    const copyFormIcon = document.getElementById("copyFormIcon");
    const copyFormTitle = document.getElementById("copyFormTitle");
    
    const formCopyId = document.getElementById("formCopyId");
    const formLocationShelf = document.getElementById("formLocationShelf");
    const formQuantityGroup = document.getElementById("formQuantityGroup");
    const formQuantity = document.getElementById("formQuantity");
    const formStatusGroup = document.getElementById("formStatusGroup");
    const formCopyStatus = document.getElementById("formCopyStatus");
    const optionBorrowed = document.getElementById("optionBorrowed");
    const borrowedWarning = document.getElementById("borrowedWarning");
    const formPrice = document.getElementById("formPrice");
    const defaultBookPrice = formPrice ? formPrice.value : "0";
    
    const btnCancelEdit = document.getElementById("btnCancelEdit");
    const btnSubmitForm = document.getElementById("btnSubmitForm");
    const btnSubmitIcon = document.getElementById("btnSubmitIcon");
    const btnSubmitText = document.getElementById("btnSubmitText");
    const formBarcodeHint = document.getElementById("formBarcodeHint");

    // Lọc các hàng trong bảng để hỗ trợ highlight
    const tableRows = document.querySelectorAll("tbody tr");

    // Hàm chuyển sang Chế độ Thêm mới (Mặc định)
    function switchToAddMode() {
        // Reset Form & Action URL
        copyForm.action = contextPath + "/books?action=insertCopy";
        formCopyId.value = "";
        formLocationShelf.value = "";
        formQuantity.value = "1";
        if (formPrice) {
            formPrice.value = defaultBookPrice;
        }
        
        // Reset Header & Style
        copyFormHeader.style.background = ""; // về default của class CSS
        copyFormCard.style.borderColor = "rgba(0,0,0,.08)";
        copyFormIcon.className = "fa-solid fa-circle-plus fs-5 text-white";
        copyFormTitle.textContent = "Nhập nhanh bản sao mới";
        
        // Ẩn/Hiện các trường tương ứng
        formQuantityGroup.classList.remove("d-none");
        formQuantity.setAttribute("required", "true");
        formStatusGroup.classList.add("d-none");
        formCopyStatus.value = "Available";
        borrowedWarning.classList.add("d-none");
        formBarcodeHint.classList.remove("d-none");
        
        // Ẩn/Hiện nút Hủy & Đổi nút Submit
        btnCancelEdit.classList.add("d-none");
        btnSubmitIcon.className = "fa-solid fa-plus me-1";
        btnSubmitText.textContent = "Xác nhận nhập kho";
        btnSubmitForm.className = "btn btn-save hover-lift w-100 py-2.5";
        
        // Xóa Highlight trên bảng
        tableRows.forEach(row => {
            row.style.backgroundColor = "";
        });
    }

    // 1. Sự kiện khi click nút Sửa trên dòng bản sao
    const editCopyTriggers = document.querySelectorAll(".btn-edit-copy-trigger");
    editCopyTriggers.forEach(btn => {
        btn.addEventListener("click", function () {
            const id = this.getAttribute("data-id");
            const barcode = this.getAttribute("data-barcode");
            const location = this.getAttribute("data-location");
            const status = this.getAttribute("data-status");
            const price = this.getAttribute("data-price");

            // Điền dữ liệu vào form
            formCopyId.value = id;
            formLocationShelf.value = location;
            formCopyStatus.value = status;
            if (formPrice && price) {
                formPrice.value = price;
            }

            // Thiết lập Action URL của form sang updateCopy
            copyForm.action = contextPath + "/books?action=updateCopy";

            // Đổi giao diện header thành màu Warning cam nổi bật
            copyFormHeader.style.background = "linear-gradient(135deg, #f57c00 0%, #e65100 100%)";
            copyFormCard.style.borderColor = "#f57c00";
            copyFormIcon.className = "fa-solid fa-pen-to-square fs-5 text-white";
            copyFormTitle.textContent = "Cập nhật bản sao: " + barcode;

            // Ẩn trường Số lượng (vì sửa 1 bản sao duy nhất)
            formQuantityGroup.classList.add("d-none");
            formQuantity.removeAttribute("required");

            // Hiện trường Trạng thái bản sao
            formStatusGroup.classList.remove("d-none");
            formBarcodeHint.classList.add("d-none"); // Ẩn hint sinh barcode

            // Khóa/Mở khóa trạng thái dựa trên Borrowed (Tư duy phản biện bảo vệ dữ liệu)
            if (status === "Borrowed") {
                optionBorrowed.removeAttribute("disabled"); // Cho phép chọn Borrowed nếu nó đang là Borrowed
                formCopyStatus.setAttribute("disabled", "true"); // Khóa select để tránh sửa
                borrowedWarning.classList.remove("d-none");
            } else {
                optionBorrowed.setAttribute("disabled", "true"); // Khóa tùy chọn Borrowed
                formCopyStatus.removeAttribute("disabled");
                borrowedWarning.classList.add("d-none");
            }

            // Hiện nút Hủy sửa & Thay đổi nút Submit
            btnCancelEdit.classList.remove("d-none");
            btnSubmitIcon.className = "fa-solid fa-floppy-disk me-1";
            btnSubmitText.textContent = "Lưu thay đổi";
            btnSubmitForm.className = "btn btn-warning text-white hover-lift flex-grow-1 py-2.5";

            // Highlight dòng đang sửa và xóa highlight của các dòng khác
            tableRows.forEach(row => {
                row.style.backgroundColor = "";
            });
            const activeRow = document.getElementById("row-copy-" + id);
            if (activeRow) {
                activeRow.style.backgroundColor = "#FDF2F8"; // Nền màu hồng nhạt/vàng nhạt sang trọng
                activeRow.scrollIntoView({ behavior: "smooth", block: "nearest" });
            }
        });
    });

    // 2. Sự kiện khi click nút Hủy bỏ sửa
    if (btnCancelEdit) {
        btnCancelEdit.addEventListener("click", function () {
            switchToAddMode();
        });
    }

    // 3. Trước khi submit form, nếu selectStatus bị disabled thì ta mở khóa tạm thời để giá trị gửi lên server
    if (copyForm) {
        copyForm.addEventListener("submit", function () {
            formCopyStatus.removeAttribute("disabled");
        });
    }

    // 4. Sự kiện khi click nút Xóa bản sao
    const deleteCopyTriggers = document.querySelectorAll(".btn-delete-copy-trigger");
    deleteCopyTriggers.forEach(btn => {
        btn.addEventListener("click", function () {
            const id = this.getAttribute("data-id");
            const barcode = this.getAttribute("data-barcode");

            document.getElementById("deleteCopyId").value = id;
            document.getElementById("deleteCopyBarcode").textContent = barcode;

            const modal = new bootstrap.Modal(document.getElementById("deleteCopyModal"));
            modal.show();
        });
    });
});
