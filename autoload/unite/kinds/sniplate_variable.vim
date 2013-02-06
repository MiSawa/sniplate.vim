"=============================================================================
" FILE:           sniplate_variable.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  7 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \   'name'           : 'sniplate/variable',
      \   'default_action' : 'replace',
      \   'action_table'   : {},
      \   'parents'        : ['word'],
      \ }

let s:kind.alias_table = {
      \   'ex'          : 'nop',
      \ }

let s:kind.action_table.delete = {
      \   'description'         : 'clear this variable from cache',
      \   'is_quit'             : 1,
      \   'is_selectable'       : 1,
      \   'is_invalidate_cache' : 1,
      \   'is_listed'           : 1,
      \ }

function! s:kind.action_table.delete.func(candidates) "{{{
  call call('sniplate#clear_cached_variables',
        \ map(deepcopy(a:candidates), 'v:val.source__variable')
        \ )
endfunction "}}}

let s:kind.action_table.replace = {
      \   'description'         : 'clear this variable from cache',
      \   'is_quit'             : 1,
      \   'is_selectable'       : 0,
      \   'is_invalidate_cache' : 1,
      \   'is_listed'           : 1,
      \ }

function! s:kind.action_table.replace.func(candidate) "{{{
  call sniplate#set_variable(
        \ a:candidate.source__variable,
        \ sniplate#util#input_variable(a:candidate.source__variable)
        \ )
endfunction "}}}

function! unite#kinds#sniplate_variable#define() "{{{
  return s:kind
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
