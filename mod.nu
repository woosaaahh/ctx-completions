def get-last-command [buffer:string] -> record {
    let default = {
        span: {
            start: 0,
            end: 0,
        }
        text: $buffer,
        full_text: $buffer,
    }

    if ($buffer | str trim | is-empty) {
        return ($default | insert warning "No code")
    }

    let buf_ast = ast --json $buffer | get block | from json
    let spans = $buf_ast
        | get pipelines | each {
            get elements | each {
                get expr.span
            }
        }
        | each {|spans| {
            span: {
                start: (($spans | first | get start) - $buf_ast.span.start),
                end:   (($spans | last  | get end)   - $buf_ast.span.start),
            }
        }}
    if ($spans | length) == 0 {
        return ($default | insert warning "No spans")
    }

    $spans
        | last
        | insert text {|s|
            $buffer | str substring ($s.span.start)..($s.span.end)
        }
        # `ast` trim trailing comment and spaces, we might need the full text.
        | insert full_text {
            $buffer | str substring ($spans | last | get span.start)..
        }
}

def get-last-word [command:record position:int] -> record {
    let default = {
        span: {
            start: 0,
            end: 0,
        }
        text: '',
        full_text: '',
    }

    if ($command | is-empty) {
        return ($default | insert warning "Empty command")
    }
    if ($command.text | str trim | is-empty) {
        return ($default | insert warning "Empty command text")
    }

    let text = $command.text | split words | last
    {
        span: {
            start: ($position - ($text | str length)),
            end: $position,
        }
        text: $text,
    }

}

#------------------------------------------------------------------------------

use complete-use.nu
use complete-path.nu

export def build-context [buffer:string position:int] {
    let buffer    = $buffer | str substring ..$position
    let last_cmd  = get-last-command $buffer
    let last_word = get-last-word $last_cmd $position
    {
        buffer:    $buffer,
        position:  $position,
        last_cmd:  $last_cmd,
        last_word: $last_word,
    }
}

export def dispatch [] {
    let $context = $in
    let $tokens = $context.last_cmd.text | split words
    match ($tokens) {
        [use ..]         => ($context | complete-use)
        [overlay use ..] => ($context | complete-use)
        [cd ..]          => (complete-path dir ($tokens | range 1..) $context.position)
        [nvim ..]        => (complete-path file ($tokens | range 1..) $context.position)
        [..]             => (complete-path ($tokens | range 1..) $context.position)
    }
}
