function write_coveralls_json(obj,output_fn)
    monitor=obj.monitor;
    notify(monitor,'Writing JSON file to %s', output_fn);

    json=get_coverage_json(obj);
    fid=fopen(output_fn,'w');
    cleaner=onCleanup(@()fclose(fid));
    fprintf(fid,'%s',json);

    notify(monitor,'Completed writing JSON file to %s', output_fn);
