function! beyul#io#Read(path)
    exe "cd ".fnamemodify(a:path, ":h")
    let lines = readfile(a:path)
    " get header data as a dictionary
    let b:beyul_header_data = {}
    for section in split(lines[0], ",")
        let section_data = split(section, ":")
        let b:beyul_header_data[section_data[0]] = section_data[1]
    endfor
    " set filetype, if set in the header
    if has_key(b:beyul_header_data, 'ft')
        exe 'setfiletype '.b:beyul_header_data['ft']
    endif
    " we use this to check if the header data has been modified since the 
    " last save
    let b:ondisk_beyul_header_data = copy(b:beyul_header_data)
    " process the file according to the fileformat version provided
    if b:beyul_header_data['version'] == 'mk1'
        call beyul#io#ReadMk1(lines[1:])
    endif
    " update the ft in the header on :set ft and :setfiletype
    au Filetype <buffer> call beyul#io#UpdateFT(expand('<amatch>'))
endfunction

function! beyul#io#UpdateFT(ft)
    let b:beyul_header_data['ft'] = a:ft
endfunction

function! beyul#io#ReadMk1(data)
    for line in a:data
        call append(line('$'), readfile(line))
    endfor
    normal! dd
    let b:final_line = line('$')
endfunction

function! s:HeaderDictAsText()
    let sections = []
    for section in keys(b:beyul_header_data)
        call add(sections, section . ":".b:beyul_header_data[section])
    endfor
    return join(sections, ",")
endfunction

function! beyul#io#Write(path)
    " check for changes (is `modified` set?) in text and in the header
    if &modified || b:ondisk_beyul_header_data != b:beyul_header_data 
        " read old_data 
        let fl = readfile(a:path)
        " update the header
        let fl[0] = s:HeaderDictAsText()
        " update the body, according to fileformat version
        if b:beyul_header_data['version'] == "mk1"
            let fl = beyul#io#UpdateBodyMk1(fl, a:path)
        endif
        call writefile(fl, a:path)
        " update b:ondisk_beyul_header_data so we won't need to recheck again
        let b:ondisk_beyul_header_data = copy(b:beyul_header_data)
        setlocal nomodified
    endif
endfunction

function! beyul#io#UpdateBodyMk1(data, path)
    " in the mk1 scheme, we only save appends to the file
    " we should probably compress things so the collection
    " of files is protected and the "document" is self contained.
    if line('$') > b:final_line
        let new_fname = fnamemodify(a:path, ":t:r").".".localtime().".part"
        silent exe b:final_line+1.",".line('$')." w ".new_fname
        let fl = add(a:data, new_fname)
        let b:final_line = line('$')
    endif
    return fl
endfunction
