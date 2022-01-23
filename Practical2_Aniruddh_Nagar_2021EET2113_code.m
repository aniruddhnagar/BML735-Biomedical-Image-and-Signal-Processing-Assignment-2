%% ======================================================================%%
%                        Course  : BML735 / Assignment2                   %
%                        Name    : Aniruddh Nagar                         %
%                        EntryNo : 2021EET2113                            %
% ========================================================================%

%% ===================== Workspace Initialisation =========================
close all;  % Close all figures (except those of imtool).
clear;      % Erase all existing variables.
clc;        % Clear the command window.

%% ============= Code for loading & displaying image  =====================
% Reading T2W_Brain.dcm image through given path --- 
% path = 'C:\Users\hp\MATLAB Drive\bml_practical\Assign_2\T2W_Brain.dcm';
% img = dicomread(path);

img = dicomread('T2W_Brain.dcm');
img = double(img);

% Displaying Original T2W_Brain.dcm image ---
figure, imagesc(img), colormap(gray), colorbar, axis off, axis image;
                                                  title('Orignal Image');

% Normalising T2W_Brain.dcm image ---                                    
norm_img = mat2gray(img); 

% Displaying Normalised T2W_Brain.dcm image ---
figure, imagesc(norm_img), colormap(gray), colorbar, axis off, axis image;
                                                title('Normalized Image');

%% ===========  1a. Code for adding Gaussian noise to image  ==============
% Corrupting image using Gaussian noise (mean 0, σ = 0.13) ---
mean = 0;
variance = 0.13;
noisy_img = imnoise(norm_img,'gaussian',mean,variance);

% Displaying Gaussian-Noisy T2W_Brain.dcm image ---
figure, imagesc(noisy_img), colormap(gray), colorbar, axis off, axis image;
                           title('Gaussian Noise with mean:0 & var: 0.13');

%% ============  1b. Smoothing Noisy image using Filters  =================
% Applying Mean filter using fspecial ---
mean_filt = fspecial('average', 7);
m_fil_img = imfilter(noisy_img, mean_filt);

% Displaying Mean-Filtered T2W_Brain.dcm image ---
figure, imagesc(m_fil_img), colormap(gray), colorbar, axis off, axis image;
                                                title('After Mean filter');

% Applying Gaussian filter using fspecial ---
gaus_filt = fspecial('gaussian', 5, 5);
g_fil_img = imfilter(noisy_img, gaus_filt);

% Displaying Gaussian-Filtered T2W_Brain.dcm image ---
figure, imagesc(g_fil_img), colormap(gray), colorbar, axis off, axis image;
                                            title('After Gaussian filter');

%% ===========  2a. Code for adding speckle noise to image  ===============
% Corrupting image using Speckle noise ---
speky_img = imnoise(norm_img, "speckle", 0.6);

% Displaying Original Normalised T2W_Brain.dcm image ---
figure, imagesc(norm_img), colormap(gray), colorbar, axis off, axis image;
                                        title('Original Normalized Image');

% Displaying Speckle-Noisy T2W_Brain.dcm image ---
figure, imagesc(speky_img), colormap(gray), colorbar, axis off, axis image;
                                         title('Image with Speckle noise');
 
%% =============  2b. Smoothing Noisy image using Filters  ================
% Applying Mean filter using fspecial ---
mean_filt = fspecial('average', 7);
mean_img = imfilter(speky_img, mean_filt);
figure, imagesc(mean_img), colormap(gray), colorbar, axis off, axis image;
                                             title('Mean filtered image');

% Applying Gaussian filter using fspecial ---
gaus_filt = fspecial('gaussian', 5, 5);
gaus_img = imfilter(speky_img, gaus_filt);
figure, imagesc(gaus_img), colormap(gray), colorbar, axis off, axis image;
                                         title('Gaussian filtered image');

% Applying Median filter ---  
med_img = medfilt2(speky_img, [3 3]);
figure, imagesc(med_img), colormap(gray), colorbar, axis off, axis image;
                                           title('Median filtered image');

% Applying Wiener filter ---  
wnr_img = wiener2(speky_img,[3 3]);
figure, imagesc(wnr_img), colormap(gray), colorbar, axis off, axis image;
                                           title('Wiener filtered image');

%% ========= 3. Effect of High Freq removal on image quality  =============
f = figure();
f.WindowState = 'maximized';
i = 0; % iterator for subplot 
% Displaying Original T2W_Brain.dcm image ---
subplot(2,3,i+1), imagesc(norm_img), colormap(gray), colorbar, axis off, 
                                       axis image; title('Orignal Image');

for amp_Th = 11:-1:7
    i=i+1;
    % Compute the 2D fft.
    norm_fft = fftshift(fft2(norm_img));
    % Taking log magnitude for better display ---
    minVal = min(min(log(abs(norm_fft))));
    maxVal = max(max(log(abs(norm_fft))));
%     figure, imagesc(log(abs(norm_fft))+1, [minVal maxVal]), colormap(gray), 
%                   colorbar, axis off, axis image; title('fft original image');
    
    % Find the location of the high frequencies ---  
    high_freq = (log(abs(norm_fft))+1) > amp_Th; % Binary image.
%     figure, imagesc(high_freq), colormap(gray), colorbar, axis off, 
%                                 axis image; title('High freq - Bright spikes');
      
    % Removing the high freq spikes by filter/masking the spectrum ---
    norm_fft(high_freq(:) == 1) = 0;
    minVal = min(min(log(abs(norm_fft))));
    maxVal = max(max(log(abs(norm_fft))));
%     figure, imagesc(log(abs(norm_fft)),[minVal maxVal]), colormap(gray), 
%         colorbar, axis off, axis image; title('fft image with Spikes removed');

    % Final filtered image ---
    filtered_img = ifft2(fftshift(norm_fft));
    minVal = min(min(abs(filtered_img )));
    maxVal = max(max(abs(filtered_img )));
    
    subplot(2,3,i+1),imagesc(abs(filtered_img ), [minVal maxVal]), 
    colormap(gray), colorbar, axis off, axis image; title('Filtered image',i);
%     figure, imagesc(abs(filtered_img ), [minVal maxVal]), colormap(gray), 
%                        colorbar, axis off, axis image; title('Filtered image');
end
                                                             
%% ===========  4a. Additive Effect of blur and gaussian noise  ===========                                                    
% Adding blur and gaussian noise ---
PSF = fspecial('motion', 21, 11);
b_img = imfilter(norm_img, PSF,'conv','circular');
b_g_img = imnoise(b_img, 'gaussian', 0, 0.005);
figure, imshow(b_g_img);title('Blury and Gausy image')

%% ===============  4b. Restoration using Weiner Filter  ==================      
% Restoration assuming no noise.
nsr = 0;
wnr_img1 = deconvwnr(b_g_img, PSF, nsr);
figure, imshow(wnr_img1); title('Restored Blury-Gausy Image with Zero NSR')

% Restoration using a better estimate of NSR ratio.
estim_nsr = 0.01 / var(norm_img(:));
wnr_img2 = deconvwnr(b_g_img, PSF, estim_nsr);
figure, imshow(wnr_img2); title('Restored Blury-Gausy Image with Estimated NSR');
