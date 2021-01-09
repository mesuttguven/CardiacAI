% you can change the images with this code part
% Mesut GUVEN


HEALTHY= imread('HEALTHY.png');

healthy_img_R = HEALTHY(:,:,1);
healthy_img_G = HEALTHY(:,:,2);
healthy_img_B = HEALTHY(:,:,3);

healthy_img_R_gray= imresize(healthy_img_R, [800,400]);
healthy_img_G_gray= imresize(healthy_img_G, [800,400]);
healthy_img_B_gray= imresize(healthy_img_B, [800,400]);

HEALTHY_img_resized (:,:,1)= healthy_img_R_gray;
HEALTHY_img_resized (:,:,2)= healthy_img_G_gray;
HEALTHY_img_resized (:,:,3)= healthy_img_B_gray;

HEALTHY_img_resized_flipped=flip(HEALTHY_img_resized,2);

save HEALTHY_img_resized_flipped

UNHEALTHY= imread('UNHEALTHY.png');

unhealthy_img_R = UNHEALTHY(:,:,1);
unhealthy_img_G = UNHEALTHY(:,:,2);
unhealthy_img_B = UNHEALTHY(:,:,3);

unhealthy_img_R_gray= imresize(unhealthy_img_R, [800,400]);
unhealthy_img_G_gray= imresize(unhealthy_img_G, [800,400]);
unhealthy_img_B_gray= imresize(unhealthy_img_B, [800,400]);

UNHEALTHY_img_resized (:,:,1)= unhealthy_img_R_gray;
UNHEALTHY_img_resized (:,:,2)= unhealthy_img_G_gray;
UNHEALTHY_img_resized (:,:,3)= unhealthy_img_B_gray;

UNHEALTHY_img_resized_flipped=flip(UNHEALTHY_img_resized,2);


save UNHEALTHY_img_resized_flipped

