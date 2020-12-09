% Generates masks composed of squares and diamonds in random positions,
% which cover a certain viewing angle.
function [] = makeMasks(num_masks)

    global fontSize wordWidth wordHeight
    
    %@@@@@@@@ Define the following @@@@@@@@
    num_shapes_each_kind = 11; % num squares and diamonds.
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    stim_folder = './stimuli/';
    
    % font size to shapes size ratio. Measured by hand when font=100 & MarkerSize=100.
    font_square_ratio = 2.5/3;% original measured values: 2.5/2.0;
    font_diamond_ratio = 2.5/4;% original measured values: 2.5/3.5;
    
    % When font=100 and square_LineWidth=15 & diamond_LineWidth=10, all widths are equal.
    square_width = 15 * fontSize / 100;
    diamond_width = 10 * fontSize / 100;
    
    % Open fullscreen figure.
    set(gcf, 'Units','centimeters',  'WindowState','fullscreen',  'MenuBar','None');
    pause(1); % pause for 100ms because it takes matlab time to create fullscreen figure.
    % Gets screen size.
    screen_size = get(gcf,'Position');
    width = screen_size(3);
    height = screen_size(4);
    % sets mask at center of screen.
    set(gca,'Units','centimeters','Position',[(width/2 - wordWidth/2) (height/2 - wordHeight/2)...
        wordWidth wordHeight]);
    % grey background.
    set(gcf,'color',[0.5 0.5 0.5]);
    set(gcf, 'InvertHardcopy', 'off'); % prevents matlab overide my background setting when saving to a file.
    
    % make masks
    for mask_i = 1:num_masks
        hold off;
        
        % draw squares.
        for shape_i = 1:num_shapes_each_kind
            x = rand * wordWidth;
            y = rand * wordHeight;
            square_size = fontSize * font_square_ratio;
            plot(x,y, 's','MarkerEdgeColor','black','MarkerSize',square_size,'LineWidth',square_width)
            hold on;
        end
        
        % draw diamonds.
        for shape_i = 1:num_shapes_each_kind % draws a shape.
            x = rand * wordWidth;
            y = rand * wordHeight;
            diamond_size = fontSize * font_diamond_ratio;
            plot(x,y, 'd','MarkerEdgeColor','black','MarkerSize',diamond_size,'LineWidth',diamond_width)
            hold on;
        end
        xlim([0 wordWidth]);
        ylim([0 wordHeight]);
        axis 'off';
        saveas(gcf, [stim_folder '/masks/mask' num2str(mask_i) '.jpg']);%, 'jpeg');%print(gcf, '-djpeg', [STIM_FOLDER '/masks/mask' num2str(mask_i) '.jpg']);
    end
end