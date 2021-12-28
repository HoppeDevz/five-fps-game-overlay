open FileSystem
open Process
open JSON

module ConfigReader = {

    let defaultSettings = {

        "hardwareOverlayPos": "top-left"
    }

    let createSettingsDir = (~path: string) => {

        FileSystem.mkdirSync(~dirPath=path)
    }

    let createSettingsFile = (~path: string) => {
        
        let data = defaultSettings -> JSON.stringify
        FileSystem.writeFileSync(~filePath=path, ~data=data)
    }

    let mergeSettingsFile = () => {

        let appData = Process.env["APPDATA"] ++ "\\five-fps-game-overlay"  
        let fileSettingsPath = appData ++ "\\settings.json"

        switch FileSystem.existsSync(~path=appData) {

            | false => createSettingsDir(~path=appData)
            | true => "Settings folder already exists" -> Js.log
        }

        switch FileSystem.existsSync(~path=fileSettingsPath) {

            | false => createSettingsFile(~path=fileSettingsPath)
            | true => "Settings file already exists" -> Js.log
        }
    }

    let readSettingsFile = () => {

        let appData = Process.env["APPDATA"] ++ "\\five-fps-game-overlay"  
        let fileSettingsPath = appData ++ "\\settings.json"

        let buffer = FileSystem.readFileSync(~filePath=fileSettingsPath)
        let data = JSON.parse(buffer)

        switch data {
            | defaultSettingsType => data
            | None => defaultSettings
        }
    }

}