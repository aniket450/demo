function updatedOutputs = getOuputSampleTimes(hMdl,Outputs)

% This function gets the true output sample time from the Simulink model
% assuming it has been updated and has values for CompliedSampleTime.  It
% then updates the "Outputs" cell array data with the Compiled sample time
% and outputs the updated data in the "updatedOutputs" output.  It will
% also scale that time from seconds to milliseconds.
%
% Inputs:
%   hMdl = the name (char array) or handle (double) of the system.
%   Outputs (cell array) = List of output data structures to be updated.
%   Assumes that each output data structure has the fields:
%       name = variable name
%       rate = sample time
%
% Outputs:
%   updatedOutputs (cell array) = list of output data structures updated
%   with the compiled sample time.

% initialize output
updatedOutputs = Outputs;

% find all outports in hMdl system
listOutports = find_system(hMdl,'LookUnderMasks','on','FollowLinks','on','BlockType','Outport');

% match found outports with names of output variables
for idx = 1:length(updatedOutputs)
    for idy = 1:length(listOutports)
        if strcmp(get_param(listOutports{idy},'Name'),updatedOutputs{idx}.name)
            
            % when a match is found, update the variable structure with the
            % outport's compiled sample time
            dt = get_param(listOutports{idy},'CompiledSampleTime');
            
            % if the sample time is not inherited (-1) then convert
            % from seconds to milliseconds
            if dt >= 0
                dt = dt*1000;
            end
            updatedOutputs{idx}.rate = dt(1,1);
            break
        end
    end
end