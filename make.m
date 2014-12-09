function make
    
    out_dir='./';
    CPPFLAGS = ' -O -DNDEBUG -I.\ '; % your OpenCV "include" path
    LDFLAGS = ' ';                   % your OpenCV "lib" path -L/usr/lib
    LIBS = ' -lopencv_core -lopencv_highgui -lopencv_video -lopencv_imgproc';
    if strcmp(computer,'GLNXA64')
        CPPFLAGS = [CPPFLAGS ' -largeArrayDims'];
    end
    
    %-------------------------------------------------------------------
    %% add your files here!
    compile_files = {
        % the list of your code files which need to be compiled
        'matchTemplate.cpp'
        };


    %-------------------------------------------------------------------
    %% compiling...
    for k = 1 : length(compile_files)
        fprintf('compilation of: %s\n', compile_files{k});
        str = [compile_files{k} ' -outdir ' out_dir CPPFLAGS LDFLAGS LIBS];
        args = regexp(str, '\s+', 'split');
        mex(args{:});
    end

    fprintf('Congratulations, compilation successful!!!\n');
end % function make