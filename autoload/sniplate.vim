"=============================================================================
" FILE:           sniplate.vim
" AUTHOR:         Mi_Sawa <mi.sawa.1216+vim@gmail.com>
" Last Modified:  9 Feb 2013.
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
  let filetype = empty(a:filetype) ? 'nothing' : a:filetype
  let default = {'directory': filetype}
  let force = {'filetype': filetype}
  let config = {}
  for var in [
        \ 'default',
        \ 's:sniplate_filetype_config["_"]',
        \ 'g:sniplate#filetype_config["_"]',
        \ 'g:sniplate#filetype_config[filetype]',
        \ 'force',
        \ ]
    if exists(var)
      call extend(config, eval(var), "force")
    endif
  endfor
  return config
endfunction "}}}

"{{{ variables
let s:sniplate_filetype_config = {
      \ '_': {
      \  'keyword_pattern' : '{{\s*\(.\{-\}\)\s*\%(:\s*\(.\{-\}\)\s*\%(:\s*\(.\{-\}\)\s*\)\?\)\?}}',
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
  let res             = {
        \ 'require'        : [],
        \ 'pattern'        : '',
        \ 'abbr'           : '',
        \ 'priority'       : 0,
        \ 'is_invisible'   : 0,
        \ 'overwrite'      : -1,
        \ }
  let res.class       = sniplate#util#set#emptyset()
  let res.raw_lines   = split(a:str, "\n")
  let res.path        = a:sniplate_file
  let res.line_number = a:line_number
  let res.name        = matchlist(res.raw_lines[0],
        \ '\C' . s:sniplate_begin_keyword . '\s*\(\S*\)\s*')[1]
  let res.lines       = []
  let res.filetype    = a:config.filetype

  for line in res.raw_lines[1:-2]
    if line =~ a:config.keyword_pattern
      let [operator, operand, arg]
            \ = matchlist(line, a:config.keyword_pattern)[1:3]
      "{{{
      if 0

      elseif operator ==# 'class'
        call res.class.add_items(split(operand, '\s*,\s*'))

      elseif operator ==# 'require'
        call extend(res.require, split(operand, '\s*,\s*'))

      elseif operator ==# 'pattern'
        let res.pattern = operand

      elseif operator ==# 'abbr'
        let res.abbr = operand

      elseif operator ==# 'priority'
        let res.priority = operand

      elseif operator ==# 'invisible'
        let res.is_invisible = 1

      elseif operator ==# 'overwrite'
        let res.overwrite = sniplate#util#convert_to_012(
              \ operand,
              \ printf('in sniplate "%s", overwrite must be 0/1/2/false/true/auto', res.name)
              \ )

      else
        call add(res.lines, line)
      endif
      "}}}
    else
      call add(res.lines, line)
    endif
  endfor
  return res
endfunction "}}}

function! s:enumerate_sniplates_from_file(sniplate_file, config) "{{{
  if !filereadable(a:sniplate_file) | return {} | endif
  let all_text = join([''] + readfile(a:sniplate_file, 'b'), "\n")
  let pattern = "\\C\n[^\n]\\{-\\}" . s:sniplate_begin_keyword . ".\\{-\\}" . s:sniplate_end_keyword . ".\\{-\\}\n"
  let i = 1
  let sniplates = {}
  while 1
    let snip_text = matchstr(all_text, pattern, 0, i)
    if strlen(snip_text) == 0
      break
    endif
    let linenr = count(split(all_text[0 : match(all_text, pattern, 0, i)], '\zs'), "\n")
    let temp = s:parse_sniplate(snip_text, a:sniplate_file, linenr, a:config)
    if has_key(sniplates, temp.name)
      echoerr "sniplate name " . string(temp.name) . " must be unique"
    endif
    let sniplates[temp.name] = temp
    unlet temp
    let i += 1
  endwhile
  return sniplates
endfunction "}}}

function! s:enumerate_sniplate_files(config) "{{{
  let sniplate_directory = join(
        \ [s:sniplates_directory, a:config.directory, '**'], '/')
  return filter(split(globpath(sniplate_directory, '*'), '\n'), '!isdirectory(v:val)')
endfunction "}}}


function! s:noncached_enumerate_sniplates(config) "{{{
  let sniplate_files = s:enumerate_sniplate_files(a:config)
  let sniplates = {}
  for sniplate_file in sniplate_files
    let new_sniplates =
          \ s:enumerate_sniplates_from_file(sniplate_file, a:config)
    for [snipname, sniplate] in items(new_sniplates)
      if has_key(sniplates, snipname)
        echoerr "sniplate name " . string(snipname) . " must be unique"
      endif
      let sniplates[snipname] = sniplate
    endfor
    " call extend(sniplates,
    "       \ s:enumerate_sniplates_from_file(sniplate_file, a:config), "error" )
  endfor
  return sniplates
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
    for config in a:000
      unlet! s:cached_sniplates[config.filetype]
    endfor
  endif
endfunction "}}}

function! s:enumerate_connected_sniplates(sniplate) "{{{
  let stack = [a:sniplate.name]
  let sniplates = s:enumerate_sniplates(
        \ s:get_filetype_config(a:sniplate.filetype) )
  let res = []
  let state = {}
  while !empty(stack)
    let last = stack[-1]
    if has_key(state, last)
      while !empty(state[last])
            \ && has_key(state, state[last][0])
        call remove(state[last], 0)
      endwhile
      if empty(state[last])
        call add(res, sniplates[remove(stack, -1)])
      else
        call add(stack, remove(state[stack[-1]], 0))
      endif
    else
      let state[last] = deepcopy(sniplates[last].require)
    endif
  endwhile
  return res
endfunction "}}}


function! s:enumerate_sniplates_has_class(class, config) "{{{
  let all_sniplates = s:enumerate_sniplates(a:config)
  let res = {}
  for [snipname, sniplate] in items(all_sniplates)
    if sniplate.class.has(a:class)
      let res[snipname] = sniplate
    endif
  endfor
  return res
endfunction "}}}

function! s:enumerate_sniplates_has_all_classes(classes, config) "{{{
  let all_sniplates = s:enumerate_sniplates(a:config)
  let res = {}
  for [snipname, sniplate] in items(all_sniplates)
    if sniplate.class.has_all(a:classes)
      let res[snipname] = sniplate
    endif
  endfor
  return res
endfunction "}}}

function! s:enumerate_sniplates_has_any_classes(classes, config) "{{{
  let all_sniplates = s:enumerate_sniplates(a:config)
  let res = {}
  for [snipname, sniplate] in items(all_sniplates)
    if sniplate.class.has_any(a:classes)
      let res[snipname] = sniplate
    endif
  endfor
  return res
endfunction "}}}

function! s:enumerate_classes(config) "{{{
  let res = sniplate#util#set#emptyset()
  let all_sniplates = s:enumerate_sniplates(a:config)
  for [snipname, sniplate] in items(all_sniplates)
    call res.union(sniplate.class)
  endfor
  return res
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
    let variables = a:1
  elseif s:sniplate_cache_variable_in_buffer
    if !has_key(b:, 'sniplate') | let b:sniplate = {} | endif
    if !has_key(b:sniplate, 'variables') | let b:sniplate.variables = {} | endif
    let variables = b:sniplate.variables
  else
    return
  endif
  let variables[a:var] = a:val
endfunction "}}}

function! s:clear_cached_variables(...) "{{{
  if has_key(b:, 'sniplate') && has_key(b:sniplate, 'variables')
    if a:0
      for var in a:000
        unlet! b:sniplate.variables[var]
      endfor
    else
      unlet! b:sniplate.variables
    endif
  endif
endfunction "}}}

function! s:insert_lines(lines, line_to_insert, overwrite_line) "{{{
  " line_to_insert は, range(1, line('$')) に入っていなければならない.
  let cursor_bck = getpos('.')

  let tempfile = tempname()
  call writefile(a:lines, tempfile)

  execute 'silent! keepalt ' . a:line_to_insert . 'read `=tempfile`'
  if a:overwrite_line
    execute 'silent! .-1 delete _'
  endif

  if cursor_bck[1] > a:line_to_insert - 1
    let cursor_bck[1] += len(a:lines) - (!!a:overwrite_line)
  endif
  call setpos('.', cursor_bck)
endfunction "}}}

function! s:apply_sniplates(sniplates, config, ...) "{{{
  if empty(a:sniplates) | return | endif

  let lines = []
  let line_to_insert = get(a:000, 0, line('.'))
  " if line_to_insert < 0 | let line_to_insert = line('.') | endif
  let force_insert = get(a:000, 1, 0)
  let overwrite = a:config.overwrite "{{{
  if a:sniplates[-1].overwrite != -1
    let overwrite = a:sniplates[-1].overwrite
  endif
  if overwrite == 2
    let overwrite = sniplate#util#is_empty_buffer()
  endif "}}}
  let variables = {} "{{{
  if s:sniplate_cache_variable_in_buffer
    if !has_key(b:, 'sniplate') | let b:sniplate = {} | endif
    if !has_key(b:sniplate, 'variables') | let b:sniplate.variables = {} | endif
    let variables = b:sniplate.variables  "NOTE: shallow
  endif "}}}
  let indent_whitspace = matchstr(getline(line_to_insert), '\s*')

  for sniplate in a:sniplates "{{{
    if !force_insert && sniplate#util#is_already_insert(sniplate)
      continue
    endif
    for line in sniplate.lines
      if line =~ a:config.keyword_pattern
        let [operator, operand, arg]
              \ = matchlist(line, a:config.keyword_pattern)[1:3]
        " keywords which is delete line {{{
        if 0

        elseif operator ==# 'exec'
          execute operand
          continue

        elseif operator ==# 'let'
          let variables[operand] = eval(arg)
          continue

        elseif operator ==# 'input' || operator ==# 'input!'
          if !has_key(variables, operand) || operator ==# 'input!'
            let variables[operand] =
                  \ eval('sniplate#util#input_variable('
                  \ . string(operand) . ', '. arg . ')')
          endif
          continue
        endif
        "}}}

        " construct line "{{{
        " eval "{{{
        let edit_flg = 1
        while line =~ a:config.keyword_pattern && edit_flg
          let edit_flg = 0
          let [operator, operand, arg] =
                \ matchlist(line, a:config.keyword_pattern)[1:3]
          if operator ==# 'eval'
            let line = substitute(
                  \ line, a:config.keyword_pattern, eval(operand), '')
            let edit_flg = 1
          endif
        endwhile "}}}

        " var "{{{
        let edit_flg = 1
        while line =~ a:config.keyword_pattern && edit_flg
          let edit_flg = 0
          let [operator, operand, var] =
                \ matchlist(line, a:config.keyword_pattern)[1:3]
          if operator ==# 'var'
            if !has_key(variables, operand)
              let variables[operand] =
                    \ sniplate#util#input_variable(operand)
            endif
            let line = substitute(
                  \ line, a:config.keyword_pattern, variables[operand], '')
            let edit_flg = 1
          endif
        endwhile "}}}

        " cursor "{{{
        let edit_flg = 1
        while line =~ a:config.keyword_pattern && edit_flg
          let edit_flg = 0
          let [operator, operand, var] =
                \ matchlist(line, a:config.keyword_pattern)[1:3]
          if operator ==# 'cursor'
            let cursor_pos = getpos('.')
            let cursor_pos[1] = line_to_insert + len(lines) + !overwrite
            let cursor_pos[2] = match(line, a:config.keyword_pattern, '')
            let cursor_pos[2] += len(indent_whitspace)
            let line = substitute(line, a:config.keyword_pattern, '', '')
            let edit_flg = 1
          endif
        endwhile "}}}
        "}}}
      endif
      call add(lines, indent_whitspace . line)
    endfor
  endfor "}}}

  call s:insert_lines(lines, line_to_insert, overwrite)

  if exists('cursor_pos')
    call setpos('.', cursor_pos)
  endif
endfunction "}}}

function! s:apply_sniplate(sniplate, config, ...) "{{{
  call call('s:apply_sniplates',
        \ [[a:sniplate], a:config] + a:000)
endfunction "}}}

function! s:apply_sniplates_with_require(sniplates, config, ...) "{{{
  let sniplist = []
  for sniplate in a:sniplates
    call sniplate#util#marge(sniplist,
          \ s:enumerate_connected_sniplates(sniplate),
          \ 'v:val.name')
  endfor
  call call('s:apply_sniplates',
        \ [sniplist, a:config] + a:000)
endfunction "}}}

function! s:apply_sniplate_with_require(sniplate, config, ...) "{{{
  call call('s:apply_sniplates_with_require',
        \ [[a:sniplate], a:config] + a:000)
endfunction "}}}
"}}}

" function for user "{{{
function! sniplate#enumerate_sniplates(...) "{{{
  " 引数はファイルタイプ. 省略時は&ft.
  let filetype = get(a:000, 0, &ft)
  return s:enumerate_sniplates(s:get_filetype_config(filetype))
endfunction "}}}

function! sniplate#remove_invisible(sniplates) "{{{
  return filter(a:sniplates, '!v:val.is_invisible')
endfunction "}}}

function! sniplate#enumerate_classes(...) "{{{
  " 引数はファイルタイプ. 省略時は&ft.
  let filetype = get(a:000, 0, &ft)
  return deepcopy(s:enumerate_classes(s:get_filetype_config(filetype)).items())
endfunction "}}}

function! sniplate#enumerate_sniplates_has_class(class, ...) "{{{
  " 2番目の引数はファイルタイプ. 省略時は&ft.
  let filetype = get(a:000, 0, &ft)
  return s:enumerate_sniplates_has_class(a:class, s:get_filetype_config(filetype))
endfunction "}}}

function! sniplate#enumerate_sniplates_has_all_classes(classes, ...) "{{{
  " 2番目の引数はファイルタイプ. 省略時は&ft.
  let filetype = get(a:000, 0, &ft)
  return s:enumerate_sniplates_has_all_classes(a:classes, s:get_filetype_config(filetype))
endfunction "}}}

function! sniplate#enumerate_sniplates_has_any_classes(classes, ...) "{{{
  " 2番目の引数はファイルタイプ. 省略時は&ft.
  let filetype = get(a:000, 0, &ft)
  return s:enumerate_sniplates_has_any_classes(a:classes, s:get_filetype_config(filetype))
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
  let config = s:get_filetype_config(a:sniplates[0].filetype)
  call call('s:apply_sniplates_with_require',
        \ [a:sniplates, config]
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
  let all_sniplates = sniplate#enumerate_sniplates()
  let sniplates = []
  for sniplate_name in a:sniplate_names
    if !has_key(all_sniplates, sniplate_name)
      echoerr 'sniplate ' . sniplate_name . ' not found'
      return
    endif
    call add(sniplates, all_sniplates[sniplate_name])
  endfor
  call call('sniplate#apply_sniplates',
        \ [sniplates]
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
  let valid_names = filter(deepcopy(a:sniplate_names),
        \ 'sniplate#has_sniplate(v:val)')
  call call('sniplate#load_sniplates',
        \ [valid_names]
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
  let all_sniplates = sniplate#enumerate_sniplates()
  call sniplate#remove_invisible(all_sniplates)
  let res = filter(values(all_sniplates),
        \ 'stridx(tolower(v:val.name), tolower(a:arglead)) >= 0')
  call sniplate#util#sort_by(res, 'stridx(tolower(a:1.name), tolower(' . string(a:arglead) . '))')
  call sniplate#util#sort_by(res, '-a:1.priority')
  return map(res, 'v:val.name')
endfunction "}}}

function! sniplate#complete_cached_variables(arglead, cmdline, cursorpos) "{{{
  let res = filter(keys(sniplate#enumerate_cached_variables()),
        \ 'stridx(tolower(v:val), tolower(a:arglead)) >= 0')
  call sniplate#util#sort_by(res, 'stridx(tolower(a:1), tolower(' . string(a:arglead) . '))')
  return res
endfunction "}}}

function! sniplate#complete_classes(arglead, cmdline, cursorpos) "{{{
  " 今は使われていない
  let res = filter(sniplate#enumerate_classes(),
        \ 'stridx(tolower(v:val), tolower(a:arglead)) >= 0')
  call sniplate#util#sort_by(res, 'stridx(tolower(a:1), tolower(' . string(a:arglead) . '))')
  return res
endfunction "}}}
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:se ts=2 sw=2 sts=2 fenc=utf-8 ff=unix ft=vim foldmethod=marker :
