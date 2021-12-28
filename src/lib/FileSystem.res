@module("fs") external existsSync: (~path: string) => bool = "existsSync"
@module("fs") external readFileSync: (~filePath: string) => array<int> = "readFileSync"
@module("fs") external writeFileSync: (~filePath: string, ~data: string) => unit = "writeFileSync"
@module("fs") external mkdirSync: (~dirPath: string) => unit = "mkdirSync"

@scope("String") @val external toString: (~data: 'a) => string = "toString"

module FileSystem = {

    let existsSync = existsSync
    let readFileSync = readFileSync
    let writeFileSync = writeFileSync
    let mkdirSync = mkdirSync

    let toString = toString
}