import xlrd


def list_to_string(s):
    str1 = ""
    for str_data in s:
        str1 += str_data + '\t|'

    return str1


def scr_text(file_name):

    open_book = xlrd.open_workbook(file_name)  #open worksbook
    len_sheet = open_book.nsheets
    scr_txt = 'SCR_Tracker.txt'
    write_to_files(scr_txt, 'SCR Tracker Info')
    for sheet_1 in range(len_sheet):
        first_sheet = open_book.sheet_by_index(sheet_1)
        for row_n in range(first_sheet.nrows):
            row1 = first_sheet.row_values(row_n, start_colx=0, end_colx=None)
            write_data = list_to_string(row1)
            write_to_files_append(scr_txt, write_data)


def write_to_files(stub_filename, str_data):
    file_write1 = open(stub_filename, "w+")
    file_write1.write(str_data)
    file_write1.write("\n")
    file_write1.close()


def write_to_files_append(stub_filename, str_data):
    file_write1 = open(stub_filename, "a+")
    file_write1.write(str_data)
    file_write1.write("\n")
    file_write1.close()


file_name = 'SCR_Tracker.xlsx'
scr_text(file_name)
