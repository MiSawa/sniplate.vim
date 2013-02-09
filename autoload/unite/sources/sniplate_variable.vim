"=============================================================================
" FILE:           sniplate_variable.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  10 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \   'name'           : 'sniplate/variable',
      \   'description'    : 'candidates from sniplate variables in current buffer',
      \   'default_kind'   : 'sniplate/variable',
      \   'default_action' : 'replace',
      \ }

function! s:source.gather_candidates(args, context) "{{{
  call unite#print_message('[sniplate/variable]')
  let variables = sniplate#enumerate_cached_variables()
  let res = []
  for [var, val] in items(variables)
    call add(res, {})
    let res[-1].word             = var
    let res[-1].kind             = s:source.default_kind
    let res[-1].action__text     = val
    let res[-1].abbr             = printf('%-15s %s', var, val)
    let res[-1].source__variable = var
  endfor
  call sort(res)
  return res
endfunction "}}}

function! s:source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  let res = keys(sniplate#enumerate_cached_variables())
  call filter(res, 'index(a:args[:-2], v:val) == -1')
  return res
endfunction "}}}

function! unite#sources#sniplate_variable#define() "{{{
  return s:source
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :

