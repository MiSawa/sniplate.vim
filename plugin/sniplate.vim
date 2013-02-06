"=============================================================================
" FILE:           sniplate.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  6 Feb 2013.
" License:        zlib License
"=============================================================================
if exists('g:loaded_sniplate')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=+ -bang -range -complete=customlist,sniplate#complete
      \ SniplateLoad call sniplate#load_sniplates([<f-args>], <line1>, <bang>0)
command! -nargs=* -complete=filetype
      \ SniplateClearCache call sniplate#clear_cached_sniplates(<f-args>)
command! -nargs=* -complete=customlist,sniplate#complete_cached_variables
      \ SniplateClearVariables call sniplate#clear_cached_variables(<f-args>)

let g:loaded_sniplate = 1
let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
