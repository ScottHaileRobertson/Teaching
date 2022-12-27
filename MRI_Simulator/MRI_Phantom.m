% MRI_Phantom This object is used for MRI simulations that require a digital
% phantom. This phantom is described analytically in k-space, so it is a
% perfect representation of the object. T1, T2, PD, and chemical shift
% properties are also considered.
%
%   Copyright: 2022 Scott Haile Robertson.
%   Website: www.ScottHaileRobertson.com
%   $Revision: 1.0 $  $Date: 2022/12/23 $
classdef MRI_Phantom < handle
    properties
        materials
    end

    methods
        function this = MRI_Phantom(varargin)
            nMaterials = length(varargin)/5;
            for iMaterial = 1:nMaterials
                T1_s = varargin{1+(iMaterial-1)*5};
                T2_s = varargin{2+(iMaterial-1)*5};
                PD_arb = varargin{3+(iMaterial-1)*5};
                chemShift_Hz = varargin{4+(iMaterial-1)*5};
                shapeData = varargin{5+(iMaterial-1)*5};
                this.materials{iMaterial} = MRI_Material(T1_s, T2_s, PD_arb, chemShift_Hz, shapeData);
            end
        end

        function kspaceV = kspace(this,u,v,bw,phaseEncodingDir, FOV)
            nMaterials = length(this.materials);
            kspaceV = 0;
            for iMaterials = 1:nMaterials
                kspaceV = kspaceV + this.materials{iMaterials}.kspace(u,v,bw,phaseEncodingDir, FOV);
            end
        end
    end
end