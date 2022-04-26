% Recieves 2 lists of words (array of char arrays) and relations type ('prime_taregt' or 'prime_dist').
% Makes sure matching words (same row) from both lists don't share letters in common locations.
% rel_type: relation type.
%           'prime-target': check prime categor is different from target.
%           'prime-dist': check prime categor is same as distractor.
function pass_test = relationsTest (list_a, list_b, rel_type, p)
    pass_test.common_letters = 1;
    pass_test.categor = 1;
    
    common_letters = list_a == list_b;
    common_words = any(common_letters, 2); % OR on columns.
    % Ignore prime = target.
    if strcmp(rel_type,'prime_target')
        same_word = prod(common_letters, 2); % AND on columns.
        same_word = logical(same_word);
        common_words(same_word) = 0;
    end
    if any(common_words)
        disp([rel_type ' has common letters in trials: ' num2str(find(common_words)')]);
        pass_test.common_letters = 0;
    end
    
    
    categor_a = getCategor(list_a, p);
    categor_b = getCategor(list_b, p);
    if strcmp(rel_type,'prime_target') % checks if prime & target from same categor.
        bad_categor = categor_a == categor_b;
        bad_categor(same_word) = 0; % Ignore same word instances.
    else % checks if prime & dist from different categor.
        bad_categor = categor_a ~= categor_b;
    end
    if any(bad_categor)
        disp([rel_type ' are from bad categories in trials: ' num2str(find(bad_categor)')]);
        pass_test.categor = 0;
    end
end

% Gets word list, returns category (natural/artificial) of each word.
function categor = getCategor(words, p)
    categor = strings(size(words,1), 1);
    % locate word in each list.
    nat_words = ismember(words, p.WORD_LIST.natural);
    art_words = ismember(words, p.WORD_LIST.artificial);
    
    categor(nat_words) = 'natural';
    categor(art_words) = 'artificial';
end