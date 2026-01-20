% APPM2360_Project_2.m
% Authors: Brian Hilten and Ethan Sandersfield
% Date Last Modified: 10/26/2025
clear; close all;
%% Image Manipulation:
% Question 1:
[Ag,Red,Green,Blue] = grayImage('rectangle.jpg'); % Our function implementation
imagesc(uint8(Ag)) % Display our grayscale image
colormap('gray')
figure()
A = cat(3,Red,Green,Blue); 
imagesc(uint8(A)) % Display our color image
%------------------------------------------------------------------------%
% Question 2:
Ag_exposed = Ag.*2; %Element-wise multiplication to increase white intensity levels
figure()
imagesc(uint8(Ag_exposed));
colormap('gray')
%------------------------------------------------------------------------%
% Question 3:
Ad = double(A);
% Break our mxnx3 matrix into its component mxn matrices:
Ad_Red = Ad(:,:,1);
Ad_Green = Ad(:,:,2);
Ad_Blue = Ad(:,:,3);
% Apply modifications:
Ad_Red_0 = 0*Ad(:,:,1);
Ad_Blue_plus80 = Ad(:,:,3)+80;
A_cshift = cat(3,Ad_Red_0,Ad_Green,Ad_Blue_plus80);
figure()
imagesc(uint8(A_cshift));
%------------------------------------------------------------------------%
% Question 4:
disp("Original B:")
B = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]
E = eye(4); %Generate our 4x4 identity matrix
E(:,[1,4]) = E(:,[4 1]) %Swaps columns 4 and 1 in E
disp("Horizontal Shift B:")
B = B*E %Swaps columns 4 and 1 in B
%------------------------------------------------------------------------%
% Question 5: Horizontal Shift
figure()
% Find our transformation matrix:
I = eye(1900); % Generate our appropriate identity matrix
T = zeros(1900); % Generate our zero matrix which will become our transformation matrix
spy(I) % Figure to show what the original I matrix looks like
figure()
T(:,[1:306]) = I(:,[1595:1900]); %puts last 306 into first 306
T(:,[307:1900]) = I(:,[1:1594]); %puts original 1:1594 into 307:1900
spy(T); % Figure to show what our new transformation matrix looks like

% Modify each R G B matrix with the transformation matrix
figure()
Ad_Red_hshift = Ad_Red*T;
Ad_Green_hshift = Ad_Green*T;
Ad_Blue_hshift = Ad_Blue*T;
% Display our horizontally shifted color image!
A_hshift = cat(3,Ad_Red_hshift,Ad_Green_hshift,Ad_Blue_hshift);
imagesc(uint8(A_hshift));
%------------------------------------------------------------------------%
% Question 6: Horizontal and Vertical Shift
figure()
% Find our vertical transformation matrix:
I2 = eye(1425); % Generate our appropriate identity matrix
T2 = zeros(1425); % Generate our zero matrix which will become our transformation matrix
spy(I2);
figure()
T2([1:250],:) = I2([1176:1425],:); % Swaps last 250 rows of I into the first 250 of T
T2([251:1425],:) = I2([1:1175],:); % Rest of the image, but shifted down
spy(T2);
% Modify each R G B matrix with the transformation matrix
figure()
Ad_Red_vshift = T2*Ad_Red;
Ad_Green_vshift = T2*Ad_Green;
Ad_Blue_vshift = T2*Ad_Blue;
% Display our vertically shifted color image!
A_vshift = cat(3,Ad_Red_vshift,Ad_Green_vshift,Ad_Blue_vshift);
imagesc(uint8(A_vshift));
%Shift our image vertically and horizontally:
figure()
Ad_Red_vhshift = T2*Ad_Red*T;
Ad_Green_vhshift = T2*Ad_Green*T;
Ad_Blue_vhshift = T2*Ad_Blue*T;
% Display our vertically shifted color image!
A_vhshift = cat(3,Ad_Red_vhshift,Ad_Green_vhshift,Ad_Blue_vhshift);
imagesc(uint8(A_vhshift));
%------------------------------------------------------------------------%
% Question 7: Flip the image
% Find our 'flip' transformation matrix:
I3 = eye(1425); % Generate our appropriate identity matrix
T3 = zeros(1425); % Generate our zero matrix which will become our transformation matrix
figure()
% Use the for loop below to generate an anti-diagonal transformation
% matrix:
j = 1;                      % _________
for i = 1425:-1:1           % |j ... i|
    T3(j,i) = I3(i,i);      % |1      |
    j = j+1;                % |.     ^|
end                         % |.     .|
                            % |1424  .|
                            % |i_____i|
        % A very poor pictoral representation of the algorithm I used
spy(T3);
figure()
% Apply our 'flip' transformation matrix to the color matrices:
Ad_Red_flip = T3*Ad_Red;
Ad_Green_flip = T3*Ad_Green;
Ad_Blue_flip = T3*Ad_Blue;
A_flip = cat(3,Ad_Red_flip,Ad_Green_flip,Ad_Blue_flip);
imagesc(uint8(A_flip));
% Huzzah!
%------------------------------------------------------------------------%
% Question 8: Transposing an image
% Transposing an image should have the effect of flipping it across both
% the vertical axis and horizontal axis and changing the picture from a
% 1425x1900 image to a 1900x1425 image.
figure()
Ad_Red_transpose = Ad_Red';
Ad_Green_transpose = Ad_Green';
Ad_Blue_transpose = Ad_Blue';
A_transpose = cat(3,Ad_Red_transpose,Ad_Green_transpose,Ad_Blue_transpose);
imagesc(uint8(A_transpose));
%------------------------------------------------------------------------%
% Question 9: Cropping an image
figure()
% Construct our horizontal crop transformation matrix
T4 = eye(1900); % We can just modify this matrix
% Remove our first 200 1s at j,j:
for j = 1:1:200
    T4(j,j) = 0;
end
% Remove our last 200 1s at j,j:
for j = 1900:-1:1700
    T4(j,j) = 0;
end
spy(T4)
% Construct our vertical crop transformation matrix
figure()
T5 = eye(1425); % So we can just modify this matrix, no need to reference I
% Remove our first 200 pixels 1s at i,i:
for i = 1:1:200
    T5(i,i) = 0;
end
% Remove our last 200 pixels 1s at i,i:
for i = 1425:-1:1225
    T5(i,i) = 0;
end
spy(T5)
% Display our cropped image
figure()
Ad_Red_crop = T5*Ad_Red*T4;
Ad_Green_crop = T5*Ad_Green*T4;
Ad_Blue_crop = T5*Ad_Blue*T4;

Ad_crop = cat(3,Ad_Red_crop,Ad_Green_crop,Ad_Blue_crop);
imagesc(uint8(Ad_crop))
%-------------------------------------------------------------------------%
%% Image Compression:
function project02_image_compression(inputFile, p_values, writeOutputs)

if nargin < 3
    writeOutputs = false;
end

% --- Read image and convert to double ---
A_uint8 = imread(inputFile);         % read color image (R,G,B)
A = double(A_uint8);                 % operate in double precision
[m, n, c] = size(A);
if c ~= 3
    error('Input image must be an RGB color image.');
end

% Separate channels
R = A(:,:,1); G = A(:,:,2); B = A(:,:,3);

% --- Build DST matrices (rows and columns) (Q10) ---
S_row = DSTmatrix(m);
S_col = DSTmatrix(n);

% --- Verify involutory property for n = 5 (Q11) ---
S5 = DSTmatrix(5);
norm_err = norm(S5 * S5 - eye(5));
fprintf('Check Q11: ||S5*S5 - I5||_2 = %.3e (should be ~0 allowing numerical error)\n', norm_err);

% --- Show S_row and S_col dimensions ---
fprintf('Image size: %d x %d, channels: 3\n', m, n);

% --- Helper: precompute grids for mask decisions ---
[Igrid, Jgrid] = ndgrid(1:m, 1:n);

% --- Original image display ---
figure('Name','Compression: original and reconstructions','Units','normalized','Position',[0.05 0.05 0.9 0.85]);
subplot(numel(p_values)+1,3,1);
imagesc(uint8(A)); axis image off; title('Original (color)');

% Display the three channel DST magnitude visualizations for inspection
YR_full = S_row * R * S_col;
YG_full = S_row * G * S_col;
YB_full = S_row * B * S_col;
subplot(numel(p_values)+1,3,2);
imagesc(log10(abs(YR_full)+1)); colormap(gca,'jet'); axis image off;
title('log10(|YR|) full');
subplot(numel(p_values)+1,3,3);
imagesc(log10(abs(YG_full)+1)); colormap(gca,'jet'); axis image off;
title('log10(|YG|) full');

% --- Loop through p values performing compression (Q13-Q15) ---
results = table('Size',[numel(p_values) 3],...
    'VariableTypes',{'double','double','double'},...
    'VariableNames',{'p','nnz_total','CR'});
uncompressed_coeffs = m * n * 3; % total coefficients (3 channels)
for k = 1:numel(p_values)
    p = p_values(k);
    % Forward 2D DST on each channel
    YR = S_row * R * S_col;
    YG = S_row * G * S_col;
    YB = S_row * B * S_col;
    
    % --- Build mask_keep using anti-diagonal rule ---
    % For square n x n the assignment uses: if (i + j > p*2*n) zero-out.
    % For non-square, we preserve proportion by using min(m,n).
    % This keeps the "upper-left low frequency" region.
    minDim = min(m, n);
    mask_keep = (Igrid + Jgrid <= p * 2 * minDim);  % logical matrix (m x n)
    
    % Visualize mask for one p (first p) using spy
    if k == 1
        figure('Name','Coefficient mask and sparsity','Units','normalized','Position',[0.05 0.05 0.4 0.4]);
        subplot(1,2,1);
        spy(mask_keep); title(sprintf('mask_keep (p=%.3g)', p));
        subplot(1,2,2);
        imagesc(mask_keep); colormap('gray'); axis image off;
        title('mask_keep image');
    end
    
    % Apply mask (zero high-frequency entries)
    YR_masked = YR .* mask_keep;
    YG_masked = YG .* mask_keep;
    YB_masked = YB .* mask_keep;
    
    % Show spy of YR_masked to illustrate retained coefficients (first p only)
    if k == 1
        figure('Name','Sparsity of YR after mask (p first)','Units','normalized','Position',[0.5 0.05 0.4 0.4]);
        spy(YR_masked); title(sprintf('spy(YR) masked p=%.3g', p));
    end
    
    % Count nonzero coefficients (Q14 & Q15)
    nnzR = nnz(YR_masked);
    nnzG = nnz(YG_masked);
    nnzB = nnz(YB_masked);
    nnz_total = nnzR + nnzG + nnzB;
    CR = uncompressed_coeffs / max(nnz_total,1);  % compression ratio
    
    % Save results
    results.p(k) = p;
    results.nnz_total(k) = nnz_total;
    results.CR(k) = CR;
    
    % --- Inverse 2D DST (S is its own inverse) (Q12) ---
    Rrec = S_row * YR_masked * S_col;
    Grec = S_row * YG_masked * S_col;
    Brec = S_row * YB_masked * S_col;
    
    % Clip and cast back to uint8 safely
    Rec = cat(3, uint8(round(clamp(Rrec,0,255))), ...
                  uint8(round(clamp(Grec,0,255))), ...
                  uint8(round(clamp(Brec,0,255))));
    
    % Display reconstructed image and a difference image
    subplot(numel(p_values)+1,3, (k+1)*3 - 2);
    imagesc(Rec); axis image off;
    title(sprintf('Reconstruction p=%.3g', p));
    
    diff_img = sqrt(sum((double(Rec) - A).^2, 3)); % per-pixel RMS difference
    subplot(numel(p_values)+1,3,(k+1)*3 - 1);
    imagesc(diff_img); colormap(gca,'hot'); axis image off;
    title('Per-pixel RMS difference');
    
    subplot(numel(p_values)+1,3,(k+1)*3);
    imagesc(log10(abs(YR_masked)+1)); colormap(gca,'jet'); axis image off;
    title('log10(|YR_masked|)');
    
    % Optionally write compressed output image
    if writeOutputs
        [~, name, ext] = fileparts(inputFile);
        pstr = regexprep(sprintf('%.3f',p), '\.', '_');
        outname = sprintf('%s_p%s%s', name, pstr, ext);
        imwrite(Rec, outname);
        fprintf('Wrote %s  (p=%.3g, nnz=%d, CR=%.3f)\n', outname, p, nnz_total, CR);
    end
end

% --- Summary output (Q14-Q15) ---
fprintf('\nCompression Summary for image: %s\n', inputFile);
disp(results);

% Suggest a "good" p value (heuristic): choose largest CR with nnz_total >= 0.05*uncompressed
% (user-adjustable; here we just print suggestion)
threshold = 0.05 * uncompressed_coeffs;
idx_good = find(results.nnz_total >= threshold, 1, 'last'); % largest p with enough coefficients
if ~isempty(idx_good)
    fprintf('Heuristic suggested p = %.3g (nnz=%d, CR=%.3f)\n', ...
        results.p(idx_good), results.nnz_total(idx_good), results.CR(idx_good));
else
    fprintf('No p in tested set meets the heuristic threshold; consider larger p.\n');
end

end

% ----------------------------
% DSTmatrix(n) - builds n x n DST matrix per project formula (Q10)
function S = DSTmatrix(n)
% s_{i,j} = sqrt(2/n) * sin( pi*(i-0.5)*(j-0.5)/n )
S = zeros(n,n);
fac = sqrt(2 / n);
for i = 1:n
    for j = 1:n
        S(i,j) = fac * sin( pi * (i - 0.5) * (j - 0.5) / n );
    end
end
end

% ----------------------------
% small clamp utility
function Y = clamp(X, lo, hi)
Y = min(max(X, lo), hi);
end

%% External Functions
%
% <include>grayImage.m</include>
%