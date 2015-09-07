function [ reconMat ] = alignImagePyramid( mat )
    [reconMat] = alignImageSSD(mat);
end

function [reconMat, dBRow, dBCol, dGRow, dGCol]  = alignImageSSD(mat)
    %construct the image pyramid recursively
    [h, w] = size(mat);
    if(h > 256)
        %reduce mat until the mat is less than 256
        reducedMat = impyramid(mat, 'reduce');
        [~, dBRowBase, dBColBase, dGRowBase, dGColBase] = alignImageSSD(reducedMat);
        dBRowBase = 2*dBRowBase;
        dBColBase = 2*dBColBase;
        dGRowBase = 2*dGRowBase;
        dGColBase = 2*dGColBase;
    else
        dBRowBase = 0;
        dBColBase = 0;
        dGRowBase = 0;
        dGColBase = 0;
    end
    
    d = 4;
    %1.extract three parts
    h = floor(h/3);
    matB = mat(1:h, :);
    matR = mat(h+1:2*h, :);
    matG = mat(2*h+1:3*h, :);
    %cut off the white and black border
    dw = int16(w*0.06);
    dh = int16(h*0.06);
    matB = matB(dh+1:h-dh, dw+1:w-dw);
    matG = matG(dh+1:h-dh, dw+1:w-dw);
    matR = matR(dh+1:h-dh, dw+1:w-dw);
    w = w - 2*dw;
    h = h - 2*dh;
    
    %2. align image using SSD
    %normalize the mat firstly
    normMatB = double(matB)./sum(matB(:));
    normMatG = double(matG)./sum(matG(:));
    normMatR = double(matR)./sum(matR(:));
    %compute the sum squared difference
    minDiff4BG = -1;
    for i = dBRowBase-d : dBRowBase+d
        if i < 0
            matBTranRow = normMatB(-i+1:h, :);
            matRTranRow = normMatR(1:h+i, :);
        else
            matBTranRow = normMatB(1:h-i, :);
            matRTranRow = normMatR(i+1:h, :);
        end
        for j = dBColBase-d : dBColBase + d
            if j < 0
                matBTranCol = matBTranRow(:, -j+1:w);
                matRTranCol = matRTranRow(:, 1:w+j);
            else
                matBTranCol = matBTranRow(:, 1:w-j);
                matRTranCol = matRTranRow(:, j+1:w);
            end
            diff4BR = sum(sum((matBTranCol - matRTranCol).^2));
            if(diff4BR < minDiff4BG || minDiff4BG == -1)
                minDiff4BG = diff4BR;
                dBRow = i;
                dBCol = j;
            end
        end
    end
    fprintf('B: (%d,%d)\n',dBRow,dBCol);
    minDiff4GR = -1;
    for i = dGRowBase-d : dGRowBase+d
        if i < 0
            matGTranRow = normMatG(-i+1:h, :);
            matRTranRow = normMatR(1:h+i, :);
        else
            matGTranRow = normMatG(1:h-i, :);
            matRTranRow = normMatR(i+1:h, :);
        end
        for j = dGColBase-d : dGColBase + d
            if j < 0
                matGTranCol = matGTranRow(:, -j+1:w);
                matRTranCol = matRTranRow(:, 1:w+j);
            else
                matGTranCol = matGTranRow(:, 1:w-j);
                matRTranCol = matRTranRow(:, j+1:w);
            end
            diff4GR = sum(sum((matGTranCol - matRTranCol).^2));
            if(diff4GR < minDiff4GR || minDiff4GR == -1)
                minDiff4GR = diff4GR;
                dGRow = i;
                dGCol = j;
            end
        end
    end
    fprintf('G: (%d,%d)\n',dGRow,dGCol);
    %initialize the boundary
    startRow = 1; 
    endRow = h; 
    startCol = 1; 
    endCol = w;
    %process the blue channel
    if dBRow < 0
        matB = matB(-dBRow+1:h, :);
        matB = [matB;zeros(-dBRow, w)];
        endRow = h + dBRow;
    else
        matB = matB(1:h-dBRow, :);
        matB = [zeros(dBRow, w);matB];
        startRow = dBRow + 1;
    end
    if dBCol < 0
        matB = matB(:, -dBCol+1:w);
        matB = [matB, zeros(h, -dBCol)];
        endCol = w + dBCol;
    else
        matB = matB(:, 1:w-dBCol);
        matB = [zeros(h, dBCol), matB];
        startCol = dBCol + 1;
    end
    %process the green channel
    if dGRow < 0
        matG = matG(-dGRow+1:h, :);
        matG = [matG;zeros(-dGRow, w)];
        if endRow > h + dGRow
            endRow = h + dGRow;
        end
    else
        matG = matG(1:h-dGRow, :);
        matG = [zeros(dGRow, w);matG];
        if startRow < dGRow + 1
            startRow = dGRow + 1;
        end
    end
    if dGCol < 0
        matG = matG(:, -dGCol+1:w);
        matG = [matG, zeros(h, -dGCol)];
        if endCol > w + dGCol
            endCol = w + dGCol;
        end
    else
        matG = matG(:, 1:w-dGCol);
        matG = [zeros(h, dGCol), matG];
        if startCol < dGCol + 1
            startCol = dGCol + 1;
        end
    end
    
    %3.combine three channels
    reconMat(:,:,1)=matG;
    reconMat(:,:,2)=matR;
    reconMat(:,:,3)=matB;
    reconMat = reconMat(startRow:endRow, startCol:endCol, :);
    %figure;imshow(reconMat);
end
