"=============================================================================
" FILE:           sniplate.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  4 Feb 2013.
" License:        zlib License
"=============================================================================
if exists('g:loaded_sniplate')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=1 -bang -range -complete=customlist,sniplate#complete
      \ SniplateLoad call sniplate#load(<q-args>, <bang>0, <line1>)
command! -nargs=* -complete=filetype
      \ SniplateClearCache call sniplate#clear_cached_sniplates(<f-args>)
command! -nargs=* -complete=customlist,sniplate#complete_cached_variables
      \ SniplateClearVariables call sniplate#clear_cached_variables()

let g:loaded_sniplate = 1
let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
