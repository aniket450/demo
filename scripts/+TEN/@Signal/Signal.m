classdef Signal < Simulink.Signal
%SimulinkDemos.Signal  Class definition.

%   Copyright 2009-2013 The MathWorks, Inc.

  properties(PropertyType = 'char', ...
             AllowedValues = {'volatile'; 'non-volatile'})
    SignalType = 'volatile';
  end
  
  properties(PropertyType = 'char')
    A2L_Description = '';
  end
  
  properties(PropertyType = 'double scalar')
    Res = 0;
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
  
  methods (Access=protected)
    %---------------------------------------------------------------------------
    function retVal = copyElement(obj)
    %COPYELEMENT  Define special copy behavior for properties of this class.
    %             See matlab.mixin.Copyable for more details.
      retVal = copyElement@Simulink.Signal(obj);
      if isobject(obj.GenericProperty)
        retVal.GenericProperty = copy(obj.GenericProperty);
      end
    end
  end % Protected methods
  
  methods
      
      function h = Signal()
         % SIGNAL  Class constructor.
      end % End of Constructor
      
  end % End of Public methods
end % classdef
