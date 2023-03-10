% Create phantom


FOV = 250;
phaseFOV = 1;
FOV_Mat = [FOV phaseFOV*FOV];

MatrixSize = 256;
pctPhase = 1;
Matrix_Mat = [MatrixSize MatrixSize*pctPhase];

pixSz = FOV_Mat./Matrix_Mat;

FOVu = 1./pixSz;
deltau = 1./FOV_Mat;

NValsNeg = floor(0.5*Matrix_Mat);
NValsPos = Matrix_Mat - NValsNeg - 1;
kx = -NValsNeg(1)*deltau(1):deltau(1):deltau(1)*NValsPos(1);
ky = -NValsNeg(2)*deltau(2):deltau(2):deltau(2)*NValsPos(2);

% sample kspace
[Mx, My] = meshgrid(kx,ky);

T1_s = 0;
T2_s = inf;
PD_arb = 20;
chemShift_Hz = 500;


bw = 32000;
phaseEncodingDir = 'ROW';
kspIm_cart = phantom.kspace(Mx,My,bw,phaseEncodingDir,FOV_Mat);
im_cart = ifftshift(ifftn(kspIm_cart));

figure();
subplot(1,2,1);
imagesc(log(abs(kspIm_cart)))
colormap(gray)

subplot(1,2,2);
imagesc(abs(im_cart))
colormap(gray)
