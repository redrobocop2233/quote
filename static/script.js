const RASA_SERVER_URL = 'https://your-app-name.onrender.com/webhooks/rest/webhook';
let sessionId = 'user_' + Date.now() + '_' + Math.random().toString(36).substring(7);
let conversationStarted = false;

document.addEventListener('DOMContentLoaded', function() {
    console.log('✅ Ultimate QuoteBot frontend loaded');
    document.getElementById('userInput').focus();
    attachEventListeners();
});

function attachEventListeners() {
    document.getElementById('userInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') sendUserMessage();
    });
}

function hideWelcome() {
    if (!conversationStarted) {
        document.getElementById('welcomeScreen')?.classList.add('hidden');
        document.getElementById('chatMessages')?.classList.remove('hidden');
        document.getElementById('quickActions')?.classList.remove('hidden');
        conversationStarted = true;
    }
}

function addMessage(text, isUser = false) {
    hideWelcome();
    
    const messagesContainer = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${isUser ? 'user' : 'bot'}`;
    
    const avatar = document.createElement('div');
    avatar.className = 'message-avatar';
    avatar.innerHTML = isUser ? '<i class="fas fa-user"></i>' : '<i class="fas fa-robot"></i>';
    
    const content = document.createElement('div');
    content.className = 'message-content';
    content.textContent = text;
    
    const time = document.createElement('div');
    time.className = 'message-time';
    time.textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    content.appendChild(time);
    
    if (!isUser) messageDiv.appendChild(avatar);
    messageDiv.appendChild(content);
    if (isUser) messageDiv.appendChild(avatar);
    
    messagesContainer.appendChild(messageDiv);
    scrollToBottom();
}

function addTypingIndicator() {
    document.getElementById('typingIndicator').style.display = 'block';
    scrollToBottom();
}

function removeTypingIndicator() {
    document.getElementById('typingIndicator').style.display = 'none';
}

function scrollToBottom() {
    const messagesContainer = document.getElementById('chatMessages');
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

async function sendToRasa(message) {
    try {
        const response = await fetch(RASA_SERVER_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ sender: sessionId, message: message })
        });

        if (!response.ok) throw new Error(`Rasa server error: ${response.status}`);

        const data = await response.json();
        removeTypingIndicator();

        if (data && data.length > 0) {
            data.forEach(msg => {
                if (msg.text) addMessage(msg.text, false);
            });
        }
    } catch (error) {
        console.error('Error:', error);
        removeTypingIndicator();
        addMessage("⚠️ Cannot connect to the bot. Please try again later.", false);
    }
}

function sendUserMessage() {
    const input = document.getElementById('userInput');
    const message = input.value.trim();
    
    if (message) {
        addMessage(message, true);
        addTypingIndicator();
        sendToRasa(message);
        input.value = '';
    }
}

function sendMessage(text) {
    addMessage(text, true);
    addTypingIndicator();
    sendToRasa(text);
}

function sendCategory(category) {
    const messages = {
        'motivation': 'motivate me',
        'love': 'love quote',
        'humor': 'tell me a joke',
        'wisdom': 'give me wisdom'
    };
    sendMessage(messages[category] || `I want ${category} quotes`);
}

function sendEmotion(emotion) {
    const messages = {
        'happy': "I'm feeling happy today",
        'sad': "I feel sad",
        'stressed': "I'm stressed",
        'tired': "I'm tired"
    };
    sendMessage(messages[emotion] || `I feel ${emotion}`);
}

// Make functions global
window.sendCategory = sendCategory;
window.sendEmotion = sendEmotion;
window.sendMessage = sendMessage;
window.sendUserMessage = sendUserMessage;