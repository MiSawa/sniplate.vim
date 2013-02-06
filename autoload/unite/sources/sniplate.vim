"=============================================================================
" FILE:           sniplate.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  6 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \   'name'        : 'sniplate',
      \   'description' : 'candidates from sniplate list',
      \   'default_kind': 'sniplate',
      \ }

function! s:source.gather_candidates(args, context) "{{{
  call unite#print_message('[sniplate]')
  let l:sniplates = sniplate#enumerate_visible_sniplates()
  let l:res = []
  for l:sniplate in values(sniplates)
    call add(l:res, {})
    let l:res[-1].word           = l:sniplate.name
    ". 't ' . l:sniplate.abbr
    let l:res[-1].kind           = 'sniplate'
    " let l:res[-1].action__name   = l:sniplate.name
    let l:res[-1].action__path   = l:sniplate.path
    let l:res[-1].action__line   = l:sniplate.line_number
    let l:res[-1].abbr           = printf('%-30s %s', l:sniplate.name, l:sniplate.abbr)
    let l:res[-1].sniplate       = l:sniplate
  endfor
  call sniplate#util#sort_by(l:res, '-a:1.sniplate.priority')
  return l:res
endfunction "}}}

function! s:source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  return sniplate#complete(
        \ a:arglead, a:cmdline, a:cursorpos)
endfunction"}}}

function! unite#sources#sniplate#define() "{{{
  return s:source
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :

