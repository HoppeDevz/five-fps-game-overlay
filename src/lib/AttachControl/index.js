const { exec } = require("child_process");
const { overlayWindow } = require("electron-overlay-window");
const plist = require("ps-list");
const apps = require("./apps");
const exceptions = require("./exceptions");

class AttachControl {

    constructor(overlay) {
        
        this.searchingForWindow = false;

        this.currentTargetProc;

        this.overlay = overlay;
    }

    wait(ms) {

        return new Promise(resolve => setTimeout(resolve, ms));
    }

    async listenProcKill() {

        console.log("[GAME-OVERLAY] - LISTEN PROC KILL");

        const procs = await plist();

        let hasKilled = true;

        for (let proc of procs) {

            if (proc.name == `${this.currentTargetProc}.exe` || proc.name == `${this.currentTargetProc}.EXE`) {

                hasKilled = false;
            }
        }

        await this.wait(2500);

        if (hasKilled) {

            console.log("[GAME-OVERLAY] - HAS KILLED, SEARCHING OTHER WINDOW...");

            this.searchForWindow();

            return;
        }

        this.listenProcKill();
    }

    async attachToWindow(procName) {

        this.searchingForWindow = false;
        this.currentTargetProc = procName;

        // Get-Process ${procName} |where {$_.mainWindowTItle} |format-table id,name,mainwindowtitle –AutoSize

        exec(`Get-Process ${procName} |where {$_.mainWindowTItle} |format-table mainwindowtitle –AutoSize`,
        { shell:"powershell.exe" },
        (err, stdout, stderr) => {

            
            if (err || stderr) {

                this.currentTargetProc = null;
                this.searchForWindow();

                return
            };

            try {

                console.log("[GAME-OVERLAY] - TRY ATTACH TO ", procName, exceptions[procName])

                if (exceptions[procName]) {

                    overlayWindow.attachTo(this.overlay, exceptions[procName]);
                    this.overlay.show();
                    
                    this.listenProcKill();

                    return
                }
                    
                const lines = stdout.split("\n");

                const windowName = lines[3]
                    .replace("\n", "")
                    .replace("\r", "")

                overlayWindow.attachTo(this.overlay, windowName);
                this.overlay.show();

                this.listenProcKill();

            } catch(err) {

                console.log(err);

                this.currentTargetProc = null;
                this.searchForWindow();
            }
            
        });
    }

    async searchForWindow() {

        console.log("[GAME-OVERLAY] - SEARCH FOR GAME WINDOW");

        this.searchingForWindow = true;

        const procs = await plist();
        let gameSearched;

        for (let proc of procs) {

            for (let app of apps) {

                if (proc.name == `${app}.exe` || proc.name == `${app}.EXE`) {

                    gameSearched = app;
                }
            }
        }

        await this.wait(2500);

        gameSearched ? this.attachToWindow (gameSearched) : this.searchForWindow();
    }

    startThread() {

        this.searchForWindow();
    }
}

module.exports = AttachControl;