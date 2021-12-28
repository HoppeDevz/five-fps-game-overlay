@scope("process") @val external env: 'a = "env"

module Process = {

    let env = env
}