function str_return = split_col(arg,delimeter)
str_return = split(arg,delimeter);
[row, ~]= size(arg);
if( row == 1)
    str_return = str_return';
end
end