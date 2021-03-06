// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var $$JSON = require("./JSON.js");
var Process = require("./Process.js");
var FileSystem = require("./FileSystem.js");
var Caml_option = require("rescript/lib/js/caml_option.js");

var defaultSettings = {
  showHardwareOverlayHeader: true,
  hardwareOverlayPos: "top-left",
  backgroundColor: "#08080864"
};

function createSettingsDir(path) {
  return FileSystem.FileSystem.mkdirSync(path);
}

function createSettingsFile(path) {
  var data = $$JSON.$$JSON.stringify(defaultSettings);
  return FileSystem.FileSystem.writeFileSync(path, data);
}

function mergeSettingsFile(param) {
  var appData = Process.Process.env.APPDATA + "\\five-fps-game-overlay";
  var fileSettingsPath = appData + "\\settings.json";
  if (FileSystem.FileSystem.existsSync(appData)) {
    console.log("Settings folder already exists");
  } else {
    FileSystem.FileSystem.mkdirSync(appData);
  }
  if (FileSystem.FileSystem.existsSync(fileSettingsPath)) {
    console.log("Settings file already exists");
    return ;
  } else {
    return createSettingsFile(fileSettingsPath);
  }
}

function readSettingsFile(param) {
  var appData = Process.Process.env.APPDATA + "\\five-fps-game-overlay";
  var fileSettingsPath = appData + "\\settings.json";
  var buffer = FileSystem.FileSystem.readFileSync(fileSettingsPath);
  var data = $$JSON.$$JSON.parse(buffer);
  if (data !== undefined) {
    return Caml_option.valFromOption(data);
  } else {
    return defaultSettings;
  }
}

var ConfigReader = {
  defaultSettings: defaultSettings,
  createSettingsDir: createSettingsDir,
  createSettingsFile: createSettingsFile,
  mergeSettingsFile: mergeSettingsFile,
  readSettingsFile: readSettingsFile
};

exports.ConfigReader = ConfigReader;
/* Process Not a pure module */
