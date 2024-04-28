def fuzzy-path [--type:string=''] {
    ls --all **/*
    | where name !~ '.*(.git|node_modules)[/\\]?'
    | match $type {
        d | dir  | directory => { $in | where type == dir }
        f | file | directory => { $in | where type == file }
        _ => { $in }
    }
    | get name
    | sort --ignore-case
}

def build-source-completion [
    tokens:list<string>
    position:int
    --type:string=''
] {
    let word = $tokens | range (-1).. | get 0? | default ''
    let span = {
        start: ($position - ($word | str length)),
        end: $position
    }

    fuzzy-path --type=$type
    | if ($word | str length) > 0 {
        where { ($in | path basename) =~ $word }
    } else {
        $in
    }
    | each { {value:$in, span:$span} }
}

#------------------------------------------------------------------------------

export def dir [tokens:list<string> position:int] {
    build-source-completion --type=dir $tokens $position
}

export def file [tokens:list<string> position:int] {
    build-source-completion --type=file $tokens $position
}

export def main [tokens:list<string> position:int] {
    build-source-completion $tokens $position
}
