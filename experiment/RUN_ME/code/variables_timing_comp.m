function [time] = variables_timing_comp()
    small_var.v = 2;
    big_var = load('p.mat');
    big_var.v = 2;
    iterations = 100000;
    
    tic;
    for i = 1:iterations
        calc(small_var);
    end
    time.small_var_time = toc;
    
    tic;
    for i = 1:iterations
        calc(big_var);
    end
    time.big_var_time = toc;
end
function output = calc(var)
    output = var.v + 10000234 / 5;
end
