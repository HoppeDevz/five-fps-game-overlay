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
    let (containerBackground, setContainerBackground) = React.useState(_ => "#08080864")
    let (showHardwareOverlayHeader, setShowHardwareOverlayHeader) = React.useState(_ => true)

    let sendToIpcMain = () => {

        let response = ipcRenderer["sendSync"](."get-system-infos", Js.null)

        switch response {
            | systemInfo => setSystemInfo(_ => response)
            | None => Js.log("None")
        }
    }

    let mergeAndReadConfigFile = () => {

        ConfigReader.mergeSettingsFile()

        let data = ConfigReader.readSettingsFile()

        setContainerPos(_ => data["hardwareOverlayPos"])
        setContainerBackground(_ => data["backgroundColor"])
        setShowHardwareOverlayHeader(_ => data["showHardwareOverlayHeader"])
    }

    React.useEffect0(() => {

        let _ = mergeAndReadConfigFile()
        let _ = Js.Global.setInterval(sendToIpcMain, 1500)
        None
    })

    <div className="hardware-overlay-wrapper">

        <div 
            style={ReactDOM.Style.make(~backgroundColor=containerBackground, ())}
            className={"system-informations" ++ " " ++ containerPosition}
        >

            {showHardwareOverlayHeader ?
             
                <h1 className="header-container">

                    <img className="image" src="./src/assets/rocket-20x20.png" />
                    <p className="text">{"FIVE.FPS" -> s}</p>
                </h1>
            : 
                <div style={ReactDOM.Style.make(~display="none", ())}></div>
            }
            

            <div 
                style={ReactDOM.Style.make(
                    ~display="flex", 
                    ~flexDirection="row",
                    ~justifyContent="space-between",
                    ~alignItems="center",

                    ~padding="5px 10px",

                    ()
                )}
            >
                <div className="info-container">

                    <p className="label">{"CPU: " -> s}</p>

                    <p className="value">
                        {
                            systemInfo["cpu"] 
                            -> toFixed(~floating=1)
                            -> s
                        }
                        { "%" -> s }
                    </p>
                </div>

                <div className="info-container">
                    <p className="label">{"GPU: " -> s}</p>

                    <p className="value">
                        {
                            systemInfo["gpu"] 
                            -> toFixed(~floating=1)
                            -> s
                        }
                        { "%" -> s }
                    </p>
                </div>

                <div className="info-container">
                        <p className="label">{"RAM: " -> s}</p>

                        <p className="value">
                            {
                                systemInfo["memoryPercentage"] 
                                -> toFixed(~floating=1)
                                -> s
                            }
                            { "%" -> s }
                        </p>
                </div>
            </div>

        </div>
    </div>
}