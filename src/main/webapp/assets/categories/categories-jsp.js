document.addEventListener("DOMContentLoaded", function () {
    // Xử lý nạp dữ liệu cho Modal Sửa
    const editButtons = document.querySelectorAll(".btn-edit-trigger");
    editButtons.forEach(btn => {
        btn.addEventListener("click", function () {
            const id = this.getAttribute("data-id");
            const name = this.getAttribute("data-name");
            const desc = this.getAttribute("data-desc");

            document.getElementById("editCategoryId").value = id;
            document.getElementById("editName").value = name;
            document.getElementById("editDescription").value = desc;

            const editModal = new bootstrap.Modal(document.getElementById("editCategoryModal"));
            editModal.show();
        });
    });

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

    // Xử lý nạp dữ liệu cho Modal Khôi phục
    const restoreButtons = document.querySelectorAll(".btn-restore-trigger");
    restoreButtons.forEach(btn => {
        btn.addEventListener("click", function () {
            const id = this.getAttribute("data-id");
            const name = this.getAttribute("data-name");

            document.getElementById("restoreCategoryId").value = id;
            document.getElementById("restoreCategoryName").textContent = name;

            const restoreModal = new bootstrap.Modal(document.getElementById("restoreCategoryModal"));
            restoreModal.show();
        });
    });
});
