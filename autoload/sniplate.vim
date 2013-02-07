"=============================================================================
" FILE:           sniplate.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  7 Feb 2013.
" License:        zlib License
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

" settings "{{{
function! s:set_default(var, val, ...) "{{{
  if !exists(a:var) || type({a:var}) != type(a:val)
    let alternate_var = get(a:000, 0, '')
    let {a:var} = exists(alternate_var) ?
          \ {alternate_var} : a:val
  endif
endfunction "}}}

function! s:get_filetype_config(filetype) "{{{
  let l:filetype = empty(a:filetype) ? 'nothing' : a:filetype
  let l:default = {'directory': l:filetype}
  let l:force = {'filetype': l:filetype}
  let l:config = {}
  for l:var in [
        \ 'l:default',
        \ 's:sniplate_filetype_config["_"]',
        \ 'g:sniplate#filetype_config["_"]',
        \ 'g:sniplate#filetype_config[l:filetype]',
        \ 'l:force',
        \ ]
    if exists(l:var)
      call extend(l:config, eval(l:var), "force")
    endif
  endfor
  return l:config
endfunction "}}}

"{{{ variables
let s:sniplate_filetype_config = {
      \ '_': {
      \  'keyword_pattern' : '{{\s*\(.\{-\}\)\s*\%(:\s*\(.\{-\}\)\s*\)\?}}',
      \  'overwrite'       : 2,
      \  }
      \ }
call s:set_default(
      \ 's:sniplates_directory', '~/.vim/sniplates', 'g:sniplate#sniplates_directory' )
call s:set_default(
      \ 's:sniplate_begin_keyword', 'BEGIN SNIPLATE', 'g:sniplate#sniplate_begin_keyword' )
call s:set_default(
      \ 's:sniplate_end_keyword', 'END SNIPLATE', 'g:sniplate#sniplate_end_keyword' )
call s:set_default(
      \ 's:sniplate_enable_cache', 1, 'g:sniplate#sniplate_enable_cache')
call s:set_default(
      \ 's:sniplate_cache_variable_in_buffer', 1, 'g:sniplate#cache_variable_in_buffer')
"}}}
"}}}

" functions for make sniplate list "{{{
function! s:parse_sniplate(str, sniplate_file, line_number, config) "{{{
  let l:res             = {
        \ 'require'        : [],
        \ 'pattern'        : '',
        \ 'abbr'           : '',
        \ 'priority'       : 0,
        \ 'is_invisible'   : 0,
        \ 'overwrite'      : -1,
        \ }
  let l:res.class       = sniplate#util#set#emptyset()
  let l:res.raw_lines   = split(a:str, "\n")
  let l:res.path        = a:sniplate_file
  let l:res.line_number = a:line_number
  let l:res.name        = matchlist(l:res.raw_lines[0],
        \ s:sniplate_begin_keyword . '\s*\(\S*\)\s*')[1]
  let l:res.lines       = []
  let l:res.filetype    = a:config.filetype

  for l:line in l:res.raw_lines[1:-2]
    if l:line =~ a:config.keyword_pattern
      let [l:operator, l:operand]
            \ = matchlist(l:line, a:config.keyword_pattern)[1:2]
      "{{{
      if 0

      elseif l:operator ==? 'class'
        call l:res.class.add_items(split(l:operand, '\s*,\s*'))

      elseif l:operator ==? 'require'
        call extend(l:res.require, split(l:operand, '\s*,\s*'))

      elseif l:operator ==? 'pattern'
        let l:res.pattern = l:operand

      elseif l:operator ==? 'abbr'
        let l:res.abbr = l:operand

      elseif l:operator ==? 'priority'
        let l:res.priority = l:operand

      elseif l:operator ==? 'invisible'
        let l:res.is_invisible = 1

      elseif l:operator ==? 'overwrite'
        let l:res.overwrite = sniplate#util#convert_to_012(
              \ l:operand,
              \ printf('in sniplate "%s", overwrite must be 0/1/2/false/true/auto', l:res.name)
              \ )

      else
        call add(l:res.lines, l:line)
      endif
      "}}}
    else
      call add(l:res.lines, l:line)
    endif
  endfor
  return l:res
endfunction "}}}

function! s:enumerate_sniplates_from_file(sniplate_file, config) "{{{
  if !filereadable(a:sniplate_file)
    return {}
  endif
  let l:all_text = join([''] + readfile(a:sniplate_file, 'b'), "\n")
  let l:pattern = "\n[^\n]\\{-\\}" . s:sniplate_begin_keyword . ".\\{-\\}" . s:sniplate_end_keyword . ".\\{-\\}\n"
  let l:i = 1
  let l:sniplates = {}
  while 1
    let l:snip_text = matchstr(l:all_text, l:pattern, 0, i)
    if strlen(l:snip_text) == 0
      break
    endif
    let l:linenr = count(split(l:all_text[0 : match(l:all_text, l:pattern, 0, i)], '\zs'), "\n")
    let l:temp = s:parse_sniplate(l:snip_text, a:sniplate_file, l:linenr, a:config)
    let l:sniplates[l:temp.name] = l:temp
    unlet l:temp
    let l:i += 1
  endwhile
  return l:sniplates
endfunction "}}}

function! s:enumerate_sniplate_files(config) "{{{
  let l:sniplate_directory = join(
        \ [s:sniplates_directory, a:config.directory, '**'], '/')
  return filter(split(globpath(l:sniplate_directory, '*'), '\n'), '!isdirectory(v:val)')
endfunction "}}}


function! s:noncached_enumerate_sniplates(config) "{{{
  let l:sniplate_files = s:enumerate_sniplate_files(a:config)
  let l:sniplates = {}
  for l:sniplate_file in l:sniplate_files
    call extend(l:sniplates,
          \ s:enumerate_sniplates_from_file(l:sniplate_file, a:config), "error" )
  endfor
  return l:sniplates
endfunction "}}}

function! s:enumerate_sniplates(config) "{{{
  if !s:sniplate_enable_cache
    return s:noncached_enumerate_sniplates(a:config)
  endif
  if !exists('s:cached_sniplates')
    let s:cached_sniplates = {}
  endif
  if !exists('s:cached_sniplates[a:config.filetype]')
    let s:cached_sniplates[a:config.filetype] =
          \ s:noncached_enumerate_sniplates(a:config)
  endif
  return s:cached_sniplates[a:config.filetype]
endfunction "}}}

function! s:clear_cached_sniplates(...) "{{{
  if !exists('s:cached_sniplates')
    return
  endif
  if a:0 == 0
    unlet! s:cached_sniplates
  else
    for l:config in a:000
      unlet! s:cached_sniplates[l:config.filetype]
    endfor
  endif
endfunction "}}}

function! s:enumerate_connected_sniplates(sniplate) "{{{
  let l:stack = [a:sniplate.name]
  let l:sniplates = s:enumerate_sniplates(
        \ s:get_filetype_config(a:sniplate.filetype) )
  let l:res = []
  let l:state = {}
  while !empty(l:stack)
    let l:last = l:stack[-1]
    if has_key(l:state, l:last)
      while !empty(l:state[l:last])
            \ && has_key(l:state, l:state[l:last][0])
        call remove(l:state[l:last], 0)
      endwhile
      if empty(l:state[l:last])
        call add(l:res, l:sniplates[remove(l:stack, -1)])
      else
        call add(l:stack, remove(l:state[l:stack[-1]], 0))
      endif
    else
      let l:state[l:last] = deepcopy(l:sniplates[l:last].require)
    endif
  endwhile
  return l:res
endfunction "}}}


function! s:enumerate_sniplates_has_class(class, config) "{{{
  let l:all_sniplates = s:enumerate_sniplates(a:config)
  let l:res = {}
  for [l:snipname, l:sniplate] in items(l:all_sniplates)
    if l:sniplate.class.has(a:class)
      let l:res[l:snipname] = l:sniplate
    endif
  endfor
  return l:res
endfunction "}}}

function! s:enumerate_sniplates_has_all_classes(classes, config) "{{{
  let l:all_sniplates = s:enumerate_sniplates(a:config)
  let l:res = {}
  for [l:snipname, l:sniplate] in items(l:all_sniplates)
    if l:sniplate.class.has_all(a:classes)
      let l:res[l:snipname] = l:sniplate
    endif
  endfor
  return l:res
endfunction "}}}

function! s:enumerate_sniplates_has_any_classes(classes, config) "{{{
  let l:all_sniplates = s:enumerate_sniplates(a:config)
  let l:res = {}
  for [l:snipname, l:sniplate] in items(l:all_sniplates)
    if l:sniplate.class.has_any(a:classes)
      let l:res[l:snipname] = l:sniplate
    endif
  endfor
  return l:res
endfunction "}}}

function! s:enumerate_classes(config) "{{{
  let l:res = sniplate#util#set#emptyset()
  let l:all_sniplates = s:enumerate_sniplates(a:config)
  for [l:snipname, l:sniplate] in items(l:all_sniplates)
    call l:res.union(l:sniplate.class)
  endfor
  return l:res
endfunction "}}}
"}}}

" functions for apply sniplate "{{{
" apply系の関数は, s:apply_sniplates(sniplates, config, ...) に集約される.
" 可変長引数部分は, これのみで決まる.

function! s:enumerate_cached_variables() "{{{
  if has_key(b:, 'sniplate') && has_key(b:sniplate, 'variables')
    return deepcopy(b:sniplate.variables)
  endif
  return {}
endfunction "}}}

function! s:set_variable(var, val, ...) "{{{
  " Unite sniplate/variables の replace に必要.
  if a:0
    let l:variables = a:1
  elseif s:sniplate_cache_variable_in_buffer
    if !has_key(b:, 'sniplate') | let b:sniplate = {} | endif
    if !has_key(b:sniplate, 'variables') | let b:sniplate.variables = {} | endif
    let l:variables = b:sniplate.variables
  else
    return
  endif
  let l:variables[a:var] = a:val
endfunction "}}}

function! s:clear_cached_variables(...) "{{{
  if has_key(b:, 'sniplate') && has_key(b:sniplate, 'variables')
    if a:0
      for l:var in a:000
        unlet! b:sniplate.variables[l:var]
      endfor
    else
      unlet! b:sniplate.variables
    endif
  endif
endfunction "}}}

function! s:insert_lines(lines, line_to_insert, overwrite_line) "{{{
  " line_to_insert は, range(1, line('$')) に入っていなければならない.
  let l:cursor_bck = getpos('.')

  let l:tempfile = tempname()
  call writefile(a:lines, l:tempfile)

  execute 'silent! keepalt ' . a:line_to_insert . 'read `=l:tempfile`'
  if a:overwrite_line
    execute 'silent! .-1 delete _'
  endif

  if l:cursor_bck[1] > a:line_to_insert - 1
    let l:cursor_bck[1] += len(a:lines) - (!!a:overwrite_line)
  endif
  call setpos('.', l:cursor_bck)
endfunction "}}}

function! s:apply_sniplates(sniplates, config, ...) "{{{
  if empty(a:sniplates) | return | endif

  let l:lines = []
  let l:line_to_insert = get(a:000, 0, line('.'))
  " if l:line_to_insert < 0 | let l:line_to_insert = line('.') | endif
  let l:force_insert = get(a:000, 1, 0)
  let l:overwrite = a:config.overwrite "{{{
  if a:sniplates[-1].overwrite != -1
    let l:overwrite = a:sniplates[-1].overwrite
  endif
  if l:overwrite == 2
    let l:overwrite = sniplate#util#is_empty_buffer()
  endif "}}}
  let l:variables = {} "{{{
  if s:sniplate_cache_variable_in_buffer
    if !has_key(b:, 'sniplate') | let b:sniplate = {} | endif
    if !has_key(b:sniplate, 'variables') | let b:sniplate.variables = {} | endif
    let l:variables = b:sniplate.variables  "NOTE: shallow
  endif "}}}

  for l:sniplate in a:sniplates "{{{
    if !l:force_insert && sniplate#util#is_already_insert(l:sniplate)
      continue
    endif
    for l:line in l:sniplate.lines
      if l:line =~ a:config.keyword_pattern
        let [l:operator, l:operand]
              \ = matchlist(l:line, a:config.keyword_pattern)[1:2]
        " keywords which is delete line {{{
        if 0

        elseif l:operator =~ 'exec'
          execute l:operand
          continue

        elseif l:operator =~ 'let'
          let [l:var_name, l:val] =
                \ matchlist(l:operand, '\s*\(.\{-\}\)\s*:\(.*\)')[1:2]
          let l:variables[l:var_name] = eval(l:val)
          unlet l:var_name
          unlet l:val
          continue

        elseif l:operator =~ 'input'
          let [l:var_name, l:input_args]
                \ = matchlist(l:operand, '\s*\(.\{-\}\)\s*:\(.*\)')[1:2]
          if !has_key(l:variables, l:var_name)
            let l:variables[l:var_name] =
                  \ eval('sniplate#util#input_variable('
                  \ . string(l:var_name) . ', '. l:input_args . ')')
          endif
          unlet l:var_name
          unlet l:input_args
          continue
        endif
        "}}}

        " construct line "{{{
        " eval "{{{
        let l:edit_flg = 1
        while l:line =~ a:config.keyword_pattern && l:edit_flg
          let l:edit_flg = 0
          let [l:operator, l:operand] =
                \ matchlist(l:line, a:config.keyword_pattern)[1:2]
          if l:operator =~ 'eval'
            let l:line = substitute(
                  \ l:line, a:config.keyword_pattern, eval(l:operand), '')
            let l:edit_flg = 1
          endif
        endwhile "}}}

        " var "{{{
        let l:edit_flg = 1
        while l:line =~ a:config.keyword_pattern && l:edit_flg
          let l:edit_flg = 0
          let [l:operator, l:operand] =
                \ matchlist(l:line, a:config.keyword_pattern)[1:2]
          if l:operator =~ 'var'
            if !has_key(l:variables, l:operand)
              let l:variables[l:operand] =
                    \ sniplate#util#input_variable(l:operand)
            endif
            let l:line = substitute(
                  \ l:line, a:config.keyword_pattern, l:variables[l:operand], '')
            let l:edit_flg = 1
          endif
        endwhile "}}}

        " cursor "{{{
        let l:edit_flg = 1
        while l:line =~ a:config.keyword_pattern && l:edit_flg
          let l:edit_flg = 0
          let [l:operator, l:operand] =
                \ matchlist(l:line, a:config.keyword_pattern)[1:2]
          if l:operator =~ 'cursor'
            let l:cursor_pos = getpos('.')
            let l:cursor_pos[1] = l:line_to_insert + len(l:lines) + !l:overwrite
            let l:cursor_pos[2] = match(l:line, a:config.keyword_pattern, '')
            let l:line = substitute(l:line, a:config.keyword_pattern, '', '')
            let l:edit_flg = 1
          endif
        endwhile "}}}
        "}}}
      endif
      call add(l:lines, l:line)
    endfor
  endfor "}}}

  call s:insert_lines(l:lines, l:line_to_insert, l:overwrite)

  if exists('l:cursor_pos')
    call setpos('.', l:cursor_pos)
  endif
endfunction "}}}

function! s:apply_sniplate(sniplate, config, ...) "{{{
  call call('s:apply_sniplates',
        \ [[a:sniplate], a:config] + a:000)
endfunction "}}}

function! s:apply_sniplates_with_require(sniplates, config, ...) "{{{
  let l:sniplist = []
  for l:sniplate in a:sniplates
    call sniplate#util#marge(l:sniplist,
          \ s:enumerate_connected_sniplates(l:sniplate),
          \ 'v:val.name')
  endfor
  call call('s:apply_sniplates',
        \ [l:sniplist, a:config] + a:000)
endfunction "}}}

function! s:apply_sniplate_with_require(sniplate, config, ...) "{{{
  call call('s:apply_sniplates_with_require',
        \ [[a:sniplate], a:config] + a:000)
endfunction "}}}
"}}}

" function for user "{{{
function! sniplate#enumerate_sniplates(...) "{{{
  " 引数はファイルタイプ. 省略時は&ft.
  let l:filetype = get(a:000, 0, &ft)
  return s:enumerate_sniplates(s:get_filetype_config(l:filetype))
endfunction "}}}

function! sniplate#remove_invisible(sniplates) "{{{
  return filter(a:sniplates, '!v:val.is_invisible')
endfunction "}}}

function! sniplate#enumerate_classes(...) "{{{
  " 引数はファイルタイプ. 省略時は&ft.
  let l:filetype = get(a:000, 0, &ft)
  return deepcopy(s:enumerate_classes(s:get_filetype_config(l:filetype)).items())
endfunction "}}}

function! sniplate#enumerate_sniplates_has_class(class, ...) "{{{
  " 2番目の引数はファイルタイプ. 省略時は&ft.
  let l:filetype = get(a:000, 0, &ft)
  return s:enumerate_sniplates_has_class(a:class, s:get_filetype_config(l:filetype))
endfunction "}}}

function! sniplate#enumerate_sniplates_has_all_classes(classes, ...) "{{{
  " 2番目の引数はファイルタイプ. 省略時は&ft.
  let l:filetype = get(a:000, 0, &ft)
  return s:enumerate_sniplates_has_all_classes(a:classes, s:get_filetype_config(l:filetype))
endfunction "}}}

function! sniplate#enumerate_sniplates_has_any_classes(classes, ...) "{{{
  " 2番目の引数はファイルタイプ. 省略時は&ft.
  let l:filetype = get(a:000, 0, &ft)
  return s:enumerate_sniplates_has_any_classes(a:classes, s:get_filetype_config(l:filetype))
endfunction "}}}

function! sniplate#has_sniplate(sniplate_name, ...) "{{{
  return has_key(
        \ call('sniplate#enumerate_sniplates', a:000),
        \ a:sniplate_name)
endfunction "}}}

function! sniplate#clear_cached_sniplates(...) "{{{
  " 引数はファイルタイプ. 複数指定可能. 省略時は全て.
  call call('s:clear_cached_sniplates',
        \ map(deepcopy(a:000), 's:get_filetype_config(v:val)'))
endfunction "}}}

function! sniplate#enumerate_cached_variables() "{{{
  return s:enumerate_cached_variables()
endfunction "}}}

function! sniplate#clear_cached_variables(...) "{{{
  " 引数は変数名. 複数指定可能. 省略時は全て.
  call call('s:clear_cached_variables', a:000)
endfunction "}}}

function! sniplate#set_variable(var, val, ...) "{{{
  call call('s:set_variable',
        \ [a:var, a:val]
        \ + a:000)
endfunction "}}}

function! sniplate#apply_sniplates(sniplates, ...) "{{{
  if empty(a:sniplates) | return | endif
  let l:config = s:get_filetype_config(a:sniplates[0].filetype)
  call call('s:apply_sniplates_with_require',
        \ [a:sniplates, l:config]
        \ + a:000)
endfunction "}}}

function! sniplate#apply_sniplate(sniplate, ...) "{{{
  " 引数は sniplate 変数. 通常は from_name を用いるべき.
  call call('sniplate#apply_sniplates',
        \ [[a:sniplate]]
        \ + a:000)
endfunction "}}}

function! sniplate#apply_sniplates_from_name(sniplate_names, ...) "{{{
  " 引数はスニペット名のリスト.
  let l:all_sniplates = sniplate#enumerate_sniplates()
  let l:sniplates = []
  for l:sniplate_name in a:sniplate_names
    if !has_key(l:all_sniplates, l:sniplate_name)
      echoerr 'sniplate ' . l:sniplate_name . ' not found'
      return
    endif
    call add(l:sniplates, l:all_sniplates[l:sniplate_name])
  endfor
  call call('sniplate#apply_sniplates',
        \ [l:sniplates]
        \ + a:000)
endfunction "}}}

function! sniplate#apply_sniplate_from_name(sniplate_name, ...) "{{{
  " 引数はスニペット名.
  call call('sniplate#apply_sniplates_from_name',
        \ [[a:sniplate_name]]
        \ + a:000)
endfunction "}}}

function! sniplate#load_sniplate(...) "{{{
  " same as apply_sniplate_from_name
  call call('sniplate#apply_sniplate_from_name', a:000)
endfunction "}}}

function! sniplate#load_sniplates(...) "{{{
  " same as apply_sniplates_from_name
  call call('sniplate#apply_sniplates_from_name', a:000)
endfunction "}}}

function! sniplate#load_sniplates_if_exists(sniplate_names, ...) "{{{
  let l:valid_names = filter(deepcopy(a:sniplate_names),
        \ 'sniplate#has_sniplate(v:val)')
  call call('sniplate#load_sniplates',
        \ [l:valid_names]
        \ + a:000)
endfunction "}}}

function! sniplate#load_sniplate_if_exists(sniplate_name, ...) "{{{
  call call('sniplate#load_sniplates_if_exists',
        \ [[a:sniplate_name]]
        \ + a:000)
endfunction "}}}
"}}}

" for commands completion"{{{
" unite 向けは unite/source/*.vim で直接作っている

function! sniplate#complete(arglead, cmdline, cursorpos) "{{{
  let l:all_sniplates = sniplate#enumerate_sniplates()
  call sniplate#remove_invisible(l:all_sniplates)
  let l:res = filter(values(l:all_sniplates),
        \ 'stridx(tolower(v:val.name), tolower(a:arglead)) >= 0')
  call sniplate#util#sort_by(l:res, 'stridx(tolower(a:1.name), tolower(' . string(a:arglead) . '))')
  call sniplate#util#sort_by(l:res, '-a:1.priority')
  return map(l:res, 'v:val.name')
endfunction "}}}

function! sniplate#complete_cached_variables(arglead, cmdline, cursorpos) "{{{
  let l:res = filter(keys(sniplate#enumerate_cached_variables()),
        \ 'stridx(tolower(v:val), tolower(a:arglead)) >= 0')
  call sniplate#util#sort_by(l:res, 'stridx(tolower(a:1), tolower(' . string(a:arglead) . '))')
  return l:res
endfunction "}}}

function! sniplate#complete_classes(arglead, cmdline, cursorpos) "{{{
  " 今は使われていない
  let l:res = filter(sniplate#enumerate_classes(),
        \ 'stridx(tolower(v:val), tolower(a:arglead)) >= 0')
  call sniplate#util#sort_by(l:res, 'stridx(tolower(a:1), tolower(' . string(a:arglead) . '))')
  return l:res
endfunction "}}}
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
