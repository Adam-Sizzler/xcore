const baseDomain = "https://www.theleet.world/v2rs-subscription/sub";

const platformData = {
    windows: {
        apps: [
            { name: "V2rayN", url: "https://github.com/2dust/v2rayN/releases" },
            { name: "Invisible Man", url: "https://github.com/InvisibleManVPN/InvisibleMan-XRayClient/releases/latest", scheme: "invxray://subscription/" }
        ]
    },
    android: {
        apps: [
            { name: "V2rayNG", url: "https://play.google.com/store/apps/details?id=com.v2ray.ang", scheme: "v2rayng://install-config?url=" },
            { name: "Invisible Man", url: "https://github.com/InvisibleManVPN/InvisibleMan-XRayClient/releases/latest", scheme: "invxray://subscription/" }
        ]
    },
    ios: {
        apps: [
            { name: "V2box", url: "https://apps.apple.com/us/app/v2box-v2ray-client/id6446814690", scheme: "v2box://install-sub?url=", extra: "&name=Sub" },
            { name: "Streisand", url: "https://apps.apple.com/us/app/streisand/id6450534064", scheme: "streisand://import/" }
        ]
    },
    manual: {
        apps: [
            { name: "Copy Link", action: "copy" },
            { name: "Generate QR", action: "qr" }
        ]
    }
};

function updatePlatformContent() {
    const platform = document.getElementById("platformSelect").value;
    const platformContent = document.getElementById("platformContent");
    const appButtons = document.getElementById("appButtons");

    platformContent.innerHTML = "";
    appButtons.innerHTML = "";

    if (platformData[platform]) {
        const apps = platformData[platform].apps;
        let contentHTML = "";
        let buttonsHTML = "";

        if (platform !== "manual") {
            contentHTML = `<h3>Скачать приложение</h3>`;
            let buttonGridHTML = `<div class="button-grid${apps.length === 1 ? ' button-grid--single' : ''}">`;
            apps.forEach((app, index) => {
                buttonGridHTML += `
                    <button class="button" title="Скачать ${app.name}" onclick="window.open('${app.url}', '_blank')">${app.name}</button>
                `;
                if (index % 2 === 1 || index === apps.length - 1) {
                    buttonGridHTML += `</div>`;
                    if (index < apps.length - 1) {
                        buttonGridHTML += `<div class="button-grid${apps.length === 1 ? ' button-grid--single' : ''}">`;
                    }
                }
            });
            contentHTML += `<div class="app-section">${buttonGridHTML}</div>`;
        }

        apps.forEach(app => {
            if (app.scheme || app.action) {
                buttonsHTML += `
                    <div class="app-section">
                        <h4>${app.name}</h4>
                        <div class="button-grid">
                            <button class="button" title="${app.action === 'copy' ? 'Скопировать ссылку для Base режима' : app.action === 'qr' ? 'Сгенерировать QR-код для Base режима' : 'Добавить в ' + app.name + ' (Base)'}"
                                    onclick="${app.action === 'copy' ? 'copyXrayJsonLink' : app.action === 'qr' ? 'generateQRCode' : app.name === 'V2box' ? 'openV2boxApp' : 'openApp'}('${app.scheme || ''}', 'base')">
                                ${app.action === 'copy' ? 'Скопировать ссылку (Base)' : app.action === 'qr' ? 'Сгенерировать QR-код (Base)' : 'Добавить (Base)'}
                            </button>
                            <button class="button" title="${app.action === 'copy' ? 'Скопировать ссылку для Advanced режима' : app.action === 'qr' ? 'Сгенерировать QR-код для Advanced режима' : 'Добавить в ' + app.name + ' (Advanced)'}"
                                    onclick="${app.action === 'copy' ? 'copyXrayJsonLink' : app.action === 'qr' ? 'generateQRCode' : app.name === 'V2box' ? 'openV2boxApp' : 'openApp'}('${app.scheme || ''}', 'advanced')">
                                ${app.action === 'copy' ? 'Скопировать ссылку (Advanced)' : app.action === 'qr' ? 'Сгенерировать QR-код (Advanced)' : 'Добавить (Advanced)'}
                            </button>
                        </div>
                    </div>
                `;
            }
        });

        platformContent.innerHTML = contentHTML;
        appButtons.innerHTML = buttonsHTML;
    }
}

function generateQRCode(mode = 'advanced') {
    const name = document.getElementById('nameInput').value.trim();
    if (!name) {
        alert("Введите имя пользователя!");
        return;
    }

    const fullUrl = `${baseDomain}?user=${encodeURIComponent(name)}&mode=${mode}`;
    const qrContainer = document.getElementById('qrcode');
    qrContainer.innerHTML = '';

    const canvas = document.createElement('canvas');
    qrContainer.appendChild(canvas);

    const qrColors = {
        dark: '#000000',
        light: 'rgba(255, 255, 255, 0.1)'
    };

    QRCode.toCanvas(canvas, fullUrl, {
        width: 200,
        color: qrColors
    }, function (error) {
        if (error) {
            console.error('Ошибка генерации QR-кода', error);
        }
    });
}

function openApp(scheme, mode = 'advanced') {
    const name = document.getElementById("nameInput").value.trim();
    if (!name) {
        alert("Введите имя пользователя!");
        return;
    }
    const fullUrl = `${scheme}${baseDomain}?user=${encodeURIComponent(name)}&mode=${mode}`;
    window.open(fullUrl);
}

function openV2boxApp(scheme, mode = 'advanced') {
    const name = document.getElementById("nameInput").value.trim();
    if (!name) {
        alert("Введите имя пользователя!");
        return;
    }
    const fullUrl = `${scheme}${baseDomain}?user=${encodeURIComponent(name)}&mode=${mode}&name=Sub`;
    window.open(fullUrl);
}

function copyXrayJsonLink(mode = 'advanced') {
    const name = document.getElementById("nameInput").value.trim();
    if (!name) {
        alert("Введите имя пользователя!");
        return;
    }
    const fullUrl = `${baseDomain}?user=${encodeURIComponent(name)}&mode=${mode}`;

    const tempInput = document.createElement("input");
    tempInput.value = fullUrl;
    document.body.appendChild(tempInput);
    tempInput.select();
    document.execCommand("copy");
    document.body.removeChild(tempInput);

    alert(`Ссылка на подписку пользователя "${name}" (${mode}) скопирована в буфер обмена.`);
}

window.addEventListener('DOMContentLoaded', () => {
    const params = new URLSearchParams(window.location.search);
    const name = params.get('name');
    if (name) {
        document.getElementById('nameInput').value = name;
    }
    updatePlatformContent();
});
