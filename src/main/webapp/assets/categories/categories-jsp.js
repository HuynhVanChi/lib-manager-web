document.addEventListener("DOMContentLoaded", function () {

    // Xử lý nạp dữ liệu cho Modal Xóa
    const deleteButtons = document.querySelectorAll(".btn-delete-trigger");
    deleteButtons.forEach(btn => {
        btn.addEventListener("click", function () {
            const id = this.getAttribute("data-id");
            const name = this.getAttribute("data-name");

            document.getElementById("deleteCategoryId").value = id;
            document.getElementById("deleteCategoryName").textContent = name;

            const deleteModal = new bootstrap.Modal(document.getElementById("deleteCategoryModal"));
            deleteModal.show();
        });
    });


});
