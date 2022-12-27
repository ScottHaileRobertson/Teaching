% MRI_Material This object is used for MRI simulations of a single "material" of a digital
% phantom. The material and shape are described analytically in k-space, so it is a
% perfect representation of the object. T1, T2, PD, and chemical shift
% properties are also considered.
%
%   Copyright: 2022 Scott Haile Robertson.
%   Website: www.ScottHaileRobertson.com
%   $Revision: 1.0 $  $Date: 2022/12/23 $
classdef MRI_Material < handle
    properties
        materialT1_s;
        materialT2_s;
        materialPD_arb;
        materialChemShift_Hz;

        shapes;
    end

    methods
        function this = MRI_Material(T1_s, T2_s, PD_arb, chemShift_Hz, varargin)
            this.materialT1_s = T1_s;
            this.materialT2_s = T2_s;
            this.materialPD_arb = PD_arb;
            this.materialChemShift_Hz = chemShift_Hz;
            this.shapes = MRI_Shape(varargin);
        end

        function kspaceV = kspace(this,u,v,bw,phaseEncodingDir, FOV)
            % Calculate chemical shift
            if(phaseEncodingDir == 'ROW')
                chemicalShift = this.shapes.shift(this.materialChemShift_Hz*FOV(1)/bw,0, u,v);
            else
                chemicalShift = this.shapes.shift(0,this.materialChemShift_Hz*FOV(2)/bw, u,v);
            end
            
            % Calculate k-space of shapes
            kspaceV = this.shapes.kspace(u,v);

            % Correct for contrast
            kspaceV = this.materialPD_arb.*kspaceV.*chemicalShift;
        end
    end

end