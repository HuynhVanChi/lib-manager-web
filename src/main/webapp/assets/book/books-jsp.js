document.addEventListener("DOMContentLoaded", function () {
    // Nạp dữ liệu cho Modal Xóa đầu sách
    const deleteBookButtons = document.querySelectorAll(".btn-delete-book");
    deleteBookButtons.forEach(btn => {
        btn.addEventListener("click", function () {
            const id = this.getAttribute("data-id");
            const title = this.getAttribute("data-title");

            document.getElementById("deleteBookId").value = id;
            document.getElementById("deleteBookTitle").textContent = title;

            const modal = new bootstrap.Modal(document.getElementById("deleteBookModal"));
            modal.show();
        });
    });
});
