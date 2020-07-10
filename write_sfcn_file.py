def write_src_file(src_file,str_to_write, entry_line, end_line, skip_lines):
        entry_found = 0
        exit_found =0
        line_nbr =0

        with open(src_file, "r") as f:
            lines = f.readlines()
        with open(src_file, "w") as f:
            for line in lines:
                line_nbr = line_nbr+1
                if (entry_found==0):
                    if entry_line in line:
                        entry_found = 1
                        print(line_nbr)
                        line_to_del_start = line_nbr + skip_lines
                if(entry_found==1 and exit_found == 0):
                    if end_line == line:
                        line_to_del_end =line_nbr - 1
                        exit_found = 1
                        print(line_nbr)
            line_nbr =0
            for line in lines:
                line_nbr = line_nbr+1
                if(line_nbr<line_to_del_start or line_nbr>line_to_del_end):
                    f.write(line)
                elif(line_nbr == line_to_del_start):
                    f.write(str_to_write)