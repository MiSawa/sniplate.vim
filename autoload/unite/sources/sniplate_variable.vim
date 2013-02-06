"=============================================================================
" FILE:           sniplate_variable.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  7 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \   'name'           : 'sniplate/variable',
      \   'description'    : 'candidates from sniplate variables in current buffer',
      \   'default_kind'   : 'sniplate/variable',
      \   'default_action' : 'insert',
      \ }

function! s:source.gather_candidates(args, context) "{{{
  call unite#print_message('[sniplate]')
  let l:variables = sniplate#enumerate_cached_variables()
  let l:res = []
  for [l:var, l:val] in items(l:variables)
    call add(l:res, {})
    let l:res[-1].word             = l:var
    let l:res[-1].kind             = s:source.default_kind
    let l:res[-1].action__text     = l:val
    let l:res[-1].abbr             = printf('%-15s %s', l:var, l:val)
    let l:res[-1].source__variable = l:var
  endfor
  call sort(l:res)
  return l:res
endfunction "}}}

function! s:source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  return sniplate#complete_cached_variables(
        \ a:arglead, a:cmdline, a:cursorpos
        \ )
endfunction "}}}

function! unite#sources#sniplate_variable#define() "{{{
  return s:source
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :

