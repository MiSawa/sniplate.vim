"=============================================================================
" FILE:           sniplate_variable.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  9 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \   'name'           : 'sniplate/class',
      \   'description'    : 'candidates from sniplate class',
      \   'default_kind'   : 'sniplate/class',
      \   'default_action' : 'start',
      \ }

function! s:source.gather_candidates(args, context) "{{{
  call unite#print_message('[sniplate/class]')
  let l:classes = sniplate#enumerate_classes()
  let l:res = []
  for l:class in l:classes
    call add(l:res, {})
    let l:res[-1].word             = l:class
    let l:res[-1].kind             = s:source.default_kind
    let l:res[-1].abbr             = l:class
  endfor
  call sort(l:res)
  return l:res
endfunction "}}}

function! s:source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  let l:res = keys(sniplate#enumerate_cached_variables())
  call filter(l:res, 'index(a:args[:-2], v:val) == -1')
  return l:res
endfunction "}}}

function! unite#sources#sniplate_class#define() "{{{
  return s:source
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :


