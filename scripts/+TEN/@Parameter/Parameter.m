classdef Parameter < Simulink.Parameter
%TEN.Parameter  Class definition.

%   Mario Maes, jan 2018

  properties(PropertyType = 'char')
    A2L_Description = '';
  end
  
  properties(PropertyType = 'double scalar')
    Res = 0;
  end
   
  properties(PropertyType = 'char')
    Enumeration = '[]';
  end
  
  properties(PropertyType = 'char')
    X_Axis = '';
  end
  
  properties(PropertyType = 'char')
    Y_Axis = '';
  end
  
  properties
    array_or_structure_alias = 0;
  end
  
  properties
    array_number_of_columns = 0;
  end

  properties
    array_number_of_rows = 0;
  end

  %---------------------------------------------------------------------------
  % NOTE:
  % -----
  % By default this class will use the custom storage classes from its
  % superclass.  To define your own custom storage classes:
  % - Uncomment the following method and specify the correct package name.
  % - Launch the cscdesigner for this package.
  %     >> cscdesigner('packageName');
  %
  % methods
  %   function setupCoderInfo(h)
  %     % Use custom storage classes from this package
  %     useLocalCustomStorageClasses(h, 'packageName');
  %   end
  % end % methods
  
  methods
    %---------------------------------------------------------------------------
    function h = Parameter(varargin)
        %PARAMETER  Class constructor.
        
        % Call superclass constructor with variable arguments
        h@Simulink.Parameter(varargin{:});      
    end % End of constructor
    
  end % End of Public methods
  
  methods (Access=protected)
    %---------------------------------------------------------------------------
    function retVal = copyElement(obj)
    %COPYELEMENT  Define special copy behavior for properties of this class.
    %             See matlab.mixin.Copyable for more details.
      retVal = copyElement@Simulink.Parameter(obj);
      if isobject(obj.GenericProperty)
        retVal.GenericProperty = copy(obj.GenericProperty);
      end
    end
  end % Protected methods
  
end % classdef
