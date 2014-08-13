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
    let s:final_line = line('$')
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
    normal dd
endfunction

function! s:HeaderDictAsText()
    let sections = []
    for section in keys(b:beyul_header_data)
        call add(sections, section . ":".b:beyul_header_data[section])
    endfor
    return join(sections, ",")
endfunction

function! beyul#io#Write(path)
    " check for changes changes (is `modified` set?)
    if &modified || b:ondisk_beyul_header_data != b:beyul_header_data 
        " extract changes in chunks of continuous lines
        " check if new chunks split old chunks
        " for each chunk, create a file and save the data
        " rebuild the table in the .beyul file
        "
        " for now, we only save appends to the file
        " on this scheme, we should probably compress things so the collection
        " of files is protected and the "document" is self contained.
        let fl = readfile(a:path)
        let fl[0] = s:HeaderDictAsText()
        if b:beyul_header_data['version'] == "mk1"
            if line('$') > s:final_line
                let new_fname = fnamemodify(a:path, ":t:r").".".localtime().".part"
                silent exe s:final_line+1.",".line('$')." w ".new_fname
                let fl = add(fl, new_fname)
                let s:final_line = line('$')
            endif
        endif
        call writefile(fl, a:path)
        let b:ondisk_beyul_header_data = copy(b:beyul_header_data)
        setlocal nomodified
    endif
endfunction

function! beyul#io#Mk1Body(path)
endfunction
