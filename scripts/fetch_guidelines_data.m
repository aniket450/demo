%% this function is to write & append the summary of guideliness check...
% in a text file 
function fetch_guidelines_data(filename,data,rwmode)

%'w+':- open or create file for reading and writing; discard existing contents
if strcmp(rwmode, 'w+') || strcmp(rwmode, 'w')
    open_file = fopen(filename, rwmode);
    fprintf(open_file,data);
    fprintf(open_file,'\r\n');

%'a+':- open or create file for reading and writing; append data to end of file
elseif strcmp(rwmode, 'at+') || strcmp(rwmode, 'a+') || strcmp(rwmode, 'a')
    open_file = fopen(filename, rwmode);
    extract_data = split(data,'\n');% data is split into each cell
    str = extract_data;
    pat = '<[^>]*>';% pattern of the html ref tags
    extract_data = regexprep(str, pat, '');%to remove the pattern
    for i = 1 :length(extract_data)
        fprintf(open_file,extract_data(i));
        fprintf(open_file,'\r\n');%\r\n is mandatory for new line
    end
end
fclose(open_file);
end