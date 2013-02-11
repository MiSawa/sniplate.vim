"=============================================================================
" FILE:           sniplate_information.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  11 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \   'name'           : 'sniplate/information',
      \   'description'    : 'information about sniplate',
      \   'default_kind'   : '',
      \   'is_listed'     : 0,
      \ }

function! s:source.gather_candidates(arg, context) "{{{
  call unite#print_message('[sniplate/information]')
  let sniplates = sniplate#enumerate_sniplates(
        \  a:context.source__filetype
        \ )
  let sniplate = sniplates[a:arg[0]]
  let ancestors = sniplate#enumerate_ancestor_sniplates(
        \  sniplate
        \ )
  let descendants = sniplate#enumerate_descendant_sniplates(
        \  sniplate
        \ )
  let res = []
  call add(res,
        \ sniplate#candidate_factory#get_sniplate_candidate(
        \  sniplate
        \ ))

  "file "{{{
  call add(res, sniplate#candidate_factory#get_separetor_candidate(
        \  'file'
        \ ))
  call add(res,
        \ sniplate#candidate_factory#get_file_line_candidate(
        \  sniplate.path, sniplate.line_number
        \ )) "}}}

  "classes "{{{
  if !sniplate.class.empty()
    call add(res, sniplate#candidate_factory#get_separetor_candidate(
          \  'classes'
          \ ))
    for clas in sniplate.class.items()
      call add(res, sniplate#candidate_factory#get_class_candidate(
            \ clas, sniplate.filetype
            \ ))
    endfor
  endif "}}}

  "ancestors "{{{
  if len(ancestors) > 1
    call add(res, sniplate#candidate_factory#get_separetor_candidate(
          \  'ancestors'
          \ ))
    for snip in ancestors
      if snip.name !=# a:arg[0]
        call add(res,
              \ sniplate#candidate_factory#get_sniplate_candidate(
              \  snip
              \ ))
      endif
    endfor
  endif "}}}

  "descendants "{{{
  if len(descendants) > 1
    call add(res, sniplate#candidate_factory#get_separetor_candidate(
          \  'descendants'
          \ ))
    for snip in descendants
      if snip.name !=# a:arg[0]
        call add(res,
              \ sniplate#candidate_factory#get_sniplate_candidate(
              \  snip
              \ ))
      endif
    endfor
  endif "}}}

  return res
endfunction "}}}

function! unite#sources#sniplate_information#define() "{{{
  return s:source
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
