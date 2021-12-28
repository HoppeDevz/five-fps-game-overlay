const electron = require('electron')
const { ipcMain } = require("electron")
const app = electron.app
const BrowserWindow = electron.BrowserWindow
const path = require('path')
const { currentLoad, mem, graphics } = require("systeminformation");
const AttachControl = require("./src/lib/AttachControl");

let CURRENT_CPU_USAGE = 0.0;
let CURRENT_MEMORY_USAGE = {memoryTotal: 0, memoryFree: 0, memoryPercentage: 0.0 };
let CURRENT_GPU_USAGE = { gpuUsage: 0.0 };

function getCpuUsage() {

  const callback = data => CURRENT_CPU_USAGE = data.currentLoad;
  currentLoad(callback);
}
function getGpuUsage() {
  
  const callback = data => CURRENT_GPU_USAGE = { gpuUsage: data.controllers[0].utilizationGpu ?? 0.0 };
  graphics(callback);
}
function getMemoryUsage() {

  const callback = data => CURRENT_MEMORY_USAGE = { 
    memoryTotal: data.total, 
    memoryFree: data.free, 
    memoryPercentage:  (1 - (data.free / data.total)) * 100
  };
  mem(callback);
}
setInterval(getCpuUsage, 1500);
setInterval(getMemoryUsage, 1500);
setInterval(getGpuUsage, 1500);

function createWindow() {
  const mainWindow = new BrowserWindow({
    width: 200,
    height: 100,

    type:"toolbar",

    frame: false,
    autoHideMenuBar: true,

    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false,
      preload: path.join(__dirname, 'preload.js'),
    },

    focusable: false,

    transparent: true,
    alwaysOnTop: true
  })
  
  mainWindow.hide();
  mainWindow.loadFile('index.html')

  /*
  mainWindow.setVisibleOnAllWorkspaces(true, {visibleOnFullScreen: true}, 1);
  mainWindow.setAlwaysOnTop(true, "floating", 1);
  mainWindow.setFullScreenable(false);
  */

  mainWindow.setIgnoreMouseEvents(true);
  
  // overlayWindow.attachTo(mainWindow, "The Classic PW");
  // overlayWindow.attachTo(mainWindow, "Counter-Strike: Global Offensive - Direct3D 9");

  const attach = new AttachControl(mainWindow);
  attach.startThread();
}

ipcMain.on("get-system-infos", (event, data) => {

  let returnValue = { cpu: CURRENT_CPU_USAGE, gpu: CURRENT_GPU_USAGE.gpuUsage, ...CURRENT_MEMORY_USAGE };

  event.returnValue = returnValue;
})

app.whenReady().then(() => {
  createWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })
})

app.on('window-all-closed', () => {
   app.quit()
})