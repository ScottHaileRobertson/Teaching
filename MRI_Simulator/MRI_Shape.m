% MRI_Shape This object is used for MRI simulations of a single shape of a digital
% phantom that is described analytically in k-space, so it is a perfect representation
% of the object.
%   Copyright: 2022 Scott Haile Robertson.
%   Website: www.ScottHaileRobertson.com
%   $Revision: 1.0 $  $Date: 2022/12/23 $
classdef MRI_Shape < handle
    properties
        shapeName;
        shapeParam;
        shapeInclude;
    end

    methods
        function this = MRI_Shape(varargin)
            if(length(varargin) == 1)
                varargin = varargin{1};
                if(length(varargin) == 1)
                    varargin = varargin{1};
                end
            end
            this.shapeName = {varargin{1:3:end}};
            this.shapeParam = {varargin{2:3:end}};
            this.shapeInclude = {varargin{3:3:end}};
        end

        function kspaceV = kspace(this,u,v)
            nshapes = length(this.shapeName);
            kspaceV = 0;
            for iShape = 1:nshapes
                if(this.shapeInclude{iShape})
                    multVal = 1;
                else
                    multVal = -1;
                end
                switch(this.shapeName{iShape})
                    case 'circ'
                        kspaceV = kspaceV + multVal*this.kspace_circle(this.shapeParam{iShape}(1), ...
                            this.shapeParam{iShape}(2),...
                            this.shapeParam{iShape}(3),...
                            u,v);
                    case 'rect'
                        kspaceV = kspaceV + multVal*this.kspace_rectangle(this.shapeParam{iShape}(1), ...
                            this.shapeParam{iShape}(2), ...
                            this.shapeParam{iShape}(3),...
                            this.shapeParam{iShape}(4),...
                            this.shapeParam{iShape}(5),...
                            u,v);
                end
            end
        end

        function kspace = kspace_rectangle(this,xc,yc,xw,yw,angle_radians, u,v)
            %apply rotation
            [ru,rv] = this.rotate2D(angle_radians,u,v);

            % apply shift
            shiftMult = this.shift(xc,yc,u,v);

            kspace = xw*yw.*this.sinc(ru*xw).*this.sinc(rv*yw).*shiftMult;
        end

        function kspace = kspace_circle(this,xc,yc,radius, u,v)
            % apply shift
            shiftMult = this.shift(xc,yc,u,v);

            kspace = radius^2 * 4*this.jinc(2*sqrt(u.^2+v.^2)*radius).*shiftMult ;
        end

        function [ru,rv] = rotate2D(this,angle_radians,u,v)
            % Rotation matrix
            R = [cos(angle_radians) -sin(angle_radians)
                sin(angle_radians)  cos(angle_radians)];

            Ruv = [u(:) v(:)]*R;
            ru = reshape(Ruv(:,1),size(u));
            rv = reshape(Ruv(:,2),size(v));
        end

        function shiftMult = shift(this,xc,yc, u,v)
            % Applies a linear phase term in k-space to shift a function in
            % image space
            shiftMult = exp(-2i*pi*(u*xc + v*yc));
        end

        function y = sinc(this,x)
            iz = find(x == 0); % indices of zero arguments
            x(iz) = 1; % avoid divide by zero
            y = sin(pi*x) ./ (pi*x);
            y(iz) = 1;
        end

        function y = jinc(this,x)
            %function y = jinc(x)
            % jinc(x) = J_1(pi x) / (2 x),
            % where J_1 is Bessel function of the first kind of order 1.
            % This is the 2D Fourier transform of a disk of diameter 1,
            % so its DC value is the area of that disk which is pi/4.
            % Equivalently it is the Hankel transform of rect = @(r) abs(r) < 1/2;
            % Jeff Fessler, University of Michigan

            x = abs(x); % kludge for bessel with negative arguments, perhaps not needed
            y = pi/4 + 0 * x; % jinc(0) = pi/4
            ig = x ~= 0;
            y(ig) = besselj(1, pi * x(ig)) ./ (2 * x(ig));
        end
    end

end