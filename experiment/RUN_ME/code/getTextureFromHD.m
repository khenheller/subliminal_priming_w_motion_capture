% Gets image from file.
function [txtr] = getTextureFromHD(name, p)
    [img, map, alpha] = imread(fullfile(p.STIM_FOLDER,name));
    [~, ~, t3, ~] = size(img);
    if ~isempty(map) img = ind2rgb(img,map); end
    if ~isempty(alpha)
        if t3 == 1 % this means its a monochrome image
            img(:, :, 2) = alpha;
        else
            img(:, :, 4) = alpha;
        end
    end
    txtr = Screen('MakeTexture', p.w, imresize(img,[p.SCREEN_HEIGHT p.SCREEN_WIDTH]));
end