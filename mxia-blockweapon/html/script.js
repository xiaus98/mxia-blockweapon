let maxDuration = 10;
let currentTime = 10;

window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'showCooldown':
            showCooldown(data.duration, data.maxDuration);
            break;
        case 'updateTime':
            updateTime(data.time);
            break;
        case 'hideCooldown':
            hideCooldown();
            break;
    }
});

function showCooldown(duration, max) {
    maxDuration = max;
    currentTime = duration;
    
    const container = document.getElementById('cooldown-container');
    const timeDisplay = document.getElementById('timeDisplay');
    const progressBar = document.getElementById('progressBar');
    
    // Show container
    container.classList.remove('hidden');
    container.classList.add('visible');
    
    // Set initial time
    timeDisplay.textContent = duration;
    
    // Set progress bar to full
    progressBar.style.width = '100%';
}

function updateTime(time) {
    currentTime = time;
    
    const timeDisplay = document.getElementById('timeDisplay');
    const progressBar = document.getElementById('progressBar');
    
    // Update time display
    timeDisplay.textContent = time;
    
    // Update progress bar
    const percentage = (time / maxDuration) * 100;
    progressBar.style.width = percentage + '%';
    
    // Add pulsing effect when time is low
    if (time <= 3 && time > 0) {
        timeDisplay.style.animation = 'pulse-time 0.5s ease-in-out infinite';
    } else {
        timeDisplay.style.animation = 'none';
    }
}

function hideCooldown() {
    const container = document.getElementById('cooldown-container');
    
    container.classList.remove('visible');
    container.classList.add('hidden');
}

// Add pulse animation for low time
const style = document.createElement('style');
style.textContent = `
    @keyframes pulse-time {
        0%, 100% {
            transform: scale(1);
            color: #ffffff;
        }
        50% {
            transform: scale(1.1);
            color: #ff1493;
        }
    }
`;
document.head.appendChild(style);