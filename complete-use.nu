def prepare-dirs [] {
    let lib_dirs = $env.NU_LIB_DIRS | path expand | where { path exists }
    $lib_dirs | each {|dir| {
        lib_dir: $dir
        exclude: (
            $lib_dirs
            | where { $in != $dir and ($in | str starts-with $dir) }
            | str substring (($dir | str length) + 1)..
            | str replace --all \ /
            | each { append '**' | str join '/' }
        )
    }}
}

def scan-dir [dir:directory='', --exclude:list<string>] {
    if ($in | is-not-empty) {$in} else {$dir}
    | each {|d|
        cd ($d | path expand)
        glob --no-dir --exclude $exclude **/*.nu
    }
}

def build-completion-source [] {
    prepare-dirs
    | each {|r|
        $r.lib_dir
        | scan-dir --exclude $r.exclude
        | each {{
            value: (
                $in
                | path relative-to $r.lib_dir
                | str replace -r 'mod.nu$' ''
            )
            description: ($r.lib_dir | str replace $nu.home-path '~')
        }}
        | sort-by value
    }
    | flatten
}

#------------------------------------------------------------------------------

export def main [] {
    let context = $in
    let noop_record = {value:''}

    if not ("last_cmd" in $context) {
        # 'Missing command'
        return $noop_record
    }

    let last_cmd = $context.last_cmd
    if ($last_cmd.span.end < $context.position) {
        # 'The cursor is not after a "word".'
        return $noop_record
    }

    let rest = match ($last_cmd.text | split words) {
        [use ..$rest] => $rest
        [overlay use ..$rest] => $rest
    }
    if ($rest | describe) == "nothing" {
        # 'The command is not handled by this completer'
        return $noop_record
    }
    if ($rest | length) != 1 {
        # 'We only complete the first argument'
        return $noop_record
    }

    let last_word_text = $context.last_word.text
    let last_word_span = $context.last_word.span

    build-completion-source
    | where { ($in.value | path basename) =~ $last_word_text }
    | insert span { $last_word_span }
}
