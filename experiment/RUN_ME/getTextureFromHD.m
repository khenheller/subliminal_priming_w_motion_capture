% Gets image from file.
function [txtr] = getTextureFromHD(name)
    global ScreenHeight ScreenWidth w STIM_FOLDER
    [img, map, alpha] = imread(fullfile(pwd,STIM_FOLDER,name));
    [~, ~, t3, ~] = size(img);
    if ~isempty(map) img = ind2rgb(img,map); end
    if ~isempty(alpha)
        if t3 == 1 % this means its a monochrome image
            img(:, :, 2) = alpha;
        else
            img(:, :, 4) = alpha;
        end
    end
    txtr = Screen('MakeTexture', w, imresize(img,[ScreenHeight ScreenWidth]));
end