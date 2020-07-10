function dataObjs = makeDataObjsFromTENdd(sourceFilename)

% This function is primarily for creating TEN.Parameter and TEN.Signal
% objects for variables found in a legacy Tenneco _dd.m data dictionary.
% The TEN objects are then added to the "dataObjs" output.
%
% Inputs:
%   sourceFilename (string) = data dictionary file name.  Must be in the
%   legacy Tenneco data dictionary format
%
% Outputs:
%   dataObjs (cell array) = array of TEN.Parameter and TEN.Signal objects
%
% Dependencies:
%   TEN.Parameter class
%   TEN.Signal class

% Initialize dataObjs
dataObjs = {};
objIdx = 1;

% Set reqular expressions to sort the string data
exprLines = '[^\n]*[^\n]*';     % Get each line separately
exprAlpha = '^[a-zA-Z]';        % Find lines starting with an Alphabetic character (variable name)
exprWord = '^[\w]*';            % Get the whole variable name
exprComment = '^[%]';           % Find a line starting with a comment character (variable data)
exprDataDelim = ';';            % Delimiter for variable data

% Import data dictionary as a string and separate it into lines
mText = fileread(sourceFilename);
eachLine = regexp(mText,exprLines,'match')';

% load data dictioary variables
run(sourceFilename)

% begin sorting through each line looking for a variable name
varCount = 0;
ramVars = false;
for idx = 1:length(eachLine)
    
    % Determine if this line is declaring the rest of the variables are
    % "Scalar RAM Variables"
    if ~isempty(strfind(eachLine{idx},'Scalar RAM Variables'))
        ramVars = true;
    end
    
    % Determine if this line of text is declaring a variable
    hasAlpha = regexp(eachLine{idx},exprAlpha);
    if ~isempty(hasAlpha)
        
        % confirmed variable, increment counter
        varCount = varCount + 1;
        
        % get the variable name from the line of text
        varName = regexp(eachLine{idx},exprWord,'match')';
        varName = varName{1};
        
        % parse the next line containing a '%' which will have the variable
        % data for a2l file generation.  Stop after first '%' is found and
        % processed.
        for idy = idx+1:length(eachLine)
            
            % look for '%' character in this line, process if true, go to
            % next line if false.  This is to find the A2L data for each
            % declared variable.
            hasComment = regexp(eachLine{idy},exprComment);
            if ~isempty(hasComment)     % Test for '%'
                
                % get position in line for each ';'
                varData = strsplit(eachLine{idy},exprDataDelim);
                
                % Create a Tenneco.Parameter or Tenneco.Signal object
                if ramVars
                    obj = TEN.Signal;
                    obj.Dimensions = 1;
                    obj.DimensionsMode = 'Fixed';
                    obj.InitialValue = num2str(eval(varName));
                    obj.Description = varData{1}(2:length(varData{1}));
                else
                    obj = TEN.Parameter;
                    
                    obj.Value = double(eval(varName));
                    obj.Enumeration = varData{6};
                    obj.X_Axis = varData{7};
                    obj.Y_Axis = varData{8};
                    obj.array_or_structure_alias = varData{9};
                    obj.array_number_of_columns = varData{10};
                    obj.array_number_of_rows = varData{11};
                    obj.Description = varData{1}(2:length(varData{1}));
                    obj.A2L_Description = obj.Description;
                end
                
                %   Populate obj with VarData Fields:
                %   	(1)  Text description;
                %   	(2)  minimum value;
                %   	(3)  maximum value;
                %   	(4)  resolution;
                %   	(5)  units;
                %     	(6)  [enumeration list in [] separated by ,];
                %     	(7)  X Axis;
                %   	(8)  Y Axis;
                %   	(9)  array or structure alias;
                %   	(10) array dim (number of columns);
                %   	(11) array dim (number of rows);
                
                obj.Min = eval(varData{2});
                obj.Max = eval(varData{3});
                obj.Res = eval(varData{4});
                if strfind(varData{5},'-')
                    varData{5} = '[]';
                end
                obj.Unit = varData{5};
                obj.DataType = eval(['class(',varName,')']);
                obj.StorageClass = 'ExportedGlobal';
                
                dataObjs{objIdx}.Name = varName;
                dataObjs{objIdx}.Value = obj;
                objIdx = objIdx+1;
                
                % Variable data has been found, break loop before end
                break
                
            end % test for '%'
        end % loop to find variable data line
        
    end % test for variable name found
end % loop for each line to find variable name