data_folder = '../../experiment/RUN_ME/code/tests/test_results/';
files = string(ls(data_folder));
files = files(contains(files, '.'));
files(1:2) = [];
files = files(~contains(files, 'day'));
for file = files'
    file = replace(file,' ','');
    new_file = join([regexp(file,".*\d+",'match') "day2_" string(regexp(file,"\d+(.*)",'tokens'))]);
    new_file = replace(new_file,' ','');
    file = [data_folder char(file)];
    new_file = [data_folder char(new_file)];
    file = replace(file,'/','\');
    new_file = replace(new_file,'/','\');
    cmd = ['copy ' file ' ' new_file];
    system(cmd);
    cmd = ['del ' file];
    system(cmd);
end
disp('DONE!');