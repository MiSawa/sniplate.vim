"=============================================================================
" FILE:           sniplate.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  10 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \   'name'           : 'sniplate',
      \   'default_action' : 'insert',
      \   'action_table'   : {},
      \   'parents'        : ['jump_list'],
      \ }

let s:kind.alias_table = {
      \   'ex'          : 'nop',
      \   'yank'        : 'nop',
      \   'yank_escape' : 'nop',
      \ }

let s:kind.action_table.insert = {
      \   'description'         : 'insert this/those sniplate',
      \   'is_quit'             : 1,
      \   'is_selectable'       : 1,
      \   'is_invalidate_cache' : 0,
      \   'is_listed'           : 1,
      \ }

function! s:kind.action_table.insert.func(candidates) "{{{
  if empty(a:candidates) | return | endif
  let bang = 0
  for candidate in a:candidates
    let bang = bang || candidate.source__bang
  endfor
  call call('sniplate#apply_sniplates',
        \ [map(deepcopy(a:candidates), 'v:val.source__sniplate')]
        \ + [line('.'), bang])
endfunction "}}}

function! unite#kinds#sniplate#define() "{{{
  return s:kind
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
