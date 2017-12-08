function [r,b] = get_data_from_whites(image_current,image_width,x_start,x_end,y_start,y_end)

[~ , ~, T] = size(image_current);

for i = 1:T
if x_end<=image_width, 
    b(:,:,i) = image_current(y_start:y_end,x_start:x_end,i);
    r(:,:,i) = image_current(y_start:y_end,x_start+image_width:x_end+image_width,i);
else
    r(:,:,i) = image_current(y_start:y_end,x_start:x_end,i);
    b(:,:,i) = image_current(y_start:y_end,x_start-image_width:x_end-image_width,i);
end
end
