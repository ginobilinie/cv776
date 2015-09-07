%this script is to demosaicing the images after bayer filtered for hw1 
%dong nie, dongnie@cs.unc.edu
function problem1()
%1. demasaicing
filename='crayons_mosaic.bmp';
path='../Assignment_1/';
file=[path,filename];
mat=imread(file);
reconMat=demosaicing(mat);
figure;
imshow(reconMat);
imwrite(reconMat,'crayons_recon.jpg');

%2.compute difference map
originfile=[path,'crayons.jpg'];
originMat=imread(originfile);
diff=computeDiff(originMat,reconMat);
figure,imagesc(diff);
title('Squared difference between original image and reconstructed one');
colorbar;axis equal;
saveas(gcf,'diff.jpg');

%3. compute average and per-pixel errors
mean_error=mean(diff(:));
fprintf('Average per-pixel error for reconstruced image is %f.\n', mean_error);
[mError, mInd] = max(diff(:));
[mRow, mCol] = ind2sub(size(diff), mInd);
fprintf('Maximum per-pixel error for reconstructed image is %f at pixel (%d, %d).\n',mError, mRow, mCol);

%4. show close-up patch
d=50;
close_up = originMat(mRow -d : mRow+d, mCol-d: mCol+d, :);
close_up_recon = reconMat(mRow -d : mRow+d, mCol-d: mCol+d, :);
figure;
subplot(1, 2, 1);
imshow(close_up);
title('Close-up of original color image');
subplot(1, 2, 2);
imshow(close_up_recon);
title('Close-up of reconstructed image');
saveas(gcf,'close_up.jpg');
return

%this is the core demosaicing function
function reconMat=demosaicing(mat)
    mR=zeros(size(mat));
    mG=zeros(size(mat));
    mB=zeros(size(mat));
    mR(1:2:end, 1:2:end) = mat(1:2:end, 1:2:end);
    mB(2:2:end, 2:2:end) = mat(2:2:end, 2:2:end);
    mG(1:2:end, 2:2:end) = mat(1:2:end, 2:2:end);
    mG(2:2:end, 1:2:end) = mat(2:2:end, 1:2:end);
    redFilter=[1/4,1/2,1/4;
               1/2,1.0,1/2;
               1/4,1/2,1/4];
    greenFilter=[0,1/4,0;
                 1/4,1.0,1/4;
                 0,1/4,0];
    blueFilter=[1/4,1/2,1/4;
                1/2,1.0,1/2;
                1/4,1/2,1/4];
     R=imfilter(mR,redFilter);
     G=imfilter(mG,greenFilter);
     B=imfilter(mB,blueFilter);
%     R=imfilter(mR,redFilter,'symmetric');
%     G=imfilter(mG,greenFilter,'symmetric');
%     B=imfilter(mB,blueFilter,'symmetric');
    reconMat(:,:,1)=R;
    reconMat(:,:,2)=G;
    reconMat(:,:,3)=B;
    reconMat=uint8(reconMat);
return

%compute a map of squared differences
function diff=computeDiff(mat,reconMat)
    dMat=double(mat-reconMat);
    sz=size(mat);
    sum=zeros(sz(1),sz(2));

    for k=1:sz(3)
        sum=sum+dMat(:,:,k).^2;
    end

    diff=sum;
return