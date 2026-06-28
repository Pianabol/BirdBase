// CHAT ELEMENTS
const chatScreen = document.getElementById("chat-screen");
const chatBox = document.getElementById("chat-box");
const chatInput = document.getElementById("chat-input");
const chatSendBtn = document.getElementById("chat-send-btn");
const chatBackBtn = document.getElementById("chat-back-btn");

// ------------------- ELEMENTS -------------------
const uploadScreen = document.getElementById("upload-screen");
const resultScreen = document.getElementById("result-screen");

const fileInput = document.getElementById("file-upload");
const previewBox = document.getElementById("preview-box");
const previewImg = document.getElementById("preview-image");
const previewName = document.getElementById("preview-name");
const analyzeBtn = document.getElementById("analyze-btn");
const chatbotBtn = document.getElementById("chatbot-btn"); 

const detectedImg = document.getElementById("detected-image");
const detList = document.getElementById("det-list");
const backBtn = document.getElementById("back-btn");
const askExpertBtn = document.getElementById("ask-expert-btn"); 

let lastDetectedBird = ""; 

// Chat history array for context
let chatHistory = []; 

// INFO CARD ELEMENTS
const infoCard = document.getElementById("info-card");
const infoName = document.getElementById("info-name");
const infoHabitat = document.getElementById("info-habitat");
const infoLifespan = document.getElementById("info-lifespan");
const infoDesc = document.getElementById("info-desc");

// ------------------- HELPERS -------------------
function resetResultUI() {
    detList.innerHTML = "";
    detectedImg.src = "";

    infoCard.style.display = "none";
    infoName.textContent = "";
    infoHabitat.textContent = "";
    infoLifespan.textContent = "";
    infoDesc.textContent = "";
}

function resetUploadUI() {
    previewImg.src = "";
    previewName.textContent = "";
    previewBox.style.display = "none";
    fileInput.value = "";
}

function showResultScreen() {
    uploadScreen.classList.remove("fade-in", "fade-out");
    resultScreen.classList.remove("fade-in", "fade-out");

    uploadScreen.classList.add("fade-out");

    setTimeout(() => {
        uploadScreen.style.display = "none";

        resultScreen.style.display = "block";
        resultScreen.classList.remove("fade-out");
        resultScreen.classList.add("fade-in");
    }, 300);
}

function showUploadScreen() {
    uploadScreen.classList.remove("fade-in", "fade-out");
    resultScreen.classList.remove("fade-in", "fade-out");

    resultScreen.classList.add("fade-out");

    setTimeout(() => {
        resultScreen.style.display = "none";

        uploadScreen.style.display = "block";
        uploadScreen.classList.add("fade-in");
    }, 300);
}

// ------------------- PREVIEW -------------------
fileInput.addEventListener("change", () => {
    const file = fileInput.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = () => {
        previewImg.src = reader.result;
        previewName.textContent = file.name;
        previewBox.style.display = "block";
    };
    reader.readAsDataURL(file);
});

// ------------------- ANALYZE -------------------
analyzeBtn.addEventListener("click", async () => {
    const file = fileInput.files[0];
    if (!file) {
        alert("Please select a photo first.");
        return;
    }

    const originalBtnText = analyzeBtn.textContent;
    analyzeBtn.textContent = "Analyzing... ⏳";
    analyzeBtn.disabled = true;
    analyzeBtn.style.opacity = "0.7"; 
    analyzeBtn.style.cursor = "not-allowed";
    analyzeBtn.style.backgroundColor = ""; 

    resetResultUI();

    const formData = new FormData();
    formData.append("image", file);

    let data;
    try {
        const response = await fetch("http://127.0.0.1:8000/predict", {
            method: "POST",
            body: formData
        });
        data = await response.json();
    } catch (err) {
        showResultScreen();
        detectedImg.src = previewImg.src;
        detList.innerHTML = `
            <li style="list-style:none; font-size:16px; font-weight:600; color:#c0392b; margin-top:15px;">
                API connection error. Ensure the backend is running.
            </li>
        `;
        return;
    } finally {
        analyzeBtn.textContent = originalBtnText;
        analyzeBtn.disabled = false;
        analyzeBtn.style.opacity = "1";
        analyzeBtn.style.cursor = "pointer";
        analyzeBtn.style.backgroundColor = ""; 
    }

    showResultScreen();

    // ---- NO DETECTION ----
    if (!data.detections || data.detections.length === 0) {
        detectedImg.src = previewImg.src;

        detList.innerHTML = `
            <li style="list-style:none; font-size:16px; font-weight:600; color:#c0392b; margin-top:15px;">
                No birds detected in the image.
            </li>
        `;

        infoCard.style.display = "none";
        return;
    }

    // ---- DETECTION FOUND ----
    detectedImg.src = "http://127.0.0.1:8000" + data.output_image;
    lastDetectedBird = data.detections[0].class; 

    // O eski forEach döngüsünü uçurduk. Yerine Python'dan gelen hazır mesajı tek satırda basıyoruz.
    // CSS'in white-space özelliği \n (alt satıra geçme) komutlarını ekranda düzgün gösterir.
    detList.innerHTML = `
        <li style="list-style:none; font-size:16px; font-weight:600; color:#222; white-space: pre-wrap; line-height: 1.5;">
            ${data.message}
        </li>
    `;

    // INFO CARD
    if (data.bird_info) {
        infoName.textContent = data.bird_info.name ?? "";
        infoHabitat.textContent = data.bird_info.habitat ?? "";
        infoLifespan.textContent = data.bird_info.lifespan ?? "";
        infoDesc.textContent = data.bird_info.description ?? "";
        infoCard.style.display = "block";
    } else {
        infoCard.style.display = "none";
    }
});

// ------------------- BACK -------------------
backBtn.addEventListener("click", () => {
    resetResultUI();
    resetUploadUI();
    showUploadScreen();
});

// ------------------- CHATBOT LOGIC -------------------

chatbotBtn.addEventListener("click", () => {
    uploadScreen.classList.remove("fade-in", "fade-out");
    uploadScreen.classList.add("fade-out");

    setTimeout(() => {
        uploadScreen.style.display = "none";
        chatScreen.style.display = "block";
        chatScreen.classList.remove("fade-out");
        chatScreen.classList.add("fade-in");
    }, 300);
});

chatBackBtn.addEventListener("click", () => {
    chatScreen.classList.remove("fade-in", "fade-out");
    chatScreen.classList.add("fade-out");

    setTimeout(() => {
        chatScreen.style.display = "none";
        uploadScreen.style.display = "block";
        uploadScreen.classList.add("fade-in");
    }, 300);
});

function appendMessage(sender, text) {
    const msgDiv = document.createElement("div");
    msgDiv.classList.add("chat-message");
    
    if (sender === "user") {
        msgDiv.classList.add("msg-user");
    } else {
        msgDiv.classList.add("msg-bot");
    }
    
    msgDiv.textContent = text;
    chatBox.appendChild(msgDiv);
    
    chatBox.scrollTop = chatBox.scrollHeight;
}

// Memory-enabled chat sending
async function sendMessage() {
    const text = chatInput.value.trim();
    if (!text) return;

    appendMessage("user", text);
    chatInput.value = "";
    
    chatSendBtn.disabled = true;
    chatSendBtn.style.opacity = "0.7";

    // --- CONTEXT BUILDING ---
    let promptToSend = text;
    
    if (chatHistory.length > 0) {
        promptToSend = "Below is a summary of our previous conversation. Please remember the context and answer only my latest question:\n\n";
        
        let startIndex = chatHistory.length > 4 ? chatHistory.length - 4 : 0;
        for (let i = startIndex; i < chatHistory.length; i++) {
            promptToSend += `${chatHistory[i].role}: ${chatHistory[i].text}\n`;
        }
        
        promptToSend += `\nCurrent Question: ${text}`;
    }

    chatHistory.push({ role: "User", text: text });

    const loadingId = "loading-" + Date.now();
    const loadingDiv = document.createElement("div");
    loadingDiv.id = loadingId;
    loadingDiv.classList.add("chat-message", "msg-bot");
    loadingDiv.textContent = "Thinking... ⏳";
    chatBox.appendChild(loadingDiv);
    chatBox.scrollTop = chatBox.scrollHeight;

    try {
        const response = await fetch("http://127.0.0.1:8000/chat", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ text: promptToSend }) 
        });
        
        const data = await response.json();
        
        document.getElementById(loadingId).remove();
        
        if (data.success) {
            appendMessage("bot", data.reply);
            chatHistory.push({ role: "Avian Expert", text: data.reply });
        } else {
            appendMessage("bot", "An error occurred: " + data.reply);
        }
        
    } catch (err) {
        document.getElementById(loadingId).remove();
        appendMessage("bot", "API connection error. Ensure the backend is running.");
    } finally {
        chatSendBtn.disabled = false;
        chatSendBtn.style.opacity = "1";
        chatInput.focus();
    }
}

chatSendBtn.addEventListener("click", sendMessage);

chatInput.addEventListener("keypress", (e) => {
    if (e.key === "Enter") {
        sendMessage();
    }
});


// ------------------- ASK EXPERT (BRIDGE) -------------------
askExpertBtn.addEventListener("click", () => {
    if (!lastDetectedBird) return;

    resultScreen.classList.remove("fade-in", "fade-out");
    resultScreen.classList.add("fade-out");

    setTimeout(() => {
        resultScreen.style.display = "none";
        chatScreen.style.display = "block";
        chatScreen.classList.remove("fade-out");
        chatScreen.classList.add("fade-in");

        chatInput.value = `Give me some brief information about ${lastDetectedBird}.`;

        sendMessage();
    }, 300);
});