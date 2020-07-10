function blkStruct = slblocks
		% This function specifies that the library should appear
		% in the Library Browser
		% and be cached in the browser repository

		Browser(1).Library = 'tenneco_lib';
		% 'mylib' is the name of the library

		Browser(1).Name = 'Tenneco Library';
		% 'My Library' is the library name that appears in the Library Browser
		
		Browser(1).IsFlat  = 0;
		% Is this library "flat" (i.e. no subsystems)?
		
		blkStruct.Browser = Browser;
        