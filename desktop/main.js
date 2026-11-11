// SmartEye Price Manager — Windows app (Electron). Loads the same files as smarteye.am/calc.
const { app, BrowserWindow, shell } = require('electron');
const path = require('path');

function createWindow() {
  const win = new BrowserWindow({
    width: 560, height: 920, minWidth: 380, minHeight: 600,
    backgroundColor: '#dfe6ef',
    title: 'SmartEye Price Manager',
    icon: path.join(__dirname, 'icon.png'),
    autoHideMenuBar: true,
    webPreferences: { contextIsolation: true, sandbox: true, nodeIntegration: false }
  });
  win.loadFile(path.join(__dirname, 'www', 'index.html'));
  // PDF downloads: save straight to the Downloads folder and show the file, so it can be dragged into Telegram / Viber / WhatsApp
  win.webContents.session.on('will-download', (e, item) => {
    const file = path.join(app.getPath('downloads'), item.getFilename());
    item.setSavePath(file);
    item.once('done', (ev, state) => { if (state === 'completed') shell.showItemInFolder(file); });
  });
  // Instagram / Telegram / Viber / WhatsApp / any web link → default browser or app
  win.webContents.setWindowOpenHandler(({ url }) => { shell.openExternal(url).catch(() => {}); return { action: 'deny' }; });
  win.webContents.on('will-navigate', (e, url) => {
    if (!url.startsWith('file:')) { e.preventDefault(); shell.openExternal(url); }
  });
}

const single = app.requestSingleInstanceLock();
if (!single) app.quit();
else {
  app.on('second-instance', () => { const w = BrowserWindow.getAllWindows()[0]; if (w) { if (w.isMinimized()) w.restore(); w.focus(); } });
  app.whenReady().then(createWindow);
  app.on('window-all-closed', () => app.quit());
}
