document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".titoloCliccabile").forEach(button => {
        button.addEventListener("click", () => {
            const contenuto = button.nextElementSibling;
            contenuto.style.display =
                contenuto.style.display === "grid" ? "none" : "grid";
        });
    });
});
