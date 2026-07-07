document.addEventListener("DOMContentLoaded", function () {
    // 1. Sự kiện sửa Bản sao (cuốn sách)
    const editCopyTriggers = document.querySelectorAll(".btn-edit-copy-trigger");
    editCopyTriggers.forEach(btn => {
        btn.addEventListener("click", function () {
            const id = this.getAttribute("data-id");
            const barcode = this.getAttribute("data-barcode");
            const location = this.getAttribute("data-location");
            const status = this.getAttribute("data-status");

            document.getElementById("editCopyId").value = id;
            document.getElementById("editCopyBarcodeLabel").textContent = barcode;
            document.getElementById("editCopyLocation").value = location;
            
            const selectStatus = document.getElementById("editCopyStatus");
            const optionBorrowed = document.getElementById("optionBorrowed");
            const borrowedWarning = document.getElementById("borrowedWarning");

            selectStatus.value = status;

            // TƯ DUY PHẢN BIỆN: Nếu trạng thái là Borrowed, khóa lựa chọn status, mở cảnh báo
            if (status === "Borrowed") {
                optionBorrowed.removeAttribute("disabled"); // Cho phép hiển thị giá trị hiện tại
                selectStatus.setAttribute("disabled", "true"); // Khóa select
                // Để form vẫn gửi được field status lên server khi submit, ta nên tạo 1 hidden input hoặc tạm thời mở khóa khi submit.
                // Một mẹo chuẩn là: trước khi form submit, ta gỡ bỏ disabled hoặc dùng hidden input.
                borrowedWarning.classList.remove("d-none");
            } else {
                optionBorrowed.setAttribute("disabled", "true"); // Khóa không cho chọn Borrowed thủ công
                selectStatus.removeAttribute("disabled");
                borrowedWarning.classList.add("d-none");
            }

            const modal = new bootstrap.Modal(document.getElementById("editCopyModal"));
            modal.show();
        });
    });

    // Mẹo chuẩn: Trước khi submit form edit copy, nếu selectStatus bị disabled thì ta mở khóa tạm thời để giá trị gửi lên server
    const editCopyForm = document.getElementById("editCopyForm");
    if (editCopyForm) {
        editCopyForm.addEventListener("submit", function () {
            const selectStatus = document.getElementById("editCopyStatus");
            if (selectStatus) {
                selectStatus.removeAttribute("disabled");
            }
        });
    }

    // 2. Sự kiện xóa Bản sao (cuốn sách)
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
