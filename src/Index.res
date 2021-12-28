let s = React.string

module App = {
  @react.component
  let make = () => <HardwareOverlay/>
}

switch ReactDOM.querySelector("#root") {
  
  | Some(root) => ReactDOM.render(<div> <App /> </div>, root)
  | None => ()
}