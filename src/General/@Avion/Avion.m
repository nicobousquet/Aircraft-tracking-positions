classdef Avion < handle
    properties
        displayText       = true,
        trackTrajectory   = true,
        displayTrajectory = true,
        displayLogo       = true
    end
    %% Private properties
    properties (SetAccess = private)
        latitude, % latitude de l'avion,
        longitude, % longitude de l'avion,
        altitude, % altitude de l'avion,
        adresse,  % adresse ICAO de l'avion(24 bits)
        
        nom, % nom de l'avion ('AF-1234')
        
        trajectoire,
        trames,
        
        handleFigurePlane = [],
        handleTextPlane = [],
        handleTrajectoryPlane = [];
        handleLogo = [];
        
        color = [];
        style = [];
    end
    
    methods
        function obj = Avion(nom,varargin)
            obj.nom = nom;
            
            switch nargin-1
                case 0
                    %% Cas Avion(nom)
                    % Dans ce cas l'avion est cr�� au sol sur l'a�roport de
                    % M�rignac
                    obj.longitude = [];
                    obj.latitude = [];
                    obj.altitude = [];
                    obj.adresse = '';
                    
                    
                case 2
                    %% Cas Avion(nom,lon,lat)
                    % Dans ce cas l'avion est cr�� au sol avec les
                    % coordonn�es fournies
                    obj.longitude = varargin{1};
                    obj.latitude = varargin{2};
                    obj.altitude = [];
                    obj.adresse = '';
                    
                case 3
                    %% Cas Avion(nom,lon,lat,alt)
                    % Dans ce cas l'avion est cr�� au sol avec les
                    % coordonn�es fournies
                    obj.longitude = varargin{1};
                    obj.latitude = varargin{2};
                    obj.altitude = varargin{3};
                    obj.adresse = '';
                    
                case 4
                    %% Cas Avion(nom,lon,lat,alt,adresse)
                    % Dans ce cas l'avion est cr�� au sol avec les
                    % coordonn�es fournies
                    obj.longitude = varargin{1};
                    obj.latitude = varargin{2};
                    obj.altitude = varargin{3};
                    obj.adresse = varargin{4};
                    
                otherwise
                    error('Constructeur non reconnu')
            end
            if obj.trackTrajectory
                obj.trajectoire = [obj.longitude ; obj.latitude ; obj.altitude];
            else
                obj.trajectoire = [];
            end
            obj.trames = [];
            obj.handleFigurePlane = [];
            obj.handleTextPlane = [];
            obj.handleTrajectoryPlane = [];
            obj.handleLogo = [];
        end
        
        function setStyle(obj, idx)
            STYLES = {'-','--',':'};
            COLORS = lines(6);
            
            obj.color = COLORS(mod(idx-1,size(COLORS,1))+1,:);
            obj.style = STYLES{mod(floor((idx-1)/size(COLORS,1)),length(STYLES))+1};
        end
        function setPosition(obj,lon,lat,alt)
            if nargin < 2
                error('Cette fonction prends au moins deux arguments : longitude, latitude')
            end
            if isempty(alt)
                alt  =0;
            end
            obj.longitude = lon;
            obj.latitude = lat;
            obj.altitude = alt;
            if obj.trackTrajectory
                if obj.trajectoire == 0
                    obj.trajectoire = [];
                end
                obj.trajectoire = [obj.trajectoire, [obj.longitude;obj.latitude;obj.altitude] ];
            end
        end
        function updateWithRegister(obj,reg)
            if reg.type > 0 && reg.type <= 4
                if isempty(obj.nom) && ~isempty(reg.planeName)
                    obj.nom = reg.planeName;
                end
                if isempty(obj.adresse)
                    obj.adresse = ['0x', reg.adresse];
                end
                
            elseif reg.type>4 && reg.type<=17
                obj.setPosition(reg.longitude,reg.latitude,reg.altitude)
                if isempty(obj.adresse)
                    obj.adresse = ['0x', reg.adresse];
                end
            end
            
            
        end
        function addTrame(obj,trame)
            obj.trames = [obj.trames, trame(:)];
        end
        function setLattitude(obj,lat)
            obj.latitude = lat;
        end
        function setLongitude(obj,lon)
            obj.longitude = lon;
        end
        function setAltitude(obj,alt)
            obj.altitude = alt;
        end
        function setAdresse(obj,adresse)
            obj.adresse = adresse;
        end
        
        function plot(obj)
            if ~isempty(obj.handleTextPlane)
                delete(obj.handleFigurePlane)
                delete(obj.handleTextPlane)
                delete(obj.handleLogo)
            end
            
            if ~isempty([obj.longitude,obj.latitude])
                if isempty(obj.nom)
                    etiquette = obj.adresse;
                else
                    etiquette = obj.nom;
                end
                obj.handleFigurePlane = plot(obj.longitude,obj.latitude, '>','color',obj.color);
                
                if obj.displayText
                    obj.handleTextPlane = text(obj.longitude,obj.latitude,etiquette,'color',obj.color,'Margin',3,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',12);
                end
                if obj.displayTrajectory
                    obj.handleTrajectoryPlane = plot(obj.trajectoire(1,:),obj.trajectoire(2,:),obj.style,'color',obj.color);
                end
                
                if obj.displayLogo
                    fileName = 'avion.png';
                    [marker,~,transperancy] = imread(fileName);
                    bias = -45;
                    markersize = [.1,.05];
                    x = obj.trajectoire(1,:);
                    y = obj.trajectoire(2,:);
                    x_low = x - markersize(1)/2;
                    x_high = x + markersize(1)/2;
                    y_low = y - markersize(2)/2;
                    y_high = y + markersize(2)/2;
                    k = length(obj.trajectoire(1,:));
                    if k>1 && (x(k)-x(k-1) ~= 0)
                        angle = -atan((y(k)-y(k-1))/(x(k)-x(k-1)))*180/pi;
                        if x(k) < x(k-1)
                            angle = angle + 180;
                        end
                    else
                        angle = 0;
                    end
                    angle = angle+bias;
                    marker_rot = imrotate(marker, angle, 'crop');
                    transperancy_rot = imrotate(transperancy, angle, 'crop');
                    
                    figure(1)
                    obj.handleLogo = imagesc([x_low(k) x_high(k)], [y_low(k) y_high(k)], marker_rot);
                    set(obj.handleLogo ,'AlphaData',transperancy_rot);
                end
                
            end
        end
        
        function printTrajectoireInFile(obj,fid)
            nI = size(obj.trajectoire,2);
            nM = size(obj.trajectoire,1);
            
            for i = 1:nI
                for m = 1:nM-1
                    fprintf(fid, '%f,' ,obj.trajectoire(m,i));
                end
                fprintf(fid, '%f \n' ,obj.trajectoire(nM,i));
            end
        end
        
        function printTramesInFile(obj,fid)
            nI = size(obj.trames,2);
            nM = size(obj.trames,1);
            for i = 1:nI
                for m = 1:nM-1
                    fprintf(fid, '%f,%f,' ,real(obj.trames(m,i)),imag(obj.trames(m,i)));
                end
                fprintf(fid, '%f,%f \n' ,real(obj.trames(nM,i)),imag(obj.trames(nM,i)));
            end
        end
    end
end

