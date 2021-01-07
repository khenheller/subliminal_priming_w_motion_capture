% For each stimuli word it generates a list of words that don't share common letters in same
% location with it.
% distractors are from same category as prime and can't share letters with it.
% primes are from different category from target and can't share letters with it.
% Generates 4 lists:
%   art_distractors - possible distractors for each artificial prime.
%   nat_distractors - possible distractors for each natural prime.
%   art_primes - possible primes for each natural target.
%   nat_primes - possible primes for each artificial target.
% Saves results to file.
function [] = genWordsLists()
    
    words = readtable('./stimuli/word_lists/word_freq_list.xlsx');
    words = words(:,[1,3]); % Remove word frequencies.
    nWords = height(words);
    % List all words. Later we eliminate bad words.
    nat_distractors = cell2table(repmat(words.natural,1,nWords));
    art_distractors = cell2table(repmat(words.artificial,1,nWords));
    art_primes = cell2table(repmat(words.artificial,1,nWords));
    nat_primes = cell2table(repmat(words.natural,1,nWords));
    
    for iWord = 1:height(words)
        % natural dists for each natural prime.
        share_letters = any(words.natural{iWord} == cell2mat(words.natural), 2);
        nat_distractors(share_letters, iWord) = table('Size',[1 1],'VariableTypes',{'char'});
        % artificial dists for each artificial prime.
        share_letters = any(words.artificial{iWord} == cell2mat(words.artificial), 2);
        art_distractors(share_letters, iWord) = table('Size',[1 1],'VariableTypes',{'char'});
        % artificial primes for each natural target.
        share_letters = any(words.natural{iWord} == cell2mat(words.artificial), 2);
        art_primes(share_letters, iWord) = table('Size',[1 1],'VariableTypes',{'char'});
        % natural primes for each artificial target.
        share_letters = any(words.artificial{iWord} == cell2mat(words.natural), 2);
        nat_primes(share_letters, iWord) = table('Size',[1 1],'VariableTypes',{'char'});
    end
    
    writetable(nat_distractors,'./stimuli/word_lists/nat_distractors.csv');
    writetable(art_distractors,'./stimuli/word_lists/art_distractors.csv');
    writetable(art_primes,'./stimuli/word_lists/art_primes.csv');
    writetable(nat_primes,'./stimuli/word_lists/nat_primes.csv');
end