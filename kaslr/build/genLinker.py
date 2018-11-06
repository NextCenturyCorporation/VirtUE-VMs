'''
pip install pyelftools
https://github.com/eliben/pyelftools/
'''

import sys
from elftools.elf.elffile import ELFFile
import json

#-------------------------------------------------------------------
ARCH_SHF_SMALL = 0 # for x86 processors

# sh_flags
SHF_WRITE		    = 0x1
SHF_ALLOC		    = 0x2
SHF_EXECINSTR		= 0x4
SHF_RELA_LIVEPATCH	= 0x00100000
SHF_RO_AFTER_INIT	= 0x00200000
SHF_MASKPROC		= 0xf0000000

section_masks = [
	[ SHF_EXECINSTR | SHF_ALLOC, ARCH_SHF_SMALL ],
	[ SHF_ALLOC, SHF_WRITE | ARCH_SHF_SMALL ],
	[ SHF_RO_AFTER_INIT | SHF_ALLOC, ARCH_SHF_SMALL ],
	[ SHF_WRITE | SHF_ALLOC, ARCH_SHF_SMALL ],
	[ ARCH_SHF_SMALL | SHF_ALLOC, 0 ]
]
#-------------------------------------------------------------------
# All possible relocations
rela_map = {'out': '.rela.dyn', 'in': '''
    *(.rela.init)
    *(.rela.text .rela.text.* .rela.gnu.linkonce.t.*)
    *(.rela.fini)
    *(.rela.rodata .rela.rodata.* .rela.gnu.linkonce.r.*)
    *(.rela.data .rela.data.* .rela.gnu.linkonce.d.*)
    *(.rela.tdata .rela.tdata.* .rela.gnu.linkonce.td.*)
    *(.rela.tbss .rela.tbss.* .rela.gnu.linkonce.tb.*)
    *(.rela.ctors)
    *(.rela.dtors)
    *(.rela.got)
    *(.rela.bss .rela.bss.* .rela.gnu.linkonce.b.*)
    *(.rela.ldata .rela.ldata.* .rela.gnu.linkonce.l.*)
    *(.rela.lbss .rela.lbss.* .rela.gnu.linkonce.lb.*)
    *(.rela.lrodata .rela.lrodata.* .rela.gnu.linkonce.lr.*)
    *(.rela.ifunc)
    *(.rela.plt)
    *(.rela.iplt)
    *(.rela.*)
'''}

# Our special relocation
rela_special = {'out':'.relahxnstruct', 'in':'*(.relahxnstruct)'}
#-------------------------------------------------------------------

def write_linker_file(filename, data):
    file_data = 'SECTIONS{{{}\n}}'
    body = '\n   . = SEGMENT_START("text-segment", 0) + SIZEOF_HEADERS;\n'
    
    for sec_group in data:
        if len( sec_group ) > 0:
            body = body + '\n/* ------ %s -------- */' % 'new page'
            body = body + '\n   . = ALIGN(4096);'
            for sec in sec_group:
                out_name = sec['out']
                in_name = sec['in']
                body = body +  "\n   {} : {{ {} }}".format( out_name, in_name )

    file_data =  file_data.format( body )

    with open(filename, 'w') as f:
        f.write(file_data)

def mergeSections(map_list_list, mlist):
    def removeStartsWith(map_list_list, name):
        index = None
        for i,map_list in enumerate(map_list_list):
            if any( [item['out'].startswith(name) for item in map_list] ):
                map_list_list[i] = [item for item in map_list if not item['out'].startswith(name)]
                if index and index != i: raise Exception('Merge Error')
                index = i
        
        return index

    for name in mlist:
        i = removeStartsWith(map_list_list, name)
        if i:
            out_name = name
            in_name = '*(%s.*)'%name
            map_list_list[i].append( {'out': out_name, 'in': in_name} )

    return map_list_list

'''
Returns section placements as expected by linux kernel.
Sections represented as a list of lists
'''
def getSectionPlacements(sections, ignore=[]):
    # These sections flags are removed in rewrite_section_headers() function
    expections = ['.modinfo', '__versions']
    input_sections = list()

    for sect in sections: sect.done = False
    
    for i,mask in enumerate(section_masks):
        sect_group = list()
        for sect in sections:
            sh_flags = sect.header['sh_flags']
            sh_entsize = sect.header['sh_entsize']
            if (sh_flags & mask[0]) != mask[0] or ((sh_flags & mask[1]) != 0) or sect.done or any([sect.name.startswith(ex) for ex in expections]):
                continue
            sect.done = True
            should_ignore = any([sect.name.startswith(ig) for ig in ignore])
            if sect.name and not should_ignore: sect_group.append( sect.name )
        input_sections.append( sect_group )

    # Add uncategorized sections
    input_sections.append( [sect.name for sect in sections if sect.name and not sect.done] )
    
    input_sections = [x for x in input_sections if x] # remove empty lists
    
    return input_sections

'''
Generates the linkerscipt that rearanges the sections according to linux's expections
Writes a file named linkerscript.ld 
'''
def process_file(filename):
    # Read File
    with open(filename, 'rb') as f:
        sections = list( ELFFile(f).iter_sections() )

    input_sections = getSectionPlacements(sections, ignore=['.rela'])

    section_map = list()

    for input_section in input_sections:
        map = list()
        for in_name in input_section:
            if in_name.startswith('.init'):
                out_name = '.x' + in_name
            else:
                out_name = in_name

            map.append( {'out': out_name, 'in': '*(%s)'%in_name} )
        section_map.append( map )

    # mergeSections(section_map, ['.rela'])

    # section_map[1].insert(0, {'out':'.rela.dyn', 'in':'.rela.dyn'})
    section_map[1].insert(0, rela_special)
    section_map[1].insert(0, rela_map)

    write_linker_file('linkerscript.ld', section_map)

'''
Verifies if the the file respects the arrangement of sections as expected by the linux kernel
Returns true if correct, false if incorrect
'''
def isCorrectPlacement(filename):
    # Read File
    with open(filename, 'rb') as f:
        sections = list( ELFFile(f).iter_sections() )

    correct = getSectionPlacements(sections)
    correct = [item for sublist in correct for item in sublist] # flatten
    actual = [sect.name for sect in sections if sect.name]

    for i in range(len(correct)):
        # print correct[i], '-'*3 ,actual[i]
        if correct[i] != actual[i]:
            return False


    return True

if __name__ == '__main__':
    if len(sys.argv) > 1 :
        if sys.argv[1] == '-v' or sys.argv[1] == '--verify':
            result = [isCorrectPlacement(filename) for filename in sys.argv[2:]]
            print result
            sys.exit( 0 if all(result) else 1 )
        else:
            for filename in sys.argv[1:]:
                process_file(filename)
    else:
        sys.exit("Error: Please specify an object *.ko file")