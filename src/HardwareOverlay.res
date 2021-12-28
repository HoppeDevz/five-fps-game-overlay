open Electron
open ConfigReader

@send external toFixed: (float, ~floating: int) => string = "toFixed"

let ipcRenderer = Electron.ipcRenderer
let s = React.string

type systemInfo = {
    cpu: float,
    gpu: float,


    memoryTotal: int,
    memoryFree: int,
    memoryPercentage: float
}

@react.component
let make = () => {

    let systemInfoStartValue = {

        "cpu": 0.0,
        "gpu": 0.0,

        "memoryTotal": 0,
        "memoryFree": 0,
        "memoryPercentage": 0.0
    }

    let (systemInfo, setSystemInfo) = React.useState(_ => systemInfoStartValue)
    let (containerPosition, setContainerPos) = React.useState(_ => "top-right")

    let sendToIpcMain = () => {

        let response = ipcRenderer["sendSync"](."get-system-infos", Js.null)

        switch response {
            | systemInfo => setSystemInfo(_ => { 
                "cpu": response.cpu,  
                "gpu":response.gpu,

                "memoryTotal": response.memoryTotal,
                "memoryFree": response.memoryFree,
                
                "memoryPercentage": response.memoryPercentage
            })
            | None => Js.log("None")
        }
    }

    let mergeAndReadConfigFile = () => {

        ConfigReader.mergeSettingsFile()

        let data = ConfigReader.readSettingsFile()

        setContainerPos(_ => data["hardwareOverlayPos"])
    }

    React.useEffect0(() => {

        let _ = mergeAndReadConfigFile()
        let _ = Js.Global.setInterval(sendToIpcMain, 1500)
        None
    })

    <div className="overlay-wrapper">

        <div className={"system-informations" ++ " " ++ containerPosition}>

            {"Overlay" -> s}

            <p>
            {
                systemInfo["cpu"] 
                -> toFixed(~floating=1)
                -> s
            }
            { "%" -> s }
            </p>

            <p>
            {
                systemInfo["gpu"] 
                -> toFixed(~floating=1)
                -> s
            }
            { "%" -> s }
            </p>

            <p>
            {
                systemInfo["memoryPercentage"]
                -> toFixed(~floating=1)
                -> s
            }
            { "%" -> s }
            </p>
        </div>
    </div>
}