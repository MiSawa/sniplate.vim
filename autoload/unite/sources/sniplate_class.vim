"=============================================================================
" FILE:           sniplate_class.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  11 Feb 2013.
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
  let classes = sniplate#enumerate_classes()
  let res = []
  for class in classes
    call add(res,
          \ sniplate#candidate_factory#get_class_candidate(
          \  class
          \ ))
    continue
  endfor
  call sort(res)
  return res
endfunction "}}}

function! s:source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  let res = keys(sniplate#enumerate_cached_variables())
  call filter(res, 'index(a:args[:-2], v:val) == -1')
  return res
endfunction "}}}

function! unite#sources#sniplate_class#define() "{{{
  return s:source
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
