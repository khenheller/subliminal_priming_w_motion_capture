% Generates masks composed of squares and diamonds in random positions,
% which cover a certain viewing angle.
% side - 'left'/'right', side of natrual category.
function [] = makeMasks(num_masks, p, side)

    p = initPsychtoolbox(p);
    p = initConstants(0, 'test', p);
    
    % closes psychtoolbox window
    Priority(0);
    sca;
    ShowCursor;
    ListenChar(0);
    
    %@@@@@@@@ Define the following @@@@@@@@
    num_shapes_each_kind = 11; % num squares and diamonds.
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    stim_folder = './stimuli/';
    
    % font size to shapes size ratio. Measured by hand when font=100 & MarkerSize=100.
    font_square_ratio = 2.5/3;% original measured values: 2.5/2.0;
    font_diamond_ratio = 2.5/4;% original measured values: 2.5/3.5;
    
    % When font=100 and square_LineWidth=15 & diamond_LineWidth=10, all widths are equal.
    square_width = 15 * p.FONT_SIZE / 100;
    diamond_width = 10 * p.FONT_SIZE / 100;
    
    % Get Categorization screen.
    categor_screen = imread(fullfile(p.STIM_FOLDER, ['categor_natural_' side '_screen.jpg']));
    % Open fullscreen figure.
    set(gcf, 'Units','centimeters',  'WindowState','fullscreen',  'MenuBar','None');
    pause(1); % pause for 100ms because it takes matlab time to create fullscreen figure.
    % Draw categories.
    categor_ax = axes('Units','normalized', 'Position',[0 0 1 1]);
    image(categor_screen);
    axis off;
    % Gets screen size.
    screen_size = get(gcf,'Position');
    width = screen_size(3);
    height = screen_size(4);
    % sets mask at center of screen.
    mask_ax = axes();
    set(gca,'Units','centimeters','Position',[(width/2 - p.WORD_WIDTH/2) (height/2 - p.WORD_HEIGHT/2)...
        p.WORD_WIDTH p.WORD_HEIGHT]);
    % grey background.
    set(gcf,'color',[0.5 0.5 0.5]);
    set(gcf, 'InvertHardcopy', 'off'); % prevents matlab overide my background setting when saving to a file.
    
    for mask_i = 1:num_masks
        hold off;
        % draw squares.
        for shape_i = 1:num_shapes_each_kind
            x = rand * p.WORD_WIDTH;
            y = rand * p.WORD_HEIGHT;
            square_size = p.FONT_SIZE * font_square_ratio;
            plot(x,y, 's','MarkerEdgeColor','black','MarkerSize',square_size,'LineWidth',square_width)
            hold on;
        end
        % draw diamonds.
        for shape_i = 1:num_shapes_each_kind % draws a shape.
            x = rand * p.WORD_WIDTH;
            y = rand * p.WORD_HEIGHT;
            diamond_size = p.FONT_SIZE * font_diamond_ratio;
            plot(x,y, 'd','MarkerEdgeColor','black','MarkerSize',diamond_size,'LineWidth',diamond_width)
            hold on;
        end
        xlim([0 p.WORD_WIDTH]);
        ylim([0 p.WORD_HEIGHT]);
        axis 'off';
        % Save as image.
        saveas(gcf, [stim_folder '/masks/practice_mask' num2str(mask_i) '_natural_' side '.jpg']);
    end
end