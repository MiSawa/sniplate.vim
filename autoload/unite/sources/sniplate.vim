"=============================================================================
" FILE:           sniplate.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  11 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \   'name'           : 'sniplate',
      \   'description'    : 'candidates from sniplate list',
      \   'default_kind'   : 'sniplate',
      \   'default_action' : 'insert',
      \   'hooks'          : {},
      \ }

function! s:source.hooks.on_init(args, context) "{{{
  let a:context.source__bang =
        \ index(a:args, '!') >= 0
  let classes = filter(copy(a:args), 'v:val != "!"')
  if empty(classes)
    let a:context.source__sniplates =
          \ sniplate#enumerate_sniplates()
  else
    let a:context.source__sniplates =
          \ sniplate#enumerate_sniplates_has_any_classes(classes)
  endif
  call sniplate#remove_invisible(a:context.source__sniplates)
endfunction "}}}

function! s:source.gather_candidates(args, context) "{{{
  call unite#print_message('[sniplate]')
  let sniplates = a:context.source__sniplates
  let bang = get(a:context, 'source__bang', 0)
  let res = []
  for [snipname, sniplate] in items(sniplates)
    let arg = {
          \ 'name'     : snipname,
          \ 'sniplate' : sniplate,
          \ 'bang'     : bang,
          \ }
    call add(res, sniplate#candidate_factory#get_sniplate_candidate(
          \ arg, a:context))
  endfor
  call sniplate#util#sort_by(res, '-a:1.source__sniplate.priority')
  return res
endfunction "}}}

function! s:source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  let res = sniplate#enumerate_classes()
  call add(res, '!')
  call filter(res, 'index(a:args[:-2], v:val) == -1')
  return res
endfunction "}}}

function! unite#sources#sniplate#define() "{{{
  return s:source
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
