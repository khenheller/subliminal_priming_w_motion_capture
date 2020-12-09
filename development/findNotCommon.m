function words = findNotCommon(words)
    words.not_common = cell(height(words))
    % Finds words from other group (natural/artificial) that don't share common letters.
    for i = 1:height(words)
        words.not_common(i) = split(words.not_common_str(i));
    end
end