@scope("JSON") @val external stringify: 'a => string = "stringify"
@scope("JSON") @val external parse: 'a => 'b = "parse"


module JSON = {

    let stringify = stringify
    let parse = parse
}