% Create phantom
%|	'dirac2'	[N 3]	[xcent ycent value]
%|	'dirac3'	[N 4]	[xcent ycent zcent value]
%|	'rect2'		[N 5]	[xcent ycent xwidth ywidth value]
%|	'rect3'		[N 7]	[xcent ycent zcent xwidth ywidth zwidth value]
%|	'gauss2'	[N 5]	[xcent ycent xwidth ywidth value]
%|	'gauss3'	[N 7]	[xcent ycent zcent xwidth ywidth zwidth value]
%|	'circ2'		[N 5]	[xcent ycent rad value]
%|	'cyl3'		[N 6]	[xcent ycent zcent xrad zwidth value]
%|	'sphere'	[N 5]	[xcent ycent zcent rad value]
st1 = mri_objects('circ2', [0 0 125 1],...% 25 cm circle
    'circ2', [0 0 100 -1],...
    'rect2',[0 0 35 35 2]); % 25 cm circle


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

% shape = MRI_Phantom(T1_s, T2_s, PD_arb, chemShift_Hz, ...
%     {'circ', [0 0 125],true,...% Ideal Fluid
%     'circ', [0 0 100],false,...
%     'rect',[0 0 35 35 0],true},...
%     )
shape = MRI_Phantom(0, inf, 1, 0, ... % Ideal Fluid
    {'circ', [0 0 125],true,...
    'rect',[0 0 35 35 0],false},...
    0, inf, 1.5, 220, ... % Chemical shift
    {'rect',[0 0 35 35 0],true});

bw = 32000;
phaseEncodingDir = 'ROW';
kspIm_cart = shape.kspace(Mx,My,bw,phaseEncodingDir,FOV_Mat);
im_cart = ifftshift(ifftn(kspIm_cart));

figure();
subplot(1,2,1);
imagesc(log(abs(kspIm_cart)))
colormap(gray)

subplot(1,2,2);
imagesc(abs(im_cart))
colormap(gray)
