import sys
import shutil, os
import re
import copy

def trim_function_name(function_list,interface_list):
    function_list_t = copy.deepcopy(function_list)
    for intrface in interface_list:
            if intrface in function_list_t:
                function_list_t = intrface
    return function_list_t

class ExtractFunctionDec:

    def __init__(self, header_File):

        file_name = header_File
        print(file_name)
        self.line_apend = []
        self.function_dict = {}
        self.header_file_dict = {}
        self.check_semi = 0

    def read_header_file(self, header_File):
        self.header_file_dict['header_file'] = header_File		
        first_check = 0
        self.fileopen = open(header_File, "r")
        self.list_lines = list(self.fileopen)
        self.len_line = len(self.list_lines)
        avoid_line = ['#define', '//', '#ifndef', '#include', 'extern', '#endif', 'typedef']
        avoid_line1 = ['/*', '*/']
        line_i = 0
        while line_i < self.len_line:
            print(line_i)
            self.line_by_line = self.list_lines[line_i]

            if all(x in self.line_by_line for x in avoid_line1):
                pass
            elif '/*' in self.line_by_line:
                first_check = 0
                pass
            elif '*/' in self.line_by_line:
                first_check = 1
            elif any(x in self.line_by_line for x in avoid_line):
                pass
            elif self.line_by_line == '\n':
                pass

            elif first_check == 1:

                if ';' in self.line_by_line:

                    if self.check_semi:
                        self.line_apend.append(self.line_by_line)
                        self.process_line()
                        self.line_apend = []
                        self.check_semi = 0
                    else:
                        self.process_line()
                        self.check_semi = 0
                else:
                    self.check_semi = 1
                    self.line_apend.append(self.line_by_line)

            line_i = line_i + 1

        print(self.function_dict)
        return self.function_dict, self.header_file_dict

    def process_line(self):
        in_list = {}
        function_dec = {}
        retn_type = {}
        in_datatype = {}

        if self.check_semi == 1:
            str_cat = ''
            remove_newline = [x.replace('\n', '') for x in self.line_apend]
            remove_tab = [x.replace('\t', '') for x in remove_newline]
            for list_data in remove_tab:
                str_cat = str_cat + list_data
        else:
            str_cat = self.line_by_line

        split_by_semi = str_cat.split(';')
        split_by_bracket = re.split("[()]", split_by_semi[0])
        remove_extra_space = split_by_bracket[0].strip()
        split_by_spa = remove_extra_space.split(' ')
        if len(split_by_spa) >= 3:
            return_type = split_by_spa[0] + ' ' + split_by_spa[1] 
            function_name = split_by_spa[2]
        else:
            return_type = split_by_spa[0]
            function_name = split_by_spa[1]

        if '*' in return_type:
            split_ptr = return_type.split('*')
            retn_type['rtrn_data_type'] = split_ptr[0]
            retn_type['rtrn_type'] = 'ptr'
        else:
            retn_type['rtrn_data_type'] = return_type
            retn_type['rtrn_type'] = 'value'

        if 'void' in split_by_bracket[1]:
            retn_type['in_list'] = {}
        elif ',' in split_by_bracket[1]:
            get_inp = split_by_bracket[1].split(',')
            for line1 in get_inp:
                remove_lead_trail_space = line1.strip()

                if '*' in remove_lead_trail_space:
                    split_by_ptr = remove_lead_trail_space.split('*')
                    in_datatype['data_type'] = split_by_ptr[0]
                    in_datatype['arg_type'] = 'ptr'
                    in_list[split_by_ptr[1]] = in_datatype

                else:
                    split_by_spa = remove_lead_trail_space.split(' ')
                    in_datatype['data_type'] = split_by_spa[0]
                    in_datatype['arg_type'] = 'value'
                    in_list[split_by_spa[1]] = in_datatype

            retn_type['in_list'] = in_list

        elif ' ' in split_by_bracket[1]:
            if '*' in split_by_bracket[1]:
                split_by_ptr = split_by_bracket[1].split('*')
                in_datatype['data_type'] = split_by_ptr[0]
                in_datatype['arg_type'] = 'ptr'
                in_list[split_by_ptr[1]] = in_datatype
            else:
                split_by_ptr = split_by_bracket[1].split(' ')
                in_datatype['data_type'] = split_by_ptr[0]
                in_datatype['arg_type'] = 'value'
                in_list[split_by_ptr[1]] = in_datatype

            retn_type['in_list'] = in_list

        function_dec[function_name] = retn_type
        self.function_dict.update(function_dec)


def stub_generation(function_list, header_info,interface_list):
    global_var_list = dict()
    function_name = ''

    get_file_name = header_info.get('header_file')
    split_by_slash = get_file_name.split('\\')
    header_info['header_file'] = split_by_slash[-1]  # updating header file name

    file_name2 = header_info['header_file'].split('/')
    file_name2 = file_name2[len(file_name2)-1].split('.')
    sw_model_name = file_name2[0].split('Rte_')
    sw_model_name = sw_model_name[1]

    file_name = file_name2[0] + '_stub.c'
    header_1 = '#include' + ' "' + sw_model_name + '.h"'
    write_to_files(file_name, header_1)

    write_to_files_append(file_name, '#include "Std_Types.h"')

    write_to_files_append(file_name, '/************* ' + 'Rte Read/Write Variable Declaration' + '****************/')
    for function_name in function_list:
        function_list.get(function_name).update({'in_list_g': copy.deepcopy(function_list.get(function_name).get('in_list'))})
        function_list_temp = copy.deepcopy(function_list)
        suffix_ = ''
        if(('Rte_IStatus' in function_name) or ('Rte_IWriteRef' in function_name)):
            suffix_ = 'ref'
        function_list_t = trim_function_name(function_name,interface_list)+ suffix_
        if len(function_list_temp.get(function_name).get('in_list_g')) != 0:
            for in_list_g in function_list_temp.get(function_name).get('in_list_g'):

                # print(function_list.get(unction_name).get('in_list_g').get('in_list_g'))
                function_list.get(function_name).get('in_list_g').update({
                                                                        function_list_t + '_' + in_list_g: function_list.get(
                                                                            function_name).get('in_list_g').get(in_list_g)})
                function_list.get(function_name).get('in_list_g').__delitem__(in_list_g)
        else:
            data_type_t_h = function_list.get(function_name).get('rtrn_data_type')
            if 'const' in data_type_t_h:
                data_type_t_h = (data_type_t_h.split('const'))[1]
            function_list.get(function_name).update({'rtrn_type_g': {function_list_t + '_g': data_type_t_h.strip()}})

    # print global variables
    global_string = '#endif\n' + header_1;
    for function_name in function_list:
        if len(function_list.get(function_name).get('in_list_g')) != 0:

            for in_list_g in function_list.get(function_name).get('in_list_g'):
                str1 = function_list.get(function_name).get('in_list_g').get(in_list_g).get(
                    'data_type') + ' ' + in_list_g + ';'
                write_to_files_append(file_name, 'extern ' + str1)
                global_string = global_string + '\n' + str1;
        elif len(function_list.get(function_name).get('rtrn_type_g')) != 0:

            for rtrn_type_g in function_list.get(function_name).get('rtrn_type_g'):
                str1 = function_list.get(function_name).get('rtrn_type_g').get(rtrn_type_g) + ' ' + rtrn_type_g + ';'
                write_to_files_append(file_name, 'extern ' + str1)
                global_string = global_string + '\n' + str1;

    write_to_files_append(file_name, '\n/* Model stub function definition */\n')
    for function_name in function_list:
        indendation = '\t'
        in_arg_str = ''
        fcn_def = '{\n'
        length = function_list.get(function_name).get('in_list_g').__len__()
        count = 1
        if length != 0:
            for in_list_g_t in function_list.get(function_name).get('in_list_g'):
                for in_list_t in function_list.get(function_name).get('in_list'):
                    if in_list_t in in_list_g_t:
                        if function_list.get(function_name).get('in_list_g').get(in_list_g_t).get('arg_type') == 'value':
                            type_prefix = ' '
                        elif function_list.get(function_name).get('in_list_g').get(in_list_g_t).get('arg_type') == 'ptr':
                            type_prefix = ' *'

                        if count < length:
                            in_arg_str = in_arg_str + ' ' + function_list.get(function_name).get('in_list').get(
                                in_list_t).get('data_type') + type_prefix + in_list_t + ','
                            count = count + 1
                        elif (count == length) or (length == 0):
                            in_arg_str = in_arg_str + ' ' + function_list.get(function_name).get('in_list').get(
                                in_list_t).get('data_type') + type_prefix + in_list_t
                            count = count + 1
                        break
                fcn_def = fcn_def + indendation + in_list_g_t + ' = ' + type_prefix + in_list_t + ';\n'
        elif len(function_list.get(function_name).get('rtrn_type_g')) != 0:
            type_prefix_t =''
            if(function_list.get(function_name).get('rtrn_type') == 'ptr'):
                type_prefix_t = '&'
            for rtrn_type_g in function_list.get(function_name).get('rtrn_type_g'):
                fcn_def = fcn_def + indendation + 'return ' + type_prefix_t + rtrn_type_g + ';\n'

        fcn_def = fcn_def + '}\n'
        rtrn_type_t =''
        if(function_list.get(function_name).get('rtrn_type') == 'ptr'):
            rtrn_type_t = '*'
        str1 = function_list.get(function_name).get(
            'rtrn_data_type')+rtrn_type_t+ ' ' + function_name + '(' + in_arg_str + ')\n' + fcn_def

        write_to_files_append(file_name, str1)

    return global_string,file_name


def write_to_files(stub_filename, str1):
    file_write1 = open(stub_filename, "w+")
    file_write1.write(str1)
    file_write1.write("\n")
    file_write1.close()


def write_to_files_append(stub_filename, str1):
    file_write1 = open(stub_filename, "a+")
    file_write1.write(str1)
    file_write1.write("\n")
    file_write1.close()

def getListOfFiles(dirName,extension):
    # create a list of file and sub directories 
    # names in the given directory 
    listOfFile = os.listdir(dirName)
    allFiles = list()
    # Iterate over all the entries
    for entry in listOfFile:
        # Create full path
        fullPath = os.path.join(dirName, entry)
        # If entry is a directory then get the list of files in this directory 
        if os.path.isdir(fullPath):
            allFiles = allFiles + getListOfFiles(fullPath,extension)
        else:
            if(fullPath.endswith(extension)):
                allFiles.append(fullPath)
    return allFiles

def processing_info(all_H_Files, interface_list):
    print(all_H_Files)
    print(len(all_H_Files))
    listOfFolders = os.listdir(os.getcwd())
    for dir_name in listOfFolders:
        if 'autosar_rtw' in dir_name:
            ar_fldr = dir_name
            break
    dest_folder = os.getcwd() + '\\'+ar_fldr+'\\'
    h = ExtractFunctionDec(all_H_Files)
    [function_list, header_info] = h.read_header_file(all_H_Files)
    #function_list = trim_function_name(function_list,interface_list)
    if len(function_list) > 1:
        global_string, stub_file_name = stub_generation(function_list, header_info,interface_list)
        #stub_file_name = getListOfFiles(os.getcwd() + '\\'+ar_fldr+'\\'+'stub','.c')
        shutil.move(stub_file_name, dest_folder)
        return global_string


#all_H_Files = UTFrameWork.h_files
#ret = processing_info(all_H_Files)

if __name__ == '__main__':
	x = sys.argv[:]
	print(x[1:])
	#g = processing_info(x[0])
	#z = sys.stdout.write(str(g.squared(x)))
	#z = g.squared(x)