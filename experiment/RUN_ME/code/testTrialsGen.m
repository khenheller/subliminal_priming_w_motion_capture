% Generates many trial sets to check all is good.
% 1. checks if any word apears more than others.
function [freq] = testTrialsGen(nSets, p)

    warning('off','MATLAB:table:PreallocateCharWarning');
    
    p.FULLSCREEN = true; % default = true
    p = initPsychtoolbox();
    p = initConstants(1, 'test', p);
    
    % closes psychtoolbox window
    Priority(0);
    sca;
    ShowCursor;
    ListenChar(0);

    TIME_SLOW = 1; % default = 1; time slower for debugging
    p.SUB_NUM = 99999;
    
    words = reshape(p.WORD_LIST{:,:}, [], 1);
    % word freq as prime/target/distractor.
    freq.prime = zeros(length(words),1);
    freq.target = zeros(length(words),1);
    freq.dist = zeros(length(words),1);
    
    for iSet = 1:nSets
        trials = newTrials();
%         writetable(trials, ['./data/testTrials/test' num2str(iSet) '.csv']);
        % Check each word's frequency.
        for iWord = 1:length(words)
            freq.prime(iWord)    = freq.prime(iWord) + count(strjoin(trials.prime), words(iWord));
            freq.target(iWord)   = freq.target(iWord) + count(strjoin(trials.target), words(iWord));
            freq.dist(iWord)     = freq.dist(iWord) + count(strjoin(trials.distractor), words(iWord));
        end
        disp(['Done with set: ' num2str(iSet)]);
    end
    freq.words = words;
    freq = struct2table(freq);
    writetable(freq,'./data/testTrials/testFrequencies.csv');
    
    % plot results.
    freq.words = categorical(freq.words, freq.words);
    figure();
    bar(freq.words(1 : length(freq.words)/2),  freq.prime(1 : length(freq.words)/2))
    hold on
    bar(freq.words(length(freq.words)/2+1 : end),  freq.prime(length(freq.words)/2+1 : end))
    title('Primes');
    mean_prime_nat = mean(freq.prime(1 : length(freq.words)/2));
    mean_prime_art = mean(freq.prime(length(freq.words)/2+1 : end));
    median_prime_nat = median(freq.prime(1 : length(freq.words)/2));
    median_prime_art = median(freq.prime(length(freq.words)/2+1 : end));
    
    figure();
    bar(freq.words(1 : length(freq.words)/2),  freq.target(1 : length(freq.words)/2))
    hold on
    bar(freq.words(length(freq.words)/2+1 : end),  freq.target(length(freq.words)/2+1 : end))
    title('Targets');
    mean_target_nat = mean(freq.target(1 : length(freq.words)/2));
    mean_target_art = mean(freq.target(length(freq.words)/2+1 : end));
    median_target_nat = median(freq.target(1 : length(freq.words)/2));
    median_target_art = median(freq.target(length(freq.words)/2+1 : end));
    
    figure();
    bar(freq.words(1 : length(freq.words)/2),  freq.dist(1 : length(freq.words)/2))
    hold on
    bar(freq.words(length(freq.words)/2+1 : end),  freq.dist(length(freq.words)/2+1 : end))
    title('Distractors');
    mean_dist_nat = mean(freq.dist(1 : length(freq.words)/2));
    mean_dist_art = mean(freq.dist(length(freq.words)/2+1 : end));
    median_dist_nat = median(freq.dist(1 : length(freq.words)/2));
    median_dist_art = median(freq.dist(length(freq.words)/2+1 : end));
end