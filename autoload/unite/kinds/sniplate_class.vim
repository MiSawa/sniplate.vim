"=============================================================================
" FILE:           sniplate.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  8 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \   'name'           : 'sniplate/class',
      \   'default_action' : 'gather',
      \   'action_table'   : {},
      \   'parents'        : [],
      \ }

let s:kind.alias_table = {
      \ }

let s:kind.action_table.gather = {
      \   'description'         : 'gather sniplates in this/those class',
      \   'is_quit'             : 0,
      \   'is_selectable'       : 1,
      \   'is_invalidate_cache' : 0,
      \   'is_listed'           : 1,
      \ }

function! s:kind.action_table.gather.func(candidates) "{{{
  if empty(a:candidates) | return | endif
  let l:list = map(copy(a:candidates), 'v:val.word')
  call unite#start([['sniplate'] + l:list])
endfunction "}}}

function! unite#kinds#sniplate_class#define() "{{{
  return s:kind
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
