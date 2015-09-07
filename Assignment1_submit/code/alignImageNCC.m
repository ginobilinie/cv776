%align the image(3 parts) using ncc, and reconMat a RGB one
%1. extract three parts(channels) 2. align them 3. form RGB image
%Dong Nie
function [reconMat]=alignImageNCC(mat)

    d = 15;%extension width/height
    %sizes
    [h, w] = size(mat);
    h = floor(h/3);
   
    %1.extract three parts from input images (each part is a channel)
    matB = mat(1:h, :);
    matG = mat(h+1:2*h, :);
    matR = mat(2*h+1:3*h, :);
    %cut off the white and black border
    dw = int16(w*0.06);
    dh = int16(h*0.06);
    matB = matB(dh+1:h-dh, dw+1:w-dw);
    matG = matG(dh+1:h-dh, dw+1:w-dw);
    matR = matR(dh+1:h-dh, dw+1:w-dw);
    w = w - 2*dw;
    h = h - 2*dh;
    
    %2. align 3 parts (channels)
    %expand matR to [h+2d,w+2d], and compute corr based on matB
    extMatR = repmat(mean(matR(:)), h+2*d, w+2*d);
    extMatR((d+1):h+d, (d+1):w+d) = matR;
    %2.1compute correlation and find the optimal offset for channel blue
    corr = normxcorr2(matB, extMatR);
    corr = corr(h:h+2*d, w:w+2*d);
    [~, maxInd] = max(abs(corr(:)));
    [maxRow, maxCol] = ind2sub(size(corr),maxInd);
    dRow4B = maxRow - (d+1);
    dCol4B = maxCol - (d+1);
    %2.2compute correlation and find the optimal offset for channel green
    corr = normxcorr2(matG, extMatR);
    corr = corr(h:h+30, w:w+30);
    [~, maxInd] = max(abs(corr(:)));
    [maxRow, maxCol] = ind2sub(size(corr),maxInd);
    dRow4G = maxRow - (d+1);%offset
    dCol4G = maxCol - (d+1);
    %initialize the boundary
    startRow = 1; 
    endRow = h; 
    startCol = 1; 
    endCol = w;
    %correct the blue part
    if dRow4B < 0
        matB = matB(-dRow4B+1:h, :);
        matB = [matB;zeros(-dRow4B, w)];
        endRow = h + dRow4B;
    else
        matB = matB(1:h-dRow4B, :);
        matB = [zeros(dRow4B, w);matB];
        startRow = dRow4B + 1;
    end
    if dCol4B < 0
        matB = matB(:, -dCol4B+1:w);
        matB = [matB, zeros(h, -dCol4B)];
        endCol = w + dCol4B;
    else
        matB = matB(:, 1:w-dCol4B);
        matB = [zeros(h, dCol4B), matB];
        startCol = dCol4B + 1;
    end
    %correct the green
    if dRow4G < 0
        matG = matG(-dRow4G+1:h, :);
        matG = [matG;zeros(-dRow4G, w)];
        if endRow > h + dRow4G
            endRow = h + dRow4G;
        end
    else
        matG = matG(1:h-dRow4G, :);
        matG = [zeros(dRow4G, w);matG];
        if startRow < dRow4G + 1
            startRow = dRow4G + 1;
        end
    end
    if dCol4G < 0
        matG = matG(:, -dCol4G+1:w);
        matG = [matG, zeros(h, -dCol4G)];
        if endCol > w + dCol4G
            endCol = w + dCol4G;
        end
    else
        matG = matG(:, 1:w-dCol4G);
        matG = [zeros(h, dCol4G), matG];
        if startCol < dCol4G + 1
            startCol = dCol4G + 1;
        end
    end
    
    %3.combine three parts (channels) to form a new image
    reconMat(:,:,1)=matR;
    reconMat(:,:,2)=matG;
    reconMat(:,:,3)=matB;
    reconMat = reconMat(startRow:endRow, startCol:endCol, :);
return