function buildBaseSubscriptionUrl() {
    const domain = CONFIG.domain || window.location.origin;
    return domain + CONFIG.path;
}
const baseSubscriptionUrl = buildBaseSubscriptionUrl();

const platformData = {
    windows: {
        apps: [
            { name: "V2RayN", url: "https://github.com/2dust/v2rayN/releases/download/7.15.7/v2rayN-windows-64-SelfContained.zip", action: "manual", client: "xray" },
            { name: "FlClash", url: "https://github.com/chen08209/FlClash/releases/download/v0.8.90/FlClash-0.8.90-windows-amd64.zip", scheme: "flclash://install-config?url=", client: "mihomo" }
        ]
    },
    android: {
        apps: [
            { name: "V2RayNG", url: "https://github.com/2dust/v2rayNG/releases/download/1.10.26/v2rayNG_1.10.26_universal.apk", scheme: "v2rayng://install-sub/?url=", client: "xray", needsEncode: true },
            { name: "FlClash", url: "https://github.com/chen08209/FlClash/releases/download/v0.8.90/FlClash-0.8.90-android-arm64-v8a.apk", scheme: "flclash://install-config?url=", client: "mihomo" },
            { name: "Happ", url: "https://play.google.com/store/apps/details?id=com.happproxy", scheme: "happ://add/", client: "xray" }
        ]
    },
    ios: {
        apps: [
            { name: "Streisand", url: "https://apps.apple.com/us/app/streisand/id6450534064", scheme: "streisand://import/", client: "xray", useHash: true },
            { name: "V2Box", url: "https://apps.apple.com/us/app/v2box-v2ray-client/id6446814690", scheme: "v2box://install-sub?url=", client: "xray", useName: true },
            { name: "Happ", url: "https://apps.apple.com/us/app/happ-proxy-utility/id6504287215", scheme: "happ://add/", client: "xray" }
        ]
    },
    manual: {
        apps: [
            { name: "Xray", action: "manual", client: "xray" },
            { name: "Clash", action: "manual", client: "mihomo" }
        ]
    }
};

function updatePlatformContent() {
    const platform = document.getElementById("platformSelect").value;
    const platformContent = document.getElementById("platformContent");
    const appButtons = document.getElementById("appButtons");
    const qrContainer = document.getElementById("qrcode");

    platformContent.innerHTML = "";
    appButtons.innerHTML = "";
    qrContainer.innerHTML = "";
    qrContainer.classList.remove("active");

    if (platformData[platform]) {
        const apps = platformData[platform].apps;
        let contentHTML = "";
        let buttonsHTML = "";

        if (platform !== "manual") {
            contentHTML = `<h3>Скачать приложение</h3>`;
            let buttonGridHTML = `<div class="button-grid">`;
            apps.forEach((app) => {
                buttonGridHTML += `
                    <button class="button download-button" title="Скачать ${app.name}" onclick="window.open('${app.url}', '_blank')">
                        <span class="button-icon">⬇</span> ${app.name}
                    </button>
                `;
            });
            buttonGridHTML += `</div>`;
            contentHTML += `<div class="app-section">${buttonGridHTML}</div>`;
        }

        apps.forEach(app => {
            buttonsHTML += `
                <div class="app-section">
                    <h4>${app.name}</h4>
                    <div class="button-grid">
                        <button class="button mode-button" title="Базовый режим (Base64)"
                                onclick="handleImport('${app.name}', '${app.scheme || ''}', '${app.client}', '${app.action || ''}', 'base', ${app.needsEncode || false}, ${app.useHash || false}, ${app.useName || false})">
                            <span class="mode-label">BASE</span> Базовый
                        </button>
                        <button class="button mode-button" title="Расширенный режим (JSON/YAML)"
                                onclick="handleImport('${app.name}', '${app.scheme || ''}', '${app.client}', '${app.action || ''}', 'advanced', ${app.needsEncode || false}, ${app.useHash || false}, ${app.useName || false})">
                            <span class="mode-label">ADVANCED</span> Расширенный
                        </button>
                    </div>
                </div>
            `;
        });

        platformContent.innerHTML = contentHTML;
        appButtons.innerHTML = buttonsHTML;
    }
}

function buildSubscriptionUrl(client, user, mode) {
    return `${baseSubscriptionUrl}?client=${client}&user=${encodeURIComponent(user)}&mode=${mode}`;
}

// Универсальная функция для генерации deep link для конкретного приложения
function buildDeepLink(app, subscriptionUrl, displayName) {
    const scheme = app.scheme || '';
    const name = (displayName || '').trim() || 'Subscription';

    if (!scheme) return '';

    // V2RayNG: v2rayng://install-sub/?url=urlencode(SUB_URL%23NAME)
    if (app.needsEncode) {
        const fullUrl = `${subscriptionUrl}#${name}`;
        const encodedUrl = encodeURIComponent(fullUrl);
        return `${scheme}${encodedUrl}`;
    }

    // Streisand: streisand://import/SUB_URL#NAME
    if (app.useHash) {
        return `${scheme}${subscriptionUrl}#${name}`;
    }

    // V2Box: v2box://install-sub?url=urlencode(SUB_URL)&name=NAME
    if (app.useName) {
        const encodedUrl = encodeURIComponent(subscriptionUrl);
        const encodedName = encodeURIComponent(name);
        return `${scheme}${encodedUrl}&name=${encodedName}`;
    }

    // FlClash
    if (scheme.includes('flclash://')) {
        const encodedUrl = encodeURIComponent(subscriptionUrl);
        return `${scheme}${encodedUrl}`;
    }

    // Happ
    if (scheme.includes('happ://')) {
        return `${scheme}${subscriptionUrl}`;
    }

    return `${scheme}${subscriptionUrl}`;
}

function handleImport(appName, scheme, client, action, mode, needsEncode, useHash, useName) {
    const name = document.getElementById("nameInput").value.trim();
    if (!name) {
        alert("Введите имя пользователя!");
        return;
    }

    const subscriptionUrl = buildSubscriptionUrl(client, name, mode);

    if (action === 'manual') {
        showManualImportInstructions(appName, client, subscriptionUrl, mode);
        return;
    }

    if (!scheme) {
        copyToClipboard(subscriptionUrl, appName, mode);
        return;
    }

    const app = {
        scheme: scheme,
        needsEncode: !!needsEncode,
        useHash: !!useHash,
        useName: !!useName
    };

    // ← теперь имя не передаётся, deep link всегда = Subscription
    const deepLink = buildDeepLink(app, subscriptionUrl, CONFIG.subscriptionName);

    console.log('Generated deepLink:', deepLink);

    try {
        window.location.href = deepLink;
        setTimeout(() => {
            window.location.href = deepLink;
        }, 300);
    } catch (e) {
        copyToClipboard(subscriptionUrl, appName, mode);
        showNotification('Не удалось открыть приложение напрямую — ссылка скопирована.');
    }
}

function copyToClipboard(url, appName, mode) {
    const tempInput = document.createElement("input");
    tempInput.value = url;
    document.body.appendChild(tempInput);
    tempInput.select();
    document.execCommand("copy");
    document.body.removeChild(tempInput);

    showNotification(`Ссылка для ${appName} (${mode}) скопирована в буфер обмена.`);
}

function showManualImportInstructions(appName, client, url, mode) {
    const qrContainer = document.getElementById('qrcode');
    qrContainer.classList.add('active');
    qrContainer.innerHTML = `
        <div class="manual-import">
            <h3>Импорт в ${appName}</h3>
            <p class="instruction">Скопируйте ссылку или отсканируйте QR-код в приложении:</p>
            <div class="url-box">
                <input type="text" readonly value="${url}" id="manualUrl" />
                <button class="button copy-button" onclick="copyManualUrl()">Копировать</button>
            </div>
            <canvas id="qrCanvas"></canvas>
        </div>
    `;

    const canvas = document.getElementById('qrCanvas');
    QRCode.toCanvas(canvas, url, {
        width: 250,
        margin: 2,
        color: {
            dark: '#212121',
            light: '#FFFFFF'
        }
    }, function (error) {
        if (error) console.error('Ошибка генерации QR-кода', error);
    });
}

function copyManualUrl() {
    const urlInput = document.getElementById('manualUrl');
    urlInput.select();
    document.execCommand("copy");
    showNotification('Ссылка скопирована в буфер обмена!');
}

function showNotification(message) {
    const notification = document.createElement('div');
    notification.className = 'notification';
    notification.textContent = message;
    document.body.appendChild(notification);

    setTimeout(() => {
        notification.classList.add('show');
    }, 10);

    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

window.addEventListener('DOMContentLoaded', () => {
    const params = new URLSearchParams(window.location.search);
    const name = params.get('name');
    if (name) {
        document.getElementById('nameInput').value = name;
    }
    updatePlatformContent();
});
