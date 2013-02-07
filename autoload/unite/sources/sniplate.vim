"=============================================================================
" FILE:           sniplate.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  7 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \   'name'           : 'sniplate',
      \   'description'    : 'candidates from sniplate list',
      \   'default_kind'   : 'sniplate',
      \   'default_action' : 'insert',
      \   'hooks'          : {},
      \ }

function! s:source.hooks.on_init(args, context) "{{{
  let a:context.source__bang =
        \ index(a:args, '!') >= 0
  let l:classes = filter(copy(a:args), 'v:val != "!"')
  if empty(l:classes)
    let a:context.source__sniplates =
          \ sniplate#enumerate_sniplates()
  else
    let a:context.source__sniplates =
          \ sniplate#enumerate_sniplates_has_any_classes(l:classes)
  endif
  call sniplate#remove_invisible(a:context.source__sniplates)
endfunction "}}}

function! s:source.gather_candidates(args, context) "{{{
  call unite#print_message('[sniplate]')
  let l:sniplates = a:context.source__sniplates
  let l:res = []
  for [l:snipname, l:sniplate] in items(l:sniplates)
    call add(l:res, {})
    let l:res[-1].word             = l:snipname . ' ' .l:sniplate.class.string()
    let l:res[-1].kind             = s:source.default_kind
    let l:res[-1].action__path     = l:sniplate.path
    let l:res[-1].action__line     = l:sniplate.line_number
    let l:res[-1].action__text     = join(l:sniplate.lines, "\n")
    if l:sniplate.class.empty()
      let l:res[-1].abbr             = printf('%-50.50s %s',
            \ l:snipname, l:sniplate.abbr)
    else
      let l:res[-1].abbr             = printf('%-30.30s %-20.20s %s',
            \ l:snipname, l:sniplate.class.string(), l:sniplate.abbr)
    endif
    let l:res[-1].source__sniplate = l:sniplate
    let l:res[-1].source__bang     = a:context.source__bang
  endfor
  call sniplate#util#sort_by(l:res, '-a:1.source__sniplate.priority')
  return l:res
endfunction "}}}

function! s:source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  let l:res = sniplate#enumerate_classes()
  call add(l:res, '!')
  call filter(l:res, 'index(a:args[:-2], v:val) == -1')
  return l:res
endfunction "}}}

function! unite#sources#sniplate#define() "{{{
  return s:source
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
