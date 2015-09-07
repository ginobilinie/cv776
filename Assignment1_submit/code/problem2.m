%this script is to align the images hor hw1 
%dong nie, dongnie@cs.unc.edu
function problem2()
%for low resolution
path='../Assignment_1/data/';
files=dir([path,'*.jpg']);
% for i=1:length(files)
%     tic;
%     filename=[path,files(i).name];
%     mat=imread(filename);
%     cMat=alignImageNCC(mat);%after processed, it returns a color one(RGB)
%     %figure(1);
%     %imshow(cMat);
%     imwrite(cMat,sprintf('color%d.jpg',i));
%     toc;
% end

%for high resolution
path='../Assignment_1/data_hires/';
files=dir([path,'*.tif']);
for i=1:length(files)
    tic;
    filename=[path,files(i).name];
    mat=imread(filename);
    cMat=alignImagePyramid(mat);%after processed, it returns a color one(RGB)
    figure(2);
    imshow(cMat);
    saveas(gcf,sprintf('highColor%d.jpg',i));
    %imwrite(cMat,sprintf('highColor%d.jpg',i));
    toc;
end

return