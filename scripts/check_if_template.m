function [is_template] = check_if_template(req_nbrs,test_case_id)

is_template =0;
req_str = '<RequirementIDs>';
TC_str = '<testCaseID>';
if strcmp(req_nbrs{1,1},req_str) || strcmp(test_case_id{1,1},TC_str)
    is_template = 1;
end