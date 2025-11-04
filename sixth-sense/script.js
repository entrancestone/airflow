// DOM elements
const video = document.getElementById("video");
const startBtn = document.getElementById("startBtn");

// Start camera when button clicked
startBtn.addEventListener("click", async () => {
    try {
        const stream = await navigator.mediaDevices.getUserMedia({
            video: { facingMode: "environment" }, // rear camera on phones
            audio: false
        });
        video.srcObject = stream;
    } catch (err) {
        alert("Camera access denied or unavailable.");
        console.error(err);
    }
});
