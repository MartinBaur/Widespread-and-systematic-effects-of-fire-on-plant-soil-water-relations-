%% MJB 06-Aug-2024 Clean code of fire project



%% Step1 find all SMAP pixels with at least 100 burns

clear

cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
lat_SMAP = load('lat.mat','lat') ;lat_SMAP = lat_SMAP.lat ;
lon_SMAP = load('lon.mat','lon') ;lon_SMAP = lon_SMAP.lon ;
lat_SMAP = lat_SMAP(:,1) ;
lon_SMAP = lon_SMAP(1,:) ;


cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\SM')
tilelist_SM = dir() ;
% cut to SM only
tilelist_SM = tilelist_SM(3:194) ;

cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\TAU')
tilelist_TAU = dir() ;
% cut to TAU only
tilelist_TAU = tilelist_TAU(3:194) ;

tilelist_latlonindex = dir() ; 
tilelist_lat = tilelist_latlonindex(195:386) ; 
tilelist_lon = tilelist_latlonindex(387:end) ; 

cd('E:\MOSEV_tiles\MOSEV_tiles_processed')
tilelist_MOSEV = dir() ;
tilelist_MOSEV = tilelist_MOSEV(3:end) ;

% set min number of points in drydown
dLength = 4;
% define arrays to save to

% run for limited number of tiles if for test reason
for i = 1: length(tilelist_SM)  % test with 12  h09 v07
     
    cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\SM')
    curtile_SM = tilelist_SM(i) ;
    cur_SM = load(curtile_SM.name,'SM_full_series') ; 
    % use eval .. find solid solution to do this
    eval(    strcat('cur_SM=','cur_SM.','SM_full_series',';')    )
    
    cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\TAU')
    curtile_TAU = tilelist_TAU(i) ;
    cur_TAU = load(curtile_TAU.name,'TAU_full_series') ; 
    % use eval .. find solid solution to do this
    eval(    strcat('cur_TAU=','cur_TAU.','TAU_full_series',';')    )  
    % get latlon
    curtile_lat = tilelist_lat(i) ; 
    cur_lat_index = load(curtile_lat.name) ; cur_lat_index = cur_lat_index.lat_index ; 
    curtile_lon = tilelist_lon(i) ; 
    cur_lon_index = load(curtile_lon.name) ; cur_lon_index = cur_lon_index.lon_index ; 
    % get actual lat and lon array from layer .. this is center pixel get
    % +- 1to find the border between pixels.

    if cur_lat_index(1) == cur_lat_index(2)
    cur_lat_index(2) = cur_lat_index(1) +1 ;
    end
    if cur_lon_index(1) == cur_lon_index(2)
    cur_lon_index(2) = cur_lon_index(1) +1 ;
    end

    cur_lat_SMAP = lat_SMAP(min(cur_lat_index):max(cur_lat_index)) ; 
    cur_lon_SMAP = lon_SMAP(min(cur_lon_index):max(cur_lon_index)) ; 
    

    % bring in MOSEV lat and lon .. define burn pixel .. only detect dry
    % downs for relevant SM pixels .. otherwise it will take very long    
    cd('E:\MOSEV_tiles\MOSEV_tiles_processed')
    curtile_MOSEV = tilelist_MOSEV(i) ;
    cur_MOSEV = load(curtile_MOSEV.name) ;
    cur_MOSEV = struct2array(cur_MOSEV) ;

    % extra loop through MOSEV pixels find their lat lon .. match to SMAP
    % pixels

    cur_MOSEV_latlon = [cur_MOSEV.Var2 , cur_MOSEV.Var3] ; 
    cur_MOSEV_latlon = unique(cur_MOSEV_latlon,'rows') ; 
    % Var 2 is lat
    MOSEV_latlist = cur_MOSEV_latlon(:,1) ; 
    % Var 3 is lon
    MOSEV_lonlist = cur_MOSEV_latlon(:,2) ; 



  % get SMAP lat lon differences
  cur_lat_SMAP_diff = diff(cur_lat_SMAP) ; 
  cur_lon_SMAP_diff = diff(cur_lon_SMAP) ; 
  % 
  cur_lat_SMAP_half = abs(cur_lat_SMAP_diff ./ 2) ;
  cur_lon_SMAP_half = abs(cur_lon_SMAP_diff ./ 2) ;
  % pad a last value small inaccuracy probably
  cur_lat_SMAP_half = vertcat(cur_lat_SMAP_half, cur_lat_SMAP_half(end)) ;
  cur_lon_SMAP_half = horzcat(cur_lon_SMAP_half, cur_lon_SMAP_half(end)) ;  
  % do differently .. loop through SMAP pixels .. looping through MOSEV
  % might redo all the work for each SMAP pixel multiple times
  q = 1 ;
  % create rowcollist later shhorten
  row_col_list = NaN( size(cur_SM,1)*size(cur_SM,1), 2 ) ; 



    for r = 1:length(cur_lat_SMAP)
        for c = 1:length(cur_lon_SMAP)
           
        % get SMAP lat lon then check if MOSEV burn is within pixel .. if
        % even one pixel is inside we calculate dry downs.
        cur_lat_SMAP_dummy = cur_lat_SMAP(r) ;
        cur_lon_SMAP_dummy = cur_lon_SMAP(c) ;      


        % find min
        lat_diff =  abs(cur_lat_SMAP_dummy - MOSEV_latlist)  ; 
        lon_diff  = abs(cur_lon_SMAP_dummy - MOSEV_lonlist)  ;
        % check if mins are below threhsolds
        lat_diff_thresh = lat_diff < cur_lat_SMAP_half(r) ; 
        lon_diff_thresh = lon_diff < cur_lon_SMAP_half(c) ;    
        In_pixel = lat_diff_thresh & lon_diff_thresh ; 
        In_pixel(In_pixel == 0) = [] ; 

        % just to check if everything is working
%         if (length(In_pixel) > 18^2)
%             length(In_pixel)
%             %error('double check length > 18^2')
%         end

        % only take pixels with a sufficiently high number of burns ..
        % otherwise it might not be worth it to extract dry downs later
        if (length(In_pixel) > 100)
                % assign pixel to list for drydown calculation
               row_col_list(q,1) = r ;
               row_col_list(q,2) = c ;        
        q = q + 1 ;
        else

        end


        end
    end
    
     % remove padding .. 
     row_col_list(all(isnan(row_col_list),2),:) = [] ;


   % define r x c dim array to save all 
   timevOL_cell   = cell(size(cur_SM,1), size(cur_SM,2)) ; 
   smvOL_cell     = cell(size(cur_SM,1), size(cur_SM,2)) ; 
   tauvOL_cell    = cell(size(cur_SM,1), size(cur_SM,2)) ; 
   smvOL_S_cell   = cell(size(cur_SM,1), size(cur_SM,2)) ; 
   tauvOL_S_cell  = cell(size(cur_SM,1), size(cur_SM,2)) ;   
    timevOL_S_cell   = cell(size(cur_SM,1), size(cur_SM,2)) ; 
   
   %     now run dry down detection and extract timing as well
    for list = 1:size(row_col_list,1)
         
        % define row and col from list of matches
         r = row_col_list(list,1)  ;
         c = row_col_list(list,2)  ;       
         
         tt = [ 1 : size(cur_SM,3) ]'; 
         sm_dummy =  squeeze(cur_SM(r,c,:)) ; 
         % sm_dummy_smooth = movmean(sm_dummy,120,1,'omitnan') ; 
         % MJB 06.12.2023 adress smoothing comment
         sm_dummy_smooth = movmean(sm_dummy,365,1,'omitnan') ; 

         tau_dummy =  squeeze(cur_TAU(r,c,:)) ; 
         % tau_dummy_smooth = movmean(tau_dummy,120,1,'omitnan') ; 
         % MJB 06.12.2023 adress smoothing comment
         tau_dummy_smooth = movmean(tau_dummy,365,1,'omitnan') ; 

         % define time and then cut out day with no overpass
         nandummy = isnan(sm_dummy) ;
         tt(nandummy) =     [];    
         tau_dummy(nandummy) =   []; 
         tau_dummy_smooth(nandummy) =   []; 
         sm_dummy_smooth (nandummy) =     [];   
         sm_dummy(nandummy) =   []; 
         
         % detect dry downs and save timing tau and sm info
         cd('E:\Daten Baur\Matlab code\Project IGARSS multi frq tau\noodles_L_C_X')
         [NDryL,timevOL,smvOL,tauvOL] = DryDowns(tt,sm_dummy,tau_dummy,dLength); 
         % detect dry downs for smooth seasonal dynamics
         [NDryL_S,timevOL_S,smvOL,tauvOL_S] = DryDowns(tt,sm_dummy,tau_dummy_smooth,dLength); 
         
         
         % calc smvOL_S afterwards
         for j = 1:length(timevOL)
          
             if j == 1       
         smvOL_S = {sm_dummy_smooth( ismember(tt, timevOL{j}, 'rows'))} ; 
          else
          smvOL_S = vertcat(smvOL_S, {sm_dummy_smooth(  ismember(tt, timevOL{j}, 'rows'))}) ;     
          end
         end
         
         
         
         timevOL_cell(r,c) = {timevOL}  ; 
         smvOL_cell(r,c)   = {smvOL}  ;
         tauvOL_cell(r,c)   = {tauvOL}  ;
         timevOL_S_cell(r,c) = {timevOL_S}  ; 
         smvOL_S_cell(r,c)   = {smvOL_S}  ;
         tauvOL_S_cell(r,c)   = {tauvOL_S}  ;      
         
         
    end
    

         cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\DryDowns_365_smooth')

         % save in 2D arrays with sub cell structure
         eval(  ['save("timevOL_cell_',curtile_SM.name(4:9),'","timevOL_cell")' ]  )
         eval(  ['save("smvOL_cell',curtile_SM.name(4:9),'","smvOL_cell")' ]  )        
         eval(  ['save("tauvOL_cell',curtile_SM.name(4:9),'","tauvOL_cell")' ]  )      
         eval(  ['save("smvOL_S_cell',curtile_SM.name(4:9),'","smvOL_S_cell")' ]  )      
         eval(  ['save("tauvOL_S_cell',curtile_SM.name(4:9),'","tauvOL_S_cell")' ]  )    
         eval(  ['save("timevOL_S_cell_',curtile_SM.name(4:9),'","timevOL_S_cell")' ]  )    

  i  
end


% ==========================================
% MJB 13.09.2024 checked this step no errors
% ==========================================




%% Step 2 Loop over found pixels and define drydown events. Apply both time and total pixel burned threshold



clear 
cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\DryDowns')
% get filelists for all drydowns

filelist_sm = dir('*smvOL_cell*') ; 
filelist_tau = dir('*tauvOL_cell*') ;
filelist_time = dir('*timevOL_S_cell*') ;

% get filelist for lat and lon index of box.
cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\SM')
filelist_lat_index = dir('*lat*') ;  
filelist_lon_index = dir('*lon*') ;  

cd('E:\MOSEV_tiles\MOSEV_tiles_2015_2020')
tilelist_MOSEV = dir('*MOSEV*');
% load SMAP lat lon 9 km
cd('E:\Daten Baur\Matlab files\means_über_zeitreihe\MTDCA')
load('SMAPCenterCoordinates9KM.mat', 'SMAPCenterLatitudes')
load('SMAPCenterCoordinates9KM.mat', 'SMAPCenterLongitudes')


% loop through all tiles and pixels. Separate dry downs relative to
% temporal distance to fire test with i = 12
% h30 v10 (north australia) is  i = 178
% i = 97 for problematic linear patter Africa pixel
% 9-07-2024 MJB was at 176

i = 178 ; 


% stopped 88
for i = 1:length(filelist_sm)

    % get sm
    curtile_drydsm = filelist_sm(i) ;
    cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\DryDowns')
    drydown_sm = load(curtile_drydsm.name ,'smvOL_cell') ; 
    drydown_sm = drydown_sm.smvOL_cell ;
   % get time
    curtile_drytime = filelist_time(i) ;
    cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\DryDowns')
    drydown_time = load(curtile_drytime.name ,'timevOL_S_cell') ; 
    drydown_time = drydown_time.timevOL_S_cell ;
   % get MOSEV
    cd('E:\MOSEV_tiles\MOSEV_tiles_2015_2020')
    curtile_MOSEV = tilelist_MOSEV(i) ;
    cur_MOSEV = load(curtile_MOSEV.name) ;
    cur_MOSEV = struct2array(cur_MOSEV) ;
   % get list of unique SMAP lat lon indices .. loop over al of them
    latlon_list = unique(cur_MOSEV(:,10:11),'rows') ; 
    
   % define event timing cell array 
   fire_timings = cell(size(drydown_sm,1), size(drydown_sm,2)) ;
   fire_distribution = cell(size(drydown_sm,1), size(drydown_sm,2)) ;
   events_fire_datetimes_cells = cell(size(drydown_sm,1), size(drydown_sm,2)) ;
   d_NBR_array = NaN(size(drydown_sm,1), size(drydown_sm,2)) ;
   pre_NBR_array = NaN(size(drydown_sm,1), size(drydown_sm,2)) ;
   % for i = 12 test with p = 456
    for p = 1:size(latlon_list,1) 

        sm_dd_dummy = drydown_sm{latlon_list.SMAP_lat_index_list(p), latlon_list.SMAP_lon_index_list(p)} ; 
        if isempty(sm_dd_dummy)
        continue
        end
        time_dd_dummy = drydown_time{latlon_list.SMAP_lat_index_list(p), latlon_list.SMAP_lon_index_list(p)} ; 
        % identify burn dates in each SMAP pixel
        MOSEV_dummy = cur_MOSEV( cur_MOSEV.SMAP_lat_index_list == latlon_list.SMAP_lat_index_list(p) & ...
                                 cur_MOSEV.SMAP_lon_index_list == latlon_list.SMAP_lon_index_list(p),:   ) ; 
        
        % remove events with negative dNBR .. could be noise?
        % ?

        % sort by time in rows
        MOSEV_dummy = sortrows(MOSEV_dummy,1)    ;

        % go through MOSEV and identify fire events temporally and with
        % number of affected pixels. are they in temporal order? Should be
        
        
        
        % MB 25.12.2021 remove MOSEV table rows with low or negative dNBR
        % .. many rows seem to have low or negative dNBR which is not reasonable if there was a real fire. 
        MOSEV_dummy_dNBR = MOSEV_dummy.dNBR ; 
        MOSEV_dummy_dates = MOSEV_dummy.Var1 ; 
        MOSEV_dummy_preNBR = MOSEV_dummy.preNBR ; 
        % now remove dates if dNBR is low or negative
       % MOSEV_dummy_dates(MOSEV_dummy_dNBR < 100) = [] ; 
        MOSEV_dummy_dates_diff = days(diff(MOSEV_dummy_dates)) ; 
        
        
%         % just add new skip statement if MOSEV dummy is empty after removal
%         % of low dNBR
%         if isempty(MOSEV_dummy_dates_diff)
%             continue
%         end

        dd = 1 ; 
        event_count = 0 ;
        eventslist = table() ;
        events_fire_distribution = table() ; 
        events_fire_datetimes = table() ; 
        mean_dNBR = NaN ; 
        mean_preNBR = NaN ; 
        event_count_dist = NaN(1,700) ; 
        event_count_datetime = NaT(1,700) ;        
        event_count_dist(:) = 0 ; 
        event_count_dist_col = 1 ; 

        for dd = 1:length(MOSEV_dummy_dates_diff)
             % add new ocndition check if we reach end of MOSEV
             if MOSEV_dummy_dates_diff(dd) < 2 && dd < length(MOSEV_dummy_dates_diff)
            
                if event_count == 0
                 event_start = MOSEV_dummy_dates(dd)  ;
                end
             event_count = event_count + 1 ;
             event_count_dist(:,event_count_dist_col) = event_count_dist(:,event_count_dist_col) + 1 ;             
             event_count_datetime(:,event_count_dist_col) =  MOSEV_dummy_dates(dd) ; 
             event_count_dist_col = event_count_dist_col + MOSEV_dummy_dates_diff(dd) ; 

             continue
             
             else
             % event_count    
             event_end = MOSEV_dummy_dates(dd+1) ;
             
             
             
             
             
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             % Key condition for definition of Burn detection .. report in
             % paper
             
             if event_count > 300 &&  days(event_end - event_start) < 60
             
             event_end = MOSEV_dummy_dates(dd+1) ;
             eventslist = vertcat(eventslist,[table(event_start), table(event_end), table(event_count)]) ; 
             % calc mean dNBR
             mean_dNBR = mean(MOSEV_dummy_dNBR(find(MOSEV_dummy_dates == event_start,1,'first'):find(MOSEV_dummy_dates == event_end,1,'last')),1,'omitnan') ;
             mean_preNBR = mean(MOSEV_dummy_preNBR(find(MOSEV_dummy_dates == event_start,1,'first'):find(MOSEV_dummy_dates == event_end,1,'last')),1,'omitnan') ;
             events_fire_distribution = vertcat(events_fire_distribution,table(event_count_dist));
             events_fire_datetimes = vertcat(events_fire_datetimes,table(event_count_datetime));            
             end
             % reset if evet is ended but did surpass threhsolds
             event_count = 0 ;
             event_count_dist_col = 1 ; 
             event_count_dist(:,:) = 0 ; 
             event_count_datetime(:,:) = NaT ;

             end 
             
        end
        
      d_NBR_array(latlon_list.SMAP_lat_index_list(p), latlon_list.SMAP_lon_index_list(p)) = mean_dNBR ; 
      pre_NBR_array(latlon_list.SMAP_lat_index_list(p), latlon_list.SMAP_lon_index_list(p)) = mean_preNBR ;       
      fire_timings{latlon_list.SMAP_lat_index_list(p), latlon_list.SMAP_lon_index_list(p)} = eventslist ; 
      fire_distribution{latlon_list.SMAP_lat_index_list(p), latlon_list.SMAP_lon_index_list(p)} = events_fire_distribution ; 
      events_fire_datetimes_cells{latlon_list.SMAP_lat_index_list(p), latlon_list.SMAP_lon_index_list(p)} = events_fire_datetimes ; 
    
    end

    filesname_MOSEV = char(curtile_MOSEV.name) ;

    % % save fire timings
     cd('E:\MOSEV_tiles\fire_timings')
     save(strcat('fire_timings_',curtile_MOSEV.name(10:15)),'fire_timings')
     cd('E:\MOSEV_tiles\dNBR_fires') 
     save(strcat('d_NBR_array',curtile_MOSEV.name(10:15)),'d_NBR_array')
     cd('E:\MOSEV_tiles\preNBR_fires') 
     save(strcat('pre_NBR_array',curtile_MOSEV.name(10:15)),'pre_NBR_array')
     cd('E:\MOSEV_tiles\fire_distributions') 

   
    save(strcat('fire_distribution_',filesname_MOSEV(10:15)),'fire_distribution')
    save(strcat('events_fire_datetimes_cells',filesname_MOSEV(10:15)),'events_fire_datetimes_cells')    

i
end





% ==========================================
% MJB 13.09.2024 checked this step no errors
% ==========================================





%% step 3 inteporlate on SM axis  



% how to correct for tau seasonal dynamics? probably have to pre condition
%on tau.
clear 
% bring in IGBP
cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('IGBP_9km.mat')

sminterp = [ 0.01 : 0.005 : 0.60 ]; 
sminterp2 = linspace(-0.6,0.6,119) ;
timeinterp = 1:100 ; 

cd('E:\Daten Baur\Matlab files\means_über_zeitreihe\MTDCA')
load('SMAPCenterCoordinates9KM.mat')

cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\SM')
SM_tilelist_all = dir() ; 
SM_tilelist = SM_tilelist_all(3:194) ;
lat_tilelist = SM_tilelist_all(195:386) ; 
lon_tilelist = SM_tilelist_all(387:end) ; 


SMAP_datetime = datetime('01-Apr-2015'):days(1):datetime('30-Sep-2021') ; 

cd('E:\MOSEV_tiles\dtau_fires') 
dtau_tilelist = dir() ; dtau_tilelist = dtau_tilelist(3:end-1) ; 

cd('E:\MOSEV_tiles\dNBR_fires') 
dNBR_tilelist = dir() ; dNBR_tilelist = dNBR_tilelist(3:end-1) ; 

cd('E:\MOSEV_tiles\tau_pre_fire') 
pretau_tilelist = dir() ; pretau_tilelist = pretau_tilelist(3:end-1) ; 

cd('E:\MOSEV_tiles\preNBR_fires') 
preNBR_tilelist = dir() ; preNBR_tilelist = preNBR_tilelist(3:end-1) ; 

cd('E:\MOSEV_tiles\fire_timings')
ftimings_tilelist = dir() ; ftimings_tilelist = ftimings_tilelist(3:end-1) ;

cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\DryDowns')
DD_SM_tilelist = dir() ; DD_SM_tilelist = DD_SM_tilelist(195:386) ;
DD_SM_S_tilelist = dir() ; DD_SM_S_tilelist = DD_SM_S_tilelist(3:194) ;
DD_TAU_tilelist = dir() ; DD_TAU_tilelist = DD_TAU_tilelist(579:770) ;
DD_TAU_S_tilelist = dir() ; DD_TAU_S_tilelist = DD_TAU_S_tilelist(387:578) ;
DD_TIME_tilelist = dir() ; DD_TIME_tilelist = DD_TIME_tilelist(963:1154) ;


% here use 365 smoothened DDS
cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\DryDowns_365_smooth')
DD_SM_365S_tilelist = string(ls('*smvOL*'))   ;
DD_TAU_365S_tilelist = string(ls('*tauvOL*'))  ;
DD_TIME_365S_tilelist = string(ls('*timevOL*')) ;






% define output arrays. one for each DD in Tau and SM. Then individual ones 
% for grouping data. DO not split into pre and post anymore. Just save time
% information too.

  DD_Tau_interptime_array = NaN(500000,100) ;
  DD_SM_interptime_array  = NaN(500000,100) ; 
  DD_Tau_interpSM_array = NaN(500000,119) ;
 
  % define vectors of associated properties for each dry down
  IGBP_DD_array= NaN(500000,1) ;
  preNBR_DD_array = NaN(500000,1) ;  
  postNBR_DD_array = NaN(500000,1) ;
  D_NBR_DD_array = NaN(500000,1) ;
  D_tau_DD_array = NaN(500000,1) ; 
  Dist_to_f__max_array = NaN(500000,1) ; 
  Dist_to_f__min_array = NaN(500000,1) ; 
  DD_AIRS_day_interptime_array = NaN(600000,100) ;
  DD_ERAVPD_interptime_array = NaN(600000,100) ;
  DD_LPRM_As_interptime_array =  NaN(600000,100) ;
  DD_LPRM_interptime_array =  NaN(600000,100) ;
  DD_row = NaN(600000,1) ; 
  DD_col = NaN(600000,1) ; 
  DD_time_array = NaN(600000,100) ;
  DD_reltime_array = NaN(600000,100) ;
  DD_Phif_interptime_array =  NaN(600000,100) ;
  
 cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('lat.mat')
load('lon.mat')
  
 cd('E:\AIRS') 
% this is nighttime VPD
load('AIRS_Original_Surface.mat', 'lat_AIRS')
load('AIRS_Original_Surface.mat', 'lon_AIRS')  
load('VPD_AIRS_d_kPa.mat')
load('AIRS_Original_Surface.mat', 'Date_AIRS')
 
%this is daytime VPD
load('VPD.mat', 'VPD_raw_asc')



% add VPD from ERA5 day
cd('F:\ERA5\VPD_midday\processed')

filenames_ERA_VPD = string(ls('*ERA_5_LAND_VPD_2*')) ; 

 for i = 1:7 
 VDP_ERA_load{i} = matfile(filenames_ERA_VPD(i)) ;
 end


 % get LPRM C_band tau 
 cd('E:\AMSR2_GCOM_LPRM_10km\processed')

 AMSR_LPRM_filenames = ls() ; 
 AMSR_LPRM_filenames = string(AMSR_LPRM_filenames(2:end,:)) ; 
 AMSR_LPRM_filenames(1) = AMSR_LPRM_filenames(end) ; 
 AMSR_LPRM_filenames(end) = [] ; 

 for i = 1:7 
 AMSR_LPRM_load{i} = matfile(AMSR_LPRM_filenames(i)) ;
 end

 % get LPRM C-band tau daytime
 
  cd('E:\AMSR2_GCOM_LPRM_10km\processed_ascending')
 
 AMSR_LPRM_A_filenames = ls() ; 
 AMSR_LPRM_A_filenames = string(AMSR_LPRM_A_filenames(2:end,:)) ; 
 AMSR_LPRM_A_filenames(1) = AMSR_LPRM_A_filenames(end) ; 
 AMSR_LPRM_A_filenames(end) = [] ; 
 
 for i = 1:7 
 AMSR_LPRM_A_load{i} = matfile(AMSR_LPRM_A_filenames(i)) ;
 end
 

 

 

  
count_pre = 1 ; 
count_post = 1 ; 
count_all = 1 ; 
i = 178 ;


for i = 1:length(ftimings_tilelist)
    
    cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\DryDowns')
    % dry downs SM
    DD_SM_tile = DD_SM_tilelist(i).name ; 
    tilename = DD_SM_tilelist(i).name ; 
    DD_SM_tile = load(DD_SM_tile) ; DD_SM_tile = DD_SM_tile.smvOL_cell ; 
    % dry downs SM S
    DD_SM_S_tile = DD_SM_S_tilelist(i).name ; 
    tilename = DD_SM_S_tilelist(i).name ; 
    DD_SM_S_tile = load(DD_SM_S_tile) ; DD_SM_S_tile = DD_SM_S_tile.smvOL_S_cell ;     
    % Dry downs Tau
    DD_TAU_tile = DD_TAU_tilelist(i).name ; 
    DD_TAU_tile = load(DD_TAU_tile) ; DD_TAU_tile = DD_TAU_tile.tauvOL_cell ; 
    % Dry downs Tau S
    DD_TAU_S_tile = DD_TAU_S_tilelist(i).name ; 
    DD_TAU_S_tile = load(DD_TAU_S_tile) ; DD_TAU_S_tile = DD_TAU_S_tile.tauvOL_S_cell ; 
    % Dry Downs Time    
    DD_TIME_tile = DD_TIME_tilelist(i).name ; 
    DD_TIME_tile = load(DD_TIME_tile) ; DD_TIME_tile = DD_TIME_tile.timevOL_cell ; 


    % get 365 tiles
    cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\DryDowns_365_smooth')
    DD_SM_365S_tile = load(DD_SM_365S_tilelist(i))      ; 
    DD_TAU_365S_tile = load(DD_TAU_365S_tilelist(i))    ;     
    DD_TIME_365S_tile = load(DD_TIME_365S_tilelist(i))  ; 
    DD_SM_365S_tile = DD_SM_365S_tile.smvOL_S_cell      ;                     
    DD_TAU_365S_tile = DD_TAU_365S_tile.tauvOL_S_cell   ;   
    DD_TIME_365S_tile = DD_TIME_365S_tile.timevOL_S_cell;   



    % fire timings
    cd('E:\MOSEV_tiles\fire_timings')
    ftime_curtile = load(ftimings_tilelist(i).name) ;
    ftime_curtile = ftime_curtile.fire_timings ;   
    
    % dtau
    cd('E:\MOSEV_tiles\dtau_fires') 
    dtau_curtile = load(dtau_tilelist(i).name) ;
    dtau_curtile = dtau_curtile.dtau_fires ; 
    
     % dNBR
    cd('E:\MOSEV_tiles\dNBR_fires') 
    dNBR_curtile = load(dNBR_tilelist(i).name) ;
    dNBR_curtile = dNBR_curtile.d_NBR_array ;  
    
    % pre tau
        cd('E:\MOSEV_tiles\tau_pre_fire') 
    pretau_curtile = load(pretau_tilelist(i).name) ;
    pretau_curtile = pretau_curtile.tau_pre_fires ;  
    
    % pre NBR
    cd('E:\MOSEV_tiles\preNBR_fires') 
    preNBR_curtile = load(preNBR_tilelist(i).name) ;
    preNBR_curtile = preNBR_curtile.pre_NBR_array ;    
    
    % latlon
    cd('E:\MOSEV_tiles\SMAP_MOSEV_TILES\SM')
    lat_curtile = load(lat_tilelist(i).name) ; 
    lat_curtile = lat_curtile.lat_index ; 
    lon_curtile = load(lon_tilelist(i).name) ; 
    lon_curtile = lon_curtile.lon_index ;   
    
    % IGBP
    IGBP_curtile = IGBP_9km(min(lat_curtile):max(lat_curtile), min(lon_curtile):max(lon_curtile)) ; 

    
    % get LPRM_VOD_pixel
    for q = 1:7
        dummy = AMSR_LPRM_load{q} ; 
        dummy = dummy.Tau_C_array(min(lat_curtile):max(lat_curtile),min(lon_curtile):max(lon_curtile),:) ;
        if q ==1
        LPRM_VOD_C = dummy ; 
        else
        LPRM_VOD_C  = cat(3,LPRM_VOD_C,dummy) ;
        end

    end
    
    % get LPRM_VOD_pixel ascending
    for q = 1:7
        dummy = AMSR_LPRM_A_load{q} ; 
        dummy = dummy.Tau_C_array(min(lat_curtile):max(lat_curtile),min(lon_curtile):max(lon_curtile),:) ;
        if q ==1
        LPRM_VOD_C_As = dummy ; 
        else
        LPRM_VOD_C_As  = cat(3,LPRM_VOD_C_As,dummy) ;
        end

    end    
    


    % % get VDP_ERA
     for q = 1:7
        dummy = VDP_ERA_load{q} ; 
        dummy = dummy.ERA_5_Land_VPD(min(lat_curtile):max(lat_curtile),min(lon_curtile):max(lon_curtile),:) ;
        if q ==1
        VPD_ERA = dummy ; 
        else
        VPD_ERA  = cat(3,VPD_ERA,dummy) ;
        end

    end     
   % shorten to right time period starting in april
    
    
    
    
    % start calculation of stored precipitation fraction (see McColl et al. 2017)
   % try following pixel in i 178 r = 115 ; c = 94
   % test NaN r = 124  ; c = 117
   
    for r = 1:size(dtau_curtile,1)
        for c = 1:size(dtau_curtile,2)
            
            % dNBR=preNBR−postNBR
            firet_pixel = ftime_curtile{r,c} ;
            DD_SM_S_series = DD_SM_S_tile{r,c} ;
            DD_SM_series = DD_SM_tile{r,c} ;
            DD_TAU_series = DD_TAU_tile{r,c} ;
            DD_TAU_S_series = DD_TAU_S_tile{r,c} ;
            DD_TIME_series = DD_TIME_tile{r,c}  ;   
            dtau_pixel = dtau_curtile(r,c) ; 
            dNBR_pixel = dNBR_curtile(r,c) ;
            preNBR_pixel = preNBR_curtile(r,c) ;     
            postNBR_pixel =    preNBR_pixel - dNBR_pixel ;
            IGBP_pixel = IGBP_curtile(r,c) ; 


            DD_SM_365S_series = DD_SM_365S_tile{r,c} ;
            DD_TAU_365S_series = DD_TAU_365S_tile{r,c} ;
            DD_TIME_365S_series = DD_TIME_365S_tile{r,c} ;



            
            % jump if no data
            if  (isempty(firet_pixel))% || dtau_pixel > -0.1)
                continue
            end
            
            % calculate AIRS pixel
            pixlat_9km = lat(min(lat_curtile) + r - 1,1  ) ; 
            pixlon_9km = lon(1, min(lon_curtile) + c - 1  ) ; 
            
        Airs_index_lat =    find( min(abs(lat_AIRS(:,1) - pixlat_9km)) ==  abs(lat_AIRS(:,1) - pixlat_9km) )  ;
        Airs_index_lon =    find( min(abs(lon_AIRS(1,:) - pixlon_9km)) ==  abs(lon_AIRS(1,:) - pixlon_9km) )  ;      
        % Airs is from 1st of Jan 2015 to 21st of Sep 2
        AIRS_VPD_pixel =   VPD_raw_asc(Airs_index_lat,Airs_index_lon,91:end) ; 
        AIRS_VPD_pixel_smooth = movmean(squeeze(AIRS_VPD_pixel),120,1,'omitnan') ; 
        
        % get LPRM C-band tau pixel cut by 1 pixel cause starts at 31st of March
         LPRM_VOD_pixel = squeeze(LPRM_VOD_C(r,c,2:end)) ; 
         LPRM_VOD_pixel_smooth = movmean(squeeze(LPRM_VOD_pixel),120,1,'omitnan') ; 
        
        % get LPRM tau C band ascending
         LPRM_VOD_As_pixel = squeeze(LPRM_VOD_C_As(r,c,2:end)) ; 
         LPRM_VOD_As_pixel_smooth = movmean(squeeze(LPRM_VOD_As_pixel),120,1,'omitnan') ;       

        % get ERA 5 land VPD. Startting 1st Jan 2015
        ERA_VPD_pixel =   VPD_ERA(r,c,91:91+2374) ; 
        ERA_VPD_pixel_smooth = movmean(squeeze(ERA_VPD_pixel),120,1,'omitnan') ; 


   
         % index for calc of fire distance
         index = 1:2375 ; 
     % get fire distance
     for events = 1:height(firet_pixel)
      fstart = firet_pixel.event_start(events) ;
      fend   = firet_pixel.event_end(events)   ;     
      % maybe for simplicity just calc relative to end of fire and have
      % some days as buffer around it when selecting
      if events == 1
      fire_distance =  days(SMAP_datetime(index) - fend) ;
      
      else
      fire_distance_2 = days(SMAP_datetime(index) - fend)  ; 
      % find in cat arrys
      fire_distance_comb = vertcat(fire_distance,fire_distance_2) ;
      [rowfind, colfind] = find(abs(fire_distance_comb) ==  min(abs(fire_distance_comb),[],1,'omitnan')) ; 
       
      fire_distance_sign = [sign(fire_distance_comb(1,1:sum(rowfind == 1))) ,...
          sign(fire_distance_comb(2,sum(rowfind == 1)+1:end)) ]; 
      % assign final distance
      fire_distance = min(abs(fire_distance_comb),[],1,'omitnan') .*  fire_distance_sign ;
      end 
     end
 %         

     % loop and check if DD has relevant distance to fire
     for DDs = 1:length(DD_TIME_series)
     
         DD_curtime = DD_TIME_series{DDs,1} ;
         DD_datetime = SMAP_datetime(min(DD_curtime):max(DD_curtime)) ;
         % DD_datetime_save{DDs} = DD_datetime ; 
         DD_curdist_f = fire_distance(DD_curtime) ;
         DD_cur_TAU = DD_TAU_series{DDs,1} ; 
         DD_cur_TAU_S = DD_TAU_S_series{DDs,1} ; 
         DD_cur_SM = DD_SM_series{DDs,1} ; 
         DD_cur_SM_S = DD_SM_S_series{DDs,1} ;  
         DD_cur_TAU_365S = DD_TAU_365S_series{DDs,1} ; 
         DD_cur_SM_365S = DD_SM_365S_series{DDs,1} ;  
         % DD_cur_TIME_365S = DD_TIME_365S_series{DDs,1} ;


         % AIRS
         DD_cur_AIRS = squeeze(AIRS_VPD_pixel(min(DD_curtime):max(DD_curtime))) ;
         DD_cur_AIRS_S = squeeze(AIRS_VPD_pixel_smooth(min(DD_curtime):max(DD_curtime))) ;         
         DD_curtime_AIRS = min(DD_curtime):max(DD_curtime) ; 
         DD_curtime_AIRS(isnan(DD_cur_AIRS)) = [] ; 
         DD_cur_AIRS_S(isnan(DD_cur_AIRS)) = [] ;          
         DD_cur_AIRS(isnan(DD_cur_AIRS)) = [] ; 
         
         % LPRM C-band tau
         DD_cur_LPRM = LPRM_VOD_pixel(min(DD_curtime):max(DD_curtime)) ; 
         DD_cur_LPRM_S = LPRM_VOD_pixel_smooth(min(DD_curtime):max(DD_curtime)) ;  
         DD_curtime_LPRM = min(DD_curtime):max(DD_curtime) ; 
         DD_curtime_LPRM(isnan(DD_cur_LPRM)) = [] ; 
         DD_cur_LPRM_S(isnan(DD_cur_LPRM)) = [] ; 
         DD_cur_LPRM(isnan(DD_cur_LPRM)) = [] ; 

         % LPRM C-band tau ascending
         DD_cur_LPRM_As = LPRM_VOD_As_pixel(min(DD_curtime):max(DD_curtime)) ; 
         DD_cur_LPRM_As_S = LPRM_VOD_As_pixel_smooth(min(DD_curtime):max(DD_curtime)) ;  
         DD_curtime_LPRM_As = min(DD_curtime):max(DD_curtime) ; 
         DD_curtime_LPRM_As(isnan(DD_cur_LPRM_As)) = [] ; 
         DD_cur_LPRM_As_S(isnan(DD_cur_LPRM_As)) = [] ; 
         DD_cur_LPRM_As(isnan(DD_cur_LPRM_As)) = [] ;     
         

         % do ERA 5 VPD
         DD_cur_ERA = squeeze(ERA_VPD_pixel(min(DD_curtime):max(DD_curtime))) ;
         DD_cur_ERA_S = squeeze(ERA_VPD_pixel_smooth(min(DD_curtime):max(DD_curtime))) ;         
         DD_curtime_ERA = min(DD_curtime):max(DD_curtime) ; 
         DD_curtime_ERA(isnan(DD_cur_ERA)) = [] ; 
         DD_cur_ERA_S(isnan(DD_cur_ERA)) = [] ;          
         DD_cur_ERA(isnan(DD_cur_ERA)) = [] ; 
         
         
         
         % advanced deseason based on AF code
         Reltime = DD_curtime - DD_curtime(1)+1 ;
         Reltime_full = Reltime  ; 
         if(~isempty(DD_curtime_AIRS))
         Reltime_AIRS = DD_curtime_AIRS - DD_curtime_AIRS(1)+1 ;        
         end
         if(~isempty(DD_curtime_ERA))
         Reltime_ERA = DD_curtime_ERA - DD_curtime_ERA(1)+1 ;        
         end
         if(~isempty(DD_curtime_LPRM))
         Reltime_LPRM = DD_curtime_LPRM - DD_curtime_LPRM(1)+1 ;        
         end
    
         
         
         SlopeNulltau = diff(DD_cur_TAU_S);
         SlopeRegtau =  diff(DD_cur_TAU);
         SlopeNullsm = diff(DD_cur_SM_S);
         SlopeRegsm =  diff(DD_cur_SM);
         SlopeNullVPD = diff(DD_cur_AIRS_S);
         SlopeRegVPD = diff(DD_cur_AIRS);
         SlopeNullERAVPD = diff(DD_cur_ERA_S);
         SlopeRegERAVPD = diff(DD_cur_ERA);   

         % Slope_365S_Nulltau = diff(DD_cur_TAU_365S);
         % Slope_365S_Nullsm = diff(DD_cur_SM_365S);  

          SlopeNullLPRM = diff(DD_cur_LPRM_S);
          SlopeRegLPRM = diff(DD_cur_LPRM); 

          SlopeNullLPRM_As = diff(DD_cur_LPRM_As_S);
          SlopeRegLPRM_As = diff(DD_cur_LPRM_As); 
         
         % SlopeDifftau = SlopeRegtau-SlopeNulltau;
         % SlopeDiffsm = SlopeRegsm-SlopeNullsm;
         SlopeDiffVPD = SlopeRegVPD-SlopeNullVPD; 
         SlopeDiffERAVPD = SlopeRegERAVPD-SlopeNullERAVPD;   

         % replace using 365 smooth
         % SlopeDifftau = SlopeRegtau-Slope_365S_Nulltau;
         % SlopeDiffsm = SlopeRegsm-Slope_365S_Nullsm;

         % replace with 0 smoothing
         SlopeDifftau = SlopeRegtau ;
         SlopeDiffsm = SlopeRegsm    ; 

         SlopeDiffLPRM = SlopeRegLPRM-SlopeNullLPRM;  
         SlopeDiffLPRM_As = SlopeRegLPRM_As-SlopeNullLPRM_As;         


         
         % corrected SM and tau vectors
         ptauC = nan(size(DD_cur_TAU));
         ptauC(1) = DD_cur_TAU(1);
         psmC = nan(size(DD_cur_SM));
         psmC(1) = DD_cur_SM(1);
         pVPDC = nan(size(DD_cur_AIRS));
         pERAVPDC = nan(size(DD_cur_ERA));         
         pLPRM = nan(size(DD_cur_LPRM));         
    
         
         % get corrected tau and SM
         for a = 2:size(SlopeDifftau,1)+1
             ptauC(a) = ptauC(a-1)+SlopeDifftau(a-1);
             psmC(a) = psmC(a-1)+SlopeDiffsm(a-1);             
         end
         %VPD
         if(length(DD_cur_AIRS) > 2)
         pVPDC(1) = DD_cur_AIRS(1);         
         for a = 2:size(SlopeDiffVPD,1)+1 
             pVPDC(a) = pVPDC(a-1)+SlopeDiffVPD(a-1);               
         end         
         end
         % ERA VPD
         if(length(DD_cur_ERA) > 2)
         pERAVPDC(1) = DD_cur_ERA(1);         
         for a = 2:size(SlopeDiffERAVPD,1)+1 
             pERAVPDC(a) = pERAVPDC(a-1)+SlopeDiffERAVPD(a-1);               
         end         
         end

         % % LPRM
         if(length(DD_cur_LPRM) > 2)
         pLPRM(1) = DD_cur_LPRM(1);         
         for a = 2:size(SlopeDiffLPRM,1)+1 
             pLPRM(a) = pLPRM(a-1)+SlopeDiffLPRM(a-1);               
         end         
         end         

         % % LPRM As
         if(length(DD_cur_LPRM_As) > 2)
         pLPRM_As(1) = DD_cur_LPRM_As(1);         
         for a = 2:size(SlopeDiffLPRM_As,1)+1 
             pLPRM_As(a) = pLPRM_As(a-1)+SlopeDiffLPRM_As(a-1);               
         end         
         end       

        
         
         SlopeDiffsm_Difft = SlopeDiffsm ./ diff(Reltime) ;
                  
         if ( issorted(DD_cur_SM,'descend') && (length(DD_cur_SM) == length(unique(DD_cur_SM)))  )
           
         % interpolate for time and sm dont do any slopes yet. 
         DD_TAU_interp_SM = interp1(psmC,ptauC,sminterp,'linear',NaN) ;
         DD_TAU_interp_time = interp1(Reltime,ptauC,timeinterp,'linear',NaN) ;      
         DD_SM_interp_time = interp1(Reltime,psmC,timeinterp,'linear',NaN) ;
         
         % vpd
         if(length(pVPDC) > 2)
         DD_AIRS_interp_time = interp1(Reltime_AIRS,pVPDC,timeinterp,'linear',NaN) ;
         else
         DD_AIRS_interp_time = NaN(1,100) ;     
         end

         % ERA vpd
         if(length(pERAVPDC) > 2)
         DD_ERAVPD_interp_time = interp1(Reltime_ERA,pERAVPDC,timeinterp,'linear',NaN) ;
         else
         DD_ERAVPD_interp_time = NaN(1,100) ;     
         end

         % lprm
         if(length(pLPRM) > 2)
         DD_LPRM_interp_time = interp1(Reltime_LPRM,pLPRM,timeinterp,'linear',NaN) ;
         else
         DD_LPRM_interp_time = NaN(1,100) ;     
         end         
       
         % lprm As
         if(length(pLPRM) > 2)
         DD_LPRM_As_interp_time = interp1(Reltime_LPRM,pLPRM,timeinterp,'linear',NaN) ;
         else
         DD_LPRM_As_interp_time = NaN(1,100) ;     
         end   
     
         else
             continue
         end
      

         
         % save all independent of fire distance
          DD_Tau_interptime_array(count_all,:) = DD_TAU_interp_time ; 
          DD_Tau_interpSM_array(count_all,:) = DD_TAU_interp_SM ;
          DD_SM_interptime_array(count_all,:) = DD_SM_interp_time ;
         % save all ancillary vectors
         IGBP_DD_array(count_all,:)     = IGBP_pixel ;
         preNBR_DD_array(count_all,:)   = preNBR_pixel ;  
         postNBR_DD_array(count_all,:)  = postNBR_pixel ;
         D_NBR_DD_array(count_all,:)    = dNBR_pixel ;
         D_tau_DD_array(count_all,:)    = dtau_pixel ; 
         Dist_to_f__max_array(count_all,:)   =  mean(DD_curdist_f(abs(DD_curdist_f) == max(abs(DD_curdist_f)))); 
         Dist_to_f__min_array(count_all,:)   =  mean(DD_curdist_f(abs(DD_curdist_f) == min(abs(DD_curdist_f)))); 
         DD_AIRS_day_interptime_array(count_all,:) = DD_AIRS_interp_time ; 
         DD_ERAVPD_interptime_array(count_all,:) = DD_ERAVPD_interp_time ;                
         DD_LPRM_As_interptime_array(count_all,:) = DD_LPRM_As_interp_time ; 
         DD_LPRM_interptime_array(count_all,:) = DD_LPRM_interp_time ;        
         DD_row(count_all) = min(lat_curtile) + r - 1 ;
         DD_col(count_all) = min(lon_curtile) + c - 1 ;         
         % do time
         DD_time_array(count_all,1:length(DD_curtime)) = DD_curtime' ; 
         DD_reltime_array(count_all,1:length(DD_curtime)) = Reltime_full' ;                  
            
         count_all = count_all + 1 ; 
         end
     
     
        end
    end  
      
     i
end          



% save outputs 
save('E:\MOSEV_tiles\DD_all_unsmoothed\DD_Tau_interptime_array','DD_Tau_interptime_array','-v7.3') ;  
save('E:\MOSEV_tiles\DD_all_unsmoothed\DD_Tau_interpSM_array','DD_Tau_interpSM_array','-v7.3') ;  
save('E:\MOSEV_tiles\DD_all_unsmoothed\DD_SM_interptime_array','DD_SM_interptime_array','-v7.3') ;  


save('E:\MOSEV_tiles\DD_all_01\Dist_to_f__min_array','Dist_to_f__min_array','-v7.3') ;    
save('E:\MOSEV_tiles\DD_all_01\Dist_to_f__max_array','Dist_to_f__max_array','-v7.3') ;    
save('E:\MOSEV_tiles\DD_all_01\D_NBR_DD_array','D_NBR_DD_array','-v7.3') ;    
save('E:\MOSEV_tiles\DD_all_01\D_tau_DD_array','D_tau_DD_array','-v7.3') ;    
save('E:\MOSEV_tiles\DD_all_01\postNBR_DD_array','postNBR_DD_array','-v7.3') ;    
save('E:\MOSEV_tiles\DD_all_01\preNBR_DD_array','preNBR_DD_array','-v7.3') ;  
save('E:\MOSEV_tiles\DD_all_01\IGBP_DD_array','IGBP_DD_array','-v7.3') ;  


save('E:\MOSEV_tiles\DD_all_01\DD_row','DD_row','-v7.3') ;  
save('E:\MOSEV_tiles\DD_all_01\DD_col','DD_col','-v7.3') ;  


save('E:\MOSEV_tiles\DD_all_01\DD_AIRS_day_interptime_array','DD_AIRS_day_interptime_array','-v7.3') ;  

save('E:\MOSEV_tiles\DD_all_01\DD_LPRM_interptime_array_deseason','DD_LPRM_interptime_array','-v7.3') ;  
save('E:\MOSEV_tiles\DD_all_01\DD_LPRM_As_interptime_array_deseason','DD_LPRM_As_interptime_array','-v7.3') ;  

% shorten to 50 
DD_time_array = DD_time_array(:,1:50) ; 
save('E:\MOSEV_tiles\DD_all_01\DD_time_array','DD_time_array','-v7.3') ;  

% ERA VPD
save('E:\MOSEV_tiles\DD_all_01\DD_ERAVPD_interptime_array','DD_ERAVPD_interptime_array','-v7.3') ;  

save('E:\MOSEV_tiles\DD_all_01\DD_reltime_array','DD_reltime_array','-v7.3') ;  



% ==========================================
% MJB 14.09.2024 checked this step no errors
% ==========================================







%%  Step 4 Calculate isohydricity from LPRM post fire and in ref period

clear

cd('E:\AMSR2_GCOM_LPRM_10km\processed_ascending')
filenames_LPRM_As = ls() ;
filenames_LPRM_As(2,:) = filenames_LPRM_As(end,:) ; 
filenames_LPRM_As = string(filenames_LPRM_As) ; 
filenames_LPRM_As = filenames_LPRM_As(2:end-1) ; 


cd('E:\AMSR2_GCOM_LPRM_10km\processed')
filenames_LPRM_Ds = ls() ;
filenames_LPRM_Ds(2,:) = filenames_LPRM_Ds(end,:) ; 
filenames_LPRM_Ds = string(filenames_LPRM_Ds) ; 
filenames_LPRM_Ds = filenames_LPRM_Ds(2:end-1) ; 


cd('E:\MOSEV_tiles\DD_all_01')
load('DD_row.mat')
load('DD_col.mat')
load('index_tau_unique.mat')

% loop through each file and build 2D matrix
DD_TAU_C_As_full_array_unique = NaN(11027,2375) ; 
DD_TAU_C_Ds_full_array_unique = NaN(11027,2375) ; 
start_index = 1 ; 

for i = 1:7
    
   cd('E:\AMSR2_GCOM_LPRM_10km\processed_ascending')
   dummy_tau_C_As_full = load(filenames_LPRM_As(i)) ; 
   cd('E:\AMSR2_GCOM_LPRM_10km\processed')
   dummy_tau_C_Ds_full = load(filenames_LPRM_Ds(i)) ;    
   length_index   = size(dummy_tau_C_Ds_full.Tau_C_array,3) ; 
    
   for j = 1:length(index_tau_unique)
       
       index_dummy = index_tau_unique(j) ; 
       row_dummy = DD_row(index_dummy) ; 
       col_dummy = DD_col(index_dummy) ;   
       % load Tau series
       dummy_tau_C_As = squeeze(dummy_tau_C_As_full.Tau_C_array(row_dummy,col_dummy,:)) ;
       dummy_tau_C_Ds = squeeze(dummy_tau_C_Ds_full.Tau_C_array(row_dummy,col_dummy,:)) ;
       

       DD_TAU_C_As_full_array_unique(j,start_index:length_index+start_index-1) = dummy_tau_C_As ;
       DD_TAU_C_Ds_full_array_unique(j,start_index:length_index+start_index-1) = dummy_tau_C_Ds ;   
                
      j 
   end
 start_index = length_index+start_index ;
   
  
 i      
end


cd('E:\MOSEV_tiles\DD_all_01')

save('DD_TAU_C_As_full_array_unique','DD_TAU_C_As_full_array_unique','-v7.3')
save('DD_TAU_C_Ds_full_array_unique','DD_TAU_C_Ds_full_array_unique','-v7.3')






clear
cd('E:\MOSEV_tiles\DD_all_01')

load('DD_TAU_C_As_full_array_unique.mat')
load('DD_TAU_C_Ds_full_array_unique.mat')
% starts one day earlier than SMAP 
DD_TAU_C_As_full_array_unique = DD_TAU_C_As_full_array_unique(:,2:end) ;
DD_TAU_C_Ds_full_array_unique = DD_TAU_C_Ds_full_array_unique(:,2:end) ;

load('fire_distance_array_unique.mat')
load('D_tau_DD_array.mat')
load('index_tau_unique.mat')
D_tau_DD_array_unique = D_tau_DD_array(index_tau_unique) ; 


% MB 23.08.2022 some of the daily VOD C band is little bit scetchy,
% especially when day tau C > tau C nightime. this seems heavily affected
% by season mostly happening in dry season. This might shift dry areas into
% more ani

% testmodel = fitlm(DD_TAU_C_Ds_full_array_unique(100,:), DD_TAU_C_As_full_array_unique(100,:)) ; 
% plot(testmodel) ; hold on
% ylim([0 1.5])
% xlim([0 1.5])
% xlabel('night')
% ylabel('day')
% refline(1,0)

% figure
% plot(DD_TAU_C_Ds_full_array_unique(100,:),'b.') ; hold on
% plot(DD_TAU_C_As_full_array_unique(100,:),'r.') ; legend('nightime','daytime')
% testlogical = sum(DD_TAU_C_As_full_array_unique > DD_TAU_C_Ds_full_array_unique,2,'omitnan') ;
% 
mask = mean(DD_TAU_C_As_full_array_unique,2,'omitnan') < 0.1 ; 

DD_TAU_C_As_full_array_unique(mask) = NaN ;
DD_TAU_C_Ds_full_array_unique(mask) = NaN ;


Tau_As_day_post_cells = cell(11027,48) ; 
Tau_Ds_night_post_cells = cell(11027,48) ; 
Tau_As_day_pre_cells = cell(11027,48) ; 
Tau_Ds_night_pre_cells = cell(11027,48) ; 


  for i = 1:11027
         
 tau_dummy_day = DD_TAU_C_As_full_array_unique(i,:) ; 
 tau_dummy_night = DD_TAU_C_Ds_full_array_unique(i,:) ; 
 
 tau_dummy_day = filloutliers(tau_dummy_day,NaN,'movmedian',40) ; 
 tau_dummy_night = filloutliers(tau_dummy_night,NaN,'movmedian',40) ; 
 
 
 % remove when day is higher than night .. seems quite scetchy and
 % systematic removal of dry season data? Ask Andrew Alex?
 day_higher_night_dummy = tau_dummy_day > tau_dummy_night ;
 tau_dummy_day(day_higher_night_dummy)   = NaN ; 
 tau_dummy_night(day_higher_night_dummy) = NaN ; 
 
 taulowmask = tau_dummy_day < 0.1 | tau_dummy_night < 0.1 ;
 tau_dummy_day(taulowmask)   = NaN ; 
 tau_dummy_night(taulowmask) = NaN ; 
 
 
 
%  plot(tau_dummy_night,'b.') ; hold on
%  plot(tau_dummy_day,'r.') ; legend('nightime','daytime')

 
 
 % inner loop to construct pre fire ref         
for j = 1:48
    
    % post
    Tau_As_day_post_cells{i,j} = tau_dummy_day(fire_distance_array_unique(i,:) < 0+j*365/12 & fire_distance_array_unique(i,:) > 0+(j-1)*365/12)     ;
    Tau_Ds_night_post_cells{i,j} = tau_dummy_night(fire_distance_array_unique(i,:) < 0+j*365/12 & fire_distance_array_unique(i,:) > 0+(j-1)*365/12) ;
    % pre
    Tau_As_day_pre_cells{i,j} = tau_dummy_day(fire_distance_array_unique(i,:) > 0-j*365/12 & fire_distance_array_unique(i,:) < 0-(j-1)*365/12)     ;
    Tau_Ds_night_pre_cells{i,j} = tau_dummy_night(fire_distance_array_unique(i,:) > 0-j*365/12 & fire_distance_array_unique(i,:) < 0-(j-1)*365/12) ;    

end
  
 i
  end

  
  % now go through and calculate isohydricity for each pixel pre and post
  % fire
  
 slope_post = NaN(11027,1) ; 
intercept_post  = NaN(11027,1) ; 
 slope_pre = NaN(11027,1) ; 
intercept_pre  = NaN(11027,1) ;  
pre_cells = [12, 24, 36, 48] ; 
  
warning('off')

for i = 1:11027
    
% % get refseasons
%  Tau_As_day_pre_refseason = Tau_As_day_pre_cells{i,pre_cells(1)} ; 
%  Tau_Ds_night_pre_refseason = Tau_Ds_night_pre_cells{i,pre_cells(1)}  ;  


% get refseason all pre years 
Tau_As_day_pre_refseason = horzcat(Tau_As_day_pre_cells{i,pre_cells(1)},...
                                   Tau_As_day_pre_cells{i,pre_cells(2)},...
                                   Tau_As_day_pre_cells{i,pre_cells(3)},...                 
                                   Tau_As_day_pre_cells{i,pre_cells(4)}) ; 

Tau_Ds_night_pre_refseason = horzcat(Tau_Ds_night_pre_cells{i,pre_cells(1)},...
                                   Tau_Ds_night_pre_cells{i,pre_cells(2)},...
                                   Tau_Ds_night_pre_cells{i,pre_cells(3)},...                 
                                   Tau_Ds_night_pre_cells{i,pre_cells(4)}) ;

if isempty(Tau_As_day_pre_refseason) || isempty (Tau_Ds_night_pre_refseason)
    continue
end

 % random sample pre reference period so it ends up having similar sample
 % number
 index = randsample(1:length(Tau_As_day_pre_refseason),  min(30,length(Tau_As_day_pre_refseason))   ) ; 
 Tau_As_day_pre_refseason = Tau_As_day_pre_refseason(:,index) ;        
 Tau_Ds_night_pre_refseason = Tau_Ds_night_pre_refseason(:,index) ;  


% post fire sample
Tau_As_day_post = Tau_As_day_post_cells{i,1} ;
Tau_Ds_night_post = Tau_Ds_night_post_cells{i,1} ; 


% fit linear models id enough samples
% if sum(~isnan(Tau_As_day_post)) > 20
lm_post = fitlm(Tau_Ds_night_post,Tau_As_day_post) ; 
  
slope_post(i) = table2array(lm_post.Coefficients(2,1)) ; 
intercept_post(i) =  table2array(lm_post.Coefficients(1,1)) ; 


lm_preseason_ref = fitlm(Tau_Ds_night_pre_refseason,Tau_As_day_pre_refseason) ; 
 slope_pre(i) = table2array(lm_preseason_ref.Coefficients(2,1)) ; 
intercept_pre(i) =  table2array(lm_preseason_ref.Coefficients(1,1)) ; 

% if (~isempty(lm_post.Diagnostics ) && ~isempty(lm_preseason_ref.Diagnostics )   )
% figure
% plot(lm_post); title('post') ; ylim([0 1.5]) ; xlim([0 1.5])
% text(1.2,1.2,num2str(table2array(lm_post.Coefficients(1,1))))
% figure
% plot(lm_preseason_ref) ; title('pre') ; ylim([0 1.5]) ; xlim([0 1.5])
% text(1.2,1.2,num2str( table2array(lm_preseason_ref.Coefficients(2,1))))
% end




i
end
 


 slope_pre(slope_pre  == 0) = NaN ; 
 slope_post(slope_post == 0) = NaN ; 

 slope_pre(slope_pre  < 0 | slope_pre > 2) = NaN ; 
 slope_post(slope_post  < 0 | slope_post > 2) = NaN ; 

 
isohydricity_slope_pre = slope_pre ; 
isohydricity_slope_post =  slope_post ; 
 
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\isohydricity_slope_pre_ref_period_30_sample','isohydricity_slope_pre')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\isohydricity_slope_post_ref_period_30_sample','isohydricity_slope_post')



% ==========================================
% MJB 13.09.2024 checked this step no errors
% ==========================================







%% Step 5 extract data for 30 post-fire and a pre fire reference period: Spatial 5 degree boxes





clear
sminterp = [ 0.01 : 0.01 : 0.60 ]; 
timeinterp = 1:100 ; 



cd('E:\MOSEV_tiles\DD_all_01')

load('DD_reltime_array.mat')

load('DD_Tau_interpSM_array.mat')
load('DD_VPD_interpsm_array.mat')

load('DD_dSM_dt_interpsm_array.mat')
load('DD_SM_interptime_array.mat')

load('DD_dTau_dt_interpsm_array.mat')
load('DD_dVPD_dt_interpsm_array.mat')
load('DD_dVPD_dt_day_interpsm_array.mat')
load('DD_dtauC_dt_interpsm_array.mat')

load('DD_tauC_Ds_interpsm_array')
load('DD_tauC_As_interpsm_array')


load('DD_dERAVPD_dt_interpsm_array.mat')
load('DD_ERAVPD_interpsm_array.mat')


load('DD_row.mat')
load('DD_col.mat')
load('D_tau_DD_array.mat')
load('Dist_to_f__min_array.mat')

cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('lat.mat')
load('lon.mat')

load('F:\ESA_CCI\CCI_lat.mat')
load('F:\ESA_CCI\CCI_lon.mat')

% get ESA CCI
cd('F:\ESA_CCI\global_SMAP_time')

load('dSM_dt_interpsm_2D_array.mat')
load('dist_DD_after_previous_f_array.mat')
load('npixelf_previous_f_array.mat')
load('VODCA_interpsm_array.mat')
load('dist_DD_before_next_f_array.mat')
load('rowcol_2D_array.mat')

% get smoothing experiments
% 365 smooth
cd('E:\MOSEV_tiles\DD_all_365_smooth')
load('DD_dSM_dt_365_interpsm_array.mat')
load('DD_dTau_dt_365_interpsm_array.mat')
load('DD_Tau_365_interpsm_array.mat')

% unsmoothened
cd('E:\MOSEV_tiles\DD_all_unsmoothed')
load('DD_dSM_dt_0_interpsm_array.mat')
load('DD_dTau_dt_0_interpsm_array.mat')
load('DD_Tau_0_interpsm_array.mat')



  xs = [1 3856] ; ys = [1 1624] ; 

% cut datasets based on row and cols
latlon_logical_index = DD_row < max(ys) & DD_row > min(ys) & DD_col < max(xs) & DD_col > min(xs) ; 


% get mean layer to normalize?
sample_threshold = 1 ;
day_threshold = 365/12 ;
loop_index = 1:48 ; 




DD_tauC_diff_interpsm_array = DD_tauC_Ds_interpsm_array - DD_tauC_As_interpsm_array ; 



% dSM/dt 
 for i = 1:48
 
dSM_dt_subset_post=  DD_dSM_dt_interpsm_array( ...
           D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_subset_post(:,sum(~isnan(dSM_dt_subset_post),1,'omitnan') < sample_threshold) = NaN ;   
 dSM_dt_subset_post_cells{i} =  dSM_dt_subset_post ; 
 
 
 dSM_dt_subset_pre=  DD_dSM_dt_interpsm_array( ...
          D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;      
   dSM_dt_subset_pre(:,sum(~isnan(dSM_dt_subset_pre),1,'omitnan') < sample_threshold) = NaN ;    
 dSM_dt_subset_pre_cells{i} =  dSM_dt_subset_pre ; 


 % dSM/dt smooth 0

 dSM_dt_smooth0_subset_post=  DD_dSM_dt_0_interpsm_array( ...
           D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_smooth0_subset_post(:,sum(~isnan(dSM_dt_smooth0_subset_post),1,'omitnan') < sample_threshold) = NaN ;   
 dSM_dt_smooth0_subset_post_cells{i} =  dSM_dt_smooth0_subset_post ; 
 
 
 dSM_dt_smooth0_subset_pre=  DD_dSM_dt_0_interpsm_array( ...
          D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;      
   dSM_dt_smooth0_subset_pre(:,sum(~isnan(dSM_dt_smooth0_subset_pre),1,'omitnan') < sample_threshold) = NaN ;    
 dSM_dt_smooth0_subset_pre_cells{i} =  dSM_dt_smooth0_subset_pre ; 



 % dSM/dt smooth 365
 

 dSM_dt_smooth365_subset_post=  DD_dSM_dt_365_interpsm_array( ...
           D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_smooth365_subset_post(:,sum(~isnan(dSM_dt_smooth365_subset_post),1,'omitnan') < sample_threshold) = NaN ;   
 dSM_dt_smooth365_subset_post_cells{i} =  dSM_dt_smooth365_subset_post ; 
 
 
 dSM_dt_smooth365_subset_pre=  DD_dSM_dt_365_interpsm_array( ...
          D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;      
   dSM_dt_smooth365_subset_pre(:,sum(~isnan(dSM_dt_smooth365_subset_pre),1,'omitnan') < sample_threshold) = NaN ;    
 dSM_dt_smooth365_subset_pre_cells{i} =  dSM_dt_smooth365_subset_pre ; 



% dSM/dt ESA CCI 

dSM_dt_ESACCI_subset_post=  dSM_dt_interpsm_2D_array( ...
          dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold  & npixelf_previous_f_array > 300,:) ;     
   dSM_dt_ESACCI_subset_post(:,sum(~isnan(dSM_dt_ESACCI_subset_post),1,'omitnan') < sample_threshold) = NaN ;   
 dSM_dt_ESACCI_subset_post_cells{i} =  dSM_dt_ESACCI_subset_post ; 
 
 
 dSM_dt_subset_pre=  dSM_dt_interpsm_2D_array( ...
          dist_DD_before_next_f_array < 0+i*day_threshold & dist_DD_before_next_f_array > 0+(i-1)*day_threshold & npixelf_previous_f_array > 300 ,:) ;      
   dSM_dt_subset_pre(:,sum(~isnan(dSM_dt_subset_pre),1,'omitnan') < sample_threshold) = NaN ;    
 dSM_dt_ESACCI_subset_pre_cells{i} =  dSM_dt_subset_pre ; 



 
 % dtau/dt
 dtau_dt_subset_post=  DD_dTau_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_subset_post(:,sum(~isnan(dtau_dt_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
  
 dtau_dt_subset_pre=  DD_dTau_dt_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_subset_pre(:,sum(~isnan(dtau_dt_subset_pre),1,'omitnan') < sample_threshold) = NaN ;  
  
 dtau_dt_subset_pre_cells{i} =  dtau_dt_subset_pre ; 
 dtau_dt_subset_post_cells{i} =  dtau_dt_subset_post ; 
 
 % dtau/dt smooth 0 
 dtau_dt_smooth0_subset_post=  DD_dTau_dt_0_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth0_subset_post(:,sum(~isnan(dtau_dt_smooth0_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
  
 dtau_dt_smooth0_subset_pre=  DD_dTau_dt_0_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth0_subset_pre(:,sum(~isnan(dtau_dt_smooth0_subset_pre),1,'omitnan') < sample_threshold) = NaN ;  
  
 dtau_dt_smooth0_subset_pre_cells{i} =  dtau_dt_smooth0_subset_pre ; 
 dtau_dt_smooth0_subset_post_cells{i} =  dtau_dt_smooth0_subset_post ; 


%  dtau/dt smooth 365

 dtau_dt_smooth365_subset_post=  DD_dTau_dt_365_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth365_subset_post(:,sum(~isnan(dtau_dt_smooth365_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
  
 dtau_dt_smooth365_subset_pre=  DD_dTau_dt_365_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth365_subset_pre(:,sum(~isnan(dtau_dt_smooth365_subset_pre),1,'omitnan') < sample_threshold) = NaN ;  
  
 dtau_dt_smooth365_subset_pre_cells{i} =  dtau_dt_smooth365_subset_pre ; 
 dtau_dt_smooth365_subset_post_cells{i} =  dtau_dt_smooth365_subset_post ; 


 
  % dtau_C/dt
 dtau_C_dt_subset_post=  DD_dTau_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_C_dt_subset_post(:,sum(~isnan(dtau_C_dt_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
  
 dtau_C_dt_subset_pre=  DD_dTau_dt_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_C_dt_subset_pre(:,sum(~isnan(dtau_C_dt_subset_pre),1,'omitnan') < sample_threshold) = NaN ;  
  
 dtau_C_dt_subset_pre_cells{i} =  dtau_C_dt_subset_pre ; 
 dtau_C_dt_subset_post_cells{i} =  dtau_C_dt_subset_post ; 
 
 
% dVPD/dt 
 dVPD_dt_subset_post=  DD_dVPD_dt_day_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dVPD_dt_subset_post(:,sum(~isnan(dVPD_dt_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
  
 dVPD_dt_subset_pre=  DD_dVPD_dt_day_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dVPD_dt_subset_pre(:,sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') < sample_threshold) = NaN ;  
  
 dVPD_dt_subset_pre_cells{i} =   dVPD_dt_subset_pre ; 
 dVPD_dt_subset_post_cells{i} =  dVPD_dt_subset_post ;  
 
 
% VPD day
 VPD_subset_post=  DD_VPD_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VPD_subset_post(:,sum(~isnan(VPD_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
  
 VPD_subset_pre=  DD_VPD_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VPD_subset_pre(:,sum(~isnan(VPD_subset_pre),1,'omitnan') < sample_threshold) = NaN ;  
  
 VPD_subset_pre_cells{i} =   VPD_subset_pre ; 
 VPD_subset_post_cells{i} =  VPD_subset_post ;   
 
% ERA VPD
 VPD_subset_post=  DD_ERAVPD_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VPD_subset_post(:,sum(~isnan(VPD_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
  
 VPD_subset_pre=  DD_ERAVPD_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VPD_subset_pre(:,sum(~isnan(VPD_subset_pre),1,'omitnan') < sample_threshold) = NaN ;  
  
 ERAVPD_subset_pre_cells{i} =   VPD_subset_pre ; 
 ERAVPD_subset_post_cells{i} =  VPD_subset_post ;   
 
 % dERAVPD/dt 
 dVPD_dt_subset_post=  DD_dERAVPD_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dVPD_dt_subset_post(:,sum(~isnan(dVPD_dt_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
  
 dVPD_dt_subset_pre=  DD_dERAVPD_dt_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dVPD_dt_subset_pre(:,sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') < sample_threshold) = NaN ;  
  
 dERAVPD_dt_subset_pre_cells{i} =   dVPD_dt_subset_pre ; 
 dERAVPD_dt_subset_post_cells{i} =  dVPD_dt_subset_post ;  

 % Diurnal VWC C_band
 DD_tauC_diff_subset_post=  DD_tauC_diff_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   DD_tauC_diff_subset_post(:,sum(~isnan(DD_tauC_diff_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
  
 DD_tauC_diff_subset_pre=  DD_tauC_diff_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   DD_tauC_diff_subset_pre(:,sum(~isnan(DD_tauC_diff_subset_pre),1,'omitnan') < sample_threshold) = NaN ;  
  
 tauC_diff_subset_pre_cells{i} =   DD_tauC_diff_subset_pre ; 
 tauC_diff_subset_post_cells{i} =  DD_tauC_diff_subset_post ;   
 
 % dtau_fire
 
  D_tau_subset_post=  D_tau_DD_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   D_tau_subset_post(:,sum(~isnan(D_tau_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
  
 D_tau_subset_pre=  D_tau_DD_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   D_tau_subset_pre(:,sum(~isnan(D_tau_subset_pre),1,'omitnan') < sample_threshold) = NaN ;  
  
 D_tau_subset_pre_cells{i} =   D_tau_subset_pre ; 
 D_tau_subset_post_cells{i} =  D_tau_subset_post ;  
 
% just SM timetinterp for DD length analysis
 SM_interpt_subset_post=  DD_SM_interptime_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array < 0+i* day_threshold & Dist_to_f__min_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
 SM_interpt_subset_post(:,sum(~isnan(SM_interpt_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
    
 SM_interpt_subset_pre=  DD_SM_interptime_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i* day_threshold & Dist_to_f__min_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
 SM_interpt_subset_pre(:,sum(~isnan(SM_interpt_subset_pre),1,'omitnan') < sample_threshold) = NaN ;     
 
  SM_interpt_pre_cells{i} =   SM_interpt_subset_pre ; 
  SM_interpt_post_cells{i} =  SM_interpt_subset_post ; 


 
 % just tau 
 
 tau_subset_post=  DD_Tau_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array < 0+i* day_threshold & Dist_to_f__min_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
 tau_subset_post(:,sum(~isnan(tau_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
    
 tau_subset_pre=  DD_Tau_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i* day_threshold & Dist_to_f__min_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
 tau_subset_pre(:,sum(~isnan(tau_subset_pre),1,'omitnan') < sample_threshold) = NaN ;     
 
  tau_subset_pre_cells{i} =   tau_subset_pre ; 
  tau_subset_post_cells{i} =  tau_subset_post ; 
  
% just tau VODCA for ESA CCI

 tau_VODCA_subset_post=  VODCA_interpsm_array( ...
           dist_DD_after_previous_f_array < 0+i* day_threshold & dist_DD_after_previous_f_array > 0+(i-1)* day_threshold & npixelf_previous_f_array > 300 ,:) ; 
 tau_VODCA_subset_post(:,sum(~isnan(tau_VODCA_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
    
 tau_VODCA_subset_pre=  VODCA_interpsm_array( ...
           dist_DD_before_next_f_array < 0+i* day_threshold & dist_DD_before_next_f_array > 0+(i-1)* day_threshold & npixelf_previous_f_array > 300  ,:) ; 
 tau_VODCA_subset_pre(:,sum(~isnan(tau_VODCA_subset_pre),1,'omitnan') < sample_threshold) = NaN ;     
 
  tau_VODCA_subset_pre_cells{i} =   tau_VODCA_subset_pre ; 
  tau_VODCA_subset_post_cells{i} =  tau_VODCA_subset_post ;


  
  % just tau C
  tau_C_subset_post=  DD_tauC_Ds_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array < 0+i* day_threshold & Dist_to_f__min_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
 tau_C_subset_post(:,sum(~isnan(tau_C_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
    
 tau_C_subset_pre=  DD_tauC_Ds_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i* day_threshold & Dist_to_f__min_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
 tau_C_subset_pre(:,sum(~isnan(tau_C_subset_pre),1,'omitnan') < sample_threshold) = NaN ;     
 
  tau_C_subset_pre_cells{i} =   tau_C_subset_pre ; 
  tau_C_subset_post_cells{i} =  tau_C_subset_post ; 
 
 % get row and col
 
  D_col_post = DD_col(D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index) ;
  D_row_post = DD_row(D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index) ;
  
  D_col_pre = DD_col( D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index )  ;
  D_row_pre = DD_row( D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ) ; 
 
  % get ESACCI row and cols

  D_col_ESACCI_post = rowcol_2D_array( dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold & npixelf_previous_f_array > 300 ,2) ;
  D_row_ESACCI_post = rowcol_2D_array( dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold & npixelf_previous_f_array > 300,1) ;
  
  D_col_ESACCI_pre = rowcol_2D_array(dist_DD_before_next_f_array < 0+i*day_threshold & dist_DD_before_next_f_array > 0+(i-1)*day_threshold & npixelf_previous_f_array > 300 ,2 )  ;
  D_row_ESACCI_pre = rowcol_2D_array( dist_DD_before_next_f_array < 0+i*day_threshold & dist_DD_before_next_f_array > 0+(i-1)*day_threshold & npixelf_previous_f_array > 300,1 ) ; 
 


D_col_post_cells{i} =  D_col_post ;
D_row_post_cells{i} =  D_row_post ;
D_col_pre_cells{i}  =  D_col_pre ;
D_row_pre_cells{i}  =  D_row_pre ;   

D_col_ESACCI_post_cells{i} =  D_col_ESACCI_post ;
D_row_ESACCI_post_cells{i} =  D_row_ESACCI_post ;
D_col_ESACCI_pre_cells{i}  =  D_col_ESACCI_pre ;
D_row_ESACCI_pre_cells{i}  =  D_row_ESACCI_pre ;   


D_lon_post_cells{i} =  lon(1,D_col_post) ;
D_lat_post_cells{i} =  lat(D_row_post,1) ;
D_lon_pre_cells{i}  =  lon(1,D_col_pre) ;
D_lat_pre_cells{i}  =  lat(D_row_pre,1) ;   





 end 


 

  select_cells_pre = [12 24 36 48] ; 
 


  dSM_dt_post_array  = dSM_dt_subset_post_cells{1} ; 
   % dSM_dt_pre_array  = dSM_dt_subset_pre_cells{select_cells_post(1)} ; 
 dSM_dt_pre_array =  vertcat(dSM_dt_subset_pre_cells{select_cells_pre(1)}, dSM_dt_subset_pre_cells{select_cells_pre(2)},...
     dSM_dt_subset_pre_cells{select_cells_pre(3)},dSM_dt_subset_pre_cells{select_cells_pre(4)}) ; 


  dSM_dt_smooth0_post_array  = dSM_dt_smooth0_subset_post_cells{1} ; 
  dSM_dt_smooth0_pre_array  = dSM_dt_smooth0_subset_pre_cells{select_cells_pre(1)} ; 

  dSM_dt_smooth365_post_array  = dSM_dt_smooth365_subset_post_cells{1} ; 
  dSM_dt_smooth365_pre_array  = dSM_dt_smooth365_subset_pre_cells{select_cells_pre(1)} ; 

  dSM_dt_ESACCI_post_array  = dSM_dt_ESACCI_subset_post_cells{1} ; 
  % dSM_dt_ESACCI_pre_array  = dSM_dt_ESACCI_subset_pre_cells{select_cells_post(1)} ; 
 dSM_dt_ESACCI_pre_array =  vertcat(dSM_dt_ESACCI_subset_pre_cells{select_cells_pre(1)}, dSM_dt_ESACCI_subset_pre_cells{select_cells_pre(2)},...
     dSM_dt_ESACCI_subset_pre_cells{select_cells_pre(3)},dSM_dt_ESACCI_subset_pre_cells{select_cells_pre(4)}) ; 

 
  dtau_dt_post_array  = dtau_dt_subset_post_cells{1} ; 
   % dtau_dt_pre_array  = dtau_dt_subset_pre_cells{select_cells_post(1)} ;  
 dtau_dt_pre_array =  vertcat(dtau_dt_subset_pre_cells{select_cells_pre(1)}, dtau_dt_subset_pre_cells{select_cells_pre(2)},...
      dtau_dt_subset_pre_cells{select_cells_pre(3)},dtau_dt_subset_pre_cells{select_cells_pre(4)}) ;  

   dtau_dt_smooth0_post_array  = dtau_dt_smooth0_subset_post_cells{1} ; 
   dtau_dt_smooth0_pre_array  = dtau_dt_smooth0_subset_pre_cells{select_cells_pre(1)} ;  

   dtau_dt_smooth365_post_array  = dtau_dt_smooth365_subset_post_cells{1} ; 
   dtau_dt_smooth365_pre_array  = dtau_dt_smooth365_subset_pre_cells{select_cells_pre(1)} ;  


  dtau_C_dt_post_array  = dtau_C_dt_subset_post_cells{1} ; 
   % dtau_C_dt_pre_array  = dtau_C_dt_subset_pre_cells{select_cells_post(1)} ;
     dtau_C_dt_pre_array =  vertcat(dtau_C_dt_subset_pre_cells{select_cells_pre(1)}, dtau_C_dt_subset_pre_cells{select_cells_pre(2)},...
      dtau_C_dt_subset_pre_cells{select_cells_pre(3)},dtau_C_dt_subset_pre_cells{select_cells_pre(4)}) ;  
 

  dVPD_dt_post_array  = dVPD_dt_subset_post_cells{1} ; 
  % dVPD_dt_pre_array  = dVPD_dt_subset_pre_cells{select_cells_post(1)} ;  
  dVPD_dt_pre_array =  vertcat(dVPD_dt_subset_pre_cells{select_cells_pre(1)}, dVPD_dt_subset_pre_cells{select_cells_pre(2)},...
      dVPD_dt_subset_pre_cells{select_cells_pre(3)},dVPD_dt_subset_pre_cells{select_cells_pre(4)}) ;  
 

  VPD_post_array  = VPD_subset_post_cells{1} ; 
  % VPD_pre_array  = VPD_subset_pre_cells{select_cells_post(1)} ;  
   VPD_pre_array =  vertcat(VPD_subset_pre_cells{select_cells_pre(1)}, VPD_subset_pre_cells{select_cells_pre(2)},...
     VPD_subset_pre_cells{select_cells_pre(3)},VPD_subset_pre_cells{select_cells_pre(4)}) ; 



    dERAVPD_dt_post_array  = dERAVPD_dt_subset_post_cells{1} ; 
  dERAVPD_dt_pre_array  = dERAVPD_dt_subset_pre_cells{select_cells_pre(1)} ;  
%  dVPD_dt_pre_array =  vertcat(dVPD_dt_subset_pre_cells{select_cells_post(1)}, dVPD_dt_subset_pre_cells{select_cells_post(2)},...
%      dVPD_dt_subset_pre_cells{select_cells_post(3)},dVPD_dt_subset_pre_cells{select_cells_post(4)}) ;  
 

  ERAVPD_post_array  = ERAVPD_subset_post_cells{1} ; 
  % ERAVPD_pre_array  = ERAVPD_subset_pre_cells{select_cells_post(1)} ;  
     ERAVPD_pre_array =  vertcat(ERAVPD_subset_pre_cells{select_cells_pre(1)}, ERAVPD_subset_pre_cells{select_cells_pre(2)},...
     ERAVPD_subset_pre_cells{select_cells_pre(3)},ERAVPD_subset_pre_cells{select_cells_pre(4)}) ; 



 VWC_diurnal_post_array  = tauC_diff_subset_post_cells{1} ; 
 % VWC_diurnal_pre_array  = tauC_diff_subset_pre_cells{select_cells_post(1)} ;  
  VWC_diurnal_pre_array =  vertcat(tauC_diff_subset_pre_cells{select_cells_pre(1)}, tauC_diff_subset_pre_cells{select_cells_pre(2)},...
      tauC_diff_subset_pre_cells{select_cells_pre(3)},tauC_diff_subset_pre_cells{select_cells_pre(4)}) ;     
 
 VWC_diurnal_post_array(VWC_diurnal_post_array <= 0) = NaN ; 
 VWC_diurnal_pre_array(VWC_diurnal_pre_array <= 0) = NaN ; 


 D_tau_subset_post_array =  D_tau_subset_post_cells{1} ; 
 % D_tau_subset_pre_array =  D_tau_subset_pre_cells{select_cells_post(1)} ; 
  D_tau_subset_pre_array =  vertcat(D_tau_subset_pre_cells{select_cells_pre(1)}, D_tau_subset_pre_cells{select_cells_pre(2)},...
      D_tau_subset_pre_cells{select_cells_pre(3)},D_tau_subset_pre_cells{select_cells_pre(4)}) ;
 
 tau_post_array =  tau_subset_post_cells{1} ; 
 % tau_pre_array =  tau_subset_pre_cells{select_cells_post(1)} ;  
  tau_pre_array =  vertcat(tau_subset_pre_cells{select_cells_pre(1)}, tau_subset_pre_cells{select_cells_pre(2)},...
      tau_subset_pre_cells{select_cells_pre(3)},tau_subset_pre_cells{select_cells_pre(4)}) ;
%  

 tau_VODCA_post_array =  tau_VODCA_subset_post_cells{1} ; 
 % tau_VODCA_pre_array =  tau_VODCA_subset_pre_cells{select_cells_post(1)} ;
   tau_VODCA_pre_array =  vertcat(tau_VODCA_subset_pre_cells{select_cells_pre(1)}, tau_VODCA_subset_pre_cells{select_cells_pre(2)},...
      tau_VODCA_subset_pre_cells{select_cells_pre(3)},tau_VODCA_subset_pre_cells{select_cells_pre(4)}) ;


 tau_C_post_array =  tau_C_subset_post_cells{1} ; 
 % tau_C_pre_array =   tau_C_subset_pre_cells{select_cells_post(1)} ;   
   tau_C_pre_array =  vertcat(tau_C_subset_pre_cells{select_cells_pre(1)}, tau_C_subset_pre_cells{select_cells_pre(2)},...
      tau_C_subset_pre_cells{select_cells_pre(3)},tau_C_subset_pre_cells{select_cells_pre(4)}) ;
 
 
 D_col_post_array = D_col_post_cells{1} ; 
 % D_col_pre_array = D_col_pre_cells{select_cells_post(1)} ; 
  D_col_pre_array =  vertcat(D_col_pre_cells{select_cells_pre(1)}, D_col_pre_cells{select_cells_pre(2)},...
      D_col_pre_cells{select_cells_pre(3)},D_col_pre_cells{select_cells_pre(4)}) ; 

 
 D_row_post_array = D_row_post_cells{1} ; 
 % D_row_pre_array = D_row_pre_cells{select_cells_post(1)} ;   
  D_row_pre_array =  vertcat(D_row_pre_cells{select_cells_pre(1)}, D_row_pre_cells{select_cells_pre(2)},...
      D_row_pre_cells{select_cells_pre(3)},D_row_pre_cells{select_cells_pre(4)}) ; 


 D_col_ESACCI_post_array = D_col_ESACCI_post_cells{1} ; 
 % D_col_ESACCI_pre_array = D_col_ESACCI_pre_cells{select_cells_post(1)} ; 
  D_col_ESACCI_pre_array =  vertcat(D_col_ESACCI_pre_cells{select_cells_pre(1)}, D_col_ESACCI_pre_cells{select_cells_pre(2)},...
      D_col_ESACCI_pre_cells{select_cells_pre(3)},D_col_ESACCI_pre_cells{select_cells_pre(4)}) ; 


 D_row_ESACCI_post_array = D_row_ESACCI_post_cells{1} ; 
 % D_row_ESACCI_pre_array = D_row_ESACCI_pre_cells{select_cells_post(1)} ;   
   D_row_ESACCI_pre_array =  vertcat(D_row_ESACCI_pre_cells{select_cells_pre(1)}, D_row_ESACCI_pre_cells{select_cells_pre(2)},...
      D_row_ESACCI_pre_cells{select_cells_pre(3)},D_row_ESACCI_pre_cells{select_cells_pre(4)}) ; 


  dVWC_dSM_dt_post_array  =  (dtau_dt_subset_post_cells{1} ./ 0.11) ./ dSM_dt_subset_post_cells{1} ; 
  % dVWC_dSM_dt_pre_array  =  (dtau_dt_subset_pre_cells{select_cells_post(1)} ./ 0.11)  ./ dSM_dt_subset_pre_cells{select_cells_post(1)} ; 
  dVWC_dSM_dt_pre_array =  vertcat((dtau_dt_subset_pre_cells{select_cells_pre(1)} ./ 0.11)  ./ dSM_dt_subset_pre_cells{select_cells_pre(1)},...
      (dtau_dt_subset_pre_cells{select_cells_pre(2)} ./ 0.11)  ./ dSM_dt_subset_pre_cells{select_cells_pre(2)},...
      (dtau_dt_subset_pre_cells{select_cells_pre(3)} ./ 0.11)  ./ dSM_dt_subset_pre_cells{select_cells_pre(3)},...
      (dtau_dt_subset_pre_cells{select_cells_pre(4)} ./ 0.11)  ./ dSM_dt_subset_pre_cells{select_cells_pre(4)}) ; 
 

 % SM interpt pre and post for drydown length analysis
 SM_interpt_post_array =  SM_interpt_post_cells{1} ; 
 SM_interpt_pre_array =   SM_interpt_pre_cells{select_cells_pre(1)} ;   



% conversion from tau to VWC

dtau_dt_post_array  = dtau_dt_post_array ./ 0.11 ; 
dtau_dt_pre_array =    dtau_dt_pre_array ./ 0.11 ; 

dtau_C_dt_post_array  = dtau_C_dt_post_array ./ 0.2046 ; 
dtau_C_dt_pre_array =    dtau_C_dt_pre_array ./ 0.2046 ; 


dtau_dt_smooth0_post_array  = dtau_dt_smooth0_post_array ./ 0.11 ; 
dtau_dt_smooth0_pre_array =    dtau_dt_smooth0_pre_array ./ 0.11 ; 

dtau_dt_smooth365_post_array  = dtau_dt_smooth365_post_array ./ 0.11 ; 
dtau_dt_smooth365_pre_array =    dtau_dt_smooth365_pre_array ./ 0.11 ; 


VWC_diurnal_post_array = VWC_diurnal_post_array ./ 0.2046  ;
VWC_diurnal_pre_array = VWC_diurnal_pre_array ./ 0.2046  ; 

D_tau_subset_post_array = D_tau_subset_post_array ./ 0.11 ; 

tau_post_array = tau_post_array ./ 0.11  ; 
tau_pre_array = tau_pre_array ./ 0.11  ; 

tau_C_post_array = tau_C_post_array ./  0.2046  ; 
tau_C_pre_array = tau_C_pre_array ./  0.2046  ; 


tau_VODCA_post_array = tau_VODCA_post_array ./  0.2046  ; 
tau_VODCA_pre_array = tau_VODCA_pre_array ./  0.2046  ;




 
% build matching matrix for lat and lon for 5° boxes
lons_5 = (-180+2.5):5:(180-2.5)   ; 
lons_5 = repmat(lons_5,[36, 1]) ; 

lats_5 = fliplr((-90+2.5):5:(90-2.5))   ; 
lats_5 = repmat(lats_5',[1, 72]) ; 

lats_matching_vector = NaN(1624,1) ; 
lons_matching_vector = NaN(3856,1) ; 
for r = 1:1624

    curlat = lat(r,1) ; 
    [mins locs] =  min(abs(lats_5(:,1) - curlat) )  ; 
    
    lats_matching_vector(r) = locs ;  
        
  
end

  for c = 1:3856
      
    curlon = lon(1,c) ; 
    [mins locs] =  min(abs(lons_5(1,:) - curlon) )  ; 
    
    lons_matching_vector(c) = locs ;  

  end 
 
lats_Ease_5_match = repmat(lats_matching_vector ,[1, 3856]) ; 
lons_Ease_5_match = repmat(lons_matching_vector' ,[1624, 1]) ; 


% same for 0.25 degree 

lats_ESACCI_matching_vector = NaN(720,1) ; 
lons_ESACCI_matching_vector = NaN(1440,1) ; 
for r = 1:720

    curlat = CCI_lat(r,1) ; 
    [mins locs] =  min(abs(lats_5(:,1) - curlat) )  ; 
    
    lats_matching_vector(r) = locs ;  
        
  
end

  for c = 1:1440
      
    curlon = CCI_lon(c,1) ; 
    [mins locs] =  min(abs(lons_5(1,:) - curlon) )  ; 
    
    lons_matching_vector(c) = locs ;  

  end 
 
lats_ESACCI_5_match = repmat(lats_matching_vector ,[1, 1440]) ; 
lons_ESACCI_5_match = repmat(lons_matching_vector' ,[720, 1]) ; 





% now do binning into 2.5 degree array
dSM_dt_diff_sampling_array = NaN(size(lats_5,1),size(lats_5,2),60) ; 
%    r = 50 ; c = 120 ; 
tauinterp = linspace(0,1.2,21) ; 
tauinterp = tauinterp ./ 0.11  ; 

tauinterp_C = linspace(0,1.2,21) ; 
tauinterp_C = tauinterp_C ./0.2046  ; 

sminterp = linspace( 0,0.60,21); 
sminterp_60 = linspace( 0,0.60,60 ); 



dSM_dt_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_dt_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_C_dt_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dVPD_dt_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
VPD_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
VWC_diurnal_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_fire_global_array = NaN(size(lats_5,1),size(lats_5,2),5000) ; 
dVWC_dSM_dt_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dERAVPD_dt_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
ERAVPD_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dSM_dt_ESACCI_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
% smooth
dSM_dt_smooth0_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_dt_smooth0_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dSM_dt_smooth365_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_dt_smooth365_diff_global_array = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 

dSM_dt_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_dt_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_C_dt_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dVPD_dt_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
VPD_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
VWC_diurnal_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dVWC_dSM_dt_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dERAVPD_dt_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
ERAVPD_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dSM_dt_ESACCI_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
% smooth
dSM_dt_smooth0_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_dt_smooth0_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dSM_dt_smooth365_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_dt_smooth365_diff_global_array_nomask = NaN(size(lats_5,1),size(lats_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 


% defin eoutput arrays 
dtau_dt_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dtau_dt_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

dtau_dt_smooth0_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dtau_dt_smooth0_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

dtau_dt_smooth365_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dtau_dt_smooth365_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

dtau_C_dt_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dtau_C_dt_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

dSM_dt_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dSM_dt_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

dSM_dt_smooth0_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dSM_dt_smooth0_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

dSM_dt_smooth365_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dSM_dt_smooth365_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;


dSM_dt_ESACCI_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dSM_dt_ESACCI_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

dVPD_dt_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dVPD_dt_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

VPD_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
VPD_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

dERAVPD_dt_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dERAVPD_dt_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

ERAVPD_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
ERAVPD_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

VWC_diurnal_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
VWC_diurnal_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

dVWC_dSM_dt_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dVWC_dSM_dt_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;


% loop over 2.5 degree boxes to find and process drydowns within each box


for r = 1:size(lats_5,1)
    for c = 1:size(lats_5,2)
        
        % find matching EASE row and cols
        [EASE_row, ~ ]= find(lats_Ease_5_match(:,1) == r) ; 
        [~, EASE_col ]= find(lons_Ease_5_match(1,:) == c) ;    
        [CCI_row, ~ ]= find(lats_ESACCI_5_match(:,1) == r) ; 
        [~, CCI_col ]= find(lons_ESACCI_5_match(1,:) == c) ;    

        
        % get dSM/dt
        dSM_dt_pre_dummy = dSM_dt_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        dSM_dt_post_dummy =  dSM_dt_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;
        % get dSM/dt ESACCI
        dSM_dt_ESACCI_pre_dummy =   dSM_dt_ESACCI_pre_array(ismember(D_col_ESACCI_pre_array,CCI_col ) & ismember(D_row_ESACCI_pre_array,CCI_row ),:)   ;
        dSM_dt_ESACCI_post_dummy =  dSM_dt_ESACCI_post_array(ismember(D_col_ESACCI_post_array,CCI_col ) & ismember(D_row_ESACCI_post_array,CCI_row ),:)   ;        
        % dtau/dt
        dtau_dt_pre_dummy =   dtau_dt_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        dtau_dt_post_dummy =  dtau_dt_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ; 
    
        % dtau_C/dt
        dtau_C_dt_pre_dummy =   dtau_C_dt_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        dtau_C_dt_post_dummy =  dtau_C_dt_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;
        % dVPD/dt
        dVPD_dt_pre_dummy =   dVPD_dt_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        dVPD_dt_post_dummy =  dVPD_dt_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;   
         % VPD
        VPD_pre_dummy =   VPD_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        VPD_post_dummy =  VPD_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;   
              
         % ERAVPD
        ERAVPD_pre_dummy =   ERAVPD_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        ERAVPD_post_dummy =  ERAVPD_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;  
             
        % VWC diurnal
        VWC_diurnal_pre_dummy =   VWC_diurnal_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        VWC_diurnal_post_dummy =  VWC_diurnal_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;  
        % dtau change fire
        dtau_dummy_post =   D_tau_subset_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;
        % get tau 
        tau_pre_dummy =   tau_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        tau_post_dummy =  tau_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;  
        
        % get tau VODCA 
        tau_VODCA_pre_dummy =   tau_VODCA_pre_array(ismember(D_col_ESACCI_pre_array,CCI_col ) & ismember(D_row_ESACCI_pre_array,CCI_row ),:)   ;
        tau_VODCA_post_dummy =  tau_VODCA_post_array(ismember(D_col_ESACCI_post_array,CCI_col ) & ismember(D_row_ESACCI_post_array,CCI_row ),:)   ;            
        % get tau_C
        tau_C_pre_dummy =   tau_C_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        tau_C_post_dummy =  tau_C_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;    

        % get dVWC dSM
        dVWC_dSM_dt_pre_dummy = dVWC_dSM_dt_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        dVWC_dSM_dt_post_dummy =  dVWC_dSM_dt_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;

        
        if(isempty(dSM_dt_pre_dummy) || isempty(dSM_dt_post_dummy))
            continue
        end
      
        
         dSM_dt_diff_sampling_array(r,c,:) = sum(~isnan(dSM_dt_post_dummy),1,'omitnan') ; 
   
     dSM_dt_pre_3D(:,:,:) = NaN ; 
     dSM_dt_post_3D(:,:,:) = NaN  ; 
     dSM_dt_smooth0_pre_3D(:,:,:) = NaN ; 
     dSM_dt_smooth0_post_3D(:,:,:) = NaN  ; 
     dSM_dt_smooth365_pre_3D(:,:,:) = NaN ; 
     dSM_dt_smooth365_post_3D(:,:,:) = NaN  ; 
     dSM_dt_ESACCI_pre_3D(:,:,:) = NaN ; 
     dSM_dt_ESACCI_post_3D(:,:,:) = NaN  ;      
     dtau_dt_pre_3D(:,:,:) = NaN  ; 
     dtau_dt_post_3D(:,:,:) = NaN  ; 
     dtau_dt_smooth0_pre_3D(:,:,:) = NaN  ; 
     dtau_dt_smooth0_post_3D(:,:,:) = NaN  ;    
     dtau_dt_smooth365_pre_3D(:,:,:) = NaN  ; 
     dtau_dt_smooth365_post_3D(:,:,:) = NaN  ;    
     dtau_C_dt_pre_3D(:,:,:) = NaN  ; 
     dtau_C_dt_post_3D(:,:,:) = NaN  ;      
     dVPD_dt_pre_3D(:,:,:) = NaN  ;
     dVPD_dt_post_3D(:,:,:) = NaN  ;
     VPD_pre_3D(:,:,:) = NaN  ;
     VPD_post_3D(:,:,:) = NaN  ;
     dERAVPD_dt_pre_3D(:,:,:) = NaN  ;
     dERAVPD_dt_post_3D(:,:,:) = NaN  ;
     ERAVPD_pre_3D(:,:,:) = NaN  ;
     ERAVPD_post_3D(:,:,:) = NaN  ;
     VWC_diurnal_pre_3D(:,:,:) = NaN  ;
     VWC_diurnal_post_3D(:,:,:) = NaN  ;
     dVWC_dSM_dt_pre_3D(:,:,:) = NaN ; 
     dVWC_dSM_dt_post_3D(:,:,:) = NaN  ;  

     
     % add additonal step for binning into VWC as well  
  for sm = 1:length(sminterp)-1
        cur_sm = sminterp(sm:sm+1) ;   
        sminterp_true = sminterp_60 > cur_sm(1) & sminterp_60 < cur_sm(2)  ;
        
    for tau = 1:length(tauinterp)-1        
    cur_tau = tauinterp(tau:tau+1) ;         
    cur_tau_C = tauinterp_C(tau:tau+1) ;  
    
    % dtau / dt
    dtau_dt_pre_dummy_cut = dtau_dt_pre_dummy(:,sminterp_true) ;
    tau_pre_2D_dummy = dtau_dt_pre_dummy_cut(tau_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 

    dtau_dt_post_dummy_cut = dtau_dt_post_dummy(:,sminterp_true) ;    
    tau_post_2D_dummy = dtau_dt_post_dummy_cut(tau_post_dummy(:,sminterp_true) > cur_tau(1) & tau_post_dummy(:,sminterp_true) < cur_tau(2)) ;    
    
    dtau_dt_pre_3D(sm,tau,1:length(tau_pre_2D_dummy)) = tau_pre_2D_dummy ; 
    dtau_dt_post_3D(sm,tau,1:length(tau_post_2D_dummy)) = tau_post_2D_dummy ;    

    % dtau_C / dt
    dtau_C_dt_pre_dummy_cut = dtau_C_dt_pre_dummy(:,sminterp_true) ;
    tau_C_pre_2D_dummy = dtau_C_dt_pre_dummy_cut(tau_C_pre_dummy(:,sminterp_true) > cur_tau_C(1) & tau_C_pre_dummy(:,sminterp_true) < cur_tau_C(2)) ; 

    dtau_C_dt_post_dummy_cut = dtau_C_dt_post_dummy(:,sminterp_true) ;    
    tau_C_post_2D_dummy = dtau_C_dt_post_dummy_cut(tau_C_post_dummy(:,sminterp_true) > cur_tau_C(1) & tau_C_post_dummy(:,sminterp_true) < cur_tau_C(2)) ;    
    
    dtau_C_dt_pre_3D(sm,tau,1:length(tau_C_pre_2D_dummy)) = tau_C_pre_2D_dummy ; 
    dtau_C_dt_post_3D(sm,tau,1:length(tau_C_post_2D_dummy)) = tau_C_post_2D_dummy ;    
    
    % dSM/dt
    dSM_dt_pre_dummy_cut = dSM_dt_pre_dummy(:,sminterp_true) ;
    dSM_pre_2D_dummy = dSM_dt_pre_dummy_cut(tau_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 

    dSM_dt_post_dummy_cut = dSM_dt_post_dummy(:,sminterp_true) ;    
    dSM_dt_post_2D_dummy = dSM_dt_post_dummy_cut(tau_post_dummy(:,sminterp_true) > cur_tau(1) & tau_post_dummy(:,sminterp_true) < cur_tau(2)) ;    
    
    dSM_dt_pre_3D(sm,tau,1:length(dSM_pre_2D_dummy)) = dSM_pre_2D_dummy ; 
    dSM_dt_post_3D(sm,tau,1:length(dSM_dt_post_2D_dummy)) = dSM_dt_post_2D_dummy ;      

    % dSM/dt ESACCI
    dSM_dt_pre_dummy_cut = dSM_dt_ESACCI_pre_dummy(:,sminterp_true) ;
    dSM_pre_2D_dummy = dSM_dt_pre_dummy_cut(tau_VODCA_pre_dummy(:,sminterp_true) > cur_tau_C(1) & tau_VODCA_pre_dummy(:,sminterp_true) < cur_tau_C(2)) ; 

    dSM_dt_post_dummy_cut = dSM_dt_ESACCI_post_dummy(:,sminterp_true) ;    
    dSM_dt_post_2D_dummy = dSM_dt_post_dummy_cut(tau_VODCA_post_dummy(:,sminterp_true) > cur_tau_C(1) & tau_VODCA_post_dummy(:,sminterp_true) < cur_tau_C(2)) ;    
    
    dSM_dt_ESACCI_pre_3D(sm,tau,1:length(dSM_pre_2D_dummy)) = dSM_pre_2D_dummy ; 
    dSM_dt_ESACCI_post_3D(sm,tau,1:length(dSM_dt_post_2D_dummy)) = dSM_dt_post_2D_dummy ;    

    % dVPD/dt
    dVPD_dt_pre_dummy_cut = dVPD_dt_pre_dummy(:,sminterp_true) ;
    dVPD_pre_2D_dummy = dVPD_dt_pre_dummy_cut(tau_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 

    dVPD_dt_post_dummy_cut = dVPD_dt_post_dummy(:,sminterp_true) ;    
    dVPD_dt_post_2D_dummy = dVPD_dt_post_dummy_cut(tau_post_dummy(:,sminterp_true) > cur_tau(1) & tau_post_dummy(:,sminterp_true) < cur_tau(2)) ;    
    
    dVPD_dt_pre_3D(sm,tau,1:length(dVPD_pre_2D_dummy)) = dVPD_pre_2D_dummy ; 
    dVPD_dt_post_3D(sm,tau,1:length(dVPD_dt_post_2D_dummy)) = dVPD_dt_post_2D_dummy ;  
    
    % VPD
    VPD_pre_dummy_cut = VPD_pre_dummy(:,sminterp_true) ;
    VPD_pre_2D_dummy = VPD_pre_dummy_cut(tau_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 

    VPD_post_dummy_cut = VPD_post_dummy(:,sminterp_true) ;    
    VPD_post_2D_dummy = VPD_post_dummy_cut(tau_post_dummy(:,sminterp_true) > cur_tau(1) & tau_post_dummy(:,sminterp_true) < cur_tau(2)) ;    
    
    VPD_pre_3D(sm,tau,1:length(VPD_pre_2D_dummy)) = VPD_pre_2D_dummy ; 
    VPD_post_3D(sm,tau,1:length(VPD_post_2D_dummy)) = VPD_post_2D_dummy ;  
    
    % ERAVPD
    ERAVPD_pre_dummy_cut = ERAVPD_pre_dummy(:,sminterp_true) ;
    ERAVPD_pre_2D_dummy = ERAVPD_pre_dummy_cut(tau_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 

    ERAVPD_post_dummy_cut = ERAVPD_post_dummy(:,sminterp_true) ;    
    ERAVPD_post_2D_dummy = ERAVPD_post_dummy_cut(tau_post_dummy(:,sminterp_true) > cur_tau(1) & tau_post_dummy(:,sminterp_true) < cur_tau(2)) ;    
    
    ERAVPD_pre_3D(sm,tau,1:length(ERAVPD_pre_2D_dummy)) = ERAVPD_pre_2D_dummy ; 
    ERAVPD_post_3D(sm,tau,1:length(ERAVPD_post_2D_dummy)) = ERAVPD_post_2D_dummy ;  
        
    
    % VWC diurnal
    VWC_diurnal_pre_dummy_cut = VWC_diurnal_pre_dummy(:,sminterp_true) ;
     VWC_diurnal_pre_2D_dummy = VWC_diurnal_pre_dummy_cut(tau_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 

    VWC_diurnal_post_dummy_cut = VWC_diurnal_post_dummy(:,sminterp_true) ;    
    VWC_diurnal_post_2D_dummy = VWC_diurnal_post_dummy_cut(tau_post_dummy(:,sminterp_true) > cur_tau(1) & tau_post_dummy(:,sminterp_true) < cur_tau(2)) ;    
    
    VWC_diurnal_pre_3D(sm,tau,1:length(VWC_diurnal_pre_2D_dummy)) = VWC_diurnal_pre_2D_dummy ; 
    VWC_diurnal_post_3D(sm,tau,1:length(VWC_diurnal_post_2D_dummy)) = VWC_diurnal_post_2D_dummy ;  


    % dVWCdSM
    dVWC_dSM_dt_pre_dummy_cut = dVWC_dSM_dt_pre_dummy(:,sminterp_true) ;
    dVWC_dSM_pre_2D_dummy = dVWC_dSM_dt_pre_dummy_cut(tau_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 

    dVWC_dSM_dt_post_dummy_cut = dVWC_dSM_dt_post_dummy(:,sminterp_true) ;    
    dVWC_dSM_dt_post_2D_dummy = dVWC_dSM_dt_post_dummy_cut(tau_post_dummy(:,sminterp_true) > cur_tau(1) & tau_post_dummy(:,sminterp_true) < cur_tau(2)) ;    
    
    dVWC_dSM_dt_pre_3D(sm,tau,1:length(dVWC_dSM_pre_2D_dummy)) = dVWC_dSM_pre_2D_dummy ; 
    dVWC_dSM_dt_post_3D(sm,tau,1:length(dVWC_dSM_dt_post_2D_dummy)) = dVWC_dSM_dt_post_2D_dummy ;   

    
    
        
    end
  sm;
end
       
        
        
  % without any sample threhsold filtering. This is used to draw X symbols on maps


        dSM_dt_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(mean(dSM_dt_post_3D,3,'omitnan') - mean(dSM_dt_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  

        dSM_dt_smooth0_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(mean(dSM_dt_smooth0_post_3D,3,'omitnan') - mean(dSM_dt_smooth0_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
    
        dSM_dt_smooth365_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(mean(dSM_dt_smooth365_post_3D,3,'omitnan') - mean(dSM_dt_smooth365_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  


       dSM_dt_ESACCI_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(mean(dSM_dt_ESACCI_post_3D,3,'omitnan') - mean(dSM_dt_ESACCI_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        
        dtau_dt_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(mean(dtau_dt_post_3D,3,'omitnan') - mean(dtau_dt_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        
        dtau_dt_smooth0_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(mean(dtau_dt_smooth0_post_3D,3,'omitnan') - mean(dtau_dt_smooth0_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
  
        dtau_dt_smooth365_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(mean(dtau_dt_smooth365_post_3D,3,'omitnan') - mean(dtau_dt_smooth365_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;          

        dtau_C_dt_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp_C)-1)) = ...
            reshape(mean(dtau_C_dt_post_3D,3,'omitnan') - mean(dtau_C_dt_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp_C)-1),1]) ;  
        
        
        dVPD_dt_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(mean(dVPD_dt_post_3D,3,'omitnan') - mean(dVPD_dt_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  

        VPD_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
           reshape(mean(VPD_post_3D,3,'omitnan') - mean(VPD_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  

                dERAVPD_dt_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(mean(dERAVPD_dt_post_3D,3,'omitnan') - mean(dERAVPD_dt_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  

        ERAVPD_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
           reshape(mean(ERAVPD_post_3D,3,'omitnan') - mean(ERAVPD_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
               
        
        VWC_diurnal_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(mean(VWC_diurnal_post_3D,3,'omitnan') - mean(VWC_diurnal_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
    
         dVWC_dSM_dt_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(mean(dVWC_dSM_dt_post_3D,3,'omitnan') - mean(dVWC_dSM_dt_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        
       % remove low numbers of samples  
        
% based on sampling
sampling_threshold = 10 ; 

mask_samples_pre = sum(~isnan(dSM_dt_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dSM_dt_post_3D),3,'omitnan') < sampling_threshold ;
dSM_dt_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dSM_dt_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ; 

mask_samples_pre = sum(~isnan(dSM_dt_smooth0_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dSM_dt_smooth0_post_3D),3,'omitnan') < sampling_threshold ;
dSM_dt_smooth0_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dSM_dt_smooth0_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ; 

mask_samples_pre = sum(~isnan(dSM_dt_smooth365_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dSM_dt_smooth365_post_3D),3,'omitnan') < sampling_threshold ;
dSM_dt_smooth365_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dSM_dt_smooth365_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ; 

mask_samples_pre = sum(~isnan(dSM_dt_ESACCI_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dSM_dt_ESACCI_post_3D),3,'omitnan') < sampling_threshold ;
dSM_dt_ESACCI_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dSM_dt_ESACCI_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ; 


mask_samples_pre = sum(~isnan(dtau_dt_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dtau_dt_post_3D),3,'omitnan') < sampling_threshold ;
dtau_dt_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dtau_dt_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;

mask_samples_pre = sum(~isnan(dtau_dt_smooth0_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dtau_dt_smooth0_post_3D),3,'omitnan') < sampling_threshold ;
dtau_dt_smooth0_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dtau_dt_smooth0_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;

mask_samples_pre = sum(~isnan(dtau_dt_smooth365_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dtau_dt_smooth365_post_3D),3,'omitnan') < sampling_threshold ;
dtau_dt_smooth365_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dtau_dt_smooth365_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;

mask_samples_pre = sum(~isnan(dtau_C_dt_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dtau_C_dt_post_3D),3,'omitnan') < sampling_threshold ;
dtau_C_dt_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dtau_C_dt_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;


mask_samples_pre = sum(~isnan(dVPD_dt_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dVPD_dt_post_3D),3,'omitnan') < sampling_threshold ;
dVPD_dt_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dVPD_dt_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;

mask_samples_pre = sum(~isnan(VPD_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(VPD_post_3D),3,'omitnan') < sampling_threshold ;
VPD_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
VPD_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;

mask_samples_pre = sum(~isnan(dERAVPD_dt_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dERAVPD_dt_post_3D),3,'omitnan') < sampling_threshold ;
dERAVPD_dt_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dERAVPD_dt_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;

mask_samples_pre = sum(~isnan(ERAVPD_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(ERAVPD_post_3D),3,'omitnan') < sampling_threshold ;
ERAVPD_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
ERAVPD_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;


mask_samples_pre = sum(~isnan(VWC_diurnal_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(VWC_diurnal_post_3D),3,'omitnan') < sampling_threshold ;
VWC_diurnal_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
VWC_diurnal_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;
   
        
mask_samples_pre = sum(~isnan(dVWC_dSM_dt_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dVWC_dSM_dt_post_3D),3,'omitnan') < sampling_threshold ;
dVWC_dSM_dt_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dVWC_dSM_dt_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;  



        
        
        dSM_dt_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape( (median(dSM_dt_post_3D,3,'omitnan') - median(dSM_dt_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  

        dSM_dt_smooth0_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape( (median(dSM_dt_smooth0_post_3D,3,'omitnan') - median(dSM_dt_smooth0_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
 
        dSM_dt_smooth365_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape( (median(dSM_dt_smooth365_post_3D,3,'omitnan') - median(dSM_dt_smooth365_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
     
        dSM_dt_ESACCI_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape( (median(dSM_dt_ESACCI_post_3D,3,'omitnan') - median(dSM_dt_ESACCI_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ; 
        
        dtau_dt_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape( (median(dtau_dt_post_3D,3,'omitnan') - median(dtau_dt_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  

        dtau_dt_smooth0_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape( (median(dtau_dt_smooth0_post_3D,3,'omitnan') - median(dtau_dt_smooth0_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  

        dtau_dt_smooth365_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape( (median(dtau_dt_smooth365_post_3D,3,'omitnan') - median(dtau_dt_smooth365_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  

        dtau_C_dt_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp_C)-1)) = ...
            reshape( (median(dtau_C_dt_post_3D,3,'omitnan') - median(dtau_C_dt_pre_3D,3,'omitnan')) ,[(length(sminterp)-1)*(length(tauinterp_C)-1),1]) ;  
        
        
        dVPD_dt_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape( (median(dVPD_dt_post_3D,3,'omitnan') - median(dVPD_dt_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
 
        VPD_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape((median(VPD_post_3D,3,'omitnan') - median(VPD_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  

                dERAVPD_dt_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape( (median(dERAVPD_dt_post_3D,3,'omitnan') - median(dERAVPD_dt_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
 
        ERAVPD_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape((median(ERAVPD_post_3D,3,'omitnan') - median(ERAVPD_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
                        
        
        VWC_diurnal_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape( (median(VWC_diurnal_post_3D,3,'omitnan') - median(VWC_diurnal_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        
        
        dtau_fire_global_array(r,c,1:length(dtau_dummy_post)) = dtau_dummy_post ; 
        

         dVWC_dSM_dt_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape( (median(dVWC_dSM_dt_post_3D,3,'omitnan') - median(dVWC_dSM_dt_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
         
        
        
        
    end
    r
end


dSM_dt_diff_global_array(dSM_dt_diff_global_array == 0) = NaN ; 
dSM_dt_smooth0_diff_global_array(dSM_dt_smooth0_diff_global_array == 0) = NaN ; 
dSM_dt_smooth365_diff_global_array(dSM_dt_smooth365_diff_global_array == 0) = NaN ; 
dSM_dt_ESACCI_diff_global_array(dSM_dt_ESACCI_diff_global_array == 0) = NaN ; 
dtau_dt_diff_global_array(dtau_dt_diff_global_array == 0) = NaN ; 
dtau_dt_smooth0_diff_global_array(dtau_dt_smooth0_diff_global_array == 0) = NaN ; 
dtau_dt_smooth365_diff_global_array(dtau_dt_smooth365_diff_global_array == 0) = NaN ; 
dtau_C_dt_diff_global_array(dtau_C_dt_diff_global_array == 0) = NaN ; 
dVPD_dt_diff_global_array(dVPD_dt_diff_global_array == 0) = NaN ; 
VPD_diff_global_array(VPD_diff_global_array == 0) = NaN ; 
VWC_diurnal_diff_global_array(VWC_diurnal_diff_global_array == 0) = NaN ; 
dtau_fire_global_array(dtau_fire_global_array == 0) = NaN ; 
dVWC_dSM_dt_diff_global_array(dVWC_dSM_dt_diff_global_array == 0) = NaN ; 
dERAVPD_dt_diff_global_array(dERAVPD_dt_diff_global_array == 0) = NaN ; 
ERAVPD_diff_global_array(ERAVPD_diff_global_array == 0) = NaN ; 

dSM_dt_diff_global_array_nomask(dSM_dt_diff_global_array_nomask == 0) = NaN ; 
dSM_dt_ESACCI_diff_global_array_nomask(dSM_dt_diff_global_array_nomask == 0) = NaN ;
dtau_dt_diff_global_array_nomask(dtau_dt_diff_global_array_nomask == 0) = NaN ; 
dtau_C_dt_diff_global_array_nomask(dtau_C_dt_diff_global_array_nomask == 0) = NaN ; 
dVPD_dt_diff_global_array_nomask(dVPD_dt_diff_global_array_nomask == 0) = NaN ; 
VPD_diff_global_array_nomask(VPD_diff_global_array_nomask == 0) = NaN ;
VWC_diurnal_diff_global_array_nomask(VWC_diurnal_diff_global_array_nomask == 0) = NaN ; 
dERAVPD_dt_diff_global_array_nomask(dERAVPD_dt_diff_global_array_nomask == 0) = NaN ; 
ERAVPD_diff_global_array_nomask(ERAVPD_diff_global_array_nomask == 0) = NaN ;



dtau_fire_global_median = median(dtau_fire_global_array,3,'omitnan') ; 
dtau_fire_global_median(isnan(median(dSM_dt_diff_global_array,3,'omitnan')) &...
                       isnan(median(dtau_dt_diff_global_array,3,'omitnan')) &...
                       isnan(median(dVPD_dt_diff_global_array,3,'omitnan')) &...
                       isnan(median(VWC_diurnal_diff_global_array,3,'omitnan')) )  = NaN ;  

   
                   
    
dVPD_dt_day_diff_global_array =  dVPD_dt_diff_global_array         ;     
dVPD_dt_day_diff_global_array_nomask = dVPD_dt_diff_global_array_nomask  ;         
  
dERAVPD_dt_day_diff_global_array =  dERAVPD_dt_diff_global_array         ;     
dERAVPD_dt_day_diff_global_array_nomask = dERAVPD_dt_diff_global_array_nomask  ;  

dSM_dt_diff_global_array_median = dSM_dt_diff_global_array ; 
dtau_dt_diff_global_array_median = dtau_dt_diff_global_array ; 
dtau_C_dt_diff_global_array_median = dtau_C_dt_diff_global_array ; 
dVPD_dt_diff_global_array_median = dVPD_dt_diff_global_array ; 
VPD_diff_global_array_median = VPD_diff_global_array ; 
VWC_diurnal_diff_global_array_median = VWC_diurnal_diff_global_array ; 
dVWC_dSM_dt_diff_global_array_median = dVWC_dSM_dt_diff_global_array ; 
dERAVPD_dt_diff_global_array_median = dERAVPD_dt_diff_global_array ; 
ERAVPD_diff_global_array_median = ERAVPD_diff_global_array ; 





% save all outputs into final plotting arrays
 save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dSM_dt_diff_global_array_median','dSM_dt_diff_global_array_median','-v7.3')   
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dSM_dt_ESACCI_diff_global_array','dSM_dt_ESACCI_diff_global_array','-v7.3')   
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dtau_dt_diff_global_array_median','dtau_dt_diff_global_array_median','-v7.3')  
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dtau_C_dt_diff_global_array_median','dtau_C_dt_diff_global_array_median','-v7.3')  
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dVPD_dt_diff_global_array_median','dVPD_dt_diff_global_array_median','-v7.3') 
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\VPD_diff_global_array_median','VPD_diff_global_array_median','-v7.3') 
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\VWC_diurnal_diff_global_array_median','VWC_diurnal_diff_global_array_median','-v7.3') 
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dVWC_dSM_dt_diff_global_array_median','dVWC_dSM_dt_diff_global_array_median','-v7.3') 
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dERAVPD_dt_diff_global_array_median','dERAVPD_dt_diff_global_array_median','-v7.3') 
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\ERAVPD_diff_global_array_median','ERAVPD_diff_global_array_median','-v7.3') 
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dSM_dt_diff_global_array_nomask','dSM_dt_diff_global_array_nomask','-v7.3')     
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dSM_dt_ESACCI_diff_global_array_nomask','dSM_dt_ESACCI_diff_global_array_nomask','-v7.3')  
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dtau_dt_diff_global_array_nomask','dtau_dt_diff_global_array_nomask','-v7.3') 
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dtau_C_dt_diff_global_array_nomask','dtau_C_dt_diff_global_array_nomask','-v7.3')  
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dVPD_dt_day_diff_global_array_nomask','dVPD_dt_day_diff_global_array_nomask','-v7.3')                    
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\VWC_diurnal_diff_global_array_nomask','VWC_diurnal_diff_global_array_nomask','-v7.3') 
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\VPD_diff_global_array_nomask','VPD_diff_global_array_nomask','-v7.3') 
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dVWC_dSM_dt_diff_global_array_nomask','dVWC_dSM_dt_diff_global_array_nomask','-v7.3') 
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dERAVPD_dt_day_diff_global_array_nomask','dERAVPD_dt_day_diff_global_array_nomask','-v7.3')                    
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\ERAVPD_diff_global_array_nomask','ERAVPD_diff_global_array_nomask','-v7.3') 



% ==========================================
% MJB 14.09.2024 checked this step no errors
% ==========================================









%% Step 6 extract data for 30 post-fire and a pre fire reference period: All data phase spaces





clear
cd('E:\Daten Baur\Matlab code')
col_L = hex2rgb('808080') ; 
col_L_light = hex2rgb('CDCDCD') ; 

col_C = hex2rgb('3399FF') ;
col_C_light = hex2rgb('80E6FF') ; 

col_X = hex2rgb('FF3333') ;
col_X_light = hex2rgb('FF8080') ; 


cd('E:\MOSEV_tiles\DD_all_01')
load('DD_reltime_array.mat')
load('Dist_to_f__min_array.mat')
load('D_tau_DD_array.mat')
load('DD_dTau_dSM_interpsm_array.mat')
load('DD_dSM_dt_interpsm_array.mat')
load('DD_dTau_dt_interpsm_array.mat')
load('DD_dTau_dVPD_interpsm_array.mat')
load('D_NBR_DD_array.mat')

load('DD_dVPD_dSM_interpsm_array.mat')
load('DD_dVPD_dt_interpsm_array.mat')
load('DD_dVPD_dt_day_interpsm_array.mat')

load('DD_dERAVPD_dSM_interpsm_array.mat')
load('DD_dERAVPD_dt_interpsm_array.mat')
load('DD_ERAVPD_interpsm_array.mat')
load('DD_ERAVPD_interptime_array.mat')

load('DD_col.mat')
load('DD_row.mat')
load('DD_dtauC_dSM_interpsm_array.mat')
load('DD_dtauC_dt_interpsm_array.mat')
load('DD_dtauC_As_dt_interpsm_array.mat')
load('DD_dtauC_As_dSM_interpsm_array.mat')
load('DD_tau_LC_ratio_interpsm_array.mat')
load('DD_dtauL_dt_dtauC_dt_interpsm_array.mat')
load('DD_tau_C_Ds_As_difference_interpsm_array.mat')
load('DD_tau_C_Ds_As_difference_interpsm_array.mat')
load('DD_tau_C_Ds_As_rel_difference_interpsm_array.mat')
load('DD_tauC_As_interpsm_array.mat')
load('DD_tauC_Ds_interpsm_array.mat')
load('DD_SM_interptime_array.mat')
load('DD_Tau_interpsm_array.mat')
load('DD_VPD_interpsm_array.mat')
sminterp = [ 0.01 : 0.01 : 0.60 ]; 

% get ESA CCI
cd('F:\ESA_CCI\global_SMAP_time')
load('dSM_dt_interpsm_2D_array.mat')
load('dist_DD_after_previous_f_array.mat')
load('npixelf_previous_f_array.mat')
load('VODCA_interpsm_array.mat')
load('dist_DD_before_next_f_array.mat')
load('rowcol_2D_array.mat')


% get smoothing experiments

% 365 smooth
cd('E:\MOSEV_tiles\DD_all_365_smooth')
load('DD_dSM_dt_365_interpsm_array.mat')
load('DD_dTau_dt_365_interpsm_array.mat')
load('DD_Tau_365_interpsm_array.mat')

% unsmoothened
cd('E:\MOSEV_tiles\DD_all_unsmoothed')
load('DD_dSM_dt_0_interpsm_array.mat')
load('DD_dTau_dt_0_interpsm_array.mat')
load('DD_Tau_0_interpsm_array.mat')



% ad another step subsetting by area based on load of global firepixels
cd('E:\MTDCA_V5_2015_2021\9_km\SM')
% load('MTDCA_V5_SM_201504_201506_9km.mat', 'MTDCA_SM')
% SM_mean_test = mean(MTDCA_SM,3,'omitnan') ; 
% clear MTDCA_SM

% figure
% imagesc(SM_mean_test)
% [xs, ys] = getpts() ; xs = round(xs) ; ys = round(ys) ; 
% close

  xs = [1 3856] ; ys = [1 1624] ; 

% cut datasets based on row and cols
latlon_logical_index = DD_row < max(ys) & DD_row > min(ys) & DD_col < max(xs) & DD_col > min(xs) ; 



 
 %
 
 
 threshold_sampling = 1; 
 loop_index = 1:48 ; 
 day_threshold = 365/12 ; 
 
 % tau
 for i = loop_index
 
tau_subset_post=  DD_Tau_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i* day_threshold & Dist_to_f__min_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
tau_subset_pre=  DD_Tau_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i* day_threshold & Dist_to_f__min_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   tau_subset_post(:,sum(~isnan(tau_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   tau_index_valid_post  = sum(~isnan(tau_subset_post),1,'omitnan') > threshold_sampling  ;  
   tau_index_valid_post_cells{i} = tau_index_valid_post;
  
   tau_subset_pre(:,sum(~isnan(tau_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   tau_index_valid_pre  = sum(~isnan(tau_subset_pre),1,'omitnan') > threshold_sampling  ;  
   tau_index_valid_pre_cells{i} = tau_index_valid_pre;   
   
   
 tau_subset_post_cells{i} =  tau_subset_post ; 
 tau_subset_pre_cells{i} =  tau_subset_pre ; 
    
 end


 
 
  % tau VODCA
 for i = loop_index
 
tau_VODCA_subset_post=  VODCA_interpsm_array( ...
           dist_DD_after_previous_f_array < 0+i* day_threshold & dist_DD_after_previous_f_array > 0+(i-1)* day_threshold & npixelf_previous_f_array > 300 ,:) ; 
     
tau_VODCA_subset_pre=  VODCA_interpsm_array( ...
            dist_DD_before_next_f_array < 0+i* day_threshold & dist_DD_before_next_f_array > 0+(i-1)* day_threshold & npixelf_previous_f_array > 300 ,:) ; 
     
   tau_VODCA_subset_post(:,sum(~isnan(tau_VODCA_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   tau_VODCA_index_valid_post  = sum(~isnan(tau_VODCA_subset_post),1,'omitnan') > threshold_sampling  ;  
   tau_VODCA_index_valid_post_cells{i} = tau_VODCA_index_valid_post;
  
   tau_VODCA_subset_pre(:,sum(~isnan(tau_VODCA_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   tau_VODCA_index_valid_pre  = sum(~isnan(tau_VODCA_subset_pre),1,'omitnan') > threshold_sampling  ;  
   tau_VDOCA_index_valid_pre_cells{i} = tau_VODCA_index_valid_pre;   
   
   
 tau_VODCA_subset_post_cells{i} =  tau_VODCA_subset_post ; 
 tau_VODCA_subset_pre_cells{i} =   tau_VODCA_subset_pre ; 
    
 end
 

% dtau/dt
 for i = loop_index
 
dtau_dt_subset_post=  DD_dTau_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i* day_threshold & Dist_to_f__min_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
dtau_dt_subset_pre=  DD_dTau_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i* day_threshold & Dist_to_f__min_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   dtau_dt_subset_post(:,sum(~isnan(dtau_dt_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dtau_dt_index_valid_post  = sum(~isnan(dtau_dt_subset_post),1,'omitnan') > threshold_sampling  ;  
   dtau_dt_index_valid_post_cells{i} = dtau_dt_index_valid_post;
  
   dtau_dt_subset_pre(:,sum(~isnan(dtau_dt_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dtau_dt_index_valid_pre  = sum(~isnan(dtau_dt_subset_pre),1,'omitnan') > threshold_sampling  ;  
   dtau_dt_index_valid_pre_cells{i} = dtau_dt_index_valid_pre;   
   
   
 dtau_dt_subset_post_cells{i} =  dtau_dt_subset_post ; 
 dtau_dt_subset_pre_cells{i} =  dtau_dt_subset_pre ; 
    
 end

% dtau/dt smooth 0


 for i = loop_index
 
dtau_dt_smooth0_subset_post=  DD_dTau_dt_0_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i* day_threshold & Dist_to_f__min_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
dtau_dt_smooth0_subset_pre=  DD_dTau_dt_0_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i* day_threshold & Dist_to_f__min_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   dtau_dt_smooth0_subset_post(:,sum(~isnan(dtau_dt_smooth0_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dtau_dt_index_valid_post  = sum(~isnan(dtau_dt_smooth0_subset_post),1,'omitnan') > threshold_sampling  ;  
   dtau_dt_smooth0_index_valid_post_cells{i} = dtau_dt_index_valid_post;
  
   dtau_dt_smooth0_subset_pre(:,sum(~isnan(dtau_dt_smooth0_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dtau_dt_index_valid_pre  = sum(~isnan(dtau_dt_smooth0_subset_pre),1,'omitnan') > threshold_sampling  ;  
   dtau_dt_smooth0_index_valid_pre_cells{i} = dtau_dt_index_valid_pre;   
   
   
 dtau_dt_smooth0_subset_post_cells{i} =  dtau_dt_smooth0_subset_post ; 
 dtau_dt_smooth0_subset_pre_cells{i} =  dtau_dt_smooth0_subset_pre ; 
    
 end



% dtau/dt smooth 365


 for i = loop_index
 
dtau_dt_smooth365_subset_post=  DD_dTau_dt_365_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i* day_threshold & Dist_to_f__min_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
dtau_dt_smooth365_subset_pre=  DD_dTau_dt_365_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i* day_threshold & Dist_to_f__min_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   dtau_dt_smooth365_subset_post(:,sum(~isnan(dtau_dt_smooth365_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dtau_dt_index_valid_post  = sum(~isnan(dtau_dt_smooth365_subset_post),1,'omitnan') > threshold_sampling  ;  
   dtau_dt_smooth365_index_valid_post_cells{i} = dtau_dt_index_valid_post;
  
   dtau_dt_smooth365_subset_pre(:,sum(~isnan(dtau_dt_smooth365_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dtau_dt_index_valid_pre  = sum(~isnan(dtau_dt_smooth365_subset_pre),1,'omitnan') > threshold_sampling  ;  
   dtau_dt_smooth365_index_valid_pre_cells{i} = dtau_dt_index_valid_pre;   
   
   
 dtau_dt_smooth365_subset_post_cells{i} =  dtau_dt_smooth365_subset_post ; 
 dtau_dt_smooth365_subset_pre_cells{i} =  dtau_dt_smooth365_subset_pre ; 
    
 end

 
% dtauC/dt  
 
 for i = loop_index
 
dtauC_dt_subset_post=  DD_dtauC_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
dtauC_dt_subset_pre=  DD_dtauC_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
   dtauC_dt_subset_post(:,sum(~isnan(dtauC_dt_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dtauC_dt_index_valid_post  = sum(~isnan(dtauC_dt_subset_post),1,'omitnan') > threshold_sampling  ;  
   dtauC_dt_index_valid_post_cells{i} = dtauC_dt_index_valid_post;
   
   dtauC_dt_subset_pre(:,sum(~isnan(dtauC_dt_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dtauC_dt_index_valid_pre  = sum(~isnan(dtauC_dt_subset_pre),1,'omitnan') > threshold_sampling  ;  
   dtauC_dt_index_valid_pre_cells{i} = dtauC_dt_index_valid_pre;   
   
   
 dtauC_dt_subset_post_cells{i} =  dtauC_dt_subset_post ; 
 dtauC_dt_subset_pre_cells{i} =  dtauC_dt_subset_pre ; 
    
 end
 
 
 
 % tauC Ds
 
 for i = loop_index
 
DD_tauC_Ds_subset_post=  DD_tauC_Ds_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
DD_tauC_Ds_subset_pre=  DD_tauC_Ds_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
   DD_tauC_Ds_subset_post(:,sum(~isnan(DD_tauC_Ds_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   DD_tauC_Ds_index_valid_post  = sum(~isnan(DD_tauC_Ds_subset_post),1,'omitnan') > threshold_sampling  ;  
   DD_tauC_Ds_index_valid_post_cells{i} = DD_tauC_Ds_index_valid_post;
   
   DD_tauC_Ds_subset_pre(:,sum(~isnan(DD_tauC_Ds_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   DD_tauC_Ds_index_valid_pre  = sum(~isnan(DD_tauC_Ds_subset_pre),1,'omitnan') > threshold_sampling  ;  
   DD_tauC_Ds_index_valid_pre_cells{i} = DD_tauC_Ds_index_valid_pre;  
   
   
 DD_tauC_Ds_subset_post_cells{i} =  DD_tauC_Ds_subset_post ; 
 DD_tauC_Ds_subset_pre_cells{i} =  DD_tauC_Ds_subset_pre ; 
    
 end
 
  % tauC As
 
 for i = loop_index
 
DD_tauC_As_subset_post=  DD_tauC_As_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
DD_tauC_As_subset_pre=  DD_tauC_As_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
   DD_tauC_As_subset_post(:,sum(~isnan(DD_tauC_As_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   DD_tauC_As_index_valid_post  = sum(~isnan(DD_tauC_As_subset_post),1,'omitnan') > threshold_sampling  ;  
   DD_tauC_As_index_valid_post_cells{i} = DD_tauC_As_index_valid_post;
   
   DD_tauC_As_subset_pre(:,sum(~isnan(DD_tauC_As_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   DD_tauC_As_index_valid_pre  = sum(~isnan(DD_tauC_As_subset_pre),1,'omitnan') > threshold_sampling  ;  
   DD_tauC_As_index_valid_pre_cells{i} = DD_tauC_As_index_valid_pre;  
   
   
 DD_tauC_As_subset_post_cells{i} =  DD_tauC_As_subset_post ; 
 DD_tauC_As_subset_pre_cells{i} =   DD_tauC_As_subset_pre ; 
    
 end
 
 
% dtau_C_As / dt 

  for i = loop_index
 
dtauC_As_dt_subset_post=  DD_dtauC_As_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
dtauC_As_dt_subset_pre=  DD_dtauC_As_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
   dtauC_As_dt_subset_post(:,sum(~isnan(dtauC_As_dt_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dtauC_dt_index_valid_post  = sum(~isnan(dtauC_As_dt_subset_post),1,'omitnan') > threshold_sampling  ;  
   dtauC_dt_index_valid_post_cells{i} = dtauC_dt_index_valid_post;
   
   dtauC_As_dt_subset_pre(:,sum(~isnan(dtauC_As_dt_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dtauC_As_dt_index_valid_pre  = sum(~isnan(dtauC_As_dt_subset_pre),1,'omitnan') > threshold_sampling  ;  
   dtauC_As_dt_index_valid_pre_cells{i} = dtauC_As_dt_index_valid_pre;   
   
   
 dtauC_As_dt_subset_post_cells{i} =  dtauC_As_dt_subset_post ; 
 dtauC_As_dt_subset_pre_cells{i} =  dtauC_As_dt_subset_pre ; 
    
  end
 

 
  
  % tau C DS (night) - tau C AS (day) difference as isohydro indicator

  for i = loop_index
         
 
tau_C_Ds_As_diff_subset_post=  DD_tau_C_Ds_As_difference_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
tau_C_Ds_As_diff_subset_pre=  DD_tau_C_Ds_As_difference_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
   tau_C_Ds_As_diff_subset_post(:,sum(~isnan(tau_C_Ds_As_diff_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   tau_C_Ds_As_diff_valid_post  = sum(~isnan(tau_C_Ds_As_diff_subset_post),1,'omitnan') > threshold_sampling  ;  
   tau_C_Ds_As_diff_index_valid_post_cells{i} = tau_C_Ds_As_diff_valid_post;
   
   tau_C_Ds_As_diff_subset_pre(:,sum(~isnan(tau_C_Ds_As_diff_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   tau_C_Ds_As_diff_valid_pre  = sum(~isnan(tau_C_Ds_As_diff_subset_pre),1,'omitnan') > threshold_sampling  ;  
   tau_C_Ds_As_diff_index_valid_pre_cells{i} = tau_C_Ds_As_diff_valid_pre;   
   
   
tau_C_Ds_As_diff_subset_post_cells{i} =  tau_C_Ds_As_diff_subset_post ; 
tau_C_Ds_As_diff_subset_pre_cells{i} =  tau_C_Ds_As_diff_subset_pre ; 
    
  end
  
  
  
 
% dSM/dt 
 for i = loop_index
 
dSM_dt_subset_post=  DD_dSM_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dSM_dt_subset_post(:,sum(~isnan(dSM_dt_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dSM_dt_index_valid_post  = sum(~isnan(dSM_dt_subset_post),1,'omitnan') > threshold_sampling  ;
   dSM_dt_index_valid_post_cells{i} = dSM_dt_index_valid_post ; 
   
 dSM_dt_subset_post_cells{i} =  dSM_dt_subset_post ; 
 
 
 dSM_dt_subset_pre=  DD_dSM_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dSM_dt_subset_pre(:,sum(~isnan(dSM_dt_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dSM_dt_index_valid_pre  = sum(~isnan(dSM_dt_subset_pre),1,'omitnan') > threshold_sampling  ;
   dSM_dt_index_valid_pre_cells{i} = dSM_dt_index_valid_pre ; 
   
 dSM_dt_subset_pre_cells{i} =  dSM_dt_subset_pre ; 
 

 
   
 end 



% dSM/dt smooth 0
 for i = loop_index
 
dSM_dt_smooth0_subset_post=  DD_dSM_dt_0_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dSM_dt_smooth0_subset_post(:,sum(~isnan(dSM_dt_smooth0_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dSM_dt_index_valid_post  = sum(~isnan(dSM_dt_smooth0_subset_post),1,'omitnan') > threshold_sampling  ;
   dSM_dt_smooth0_index_valid_post_cells{i} = dSM_dt_index_valid_post ; 
   
 dSM_dt_smooth0_subset_post_cells{i} =  dSM_dt_smooth0_subset_post ; 
 
 
 dSM_dt_smooth0_subset_pre=  DD_dSM_dt_0_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dSM_dt_smooth0_subset_pre(:,sum(~isnan(dSM_dt_smooth0_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dSM_dt_smooth0_index_valid_pre  = sum(~isnan(dSM_dt_smooth0_subset_pre),1,'omitnan') > threshold_sampling  ;
   dSM_dt_smooth0_index_valid_pre_cells{i} = dSM_dt_smooth0_index_valid_pre ; 
   
 dSM_dt_smooth0_subset_pre_cells{i} =  dSM_dt_smooth0_subset_pre ; 
    
 end 


% dSM/dt smooth 365


 for i = loop_index
 
dSM_dt_smooth365_subset_post=  DD_dSM_dt_365_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dSM_dt_smooth365_subset_post(:,sum(~isnan(dSM_dt_smooth365_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dSM_dt_smooth365_index_valid_post  = sum(~isnan(dSM_dt_smooth365_subset_post),1,'omitnan') > threshold_sampling  ;
   dSM_dt_smooth365_index_valid_post_cells{i} = dSM_dt_smooth365_index_valid_post ; 
   
 dSM_dt_smooth365_subset_post_cells{i} =  dSM_dt_smooth365_subset_post ; 
 
 
 dSM_dt_smooth365_subset_pre=  DD_dSM_dt_365_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dSM_dt_smooth365_subset_pre(:,sum(~isnan(dSM_dt_smooth365_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dSM_dt_smooth365_index_valid_pre  = sum(~isnan(dSM_dt_smooth365_subset_pre),1,'omitnan') > threshold_sampling  ;
   dSM_dt_smooth365_index_valid_pre_cells{i} = dSM_dt_smooth365_index_valid_pre ; 
   
 dSM_dt_smooth365_subset_pre_cells{i} =  dSM_dt_smooth365_subset_pre ; 
    
 end 



% dSM/dt ESACCI
 for i = loop_index
 
dSM_dt_ESACCI_subset_post=  dSM_dt_interpsm_2D_array( ...
           dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold & npixelf_previous_f_array > 300 ,:) ; 
     
   dSM_dt_ESACCI_subset_post(:,sum(~isnan(dSM_dt_ESACCI_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dSM_dt_ESACCI_index_valid_post  = sum(~isnan(dSM_dt_ESACCI_subset_post),1,'omitnan') > threshold_sampling  ;
   dSM_dt_ESACCI_index_valid_post_cells{i} = dSM_dt_ESACCI_index_valid_post ; 
   
 dSM_dt_ESACCI_subset_post_cells{i} =  dSM_dt_ESACCI_subset_post ; 
 
 
 dSM_dt_ESACCI_subset_pre=  dSM_dt_interpsm_2D_array( ...
          dist_DD_before_next_f_array < 0+i*day_threshold & dist_DD_before_next_f_array > 0+(i-1)*day_threshold & npixelf_previous_f_array > 300,:) ; 
     
   dSM_dt_ESACCI_subset_pre(:,sum(~isnan(dSM_dt_ESACCI_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dSM_dt_ESACCI_index_valid_pre  = sum(~isnan(dSM_dt_ESACCI_subset_pre),1,'omitnan') > threshold_sampling  ;
   dSM_dt_ESACCI_index_valid_pre_cells{i} = dSM_dt_ESACCI_index_valid_pre ; 
   
 dSM_dt_ESACCI_subset_pre_cells{i} =  dSM_dt_ESACCI_subset_pre ; 
 

 end 


 % DD reltime
 for i = loop_index
 
DD_reltime_subset_post=  DD_reltime_array( ...
           dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold  ,:) ; 
     
   DD_reltime_subset_post(:,sum(~isnan(DD_reltime_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   DD_reltime_index_valid_post  = sum(~isnan(DD_reltime_subset_post),1,'omitnan') > threshold_sampling  ;
   DD_reltime_index_valid_post_cells{i} = DD_reltime_index_valid_post ; 
   
 DD_reltime_subset_post_cells{i} =  DD_reltime_subset_post ; 
 
 
 DD_reltime_subset_pre=  DD_reltime_array( ...
          dist_DD_before_next_f_array < 0+i*day_threshold & dist_DD_before_next_f_array > 0+(i-1)*day_threshold ,:) ; 
     
   DD_reltime_subset_pre(:,sum(~isnan(DD_reltime_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   DD_reltime_index_valid_pre  = sum(~isnan(DD_reltime_subset_pre),1,'omitnan') > threshold_sampling  ;
   DD_reltime_index_valid_pre_cells{i} = DD_reltime_index_valid_pre ; 
   
 DD_reltime_subset_pre_cells{i} =  DD_reltime_subset_pre ; 
 

 end 




% dVPD/dt 
 for i = loop_index
 
dVPD_dt_subset_post=  DD_dVPD_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
   dVPD_dt_subset_post(:,sum(~isnan(dVPD_dt_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dVPD_dt_index_valid_post  = sum(~isnan(dVPD_dt_subset_post),1,'omitnan') > threshold_sampling  ;  
   dVPD_dt_index_valid_post_cells{i} = dVPD_dt_index_valid_post ;
   
 dVPD_dt_subset_post_cells{i} =  dVPD_dt_subset_post ; 
 
 
 dVPD_dt_subset_pre=  DD_dVPD_dt_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dVPD_dt_subset_pre(:,sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dVPD_dt_index_valid_pre  = sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') > threshold_sampling  ;  
   dVPD_dt_index_valid_pre_cells{i} = dVPD_dt_index_valid_pre ;
   
 dVPD_dt_subset_pre_cells{i} =  dVPD_dt_subset_pre ; 
 
   
 end  
 
 % dERAVPD/dt 
 for i = loop_index
 
dERAVPD_dt_subset_post=  DD_dERAVPD_dt_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
   dERAVPD_dt_subset_post(:,sum(~isnan(dERAVPD_dt_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dERAVPD_dt_index_valid_post  = sum(~isnan(dERAVPD_dt_subset_post),1,'omitnan') > threshold_sampling  ;  
   dERAVPD_dt_index_valid_post_cells{i} = dERAVPD_dt_index_valid_post ;
   
 dERAVPD_dt_subset_post_cells{i} =  dERAVPD_dt_subset_post ; 
 
 
 dERAVPD_dt_subset_pre=  DD_dERAVPD_dt_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dERAVPD_dt_subset_pre(:,sum(~isnan(dERAVPD_dt_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dERAVPD_dt_index_valid_pre  = sum(~isnan(dERAVPD_dt_subset_pre),1,'omitnan') > threshold_sampling  ;  
   dERAVPD_dt_index_valid_pre_cells{i} = dERAVPD_dt_index_valid_pre ;
   
 dERAVPD_dt_subset_pre_cells{i} =  dERAVPD_dt_subset_pre ; 
 
   
 end  
 % VPD day
 for i = loop_index
 
VPD_subset_post=  DD_VPD_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
   VPD_subset_post(:,sum(~isnan(VPD_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dVPD_dt_index_valid_post  = sum(~isnan(VPD_subset_post),1,'omitnan') > threshold_sampling  ;  
   VPD_index_valid_post_cells{i} = dVPD_dt_index_valid_post ;
   
 VPD_subset_post_cells{i} =  VPD_subset_post ; 
 
 
 VPD_subset_pre=  DD_VPD_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   VPD_subset_pre(:,sum(~isnan(VPD_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dVPD_dt_index_valid_pre  = sum(~isnan(VPD_subset_pre),1,'omitnan') > threshold_sampling  ;  
   VPD_index_valid_pre_cells{i} = dVPD_dt_index_valid_pre ;
   
 VPD_subset_pre_cells{i} =  VPD_subset_pre ; 
 
   
 end  
 
% ERAVPD day
 for i = loop_index
 
ERAVPD_subset_post=  DD_ERAVPD_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
   ERAVPD_subset_post(:,sum(~isnan(ERAVPD_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dERAVPD_dt_index_valid_post  = sum(~isnan(ERAVPD_subset_post),1,'omitnan') > threshold_sampling  ;  
   ERAVPD_index_valid_post_cells{i} = dERAVPD_dt_index_valid_post ;
   
 ERAVPD_subset_post_cells{i} =  ERAVPD_subset_post ; 
 
 
 ERAVPD_subset_pre=  DD_ERAVPD_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   ERAVPD_subset_pre(:,sum(~isnan(ERAVPD_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dERAVPD_dt_index_valid_pre  = sum(~isnan(ERAVPD_subset_pre),1,'omitnan') > threshold_sampling  ;  
   ERAVPD_index_valid_pre_cells{i} = dERAVPD_dt_index_valid_pre ;
   
 ERAVPD_subset_pre_cells{i} =  ERAVPD_subset_pre ; 
 
   
 end   
 
 % dVPD_day /dt 
 for i = loop_index
 
dVPD_dt_subset_post=  DD_dVPD_dt_day_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
   dVPD_dt_subset_post(:,sum(~isnan(dVPD_dt_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   dVPD_dt_day_index_valid_post  = sum(~isnan(dVPD_dt_subset_post),1,'omitnan') > threshold_sampling  ;  
   dVPD_dt_index_valid_post_cells{i} = dVPD_dt_index_valid_post ;
   
 dVPD_dt_day_subset_post_cells{i} =  dVPD_dt_subset_post ; 
 
 
 dVPD_dt_subset_pre=  DD_dVPD_dt_day_interpsm_array( ...
         D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dVPD_dt_subset_pre(:,sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   dVPD_dt_index_valid_pre  = sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') > threshold_sampling  ;  
   dVPD_dt_day_index_valid_pre_cells{i} = dVPD_dt_index_valid_pre ;
   
 dVPD_dt_day_subset_pre_cells{i} =  dVPD_dt_subset_pre ; 
 
   
 end  
 
 

% DD tau AS DS diff
DD_tau_As_Ds_intersm_mean_array = (DD_tauC_Ds_interpsm_array + DD_tauC_As_interpsm_array) ./2 ; 
DD_tau_C_Ds_As_rel_difference_interpsm_array = DD_tauC_Ds_interpsm_array - DD_tauC_As_interpsm_array ; 


 
  for i = loop_index
         
 
DD_tau_C_Ds_As_rel_difference_subset_post=  DD_tau_C_Ds_As_rel_difference_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold ,:) ; 
     
DD_tau_C_Ds_As_rel_difference_subset_pre=  DD_tau_C_Ds_As_rel_difference_interpsm_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold   ,:) ; 
     
   DD_tau_C_Ds_As_rel_difference_subset_post(:,sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_post),1,'omitnan') < threshold_sampling) = NaN ; 
   DD_tau_C_Ds_As_rel_difference_valid_post  = sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_post),1,'omitnan') > threshold_sampling  ;  
  DD_tau_C_Ds_As_rel_difference_valid_post_cells{i} = DD_tau_C_Ds_As_rel_difference_valid_post;
   
   DD_tau_C_Ds_As_rel_difference_subset_pre(:,sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   DD_tau_C_Ds_As_rel_difference_valid_pre  = sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_pre),1,'omitnan') > threshold_sampling  ;  
   DD_tau_C_Ds_As_rel_difference_pre_cells{i} = DD_tau_C_Ds_As_rel_difference_valid_pre;   
   
   
 DD_tau_C_Ds_As_rel_difference_subset_post_cells{i} =  DD_tau_C_Ds_As_rel_difference_subset_post ; 
 DD_tau_C_Ds_As_rel_difference_subset_pre_cells{i} =  DD_tau_C_Ds_As_rel_difference_subset_pre ; 
    
  end
 

  for i = loop_index
         
 
DD_tau_C_Ds_As_mean_post=  DD_tau_As_Ds_intersm_mean_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold ,:) ; 
     
DD_tau_C_Ds_As_mean_pre=  DD_tau_As_Ds_intersm_mean_array( ...
         D_tau_DD_array  <  10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold   ,:) ; 
     
   DD_tau_C_Ds_As_mean_post(:,sum(~isnan(DD_tau_C_Ds_As_mean_post),1,'omitnan') < threshold_sampling) = NaN ; 
   DD_tau_C_Ds_As_mean_post_valid_post  = sum(~isnan(DD_tau_C_Ds_As_mean_post),1,'omitnan') > threshold_sampling  ;  
  DD_tau_C_Ds_As_mean_post_valid_post_cells{i} = DD_tau_C_Ds_As_mean_post_valid_post;
   
   DD_tau_C_Ds_As_mean_pre(:,sum(~isnan(DD_tau_C_Ds_As_mean_pre),1,'omitnan') < threshold_sampling) = NaN ; 
   DD_tau_C_Ds_As_mean_pre_valid_pre  = sum(~isnan(DD_tau_C_Ds_As_mean_pre),1,'omitnan') > threshold_sampling  ;  
   DD_tau_C_Ds_As_mean_pre_valid_pre_cells{i} = DD_tau_C_Ds_As_mean_pre_valid_pre;   
   
   
DD_tau_C_Ds_As_mean_post_cells{i} =  DD_tau_C_Ds_As_mean_post ; 
DD_tau_C_Ds_As_mean_pre_cells{i} =  DD_tau_C_Ds_As_mean_pre ; 
    
  end  






% 1:12:48
% 12:12:48
% 
% 1:3:12
% 3:3:12





% sminterp = linspace( 0,0.60,30 ); 
% sminterp_60 = linspace( 0,0.60,60 ); 
% tauinterp = linspace(0,1,30) ; 



%  select_cells_pre = [4 8 12 16] ;
%  select_cells_post = [3 6 9 12] ; 
 select_cells_pre = [12 24 36 48] ; 


 


 %      post_anomaly_mean = tau_subset_post_cells{1}  ;
 %     !! not sure we need !! post_anomaly_mean = DD_tau_C_Ds_As_mean_post_cells{1}  ;  
 %      post_anomaly_mean = tau_VODCA_subset_post_cells{1}  ;
 %      post_anomaly_mean = DD_tauC_As_subset_post_cells{1} ; 




 post_anomaly = dSM_dt_subset_post_cells{1}  ;
 % pre_anomaly =  tau_C_Ds_As_diff_subset_post_cells{select_cells_pre(1)}  ;



% list of variables to analyze
% tau_C_Ds_As_diff_subset_post_cells


%%%%%%%%   dtau_dt_subset_post_cells
%%%%%%%%   dSM_dt_subset_post_cells
%%%%%%%%   dSM_dt_ESACCI_subset_post_cells
%%%%%%%%   dtauC_As_dt_subset_post_cells
%%%%%%%%   dtauC_As_dt_subset_post_cells
%%%%%%%%   dERAVPD_dt_subset_post_cells
%%%%%%%%   VPD_subset_post_cells
%%%%%%%%   ERAVPD_subset_post_cells
%%%%%%%%   tau_C_Ds_As_diff_subset_post_cells
%%%%%%%%   DD_tau_C_Ds_As_rel_difference_subset_post_cells


% mjb instead of only taking previous year take all previous years


 pre_anomaly =  vertcat( dSM_dt_subset_pre_cells{select_cells_pre(1)}, ...
                         dSM_dt_subset_pre_cells{select_cells_pre(2)}, ...
                         dSM_dt_subset_pre_cells{select_cells_pre(3)}, ...
                         dSM_dt_subset_pre_cells{select_cells_pre(4)})  ;


% normal L tau
pre_anomaly_mean =  vertcat(tau_subset_pre_cells{select_cells_pre(1)}, ...
                        tau_subset_pre_cells{select_cells_pre(2)}, ...
                        tau_subset_pre_cells{select_cells_pre(3)}, ...
                        tau_subset_pre_cells{select_cells_pre(4)})  ;

% tau C 
pre_anomaly_mean =  vertcat(DD_tauC_As_subset_pre_cells{select_cells_pre(1)}, ...
                        DD_tauC_As_subset_pre_cells{select_cells_pre(2)}, ...
                        DD_tauC_As_subset_pre_cells{select_cells_pre(3)}, ...
                        DD_tauC_As_subset_pre_cells{select_cells_pre(4)})  ;

% VODCA tau
pre_anomaly_mean =  vertcat(tau_VODCA_subset_pre_cells{select_cells_pre(1)}, ...
                        tau_VODCA_subset_pre_cells{select_cells_pre(2)}, ...
                        tau_VODCA_subset_pre_cells{select_cells_pre(3)}, ...
                        tau_VODCA_subset_pre_cells{select_cells_pre(4)})  ;





sminterp = linspace( 0.001,0.5999,31 ); 
sminterp_60 = linspace( 0.001,0.5999,60 ); 
tauinterp = linspace(0.001,0.9999,31) ; 





DD_day_night_diff_3_D_pre = NaN(30,30,100000)  ; 
DD_day_night_diff_3_D_post = NaN(30,30,100000)  ; 


for sm = 1:30
    
    cur_sm = sminterp(sm:sm+1) ; 
    sm_true = sminterp_60 > cur_sm(1) & sminterp_60 < cur_sm(2) ; 
    
    for tau = 1:30
        
    cur_tau = tauinterp(tau:tau+1) ;         
      
    dummypre = pre_anomaly(:,sm_true) ; 
    tau_diff_dummy_pre = dummypre(pre_anomaly_mean(:,sm_true) > cur_tau(1) & pre_anomaly_mean(:,sm_true) < cur_tau(2)) ; 
    dummypost = post_anomaly(:,sm_true) ; 
    tau_diff_dummy_post = dummypost(post_anomaly_mean(:,sm_true) > cur_tau(1) & post_anomaly_mean(:,sm_true) < cur_tau(2)) ;    
    
     DD_day_night_diff_3_D_pre(sm,tau,1:length(tau_diff_dummy_pre)) = tau_diff_dummy_pre ; 
     DD_day_night_diff_3_D_post(sm,tau,1:length(tau_diff_dummy_post)) = tau_diff_dummy_post ;    
    
        
    end


sm
end



DD_day_night_diff_3_D_pre(DD_day_night_diff_3_D_pre <= 0) = NaN ; 
DD_day_night_diff_3_D_post(DD_day_night_diff_3_D_post <= 0) = NaN ; 



mask_sample_post =  (sum(~isnan(DD_day_night_diff_3_D_post),3,'omitnan')  < 20)  ; 
mask_sample_pre =  (sum(~isnan(DD_day_night_diff_3_D_pre),3,'omitnan')  < 20)  ; 
mask_sample_post = repmat(mask_sample_post,[1,1,100000]) ; 
mask_sample_pre = repmat(mask_sample_pre,[1,1,100000]) ; 


DD_day_night_diff_3_D_pre(mask_sample_pre) = NaN ; 
DD_day_night_diff_3_D_post(mask_sample_post) = NaN ; 


test_pre = median(DD_day_night_diff_3_D_pre,3,'omitnan') ; 
test_post = median(DD_day_night_diff_3_D_post,3,'omitnan') ; 

% figure
% imagesc(test_pre) ; clim([-0.06 0]) ;
% figure
% imagesc(test_post) ; clim([-0.2 0.2]) ;
% imagesc(test_post - test_pre)


% always convert y axis to VWC
tauinterp = tauinterp ./ 0.11 ; 

% for C-band use the same for VODCA
tauinterp = tauinterp ./ 0.2046 ; 

% convert to VWC comment out if not wanted

% fore L-band
test_pre = test_pre ./0.11 ; 
test_post = test_post ./ 0.11 ; 


% for C-band
test_pre = test_pre ./0.2046 ; 
test_post = test_post ./ 0.2046 ; 

% for VODCA use C_band value 


% do test on pixels 

% 1 sample  Kolmogorov Smirnov for normal distribution
koltestpre = NaN(30,30) ; koltestppre = NaN(30,300) ; 
koltestpost = NaN(30,30) ; koltestppost = NaN(30,300) ; 

for r = 1:30
    for c = 1:30
      
       if (   ~all(isnan(squeeze(DD_day_night_diff_3_D_pre(r,c,:))))  ) 
      [koltestpre(r,c), koltestppre(1,i)]= kstest(squeeze(DD_day_night_diff_3_D_pre(r,c,:))) ; 
       end
       
       if (   ~all(isnan(squeeze(DD_day_night_diff_3_D_post(r,c,:))))  )       
      [koltestpost(r,c), koltestppost(1,i)]= kstest(squeeze(DD_day_night_diff_3_D_post(r,c,:))) ;   
       end
  
    end
end


% normally all non normal .. no surprising .. do man whithnes u
% nonparametric


% 2 sample Kolmogorov Smirnov nonparam test
MWUtesth_post = NaN(30,30) ; MWUtestp_post = NaN(30,30) ; 


for r = 1:30
    for c = 1:30
      
        dummy_pre =  squeeze(DD_day_night_diff_3_D_pre(r,c,:))  ;
        dummy_post = squeeze(DD_day_night_diff_3_D_post(r,c,:))  ;
        dummy_pre(isnan(dummy_pre)) = [] ; 
        dummy_post(isnan(dummy_post)) = [] ;         
 
         if (   ~all(isnan(dummy_pre))  &&   ~all(isnan(dummy_post))   ) 
        [MWUtestp_post(r,c),MWUtesth_post(r,c)] = ranksum(dummy_pre,dummy_post) ; 
        end
    
  
    end
end


% save if needed for panel plots



% save final results for plot here
dSM_dt_phase_space_pre  =   test_pre ; 
dSM_dt_phase_space_post =   test_post;
dSM_dt_phase_space_MWU = MWUtestp_post ; 


save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dSM_dt_phase_space_pre','dSM_dt_phase_space_pre')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dSM_dt_phase_space_post','dSM_dt_phase_space_post')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\dSM_dt_phase_space_MWU','dSM_dt_phase_space_MWU')




%%  Step 7 Bin relative to NBR severity classes
clear


cd('E:\MOSEV_tiles\DD_all_01')
load('DD_reltime_array.mat')
load('Dist_to_f__min_array.mat')
load('D_tau_DD_array.mat')
load('DD_dTau_dSM_interpsm_array.mat')
load('DD_dSM_dt_interpsm_array.mat')
load('DD_dTau_dt_interpsm_array.mat')
load('DD_dTau_dVPD_interpsm_array.mat')
load('D_NBR_DD_array.mat')
load('DD_dVPD_dSM_interpsm_array.mat')
load('DD_dVPD_dt_interpsm_array.mat')
load('DD_dERAVPD_dSM_interpsm_array.mat')
load('DD_dERAVPD_dt_interpsm_array.mat')
load('DD_ERAVPD_interpsm_array.mat')
load('DD_ERAVPD_interptime_array.mat')
load('DD_col.mat')
load('DD_row.mat')
load('DD_dtauC_dSM_interpsm_array.mat')
load('DD_dtauC_dt_interpsm_array.mat')
load('DD_dtauC_As_dt_interpsm_array.mat')
load('DD_dtauC_As_dSM_interpsm_array.mat')
load('DD_tau_LC_ratio_interpsm_array.mat')
load('DD_dtauL_dt_dtauC_dt_interpsm_array.mat')
load('DD_tau_C_Ds_As_difference_interpsm_array.mat')
load('DD_tau_C_Ds_As_difference_interpsm_array.mat')
load('DD_tau_C_Ds_As_rel_difference_interpsm_array.mat')
load('DD_tauC_As_interpsm_array.mat')
load('DD_tauC_Ds_interpsm_array.mat')
load('DD_SM_interptime_array.mat')
load('DD_Tau_interpsm_array.mat')
load('DD_tauC_Ds_interpsm_array.mat')
load('DD_tauC_As_interpsm_array.mat')
load('D_tau_DD_array.mat')
load('Dist_to_f__min_array.mat')
load('DD_VPD_interpsm_array.mat')
sminterp = [ 0.01 : 0.01 : 0.60 ]; 


% get ESA CCI
cd('F:\ESA_CCI\global_SMAP_time')
load('dSM_dt_interpsm_2D_array.mat')
load('dist_DD_after_previous_f_array.mat')
load('npixelf_previous_f_array.mat')
load('VODCA_interpsm_array.mat')
load('dist_DD_before_next_f_array.mat')
load('rowcol_2D_array.mat')
load('DNBR_mean_next_f_array.mat')
load('DNBR_mean_previous_f_array.mat')
load('npixelf_previous_f_array.mat')



% get smoothing experiments

% 365 smooth
cd('E:\MOSEV_tiles\DD_all_365_smooth')
load('DD_dSM_dt_365_interpsm_array.mat')
load('DD_dTau_dt_365_interpsm_array.mat')
load('DD_Tau_365_interpsm_array.mat')

% unsmoothened
cd('E:\MOSEV_tiles\DD_all_unsmoothed')
load('DD_dSM_dt_0_interpsm_array.mat')
load('DD_dTau_dt_0_interpsm_array.mat')
load('DD_Tau_0_interpsm_array.mat')



% ad another step subsetting by area based on load of global firepixels
cd('E:\MTDCA_V5_2015_2021\9_km\SM')
% load('MTDCA_V5_SM_201504_201506_9km.mat', 'MTDCA_SM')
% SM_mean_test = mean(MTDCA_SM,3,'omitnan') ; 
% clear MTDCA_SM

% figure
% imagesc(SM_mean_test)
% [xs, ys] = getpts() ; xs = round(xs) ; ys = round(ys) ; 
% close

  xs = [1 3856] ; ys = [1 1624] ; 

% cut datasets based on row and cols
latlon_logical_index = DD_row < max(ys) & DD_row > min(ys) & DD_col < max(xs) & DD_col > min(xs) ; 



% get mean layer to normalize?
threshold = 1 ; 
day_threshold = 365/12 ;
loop_index = 1:48 ; 


DD_tau_As_Ds_intersm_mean_array = (DD_tauC_Ds_interpsm_array + DD_tauC_As_interpsm_array) ./2 ; 



% option to remove drydowns of certain length. Show results independent of drydown length
% DD_obs_length_array = sum(DD_reltime_array ~= 0,2) ; 
% DD_dSM_dt_interpsm_array(DD_obs_length_array > 4,:) = NaN ; 
% DD_dTau_dt_interpsm_array(DD_obs_length_array > 4,:) = NaN ; 






% maybe change bins to some etablished classification but seems to be not
% really standardized
% add severity bins .. maybe do 4 classes based on tau and maybe even NBR
severity_bins_tau = linspace(-0.3,0.1,6) ; 
severity_bins_NBR = linspace(-200,600,6) ; 
severity_bins_tau = [-10 severity_bins_tau 10] ; 
severity_bins_NBR = [-10000 severity_bins_NBR 10000] ; 


for severe_count = 1:length(severity_bins_tau)-1

   bin_tau_s =  severity_bins_tau(severe_count) ; 
   bin_NBR_s =  severity_bins_NBR(severe_count) ;    
   bin_tau_e =  severity_bins_tau(severe_count+1) ; 
   bin_NBR_e =  severity_bins_NBR(severe_count+1) ;        
   
 for i = loop_index
 
     
     
 % dSM/dt tau  
dSM_dt_subset_post=  DD_dSM_dt_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_subset_post(:,sum(~isnan(dSM_dt_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dSM_dt_subset_pre=  DD_dSM_dt_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_subset_pre(:,sum(~isnan(dSM_dt_subset_pre),1,'omitnan') < threshold) = NaN ; 
  % tau
  dSM_dt_subset_pre_tau_cells{i,severe_count} =  dSM_dt_subset_pre ; 
  dSM_dt_subset_post_tau_cells{i,severe_count} =  dSM_dt_subset_post ; 
  

 % dSM/dt NBR 
dSM_dt_subset_post=  DD_dSM_dt_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_subset_post(:,sum(~isnan(dSM_dt_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dSM_dt_subset_pre=  DD_dSM_dt_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_subset_pre(:,sum(~isnan(dSM_dt_subset_pre),1,'omitnan') < threshold) = NaN ; 
  % tau
  dSM_dt_subset_pre_NBR_cells{i,severe_count} =  dSM_dt_subset_pre ; 
  dSM_dt_subset_post_NBR_cells{i,severe_count} =  dSM_dt_subset_post ;   
  
 

 % dSM/dt smooth 0 tau  
dSM_dt_smooth0_subset_post=  DD_dSM_dt_0_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_smooth0_subset_post(:,sum(~isnan(dSM_dt_smooth0_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dSM_dt_smooth0_subset_pre=  DD_dSM_dt_0_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_smooth0_subset_pre(:,sum(~isnan(dSM_dt_smooth0_subset_pre),1,'omitnan') < threshold) = NaN ; 
  % tau
  dSM_dt_smooth0_subset_pre_tau_cells{i,severe_count} =  dSM_dt_smooth0_subset_pre ; 
  dSM_dt_smooth0_subset_post_tau_cells{i,severe_count} =  dSM_dt_smooth0_subset_post ; 
  

 % dSM/dt smooth0 NBR 
dSM_dt_smooth0_subset_post=  DD_dSM_dt_0_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_smooth0_subset_post(:,sum(~isnan(dSM_dt_smooth0_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dSM_dt_smooth0_subset_pre=  DD_dSM_dt_0_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_smooth0_subset_pre(:,sum(~isnan(dSM_dt_smooth0_subset_pre),1,'omitnan') < threshold) = NaN ; 
  % tau
  dSM_dt_smooth0_subset_pre_NBR_cells{i,severe_count} =  dSM_dt_smooth0_subset_pre ; 
  dSM_dt_smooth0_subset_post_NBR_cells{i,severe_count} =  dSM_dt_smooth0_subset_post ;   



 % dSM/dt smooth 365 tau  
dSM_dt_smooth365_subset_post=  DD_dSM_dt_365_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_smooth365_subset_post(:,sum(~isnan(dSM_dt_smooth365_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dSM_dt_smooth365_subset_pre=  DD_dSM_dt_365_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_smooth365_subset_pre(:,sum(~isnan(dSM_dt_smooth365_subset_pre),1,'omitnan') < threshold) = NaN ; 
  % tau
  dSM_dt_smooth365_subset_pre_tau_cells{i,severe_count} =  dSM_dt_smooth365_subset_pre ; 
  dSM_dt_smooth365_subset_post_tau_cells{i,severe_count} =  dSM_dt_smooth365_subset_post ; 


 % dSM/dt smooth 365 NBR 
dSM_dt_smooth365_subset_post=  DD_dSM_dt_365_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_smooth365_subset_post(:,sum(~isnan(dSM_dt_smooth0_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dSM_dt_smooth365_subset_pre=  DD_dSM_dt_365_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dSM_dt_smooth365_subset_pre(:,sum(~isnan(dSM_dt_smooth0_subset_pre),1,'omitnan') < threshold) = NaN ; 
  % tau
  dSM_dt_smooth365_subset_pre_NBR_cells{i,severe_count} =  dSM_dt_smooth365_subset_pre ; 
  dSM_dt_smooth365_subset_post_NBR_cells{i,severe_count} =  dSM_dt_smooth365_subset_post ;  

  % MJB 21.11.2013 we don't have tau severity yet. 
 % dSM/dt ESACCI tau  
% dSM_dt_ESACCI_subset_post=  dSM_dt_interpsm_2D_array( ...
%          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold  ,:) ;     
%    dSM_dt_ESACCI_subset_post(:,sum(~isnan(dSM_dt_ESACCI_subset_post),1,'omitnan') < threshold) = NaN ; 
% 
%  dSM_dt_ESACCI_subset_pre=  dSM_dt_interpsm_2D_array( ...
%          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & -dist_DD_before_next_f_array > 0-i*day_threshold & -dist_DD_before_next_f_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
%    dSM_dt_ESACCI_subset_pre(:,sum(~isnan(dSM_dt_ESACCI_subset_pre),1,'omitnan') < threshold) = NaN ; 
%   % tau
%   dSM_dt_ESACCI_subset_pre_tau_cells{i,severe_count} =  dSM_dt_ESACCI_subset_pre ; 
%   dSM_dt_ESACCI_subset_post_tau_cells{i,severe_count} =  dSM_dt_ESACCI_subset_post ; 
  

 % dSM/dt ESACCI NBR 
dSM_dt_ESACCI_subset_post=  dSM_dt_interpsm_2D_array( ...
         DNBR_mean_previous_f_array > bin_NBR_s &  DNBR_mean_previous_f_array < bin_NBR_e          & dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold & npixelf_previous_f_array > 300  ,:) ;     
   dSM_dt_ESACCI_subset_post(:,sum(~isnan(dSM_dt_ESACCI_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dSM_dt_ESACCI_subset_pre=  dSM_dt_interpsm_2D_array( ...
         DNBR_mean_previous_f_array > bin_NBR_s &  DNBR_mean_previous_f_array < bin_NBR_e          & -dist_DD_before_next_f_array > 0-i*day_threshold & -dist_DD_before_next_f_array < 0-(i-1)*day_threshold & npixelf_previous_f_array > 300  ,:) ;     
   dSM_dt_ESACCI_subset_pre(:,sum(~isnan(dSM_dt_ESACCI_subset_pre),1,'omitnan') < threshold) = NaN ; 
  % tau
  dSM_dt_ESACCI_subset_pre_NBR_cells{i,severe_count} =  dSM_dt_ESACCI_subset_pre ; 
  dSM_dt_ESACCI_subset_post_NBR_cells{i,severe_count} =  dSM_dt_ESACCI_subset_post ;   




 
  % dtau/dt     tau
dtau_dt_subset_post=  DD_dTau_dt_interpsm_array( ...
          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_subset_post(:,sum(~isnan(dtau_dt_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dtau_dt_subset_pre=  DD_dTau_dt_interpsm_array( ...
          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_subset_pre(:,sum(~isnan(dtau_dt_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dtau_dt_subset_pre_tau_cells{i,severe_count} =  dtau_dt_subset_pre ; 
  dtau_dt_subset_post_tau_cells{i,severe_count} =  dtau_dt_subset_post ; 
 
   % dtau/dt     NBR
dtau_dt_subset_post=  DD_dTau_dt_interpsm_array( ...
           D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_subset_post(:,sum(~isnan(dtau_dt_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dtau_dt_subset_pre=  DD_dTau_dt_interpsm_array( ...
           D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_subset_pre(:,sum(~isnan(dtau_dt_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dtau_dt_subset_pre_NBR_cells{i,severe_count} =  dtau_dt_subset_pre ; 
  dtau_dt_subset_post_NBR_cells{i,severe_count} =  dtau_dt_subset_post ; 
 
  

  % dtau/dt smooth0    tau
dtau_dt_smooth0_subset_post=  DD_dTau_dt_0_interpsm_array( ...
          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth0_subset_post(:,sum(~isnan(dtau_dt_smooth0_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dtau_dt_smooth0_subset_pre=  DD_dTau_dt_0_interpsm_array( ...
          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth0_subset_pre(:,sum(~isnan(dtau_dt_smooth0_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dtau_dt_smooth0_subset_pre_tau_cells{i,severe_count} =    dtau_dt_smooth0_subset_pre ; 
  dtau_dt_smooth0_subset_post_tau_cells{i,severe_count} =  dtau_dt_smooth0_subset_post ; 


  % dtau/dt smooth0    NBR
dtau_dt_smooth0_subset_post=  DD_dTau_dt_0_interpsm_array( ...
           D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth0_subset_post(:,sum(~isnan(dtau_dt_smooth0_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dtau_dt_smooth0_subset_pre=  DD_dTau_dt_0_interpsm_array( ...
           D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth0_subset_pre(:,sum(~isnan(dtau_dt_smooth0_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dtau_dt_smooth0_subset_pre_NBR_cells{i,severe_count} =   dtau_dt_smooth0_subset_pre ; 
  dtau_dt_smooth0_subset_post_NBR_cells{i,severe_count} =  dtau_dt_smooth0_subset_post ; 


  % dtau/dt smooth365    tau
dtau_dt_smooth365_subset_post=  DD_dTau_dt_365_interpsm_array( ...
          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth365_subset_post(:,sum(~isnan(dtau_dt_smooth365_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dtau_dt_smooth365_subset_pre=  DD_dTau_dt_365_interpsm_array( ...
          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth365_subset_pre(:,sum(~isnan(dtau_dt_smooth365_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dtau_dt_smooth365_subset_pre_tau_cells{i,severe_count} =    dtau_dt_smooth365_subset_pre ; 
  dtau_dt_smooth365_subset_post_tau_cells{i,severe_count} =  dtau_dt_smooth365_subset_post ; 

  % dtau/dt smooth365    NBR
dtau_dt_smooth365_subset_post=  DD_dTau_dt_365_interpsm_array( ...
           D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth365_subset_post(:,sum(~isnan(dtau_dt_smooth365_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dtau_dt_smooth365_subset_pre=  DD_dTau_dt_365_interpsm_array( ...
           D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_dt_smooth365_subset_pre(:,sum(~isnan(dtau_dt_smooth365_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dtau_dt_smooth365_subset_pre_NBR_cells{i,severe_count} =   dtau_dt_smooth365_subset_pre ; 
  dtau_dt_smooth365_subset_post_NBR_cells{i,severe_count} =  dtau_dt_smooth365_subset_post ; 


    % dtau_C/dt     
dtau_C_dt_subset_post=  DD_dtauC_dt_interpsm_array( ...
          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_C_dt_subset_post(:,sum(~isnan(dtau_C_dt_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dtau_C_dt_subset_pre=  DD_dtauC_dt_interpsm_array( ...
          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_C_dt_subset_pre(:,sum(~isnan(dtau_C_dt_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dtau_C_dt_subset_pre_tau_cells{i,severe_count} =  dtau_C_dt_subset_pre ; 
  dtau_C_dt_subset_post_tau_cells{i,severe_count} =  dtau_C_dt_subset_post ; 
 
   % dtau/dt     
dtau_C_dt_subset_post=  DD_dtauC_dt_interpsm_array( ...
           D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_C_dt_subset_post(:,sum(~isnan(dtau_C_dt_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dtau_C_dt_subset_pre=  DD_dtauC_dt_interpsm_array( ...
           D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dtau_C_dt_subset_pre(:,sum(~isnan(dtau_C_dt_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dtau_C_dt_subset_pre_NBR_cells{i,severe_count} =  dtau_C_dt_subset_pre ; 
  dtau_C_dt_subset_post_NBR_cells{i,severe_count} =  dtau_C_dt_subset_post ; 

 
   % dVPD/dt    
dVPD_dt_subset_post=  DD_dVPD_dt_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dVPD_dt_subset_post(:,sum(~isnan(dVPD_dt_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dVPD_dt_subset_pre=  DD_dVPD_dt_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dVPD_dt_subset_pre(:,sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dVPD_dt_subset_pre_tau_cells{i,severe_count} =  dVPD_dt_subset_pre ; 
  dVPD_dt_subset_post_tau_cells{i,severe_count} =  dVPD_dt_subset_post ; 
 
  
 dVPD_dt_subset_post=  DD_dVPD_dt_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e         & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dVPD_dt_subset_post(:,sum(~isnan(dVPD_dt_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dVPD_dt_subset_pre=  DD_dVPD_dt_interpsm_array( ...
          D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dVPD_dt_subset_pre(:,sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dVPD_dt_subset_pre_NBR_cells{i,severe_count} =  dVPD_dt_subset_pre ; 
  dVPD_dt_subset_post_NBR_cells{i,severe_count} =  dVPD_dt_subset_post ; 

     % dERAVPD/dt    
dERAVPD_dt_subset_post=  DD_dERAVPD_dt_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dERAVPD_dt_subset_post(:,sum(~isnan(dERAVPD_dt_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dERAVPD_dt_subset_pre=  DD_dERAVPD_dt_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dERAVPD_dt_subset_pre(:,sum(~isnan(dERAVPD_dt_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dERAVPD_dt_subset_pre_tau_cells{i,severe_count} =  dERAVPD_dt_subset_pre ; 
  dERAVPD_dt_subset_post_tau_cells{i,severe_count} =  dERAVPD_dt_subset_post ; 
 
  
 dERAVPD_dt_subset_post=  DD_dERAVPD_dt_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e         & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dERAVPD_dt_subset_post(:,sum(~isnan(dERAVPD_dt_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 dERAVPD_dt_subset_pre=  DD_dERAVPD_dt_interpsm_array( ...
          D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   dERAVPD_dt_subset_pre(:,sum(~isnan(dERAVPD_dt_subset_pre),1,'omitnan') < threshold) = NaN ; 

  dERAVPD_dt_subset_pre_NBR_cells{i,severe_count} =  dERAVPD_dt_subset_pre ; 
  dERAVPD_dt_subset_post_NBR_cells{i,severe_count} =  dERAVPD_dt_subset_post ; 
 
 
   % VPD    
VPD_subset_post=  DD_VPD_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VPD_subset_post(:,sum(~isnan(VPD_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 VPD_subset_pre=  DD_VPD_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VPD_subset_pre(:,sum(~isnan(VPD_subset_pre),1,'omitnan') < threshold) = NaN ; 

  VPD_subset_pre_tau_cells{i,severe_count} =  VPD_subset_pre ; 
  VPD_subset_post_tau_cells{i,severe_count} =  VPD_subset_post ; 
 
  
 VPD_subset_post=  DD_VPD_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e         & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VPD_subset_post(:,sum(~isnan(VPD_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 VPD_subset_pre=  DD_VPD_interpsm_array( ...
          D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VPD_subset_pre(:,sum(~isnan(VPD_subset_pre),1,'omitnan') < threshold) = NaN ; 

  VPD_subset_pre_NBR_cells{i,severe_count} =  VPD_subset_pre ; 
  VPD_subset_post_NBR_cells{i,severe_count} =  VPD_subset_post ; 

   % ERAVPD    
ERAVPD_subset_post=  DD_ERAVPD_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   ERAVPD_subset_post(:,sum(~isnan(ERAVPD_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 ERAVPD_subset_pre=  DD_ERAVPD_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   ERAVPD_subset_pre(:,sum(~isnan(ERAVPD_subset_pre),1,'omitnan') < threshold) = NaN ; 

  ERAVPD_subset_pre_tau_cells{i,severe_count} =  ERAVPD_subset_pre ; 
  ERAVPD_subset_post_tau_cells{i,severe_count} =  ERAVPD_subset_post ; 
 
  
 ERAVPD_subset_post=  DD_ERAVPD_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e         & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   ERAVPD_subset_post(:,sum(~isnan(ERAVPD_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 ERAVPD_subset_pre=  DD_ERAVPD_interpsm_array( ...
          D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   ERAVPD_subset_pre(:,sum(~isnan(ERAVPD_subset_pre),1,'omitnan') < threshold) = NaN ; 

  ERAVPD_subset_pre_NBR_cells{i,severe_count} =  ERAVPD_subset_pre ; 
  ERAVPD_subset_post_NBR_cells{i,severe_count} =  ERAVPD_subset_post ; 
   
  

    % VWC diurnal     
VWCdiurnal_subset_post=  DD_tau_C_Ds_As_rel_difference_interpsm_array( ...
          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VWCdiurnal_subset_post(:,sum(~isnan(VWCdiurnal_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 VWCdiurnal_subset_pre=  DD_tau_C_Ds_As_rel_difference_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VWCdiurnal_subset_pre(:,sum(~isnan(VWCdiurnal_subset_pre),1,'omitnan') < threshold) = NaN ; 

  VWCdiurnal_pre_tau_cells{i,severe_count} =  VWCdiurnal_subset_pre ; 
  VWCdiurnal_post_tau_cells{i,severe_count} =  VWCdiurnal_subset_post ; 
 
     % VWC diurnal     
VWCdiurnal_subset_post=  DD_tau_C_Ds_As_rel_difference_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e         & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VWCdiurnal_subset_post(:,sum(~isnan(VWCdiurnal_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 VWCdiurnal_subset_pre=  DD_tau_C_Ds_As_rel_difference_interpsm_array( ...
        D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e         & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   VWCdiurnal_subset_pre(:,sum(~isnan(VWCdiurnal_subset_pre),1,'omitnan') < threshold) = NaN ; 

  VWCdiurnal_pre_NBR_cells{i,severe_count} =  VWCdiurnal_subset_pre ; 
  VWCdiurnal_post_NBR_cells{i,severe_count} =  VWCdiurnal_subset_post ;   
  
  
  
  
 % tau_mean
  tau_mean_subset_post=  DD_Tau_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   tau_mean_subset_post(:,sum(~isnan(tau_mean_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 tau_mean_subset_pre=  DD_Tau_interpsm_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   tau_mean_subset_pre(:,sum(~isnan(tau_mean_subset_pre),1,'omitnan') < threshold) = NaN ; 

   tau_mean_pre_tau_cells{i,severe_count} =   tau_mean_subset_pre ; 
   tau_mean_post_tau_cells{i,severe_count} =  tau_mean_subset_post ;  
   
    % tau_mean
  tau_mean_subset_post=  DD_Tau_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e         & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   tau_mean_subset_post(:,sum(~isnan(tau_mean_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 tau_mean_subset_pre=  DD_Tau_interpsm_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e         & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   tau_mean_subset_pre(:,sum(~isnan(tau_mean_subset_pre),1,'omitnan') < threshold) = NaN ; 

   tau_mean_pre_NBR_cells{i,severe_count} =   tau_mean_subset_pre ; 
   tau_mean_post_NBR_cells{i,severe_count} =  tau_mean_subset_post ;  



    % tau_mean VODCA
 %  tau_mean_VODCA_subset_post=  VODCA_interpsm_array( ...
 %         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
 %   tau_mean_VODCA_subset_post(:,sum(~isnan(tau_mean_VODCA_subset_post),1,'omitnan') < threshold) = NaN ; 
 % 
 % tau_mean_VODCA_subset_pre=  VODCA_interpsm_array( ...
 %         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & -dist_DD_before_next_f_array > 0-i*day_threshold & -dist_DD_before_next_f_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
 %   tau_mean_VODCA_subset_pre(:,sum(~isnan(tau_mean_VODCA_subset_pre),1,'omitnan') < threshold) = NaN ; 
 % 
 %   tau_mean_VODCA_pre_tau_cells{i,severe_count} =   tau_mean_VODCA_subset_pre ; 
 %   tau_mean_VODCA_post_tau_cells{i,severe_count} =  tau_mean_VODCA_subset_post ;  
   
    % tau_mean VODCA
  tau_mean_VODCA_subset_post=  VODCA_interpsm_array( ...
         DNBR_mean_previous_f_array > bin_NBR_s &  DNBR_mean_previous_f_array < bin_NBR_e         & dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold & npixelf_previous_f_array > 300   ,:) ;     
   tau_mean_VODCA_subset_post(:,sum(~isnan(tau_mean_VODCA_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 tau_mean_VODCA_subset_pre=  VODCA_interpsm_array( ...
         DNBR_mean_previous_f_array > bin_NBR_s &  DNBR_mean_previous_f_array < bin_NBR_e         & -dist_DD_before_next_f_array > 0-i*day_threshold & -dist_DD_before_next_f_array < 0-(i-1)*day_threshold & npixelf_previous_f_array > 300   ,:) ;     
   tau_mean_VODCA_subset_pre(:,sum(~isnan(tau_mean_VODCA_subset_pre),1,'omitnan') < threshold) = NaN ; 

   tau_mean_VODCA_pre_NBR_cells{i,severe_count} =   tau_mean_VODCA_subset_pre ; 
   tau_mean_VODCA_post_NBR_cells{i,severe_count} =  tau_mean_VODCA_subset_post ;  
   
   
   

 
  % tau C mean 
 tau_C_mean_subset_post=  DD_tau_As_Ds_intersm_mean_array( ...
         D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   tau_C_mean_subset_post(:,sum(~isnan(tau_C_mean_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 tau_C_mean_subset_pre=  DD_tau_As_Ds_intersm_mean_array( ...
          D_tau_DD_array > bin_tau_s &  D_tau_DD_array < bin_tau_e           & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   tau_C_mean_subset_pre(:,sum(~isnan(tau_C_mean_subset_pre),1,'omitnan') < threshold) = NaN ; 

  tau_C_mean_pre_tau_cells{i,severe_count} =   tau_C_mean_subset_pre ; 
  tau_C_mean_post_tau_cells{i,severe_count} =  tau_C_mean_subset_post ;  
  
   % tau C mean 
 tau_C_mean_subset_post=  DD_tau_As_Ds_intersm_mean_array( ...
         D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e         & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ;     
   tau_C_mean_subset_post(:,sum(~isnan(tau_C_mean_subset_post),1,'omitnan') < threshold) = NaN ; 
  
 tau_C_mean_subset_pre=  DD_tau_As_Ds_intersm_mean_array( ...
          D_NBR_DD_array > bin_NBR_s &  D_NBR_DD_array < bin_NBR_e          & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ;     
   tau_C_mean_subset_pre(:,sum(~isnan(tau_C_mean_subset_pre),1,'omitnan') < threshold) = NaN ; 

  tau_C_mean_pre_NBR_cells{i,severe_count} =   tau_C_mean_subset_pre ; 
  tau_C_mean_post_NBR_cells{i,severe_count} =  tau_C_mean_subset_post ;       
   
 end 



end



 
% do binning in 2 D for mean difference .. use same procedure as maps
% maintain same datastructure 

%indices
pre_cells = [12, 24, 36, 48] ; 
% bins for SM and tau
tauinterp = linspace(0,1.2,21) ; 
tauinterp = tauinterp ./ 0.11  ; 
sminterp = linspace( 0,0.60,21 ); 
sminterp_60 = linspace( 0,0.60,60 ); 

tauinterp_C = linspace(0,1.2,21) ; 
tauinterp_C = tauinterp_C ./ 0.2046  ; 




SM_3D_pre =  NaN(20,20,4000,7)  ; 
SM_3D_post =  NaN(20,20,4000,7)  ; 
SM_smooth0_3D_pre =  NaN(20,20,4000,7)  ; 
SM_smooth0_3D_post =  NaN(20,20,4000,7)  ; 
SM_smooth365_3D_pre =  NaN(20,20,4000,7)  ; 
SM_smooth365_3D_post =  NaN(20,20,4000,7)  ; 
SM_ESACCI_3D_pre =  NaN(20,20,4000,7)  ; 
SM_ESACCI_3D_post =  NaN(20,20,4000,7)  ; 
tau_3D_pre  =  NaN(20,20,4000,7)  ; 
tau_3D_post =  NaN(20,20,4000,7)  ;
tau_smooth0_3D_pre  =  NaN(20,20,4000,7)  ; 
tau_smooth0_3D_post =  NaN(20,20,4000,7)  ;
tau_smooth365_3D_pre  =  NaN(20,20,4000,7)  ; 
tau_smooth365_3D_post =  NaN(20,20,4000,7)  ;
tau_VODCA_3D_pre  =  NaN(20,20,4000,7)  ; 
tau_VODCA_3D_pos =  NaN(20,20,4000,7)  ;
tau_C_3D_pre  =  NaN(20,20,4000,7)  ; 
tau_C_3D_post =  NaN(20,20,4000,7)  ;
dVPD_3D_pre =  NaN(20,20,4000,7)  ;
dVPD_3D_post =  NaN(20,20,4000,7)  ;
VPD_3D_pre =  NaN(20,20,4000,7)  ;
VPD_3D_post =  NaN(20,20,4000,7)  ;
dERAVPD_3D_pre =  NaN(20,20,4000,7)  ;
dERAVPD_3D_post =  NaN(20,20,4000,7)  ;
ERAVPD_3D_pre =  NaN(20,20,4000,7)  ;
ERAVPD_3D_post =  NaN(20,20,4000,7)  ;
DVWC_3D_pre =  NaN(20,20,4000,7)  ;
DVWC_3D_post =  NaN(20,20,4000,7)  ;

SM_3D_NBR_pre =  NaN(20,20,4000,7)  ; 
SM_3D_NBR_post =  NaN(20,20,4000,7)  ; 
SM_smooth0_3D_NBR_pre =  NaN(20,20,4000,7)  ; 
SM_smooth0_3D_NBR_post =  NaN(20,20,4000,7)  ;
SM_smooth365_3D_NBR_pre =  NaN(20,20,4000,7)  ; 
SM_smooth365_3D_NBR_post =  NaN(20,20,4000,7)  ;

SM_ESACCI_3D_NBR_pre =  NaN(20,20,4000,7)  ; 
SM_ESACCI_3D_NBR_post =  NaN(20,20,4000,7)  ; 

tau_3D_NBR_pre  =  NaN(20,20,4000,7)  ; 
tau_3D_NBR_post =  NaN(20,20,4000,7)  ; 
tau_smooth0_3D_NBR_pre  =  NaN(20,20,4000,7)  ; 
tau_smooth0_3D_NBR_post =  NaN(20,20,4000,7)  ; 
tau_smooth365_3D_NBR_pre  =  NaN(20,20,4000,7)  ; 
tau_smooth365_3D_NBR_post =  NaN(20,20,4000,7)  ; 

tau_VODCA_3D_NBR_pre  =  NaN(20,20,4000,7)  ; 
tau_VODCA_3D_NBR_post =  NaN(20,20,4000,7)  ; 

tau_C_3D_NBR_pre  =  NaN(20,20,4000,7)  ; 
tau_C_3D_NBR_post =  NaN(20,20,4000,7)  ; 

dVPD_3D_NBR_pre =  NaN(20,20,4000,7)  ;
dVPD_3D_NBR_post =  NaN(20,20,4000,7)  ;
VPD_3D_NBR_pre =  NaN(20,20,4000,7)  ;
VPD_3D_NBR_post =  NaN(20,20,4000,7)  ;

dERAVPD_3D_NBR_pre =  NaN(20,20,4000,7)  ;
dERAVPD_3D_NBR_post =  NaN(20,20,4000,7)  ;
ERAVPD_3D_NBR_pre =  NaN(20,20,4000,7)  ;
ERAVPD_3D_NBR_post =  NaN(20,20,4000,7)  ;

DVWC_3D_NBR_pre =  NaN(20,20,4000,7)  ;
DVWC_3D_NBR_post =  NaN(20,20,4000,7)  ;
dVWC_dSM_3D_NBR_post =  NaN(20,20,4000,7)  ;
dVWC_dSM_3D_NBR_pre=  NaN(20,20,4000,7)  ;


for severe_count = 1:length(severity_bins_tau)-1
   
    % dSM_dt_pre_dummy = dSM_dt_subset_pre_tau_cells{pre_cells(1),severe_count}  ; 
   dSM_dt_pre_dummy =  vertcat(dSM_dt_subset_pre_tau_cells{pre_cells(1),severe_count},...
       dSM_dt_subset_pre_tau_cells{pre_cells(2),severe_count},...
       dSM_dt_subset_pre_tau_cells{pre_cells(3),severe_count},...
       dSM_dt_subset_pre_tau_cells{pre_cells(4),severe_count}) ; 

   dSM_dt_post_dummy =  dSM_dt_subset_post_tau_cells{1,severe_count}  ;
   dSM_dt_smooth0_pre_dummy =  dSM_dt_smooth0_subset_pre_tau_cells{pre_cells(1),severe_count}  ; 
   dSM_dt_smooth0_post_dummy =  dSM_dt_smooth0_subset_post_tau_cells{1,severe_count}  ;
   dSM_dt_smooth365_pre_dummy =  dSM_dt_smooth365_subset_pre_tau_cells{pre_cells(1),severe_count}  ; 
   dSM_dt_smooth365_post_dummy =  dSM_dt_smooth365_subset_post_tau_cells{1,severe_count}  ;


   % we have no tau severity for esa cci
   % dSM_dt_ESACCI_pre_dummy =  dSM_dt_ESACCI_subset_pre_tau_cells{pre_cells(1),severe_count}  ; 
   % dSM_dt_ESACCI_post_dummy =  dSM_dt_ESACCI_subset_post_tau_cells{1,severe_count}  ; 

   % dtau_dt_pre_dummy =  dtau_dt_subset_pre_tau_cells{pre_cells(1),severe_count}  ; 
   dtau_dt_pre_dummy =  vertcat(dtau_dt_subset_pre_tau_cells{pre_cells(1),severe_count},...
       dtau_dt_subset_pre_tau_cells{pre_cells(2),severe_count},...
       dtau_dt_subset_pre_tau_cells{pre_cells(3),severe_count},...
       dtau_dt_subset_pre_tau_cells{pre_cells(4),severe_count}) ; 


   dtau_dt_post_dummy =  dtau_dt_subset_post_tau_cells{1,severe_count}  ;  

   dtau_dt_smooth0_pre_dummy =  dtau_dt_smooth0_subset_pre_tau_cells{pre_cells(1),severe_count}  ; 
   dtau_dt_smooth0_post_dummy =  dtau_dt_smooth0_subset_post_tau_cells{1,severe_count}  ;  
   dtau_dt_smooth365_pre_dummy =  dtau_dt_smooth365_subset_pre_tau_cells{pre_cells(1),severe_count}  ; 
   dtau_dt_smooth365_post_dummy =  dtau_dt_smooth365_subset_post_tau_cells{1,severe_count}  ;

   % dtau_C_dt_pre_dummy =  dtau_C_dt_subset_pre_tau_cells{pre_cells(1),severe_count}  ; 
   dtau_C_dt_pre_dummy =  vertcat(dtau_C_dt_subset_pre_tau_cells{pre_cells(1),severe_count},...
       dtau_C_dt_subset_pre_tau_cells{pre_cells(2),severe_count},...
       dtau_C_dt_subset_pre_tau_cells{pre_cells(3),severe_count},...
       dtau_C_dt_subset_pre_tau_cells{pre_cells(4),severe_count}) ; 

   dtau_C_dt_post_dummy =  dtau_C_dt_subset_post_tau_cells{1,severe_count}  ;  
   
   dVPD_dt_pre_dummy =  dVPD_dt_subset_pre_tau_cells{pre_cells(1),severe_count}  ; 
   dVPD_dt_post_dummy =  dVPD_dt_subset_post_tau_cells{1,severe_count}  ;   
  
   % VPD_pre_dummy =  VPD_subset_pre_tau_cells{pre_cells(1),severe_count}  ; 
   VPD_pre_dummy =  vertcat(VPD_subset_pre_tau_cells{pre_cells(1),severe_count},...
       VPD_subset_pre_tau_cells{pre_cells(2),severe_count},...
       VPD_subset_pre_tau_cells{pre_cells(3),severe_count},...
       VPD_subset_pre_tau_cells{pre_cells(4),severe_count}) ; 


   VPD_post_dummy = VPD_subset_post_tau_cells{1,severe_count}  ;   

   dERAVPD_dt_pre_dummy =  dERAVPD_dt_subset_pre_tau_cells{pre_cells(1),severe_count}  ; 
   dERAVPD_dt_post_dummy =  dERAVPD_dt_subset_post_tau_cells{1,severe_count}  ;   
  
   % ERAVPD_pre_dummy =  ERAVPD_subset_pre_tau_cells{pre_cells(1),severe_count}  ;
   ERAVPD_pre_dummy =  vertcat(ERAVPD_subset_pre_tau_cells{pre_cells(1),severe_count},...
       ERAVPD_subset_pre_tau_cells{pre_cells(2),severe_count},...
       ERAVPD_subset_pre_tau_cells{pre_cells(3),severe_count},...
       ERAVPD_subset_pre_tau_cells{pre_cells(4),severe_count}) ; 


   ERAVPD_post_dummy = ERAVPD_subset_post_tau_cells{1,severe_count}  ; 
   
   % VWCdiurnal_pre_dummy =  VWCdiurnal_pre_tau_cells{pre_cells(1),severe_count}  ; 
   VWCdiurnal_pre_dummy =  vertcat(VWCdiurnal_pre_tau_cells{pre_cells(1),severe_count},...
       VWCdiurnal_pre_tau_cells{pre_cells(2),severe_count},...
       VWCdiurnal_pre_tau_cells{pre_cells(3),severe_count},...
       VWCdiurnal_pre_tau_cells{pre_cells(4),severe_count}) ; 

   VWCdiurnal_post_dummy =  VWCdiurnal_post_tau_cells{1,severe_count}  ; 
   
   % NBR
   % dSM_dt_pre_NBR_dummy =  dSM_dt_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   dSM_dt_pre_NBR_dummy =  vertcat(dSM_dt_subset_pre_NBR_cells{pre_cells(1),severe_count},...
       dSM_dt_subset_pre_NBR_cells{pre_cells(2),severe_count},...
       dSM_dt_subset_pre_NBR_cells{pre_cells(3),severe_count},...
       dSM_dt_subset_pre_NBR_cells{pre_cells(4),severe_count}) ; 


   dSM_dt_post_NBR_dummy =  dSM_dt_subset_post_NBR_cells{1,severe_count}  ;

   dSM_dt_smooth0_pre_NBR_dummy =  dSM_dt_smooth0_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   dSM_dt_smooth0_post_NBR_dummy =  dSM_dt_smooth0_subset_post_NBR_cells{1,severe_count}  ;

   dSM_dt_smooth365_pre_NBR_dummy =  dSM_dt_smooth365_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   dSM_dt_smooth365_post_NBR_dummy =  dSM_dt_smooth365_subset_post_NBR_cells{1,severe_count}  ;


   % dSM_dt_ESACCI_pre_NBR_dummy =  dSM_dt_ESACCI_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   dSM_dt_ESACCI_pre_NBR_dummy =  vertcat(dSM_dt_ESACCI_subset_pre_NBR_cells{pre_cells(1),severe_count},...
       dSM_dt_ESACCI_subset_pre_NBR_cells{pre_cells(2),severe_count},...
       dSM_dt_ESACCI_subset_pre_NBR_cells{pre_cells(3),severe_count},...
       dSM_dt_ESACCI_subset_pre_NBR_cells{pre_cells(4),severe_count}) ; 

   dSM_dt_ESACCI_post_NBR_dummy =  dSM_dt_ESACCI_subset_post_NBR_cells{1,severe_count}  ;
     
   % dtau_dt_pre_NBR_dummy =  dtau_dt_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   dtau_dt_pre_NBR_dummy =  vertcat(dtau_dt_subset_pre_NBR_cells{pre_cells(1),severe_count},...
       dtau_dt_subset_pre_NBR_cells{pre_cells(2),severe_count},...
       dtau_dt_subset_pre_NBR_cells{pre_cells(3),severe_count},...
       dtau_dt_subset_pre_NBR_cells{pre_cells(4),severe_count}) ; 

   dtau_dt_post_NBR_dummy =  dtau_dt_subset_post_NBR_cells{1,severe_count}  ; 

   dtau_dt_smooth0_pre_NBR_dummy =  dtau_dt_smooth0_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   dtau_dt_smooth0_post_NBR_dummy =  dtau_dt_smooth0_subset_post_NBR_cells{1,severe_count}  ;  

   dtau_dt_smooth365_pre_NBR_dummy =  dtau_dt_smooth365_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   dtau_dt_smooth365_post_NBR_dummy =  dtau_dt_smooth365_subset_post_NBR_cells{1,severe_count}  ;     
   
   % dtau_C_dt_pre_NBR_dummy =  dtau_C_dt_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
      dtau_C_dt_pre_NBR_dummy =  vertcat(dtau_C_dt_subset_pre_NBR_cells{pre_cells(1),severe_count},...
       dtau_C_dt_subset_pre_NBR_cells{pre_cells(2),severe_count},...
       dtau_C_dt_subset_pre_NBR_cells{pre_cells(3),severe_count},...
       dtau_C_dt_subset_pre_NBR_cells{pre_cells(4),severe_count}) ; 

   dtau_C_dt_post_NBR_dummy =  dtau_C_dt_subset_post_NBR_cells{1,severe_count}  ;  
   
   dVPD_dt_pre_NBR_dummy =  dVPD_dt_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   dVPD_dt_post_NBR_dummy =  dVPD_dt_subset_post_NBR_cells{1,severe_count}  ;   
   
   % VPD_pre_NBR_dummy =  VPD_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   VPD_pre_NBR_dummy =  vertcat(VPD_subset_pre_NBR_cells{pre_cells(1),severe_count},...
       VPD_subset_pre_NBR_cells{pre_cells(2),severe_count},...
       VPD_subset_pre_NBR_cells{pre_cells(3),severe_count},...
       VPD_subset_pre_NBR_cells{pre_cells(4),severe_count}) ; 

   VPD_post_NBR_dummy = VPD_subset_post_NBR_cells{1,severe_count}  ;  

   dERAVPD_dt_pre_NBR_dummy =  dERAVPD_dt_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   dERAVPD_dt_post_NBR_dummy =  dERAVPD_dt_subset_post_NBR_cells{1,severe_count}  ;   
   
   % ERAVPD_pre_NBR_dummy =  ERAVPD_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   ERAVPD_pre_NBR_dummy =  vertcat(ERAVPD_subset_pre_NBR_cells{pre_cells(1),severe_count},...
       ERAVPD_subset_pre_NBR_cells{pre_cells(2),severe_count},...
       ERAVPD_subset_pre_NBR_cells{pre_cells(3),severe_count},...
       ERAVPD_subset_pre_NBR_cells{pre_cells(4),severe_count}) ; 


   ERAVPD_post_NBR_dummy = ERAVPD_subset_post_NBR_cells{1,severe_count}  ; 
   
   % VWCdiurnal_pre_NBR_dummy =  VWCdiurnal_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   VWCdiurnal_pre_NBR_dummy =  vertcat(VWCdiurnal_pre_NBR_cells{pre_cells(1),severe_count},...
       VWCdiurnal_pre_NBR_cells{pre_cells(2),severe_count},...
       VWCdiurnal_pre_NBR_cells{pre_cells(3),severe_count},...
       VWCdiurnal_pre_NBR_cells{pre_cells(4),severe_count}) ; 

   VWCdiurnal_post_NBR_dummy =  VWCdiurnal_post_NBR_cells{1,severe_count}  ;    

    % dVWC_dSM_dt_pre_NBR_dummy =  (dtau_dt_subset_pre_NBR_cells{pre_cells(1),severe_count}  ./ 0.11) ./ dSM_dt_subset_pre_NBR_cells{pre_cells(1),severe_count}  ; 
     dVWC_dSM_dt_pre_NBR_dummy =  vertcat((dtau_dt_subset_pre_NBR_cells{pre_cells(1),severe_count}  ./ 0.11) ./ dSM_dt_subset_pre_NBR_cells{pre_cells(1),severe_count},...
       (dtau_dt_subset_pre_NBR_cells{pre_cells(2),severe_count}  ./ 0.11) ./ dSM_dt_subset_pre_NBR_cells{pre_cells(2),severe_count},...
       (dtau_dt_subset_pre_NBR_cells{pre_cells(3),severe_count}  ./ 0.11) ./ dSM_dt_subset_pre_NBR_cells{pre_cells(3),severe_count},...
       (dtau_dt_subset_pre_NBR_cells{pre_cells(4),severe_count}  ./ 0.11) ./ dSM_dt_subset_pre_NBR_cells{pre_cells(4),severe_count}) ;  
   
   
   dVWC_dSM_dt_post_NBR_dummy = (dtau_dt_subset_post_NBR_cells{1,severe_count} ./ 0.11) ./ dSM_dt_subset_post_NBR_cells{1,severe_count}  ;
   
 
   
    % tau C and L conditions see if we need both for binning. could do both
    % from L-band
   tau_C_mean_pre_dummy =  tau_C_mean_pre_tau_cells{pre_cells(1),severe_count}  ; 
   tau_C_mean_post_dummy =  tau_C_mean_post_tau_cells{1,severe_count}  ; 
   tau_C_mean_pre_dummy = tau_C_mean_pre_dummy ./0.2046 ;
   tau_C_mean_post_dummy = tau_C_mean_post_dummy ./0.2046 ;
   
   tau_mean_pre_dummy =  tau_mean_pre_tau_cells{pre_cells(1),severe_count}  ; 
   tau_mean_post_dummy =  tau_mean_post_tau_cells{1,severe_count}  ;    
   tau_mean_pre_dummy = tau_mean_pre_dummy /0.11 ; 
   tau_mean_post_dummy = tau_mean_post_dummy /0.11 ; 

   % no tau severity for VODCA
   % tau_VODCA_mean_pre_dummy =  tau_VODCA_mean_pre_tau_cells{pre_cells(1),severe_count}  ; 
   % tau_VODCA_mean_post_dummy =  tau_VODCA_mean_post_tau_cells{1,severe_count}  ; 
   % tau_VODCA_mean_pre_dummy = tau_VODCA_mean_pre_dummy ./0.2046 ;
   % tau_VODCA_mean_post_dummy = tau_VODCA_mean_post_dummy ./0.2046 ;

   
   % NBR
   % tau_C_mean_pre_NBR_dummy =  tau_C_mean_pre_NBR_cells{pre_cells(1),severe_count}  ; 
   tau_C_mean_pre_NBR_dummy =  vertcat(tau_C_mean_pre_NBR_cells{pre_cells(1),severe_count},...
       tau_C_mean_pre_NBR_cells{pre_cells(2),severe_count},...
       tau_C_mean_pre_NBR_cells{pre_cells(3),severe_count},...
       tau_C_mean_pre_NBR_cells{pre_cells(4),severe_count}) ; 
   
   tau_C_mean_post_NBR_dummy =  tau_C_mean_post_NBR_cells{1,severe_count}  ; 
   tau_C_mean_pre_NBR_dummy = tau_C_mean_pre_NBR_dummy ./0.2046 ;
   tau_C_mean_post_NBR_dummy = tau_C_mean_post_NBR_dummy ./0.2046 ;
   
   % tau_mean_pre_NBR_dummy =  tau_mean_pre_NBR_cells{pre_cells(1),severe_count}  ; 
      tau_mean_pre_NBR_dummy =  vertcat(tau_mean_pre_NBR_cells{pre_cells(1),severe_count},...
       tau_mean_pre_NBR_cells{pre_cells(2),severe_count},...
       tau_mean_pre_NBR_cells{pre_cells(3),severe_count},...
       tau_mean_pre_NBR_cells{pre_cells(4),severe_count}) ; 

   tau_mean_post_NBR_dummy =  tau_mean_post_NBR_cells{1,severe_count}  ;    
   tau_mean_pre_NBR_dummy = tau_mean_pre_NBR_dummy /0.11 ; 
   tau_mean_post_NBR_dummy = tau_mean_post_NBR_dummy /0.11 ;   
   
   % tau_VODCA_mean_pre_NBR_dummy =  tau_mean_VODCA_pre_NBR_cells{pre_cells(1),severe_count}  ; 
      tau_VODCA_mean_pre_NBR_dummy =  vertcat(tau_mean_VODCA_pre_NBR_cells{pre_cells(1),severe_count},...
       tau_mean_VODCA_pre_NBR_cells{pre_cells(2),severe_count},...
       tau_mean_VODCA_pre_NBR_cells{pre_cells(3),severe_count},...
       tau_mean_VODCA_pre_NBR_cells{pre_cells(4),severe_count}) ; 
   
   tau_VODCA_mean_post_NBR_dummy =  tau_mean_VODCA_post_NBR_cells{1,severe_count}  ; 
   tau_VODCA_mean_pre_NBR_dummy = tau_VODCA_mean_pre_NBR_dummy ./0.2046 ;
   tau_VODCA_mean_post_NBR_dummy = tau_VODCA_mean_post_NBR_dummy ./0.2046 ;   
   
   
   
   
   % start binning into SM and VWC conditions
     for sm = 1:length(sminterp)-1
       
         cur_sm = sminterp(sm:sm+1) ; 
        sminterp_true = sminterp_60 > cur_sm(1) & sminterp_60 < cur_sm(2)  ;
        
    for tau = 1:length(tauinterp)-1        
    cur_tau = tauinterp(tau:tau+1) ;   
    cur_tau_C = tauinterp_C(tau:tau+1) ;   

        % dSM/dt
    pre_dummy_cut = dSM_dt_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = dSM_dt_post_dummy(:,sminterp_true) ;       
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau(2)) ;     
    SM_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    SM_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  
        % dSM/dt smooth 0
    pre_dummy_cut = dSM_dt_smooth0_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = dSM_dt_smooth0_post_dummy(:,sminterp_true) ;       
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau(2)) ;     
    SM_smooth0_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    SM_smooth0_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  
        % dSM/dt smooth 365
    pre_dummy_cut = dSM_dt_smooth365_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = dSM_dt_smooth365_post_dummy(:,sminterp_true) ;       
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau(2)) ;     
    SM_smooth365_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    SM_smooth365_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  


        % dSM/dt ESACCI
    % pre_dummy_cut = dSM_dt_ESACCI_pre_dummy(:,sminterp_true) ;
    % post_dummy_cut = dSM_dt_ESACCI_post_dummy(:,sminterp_true) ;       
    % dummy_pre =  pre_dummy_cut(tau_VODCA_mean_pre_dummy(:,sm) > cur_tau(1) & tau_VODCA_mean_pre_dummy(:,sm) < cur_tau(2)) ; 
    % dummy_post = post_dummy_cut(tau_VODCA_mean_post_dummy(:,sm) > cur_tau(1) & tau_VODCA_mean_post_dummy(:,sm) < cur_tau(2)) ;     
    % SM_ESACCI_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    % SM_ESACCI_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  

    % dtau/dt 
    pre_dummy_cut = dtau_dt_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = dtau_dt_post_dummy(:,sminterp_true) ;   
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau(2)) ;       
    tau_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    tau_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  
    % dtau/dt smooth0 
    pre_dummy_cut = dtau_dt_smooth0_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = dtau_dt_smooth0_post_dummy(:,sminterp_true) ;   
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau(2)) ;       
    tau_smooth0_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    tau_smooth0_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  
    % dtau/dt smooth365 
    pre_dummy_cut = dtau_dt_smooth365_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = dtau_dt_smooth365_post_dummy(:,sminterp_true) ;   
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau(2)) ;       
    tau_smooth365_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    tau_smooth365_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  

    % dtau_C/dt 
    pre_dummy_cut = dtau_C_dt_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = dtau_C_dt_post_dummy(:,sminterp_true) ;   
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau_C(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau_C(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau_C(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau_C(2)) ;       
    tau_C_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    tau_C_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  
    % dVPD/dt
    pre_dummy_cut = dVPD_dt_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = dVPD_dt_post_dummy(:,sminterp_true) ;        
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau(2)) ;       
    dVPD_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    dVPD_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;   
    % VPD
    pre_dummy_cut = VPD_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = VPD_post_dummy(:,sminterp_true) ;        
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau(2)) ;       
    VPD_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    VPD_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;      
   % dERAVPD/dt
    pre_dummy_cut = dERAVPD_dt_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = dERAVPD_dt_post_dummy(:,sminterp_true) ;        
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau(2)) ;       
    dERAVPD_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    dERAVPD_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;   
    % ERAVPD
    pre_dummy_cut =  ERAVPD_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = ERAVPD_post_dummy(:,sminterp_true) ;        
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau(2)) ;       
    ERAVPD_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    ERAVPD_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;     
    % VWC diurnal
    pre_dummy_cut = VWCdiurnal_pre_dummy(:,sminterp_true) ;
    post_dummy_cut = VWCdiurnal_post_dummy(:,sminterp_true) ;      
    dummy_pre =  pre_dummy_cut(tau_mean_pre_dummy(:,sminterp_true) > cur_tau_C(1) & tau_mean_pre_dummy(:,sminterp_true) < cur_tau_C(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_dummy(:,sminterp_true) > cur_tau_C(1) & tau_mean_post_dummy(:,sminterp_true) < cur_tau_C(2)) ;       
    DVWC_3D_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    DVWC_3D_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;    
    
    
    
    
    % NBR
    % dSM/dt
    % MJB double chekc .. shoudlnt it be all sminterp  in col index .. for
    % sm .. maybe made mistake previously
    % dmSM/dt
    pre_dummy_cut = dSM_dt_pre_NBR_dummy(:,sminterp_true) ;
    post_dummy_cut = dSM_dt_post_NBR_dummy(:,sminterp_true) ;       
    dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau(2)) ;     
    SM_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    SM_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  
    % % dmSM/dt smooth0
    % pre_dummy_cut = dSM_dt_smooth0_pre_NBR_dummy(:,sminterp_true) ;
    % post_dummy_cut = dSM_dt_smooth0_post_NBR_dummy(:,sminterp_true) ;       
    % dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau(2)) ; 
    % dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau(2)) ;     
    % SM_smooth0_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    % SM_smooth0_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ; 
    % % dmSM/dt smooth365
    % pre_dummy_cut = dSM_dt_smooth365_pre_NBR_dummy(:,sminterp_true) ;
    % post_dummy_cut = dSM_dt_smooth365_post_NBR_dummy(:,sminterp_true) ;       
    % dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau(2)) ; 
    % dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau(2)) ;     
    % SM_smooth365_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    % SM_smooth365_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ; 


     % dSM/dt ESACCI
    pre_dummy_cut =  dSM_dt_ESACCI_pre_NBR_dummy(:,sminterp_true) ;
    post_dummy_cut = dSM_dt_ESACCI_post_NBR_dummy(:,sminterp_true) ;       
    dummy_pre =  pre_dummy_cut(tau_VODCA_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau_C(1) & tau_VODCA_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau_C(2)) ; 
    dummy_post = post_dummy_cut(tau_VODCA_mean_post_NBR_dummy(:,sminterp_true) > cur_tau_C(1) & tau_VODCA_mean_post_NBR_dummy(:,sminterp_true) < cur_tau_C(2)) ;     
    SM_ESACCI_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    SM_ESACCI_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  
    
    % dtau/dt 
    pre_dummy_cut = dtau_dt_pre_NBR_dummy(:,sminterp_true) ;
    post_dummy_cut = dtau_dt_post_NBR_dummy(:,sminterp_true) ;       
    dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau(2)) ;     
    tau_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    tau_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ; 
    % dtau/dt smooth0
    % pre_dummy_cut = dtau_dt_smooth0_pre_NBR_dummy(:,sminterp_true) ;
    % post_dummy_cut = dtau_dt_smooth0_post_NBR_dummy(:,sminterp_true) ;       
    % dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau(2)) ; 
    % dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau(2)) ;     
    % tau_smooth0_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    % tau_smooth0_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ; 
    % % dtau/dt smooth365
    % pre_dummy_cut = dtau_dt_smooth365_pre_NBR_dummy(:,sminterp_true) ;
    % post_dummy_cut = dtau_dt_smooth365_post_NBR_dummy(:,sminterp_true) ;       
    % dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau(2)) ; 
    % dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau(2)) ;     
    % tau_smooth365_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    % tau_smooth365_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ; 

    % dtau_C/dt 
    pre_dummy_cut = dtau_C_dt_pre_NBR_dummy(:,sminterp_true) ;
    post_dummy_cut = dtau_C_dt_post_NBR_dummy(:,sminterp_true) ;       
    dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau_C(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau_C(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau_C(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau_C(2)) ;     
    tau_C_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    tau_C_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ; 
    % dVPD/dt
    % pre_dummy_cut = dVPD_dt_pre_NBR_dummy(:,sminterp_true) ;
    % post_dummy_cut = dVPD_dt_post_NBR_dummy(:,sminterp_true) ;       
    % dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau(2)) ; 
    % dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau(2)) ;     
    % dVPD_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    % dVPD_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  
     % VPD
    pre_dummy_cut = VPD_pre_NBR_dummy(:,sminterp_true) ;
    post_dummy_cut = VPD_post_NBR_dummy(:,sminterp_true) ;       
    dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau(2)) ;     
    VPD_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    VPD_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ; 
    % dERAVPD/dt
    % pre_dummy_cut = dERAVPD_dt_pre_NBR_dummy(:,sminterp_true) ;
    % post_dummy_cut = dERAVPD_dt_post_NBR_dummy(:,sminterp_true) ;       
    % dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau(2)) ; 
    % dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau(2)) ;     
    % dERAVPD_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    % dERAVPD_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  
     % ERAVPD
    pre_dummy_cut = ERAVPD_pre_NBR_dummy(:,sminterp_true) ;
    post_dummy_cut = ERAVPD_post_NBR_dummy(:,sminterp_true) ;       
    dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau(2)) ;     
    ERAVPD_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    ERAVPD_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ; 
    % VWC diurnal
    pre_dummy_cut = VWCdiurnal_pre_NBR_dummy(:,sminterp_true) ;
    post_dummy_cut = VWCdiurnal_post_NBR_dummy(:,sminterp_true) ;       
    dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau_C(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau_C(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau_C(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau_C(2)) ;     
    DVWC_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    DVWC_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;      

    % dVWC/dSM
    pre_dummy_cut = dVWC_dSM_dt_pre_NBR_dummy(:,sminterp_true) ;
    post_dummy_cut = dVWC_dSM_dt_post_NBR_dummy(:,sminterp_true) ;       
    dummy_pre =  pre_dummy_cut(tau_mean_pre_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_pre_NBR_dummy(:,sminterp_true) < cur_tau(2)) ; 
    dummy_post = post_dummy_cut(tau_mean_post_NBR_dummy(:,sminterp_true) > cur_tau(1) & tau_mean_post_NBR_dummy(:,sminterp_true) < cur_tau(2)) ;     
    dVWC_dSM_3D_NBR_pre(sm,tau,1:length(dummy_pre),severe_count)   = dummy_pre ; 
    dVWC_dSM_3D_NBR_post(sm,tau,1:length(dummy_post),severe_count) = dummy_post ;  
    % 
    % 
    
    
    end
     end


severe_count
end



threshold_3D = 10 ; 


for severe_count = 1:length(severity_bins_tau)-1
    
% dSM/dt tau
mask_sample =  (sum(~isnan(SM_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_pre_dummy = SM_3D_pre(:,:,:,severe_count) ; 
SM_3D_pre_dummy(mask_sample) = NaN ; 
SM_3D_pre(:,:,:,severe_count) = SM_3D_pre_dummy ;
mask_sample =  (sum(~isnan(SM_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_post_dummy = SM_3D_post(:,:,:,severe_count) ; 
SM_3D_post_dummy(mask_sample) = NaN ; 
SM_3D_post(:,:,:,severe_count) = SM_3D_post_dummy  ;
% dSM/dt NBR
mask_sample =  (sum(~isnan(SM_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_pre_dummy = SM_3D_NBR_pre(:,:,:,severe_count) ; 
SM_3D_pre_dummy(mask_sample) = NaN ; 
SM_3D_NBR_pre(:,:,:,severe_count) = SM_3D_pre_dummy ;
mask_sample =  (sum(~isnan(SM_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_post_dummy = SM_3D_NBR_post(:,:,:,severe_count) ; 
SM_3D_post_dummy(mask_sample) = NaN ; 
SM_3D_NBR_post(:,:,:,severe_count) = SM_3D_post_dummy  ;


% dSM/dt smooth0 tau
mask_sample =  (sum(~isnan(SM_smooth0_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_pre_dummy = SM_smooth0_3D_pre(:,:,:,severe_count) ; 
SM_3D_pre_dummy(mask_sample) = NaN ; 
SM_smooth0_3D_pre(:,:,:,severe_count) = SM_3D_pre_dummy ;
mask_sample =  (sum(~isnan(SM_smooth0_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_post_dummy = SM_smooth0_3D_post(:,:,:,severe_count) ; 
SM_3D_post_dummy(mask_sample) = NaN ; 
SM_smooth0_3D_post(:,:,:,severe_count) = SM_3D_post_dummy  ;
% dSM/dt smooth0 NBR
mask_sample =  (sum(~isnan(SM_smooth0_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_pre_dummy = SM_smooth0_3D_NBR_pre(:,:,:,severe_count) ; 
SM_3D_pre_dummy(mask_sample) = NaN ; 
SM_smooth0_3D_NBR_pre(:,:,:,severe_count) = SM_3D_pre_dummy ;
mask_sample =  (sum(~isnan(SM_smooth0_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_post_dummy = SM_smooth0_3D_NBR_post(:,:,:,severe_count) ; 
SM_3D_post_dummy(mask_sample) = NaN ; 
SM_smooth0_3D_NBR_post(:,:,:,severe_count) = SM_3D_post_dummy  ;


% dSM/dt smooth365 tau
mask_sample =  (sum(~isnan(SM_smooth365_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_pre_dummy = SM_smooth365_3D_pre(:,:,:,severe_count) ; 
SM_3D_pre_dummy(mask_sample) = NaN ; 
SM_smooth365_3D_pre(:,:,:,severe_count) = SM_3D_pre_dummy ;
mask_sample =  (sum(~isnan(SM_smooth365_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_post_dummy = SM_smooth365_3D_post(:,:,:,severe_count) ; 
SM_3D_post_dummy(mask_sample) = NaN ; 
SM_smooth365_3D_post(:,:,:,severe_count) = SM_3D_post_dummy  ;
% dSM/dt smooth365 NBR
mask_sample =  (sum(~isnan(SM_smooth365_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_pre_dummy = SM_smooth365_3D_NBR_pre(:,:,:,severe_count) ; 
SM_3D_pre_dummy(mask_sample) = NaN ; 
SM_smooth365_3D_NBR_pre(:,:,:,severe_count) = SM_3D_pre_dummy ;
mask_sample =  (sum(~isnan(SM_smooth365_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_3D_post_dummy = SM_smooth365_3D_NBR_post(:,:,:,severe_count) ; 
SM_3D_post_dummy(mask_sample) = NaN ; 
SM_smooth365_3D_NBR_post(:,:,:,severe_count) = SM_3D_post_dummy  ;




% dSM/dt ESACCI
% mask_sample =  (sum(~isnan(SM_ESACCI_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
% mask_sample= repmat(mask_sample,[1,1,4000]) ; 
% SM_ESACCI_3D_pre_dummy = SM_3D_pre(:,:,:,severe_count) ; 
% SM_ESACCI_3D_pre_dummy(mask_sample) = NaN ; 
% SM_ESACCI_3D_pre(:,:,:,severe_count) = SM_ESACCI_3D_pre_dummy ;
% mask_sample =  (sum(~isnan(SM_ESACCI_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
% mask_sample= repmat(mask_sample,[1,1,4000]) ; 
% SM_ESACCI_3D_post_dummy = SM_ESACCI_3D_post(:,:,:,severe_count) ; 
% SM_ESACCI_3D_post_dummy(mask_sample) = NaN ; 
% SM_ESACCI_3D_post(:,:,:,severe_count) = SM_ESACCI_3D_post_dummy  ;

mask_sample =  (sum(~isnan(SM_ESACCI_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_ESACCI_3D_pre_dummy = SM_ESACCI_3D_NBR_pre(:,:,:,severe_count) ; 
SM_ESACCI_3D_pre_dummy(mask_sample) = NaN ; 
SM_ESACCI_3D_NBR_pre(:,:,:,severe_count) = SM_ESACCI_3D_pre_dummy ;

mask_sample =  (sum(~isnan(SM_ESACCI_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
SM_ESACCI_3D_post_dummy = SM_ESACCI_3D_NBR_post(:,:,:,severe_count) ; 
SM_ESACCI_3D_post_dummy(mask_sample) = NaN ; 
SM_ESACCI_3D_NBR_post(:,:,:,severe_count) = SM_ESACCI_3D_post_dummy  ;


% dtau/dt tau
mask_sample =  (sum(~isnan(tau_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_pre_dummy = tau_3D_pre(:,:,:,severe_count) ; 
tau_3D_pre_dummy(mask_sample) = NaN ; 
tau_3D_pre(:,:,:,severe_count) = tau_3D_pre_dummy ;
mask_sample =  (sum(~isnan(tau_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_post_dummy = tau_3D_post(:,:,:,severe_count) ; 
tau_3D_post_dummy(mask_sample) = NaN ; 
tau_3D_post(:,:,:,severe_count) = tau_3D_post_dummy  ;

% dtau/dt NBR
mask_sample =  (sum(~isnan(tau_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_pre_dummy = tau_3D_NBR_pre(:,:,:,severe_count) ; 
tau_3D_pre_dummy(mask_sample) = NaN ; 
tau_3D_NBR_pre(:,:,:,severe_count) = tau_3D_pre_dummy ;
mask_sample =  (sum(~isnan(tau_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_post_dummy = tau_3D_NBR_post(:,:,:,severe_count) ; 
tau_3D_post_dummy(mask_sample) = NaN ; 
tau_3D_NBR_post(:,:,:,severe_count) = tau_3D_post_dummy  ;


% dtau/dt smooth0 tau
mask_sample =  (sum(~isnan(tau_smooth0_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_pre_dummy = tau_smooth0_3D_pre(:,:,:,severe_count) ; 
tau_3D_pre_dummy(mask_sample) = NaN ; 
tau_smooth0_3D_pre(:,:,:,severe_count) = tau_3D_pre_dummy ;
mask_sample =  (sum(~isnan(tau_smooth0_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_post_dummy = tau_smooth0_3D_post(:,:,:,severe_count) ; 
tau_3D_post_dummy(mask_sample) = NaN ; 
tau_smooth0_3D_post(:,:,:,severe_count) = tau_3D_post_dummy  ;

% dtau/dt smooth0 NBR
mask_sample =  (sum(~isnan(tau_smooth0_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_pre_dummy = tau_smooth0_3D_NBR_pre(:,:,:,severe_count) ; 
tau_3D_pre_dummy(mask_sample) = NaN ; 
tau_smooth0_3D_NBR_pre(:,:,:,severe_count) = tau_3D_pre_dummy ;
mask_sample =  (sum(~isnan(tau_smooth0_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_post_dummy = tau_smooth0_3D_NBR_post(:,:,:,severe_count) ; 
tau_3D_post_dummy(mask_sample) = NaN ; 
tau_smooth0_3D_NBR_post(:,:,:,severe_count) = tau_3D_post_dummy  ;


% dtau/dt smooth365 tau
mask_sample =  (sum(~isnan(tau_smooth365_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_pre_dummy = tau_smooth365_3D_pre(:,:,:,severe_count) ; 
tau_3D_pre_dummy(mask_sample) = NaN ; 
tau_smooth365_3D_pre(:,:,:,severe_count) = tau_3D_pre_dummy ;
mask_sample =  (sum(~isnan(tau_smooth365_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_post_dummy = tau_smooth365_3D_post(:,:,:,severe_count) ; 
tau_3D_post_dummy(mask_sample) = NaN ; 
tau_smooth365_3D_post(:,:,:,severe_count) = tau_3D_post_dummy  ;

% dtau/dt smooth365 NBR
mask_sample =  (sum(~isnan(tau_smooth365_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_pre_dummy = tau_smooth365_3D_NBR_pre(:,:,:,severe_count) ; 
tau_3D_pre_dummy(mask_sample) = NaN ; 
tau_smooth365_3D_NBR_pre(:,:,:,severe_count) = tau_3D_pre_dummy ;
mask_sample =  (sum(~isnan(tau_smooth365_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_3D_post_dummy = tau_smooth365_3D_NBR_post(:,:,:,severe_count) ; 
tau_3D_post_dummy(mask_sample) = NaN ; 
tau_smooth365_3D_NBR_post(:,:,:,severe_count) = tau_3D_post_dummy  ;

% dtau_C/dt
mask_sample =  (sum(~isnan(tau_C_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_C_3D_pre_dummy = tau_C_3D_pre(:,:,:,severe_count) ; 
tau_C_3D_pre_dummy(mask_sample) = NaN ; 
tau_C_3D_pre(:,:,:,severe_count) = tau_C_3D_pre_dummy ;
mask_sample =  (sum(~isnan(tau_C_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_C_3D_post_dummy = tau_C_3D_post(:,:,:,severe_count) ; 
tau_C_3D_post_dummy(mask_sample) = NaN ; 
tau_C_3D_post(:,:,:,severe_count) = tau_C_3D_post_dummy  ;


mask_sample =  (sum(~isnan(tau_C_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_C_3D_pre_dummy = tau_C_3D_NBR_pre(:,:,:,severe_count) ; 
tau_C_3D_pre_dummy(mask_sample) = NaN ; 
tau_C_3D_NBR_pre(:,:,:,severe_count) = tau_C_3D_pre_dummy ;
mask_sample =  (sum(~isnan(tau_C_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
tau_C_3D_post_dummy = tau_C_3D_NBR_post(:,:,:,severe_count) ; 
tau_C_3D_post_dummy(mask_sample) = NaN ; 
tau_C_3D_NBR_post(:,:,:,severe_count) = tau_C_3D_post_dummy  ;




% VPD/dt
mask_sample =  (sum(~isnan(dVPD_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_pre_dummy = dVPD_3D_pre(:,:,:,severe_count) ; 
VPD_3D_pre_dummy(mask_sample) = NaN ; 
dVPD_3D_pre(:,:,:,severe_count) = VPD_3D_pre_dummy ;
mask_sample =  (sum(~isnan(dVPD_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_post_dummy = dVPD_3D_post(:,:,:,severe_count) ; 
VPD_3D_post_dummy(mask_sample) = NaN ; 
dVPD_3D_post(:,:,:,severe_count) = VPD_3D_post_dummy  ;


mask_sample =  (sum(~isnan(dVPD_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_pre_dummy = dVPD_3D_NBR_pre(:,:,:,severe_count) ; 
VPD_3D_pre_dummy(mask_sample) = NaN ; 
dVPD_3D_NBR_pre(:,:,:,severe_count) = VPD_3D_pre_dummy ;
mask_sample =  (sum(~isnan(dVPD_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_post_dummy = dVPD_3D_NBR_post(:,:,:,severe_count) ; 
VPD_3D_post_dummy(mask_sample) = NaN ; 
dVPD_3D_NBR_post(:,:,:,severe_count) = VPD_3D_post_dummy  ;


% VPD
mask_sample =  (sum(~isnan(VPD_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_pre_dummy = VPD_3D_pre(:,:,:,severe_count) ; 
VPD_3D_pre_dummy(mask_sample) = NaN ; 
VPD_3D_pre(:,:,:,severe_count) = VPD_3D_pre_dummy ;
mask_sample =  (sum(~isnan(VPD_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_post_dummy = VPD_3D_post(:,:,:,severe_count) ; 
VPD_3D_post_dummy(mask_sample) = NaN ; 
VPD_3D_post(:,:,:,severe_count) = VPD_3D_post_dummy  ;


mask_sample =  (sum(~isnan(VPD_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_pre_dummy = VPD_3D_NBR_pre(:,:,:,severe_count) ; 
VPD_3D_pre_dummy(mask_sample) = NaN ; 
VPD_3D_NBR_pre(:,:,:,severe_count) = VPD_3D_pre_dummy ;
mask_sample =  (sum(~isnan(VPD_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_post_dummy = VPD_3D_NBR_post(:,:,:,severe_count) ; 
VPD_3D_post_dummy(mask_sample) = NaN ; 
VPD_3D_NBR_post(:,:,:,severe_count) = VPD_3D_post_dummy  ;

% ERAVPD/dt
mask_sample =  (sum(~isnan(dERAVPD_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_pre_dummy = dERAVPD_3D_pre(:,:,:,severe_count) ; 
VPD_3D_pre_dummy(mask_sample) = NaN ; 
dERAVPD_3D_pre(:,:,:,severe_count) = VPD_3D_pre_dummy ;
mask_sample =  (sum(~isnan(dERAVPD_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_post_dummy = dERAVPD_3D_post(:,:,:,severe_count) ; 
VPD_3D_post_dummy(mask_sample) = NaN ; 
dERAVPD_3D_post(:,:,:,severe_count) = VPD_3D_post_dummy  ;


mask_sample =  (sum(~isnan(dERAVPD_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_pre_dummy = dERAVPD_3D_NBR_pre(:,:,:,severe_count) ; 
VPD_3D_pre_dummy(mask_sample) = NaN ; 
dERAVPD_3D_NBR_pre(:,:,:,severe_count) = VPD_3D_pre_dummy ;
mask_sample =  (sum(~isnan(dERAVPD_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_post_dummy = dERAVPD_3D_NBR_post(:,:,:,severe_count) ; 
VPD_3D_post_dummy(mask_sample) = NaN ; 
dERAVPD_3D_NBR_post(:,:,:,severe_count) = VPD_3D_post_dummy  ;

% ERAVPD
mask_sample =  (sum(~isnan(ERAVPD_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_pre_dummy = ERAVPD_3D_pre(:,:,:,severe_count) ; 
VPD_3D_pre_dummy(mask_sample) = NaN ; 
ERAVPD_3D_pre(:,:,:,severe_count) = VPD_3D_pre_dummy ;
mask_sample =  (sum(~isnan(ERAVPD_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_post_dummy = ERAVPD_3D_post(:,:,:,severe_count) ; 
VPD_3D_post_dummy(mask_sample) = NaN ; 
ERAVPD_3D_post(:,:,:,severe_count) = VPD_3D_post_dummy  ;


mask_sample =  (sum(~isnan(ERAVPD_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_pre_dummy = ERAVPD_3D_NBR_pre(:,:,:,severe_count) ; 
VPD_3D_pre_dummy(mask_sample) = NaN ; 
ERAVPD_3D_NBR_pre(:,:,:,severe_count) = VPD_3D_pre_dummy ;
mask_sample =  (sum(~isnan(ERAVPD_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
VPD_3D_post_dummy = ERAVPD_3D_NBR_post(:,:,:,severe_count) ; 
VPD_3D_post_dummy(mask_sample) = NaN ; 
ERAVPD_3D_NBR_post(:,:,:,severe_count) = VPD_3D_post_dummy  ;


% DVWC
mask_sample =  (sum(~isnan(DVWC_3D_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
DVWC_3D_pre_dummy = DVWC_3D_pre(:,:,:,severe_count) ; 
DVWC_3D_pre_dummy(mask_sample) = NaN ; 
DVWC_3D_pre(:,:,:,severe_count) = DVWC_3D_pre_dummy ;
mask_sample =  (sum(~isnan(DVWC_3D_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
DVWC_3D_post_dummy = DVWC_3D_post(:,:,:,severe_count) ; 
DVWC_3D_post_dummy(mask_sample) = NaN ; 
DVWC_3D_post(:,:,:,severe_count) = DVWC_3D_post_dummy  ;


mask_sample =  (sum(~isnan(DVWC_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
DVWC_3D_pre_dummy = DVWC_3D_NBR_pre(:,:,:,severe_count) ; 
DVWC_3D_pre_dummy(mask_sample) = NaN ; 
DVWC_3D_NBR_pre(:,:,:,severe_count) = DVWC_3D_pre_dummy ;
mask_sample =  (sum(~isnan(DVWC_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
DVWC_3D_post_dummy = DVWC_3D_NBR_post(:,:,:,severe_count) ; 
DVWC_3D_post_dummy(mask_sample) = NaN ; 
DVWC_3D_NBR_post(:,:,:,severe_count) = DVWC_3D_post_dummy  ;


% dVWC dSM
mask_sample =  (sum(~isnan(dVWC_dSM_3D_NBR_pre(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
dVWC_dSM_3D_pre_dummy = dVWC_dSM_3D_NBR_pre(:,:,:,severe_count) ; 
dVWC_dSM_3D_pre_dummy(mask_sample) = NaN ; 
dVWC_dSM_3D_NBR_pre(:,:,:,severe_count) = dVWC_dSM_3D_pre_dummy ;
mask_sample =  (sum(~isnan(dVWC_dSM_3D_NBR_post(:,:,:,severe_count)),3,'omitnan')  < threshold_3D)  ; 
mask_sample= repmat(mask_sample,[1,1,4000]) ; 
dVWC_dSM_3D_post_dummy = dVWC_dSM_3D_NBR_post(:,:,:,severe_count) ; 
dVWC_dSM_3D_post_dummy(mask_sample) = NaN ; 
dVWC_dSM_3D_NBR_post(:,:,:,severe_count) = dVWC_dSM_3D_post_dummy  ;




end


tau_3D_post = tau_3D_post   ./ 0.11 ; 
tau_3D_pre = tau_3D_pre ./ 0.11 ; 

tau_smooth0_3D_post = tau_smooth0_3D_post   ./ 0.11 ; 
tau_smooth0_3D_pre = tau_smooth0_3D_pre ./ 0.11 ; 

tau_smooth365_3D_post = tau_smooth365_3D_post   ./ 0.11 ; 
tau_smooth365_3D_pre = tau_smooth365_3D_pre ./ 0.11 ; 

tau_C_3D_post = tau_C_3D_post   ./ 0.2046 ; 
tau_C_3D_pre = tau_C_3D_pre ./ 0.2046 ; 
% tau_VODCA_3D_post = tau_VODCA_3D_post   ./ 0.2046 ; 
% tau_VODCA_3D_pre = tau_VODCA_3D_pre ./ 0.2046 ; 
DVWC_3D_post  = DVWC_3D_post ./ 0.2046 ; 
DVWC_3D_pre =  DVWC_3D_pre  ./ 0.2046 ; 

tau_3D_NBR_post = tau_3D_NBR_post   ./ 0.11 ; 
tau_3D_NBR_pre = tau_3D_NBR_pre ./ 0.11 ; 
tau_VODCA_3D_NBR_post = tau_3D_NBR_post   ./ 0.2046 ; 
tau_VODCA_3D_NBR_pre = tau_3D_NBR_pre ./ 0.2046 ; 
tau_C_3D_NBR_post = tau_C_3D_NBR_post   ./ 0.2046 ; 
tau_C_3D_NBR_pre = tau_C_3D_NBR_pre ./ 0.2046 ; 
DVWC_3D_NBR_post  = DVWC_3D_NBR_post ./ 0.2046 ; 
DVWC_3D_NBR_pre =  DVWC_3D_NBR_pre  ./ 0.2046 ; 



 

for severe_count = 1:length(severity_bins_tau)-1
    
 diff =  (median(SM_3D_post(:,:,:,severe_count),3,'omitnan')- median(SM_3D_pre(:,:,:,severe_count),3,'omitnan')) ;  
 boxplot_data1SM(:,severe_count) = diff(:);
   
 diff =  (median(SM_smooth0_3D_post(:,:,:,severe_count),3,'omitnan')- median(SM_smooth0_3D_pre(:,:,:,severe_count),3,'omitnan')) ;  
 boxplot_data1SM_smooth0(:,severe_count) = diff(:);

 diff =  (median(SM_smooth365_3D_post(:,:,:,severe_count),3,'omitnan')- median(SM_smooth365_3D_pre(:,:,:,severe_count),3,'omitnan')) ;  
 boxplot_data1SM_smooth365(:,severe_count) = diff(:);

  diff =  (median(SM_ESACCI_3D_NBR_post(:,:,:,severe_count),3,'omitnan')- median(SM_ESACCI_3D_NBR_pre(:,:,:,severe_count),3,'omitnan')) ;  
 boxplot_data1SM_ESACCI_NBR(:,severe_count) = diff(:);


 diff =  (median(tau_3D_post(:,:,:,severe_count),3,'omitnan') - median(tau_3D_pre(:,:,:,severe_count),3,'omitnan')) ;  
 boxplot_data2VWC(:,severe_count) = diff(:) ; 

  diff =  (median(tau_smooth0_3D_post(:,:,:,severe_count),3,'omitnan') - median(tau_smooth0_3D_pre(:,:,:,severe_count),3,'omitnan')) ;  
 boxplot_data2VWC_smooth0(:,severe_count) = diff(:) ; 

   diff =  (median(tau_smooth365_3D_post(:,:,:,severe_count),3,'omitnan') - median(tau_smooth365_3D_pre(:,:,:,severe_count),3,'omitnan')) ;  
 boxplot_data2VWC_smooth365(:,severe_count) = diff(:) ; 
 
 diff =  (median(dVPD_3D_post(:,:,:,severe_count),3,'omitnan') -  median(dVPD_3D_pre(:,:,:,severe_count),3,'omitnan')) ;     
 boxplot_data3VPD(:,severe_count) = diff(:) ;  


 diff =  (median(VPD_3D_post(:,:,:,severe_count),3,'omitnan') -  median(VPD_3D_pre(:,:,:,severe_count),3,'omitnan')) ;   
 boxplot_data6VPD_day(:,severe_count) = diff(:) ;  
  
  % ERA VPD
  diff =  (median(dERAVPD_3D_post(:,:,:,severe_count),3,'omitnan') -  median(dERAVPD_3D_pre(:,:,:,severe_count),3,'omitnan')) ;     
 boxplot_data7ERAdVPD(:,severe_count) = diff(:) ;  


 diff =  (median(ERAVPD_3D_post(:,:,:,severe_count),3,'omitnan') -  median(ERAVPD_3D_pre(:,:,:,severe_count),3,'omitnan')) ;   
 boxplot_data7ERAVPD(:,severe_count) = diff(:) ;  
 
 diff = (median(DVWC_3D_post(:,:,:,severe_count),3,'omitnan') - median(DVWC_3D_pre(:,:,:,severe_count),3,'omitnan'));    
 boxplot_data4DVWC(:,severe_count) = diff(:) ;     
 
  diff =  (median(tau_C_3D_post(:,:,:,severe_count),3,'omitnan') - median(tau_C_3D_pre(:,:,:,severe_count),3,'omitnan')) ; 
 boxplot_data5VWC_C(:,severe_count) = diff(:) ; 
                              
  % NBR 
  diff =  (median(SM_3D_NBR_post(:,:,:,severe_count),3,'omitnan')-median(SM_3D_NBR_pre(:,:,:,severe_count),3,'omitnan')) ;  
 boxplot_data1NBRSM(:,severe_count) = diff(:);

  diff =  (median(SM_smooth0_3D_NBR_post(:,:,:,severe_count),3,'omitnan')-median(SM_smooth0_3D_NBR_pre(:,:,:,severe_count),3,'omitnan')) ;  
 boxplot_data1NBRSM_smooth0(:,severe_count) = diff(:);   

  diff =  (median(SM_smooth365_3D_NBR_post(:,:,:,severe_count),3,'omitnan')-median(SM_smooth365_3D_NBR_pre(:,:,:,severe_count),3,'omitnan')) ;  
 boxplot_data1NBRSM_smooth365(:,severe_count) = diff(:);   


 diff =  (median(tau_3D_NBR_post(:,:,:,severe_count),3,'omitnan') - median(tau_3D_NBR_pre(:,:,:,severe_count),3,'omitnan'));  
 boxplot_data2NBRVWC(:,severe_count) = diff(:) ; 

 diff =  (median(tau_smooth0_3D_NBR_post(:,:,:,severe_count),3,'omitnan') - median(tau_smooth0_3D_NBR_pre(:,:,:,severe_count),3,'omitnan'));  
 boxplot_data2NBRVWC_smooth0(:,severe_count) = diff(:) ; 

  diff =  (median(tau_smooth365_3D_NBR_post(:,:,:,severe_count),3,'omitnan') - median(tau_smooth365_3D_NBR_pre(:,:,:,severe_count),3,'omitnan'));  
 boxplot_data2NBRVWC_smooth365(:,severe_count) = diff(:) ; 
 
 diff =  (median(dVPD_3D_NBR_post(:,:,:,severe_count),3,'omitnan') -  median(dVPD_3D_NBR_pre(:,:,:,severe_count),3,'omitnan'));     
 boxplot_data3NBRVPD(:,severe_count) = diff(:) ;  
 
 
 diff =  (median(VPD_3D_NBR_post(:,:,:,severe_count),3,'omitnan') -  median(VPD_3D_NBR_pre(:,:,:,severe_count),3,'omitnan'));    
 boxplot_data6NBRVPD_day(:,severe_count) = diff(:) ;  

 % ERA VPD
  diff =  (median(dERAVPD_3D_NBR_post(:,:,:,severe_count),3,'omitnan') -  median(dERAVPD_3D_NBR_pre(:,:,:,severe_count),3,'omitnan'));     
 boxplot_data7NBR_dERAVPD(:,severe_count) = diff(:) ;  
 
 diff =  (median(ERAVPD_3D_NBR_post(:,:,:,severe_count),3,'omitnan') -  median(ERAVPD_3D_NBR_pre(:,:,:,severe_count),3,'omitnan'));    
 boxplot_data7NBRERAVPD(:,severe_count) = diff(:) ;  

 
 diff = (median(DVWC_3D_NBR_post(:,:,:,severe_count),3,'omitnan') - median(DVWC_3D_NBR_pre(:,:,:,severe_count),3,'omitnan')) ; 
 boxplot_data4NBRDVWC(:,severe_count) = diff(:) ;    
 
  diff =  (median(tau_C_3D_NBR_post(:,:,:,severe_count),3,'omitnan') - median(tau_C_3D_NBR_pre(:,:,:,severe_count),3,'omitnan')) ; 
 boxplot_data5NBRVWC_C(:,severe_count) = diff(:) ; 

 % dVWC dSM
   diff =  (median(dVWC_dSM_3D_NBR_post(:,:,:,severe_count),3,'omitnan') - median(dVWC_dSM_3D_NBR_pre(:,:,:,severe_count),3,'omitnan')); 
 boxplot_data7dVWCdSM(:,severe_count) = diff(:) ; 
 
 
    
end
 


boxplot_data1SM_prct = boxplot_data1SM ;
boxplot_data2VWC_prct = boxplot_data2VWC ;
boxplot_data3VPD_prct = boxplot_data3VPD ; 
boxplot_data4DVWC_prct = boxplot_data4DVWC ; 
boxplot_data5VWC_C_prct = boxplot_data5VWC_C ;
boxplot_data6VPD_day_prct = boxplot_data6VPD_day ;


boxplot_data1NBRSM_prct = boxplot_data1NBRSM;
boxplot_data2NBRVWC_prct = boxplot_data2NBRVWC;
boxplot_data3NBRVPD_prct = boxplot_data3NBRVPD;
boxplot_data4NBRDVWC_prct = boxplot_data4NBRDVWC;
boxplot_data5NBRVWC_C_prct = boxplot_data5NBRVWC_C;
boxplot_data6NBRVPD_day_prct = boxplot_data6NBRVPD_day;


boxplot_data7NBRERAVPD = boxplot_data7NBRERAVPD;
boxplot_data7ERAVPD = boxplot_data7ERAVPD;
boxplot_data7NBR_dERAVPD = boxplot_data7NBR_dERAVPD;
boxplot_data7ERAdVPD = boxplot_data7ERAdVPD;

boxplot_data1SM_ESACCI_NBR_300 = boxplot_data1SM_ESACCI_NBR ; 


% figure
% histogram(boxplot_data7NBRERAVPD)
% hold on
% histogram(boxplot_data3NBRVPD)
% 
% boxplot(boxplot_data7NBRERAVPD)
% hold on
% boxplot(boxplot_data6NBRVPD_day)



save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data1SM','boxplot_data1SM')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data2VWC','boxplot_data2VWC')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data3VPD','boxplot_data3VPD')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data4DVWC','boxplot_data4DVWC')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data5VWC_C','boxplot_data5VWC_C')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data6VPD_day','boxplot_data6VPD_day')


save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data1NBRSM','boxplot_data1NBRSM')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data1SM_ESACCI_NBR','boxplot_data1SM_ESACCI_NBR')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data1SM_ESACCI_NBR_300','boxplot_data1SM_ESACCI_NBR_300')

save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data2NBRVWC','boxplot_data2NBRVWC')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data3NBRVPD','boxplot_data3NBRVPD')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data4NBRDVWC','boxplot_data4NBRDVWC')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data5NBRVWC_C','boxplot_data5NBRVWC_C')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data6NBRVPD_day','boxplot_data6NBRVPD_day')

save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data7dVWCdSM','boxplot_data7dVWCdSM')

% ERA VPD
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data7NBRERAVPD','boxplot_data7NBRERAVPD')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data7ERAVPD','boxplot_data7ERAVPD')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data7NBR_dERAVPD','boxplot_data7NBR_dERAVPD')
save('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\boxplot_data7ERAdVPD','boxplot_data7ERAdVPD')


% smoothing experiemnts
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data1SM_smooth0','boxplot_data1SM_smooth0')
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data1SM_smooth365','boxplot_data1SM_smooth365')
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data2VWC_smooth0','boxplot_data2VWC_smooth0')
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data2VWC_smooth365','boxplot_data2VWC_smooth365')
% 
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data1NBRSM_smooth0','boxplot_data1NBRSM_smooth0')
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data1NBRSM_smooth365','boxplot_data1NBRSM_smooth365')
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data2NBRVWC_smooth0','boxplot_data2NBRVWC_smooth0')
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data2NBRVWC_smooth365','boxplot_data2NBRVWC_smooth365')


% only 4 length drydowns
% boxplot_data1SM_DDl4 = boxplot_data1SM ;
% boxplot_data1NBRSM_DDl4= boxplot_data1NBRSM;
% boxplot_data2VWC_DDl4 = boxplot_data2VWC ;
% boxplot_data2NBRVWC_DDl4= boxplot_data2NBRVWC;
% 
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data1SM_DDl4','boxplot_data1SM_DDl4')
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data1NBRSM_DDl4','boxplot_data1NBRSM_DDl4')
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data2VWC_DDl4','boxplot_data2VWC_DDl4')
% save('E:\MOSEV_tiles\datasets_for_final_plots\boxplot_data2NBRVWC_DDl4','boxplot_data2NBRVWC_DDl4')




%%  Step 8 binning into one phase space for unburned datasets




clear 



cd('E:\Daten Baur\Matlab code')
col_L = hex2rgb('808080') ; 
col_L_light = hex2rgb('CDCDCD') ; 

col_C = hex2rgb('3399FF') ;
col_C_light = hex2rgb('80E6FF') ; 

col_X = hex2rgb('FF3333') ;
col_X_light = hex2rgb('FF8080') ; 


cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('lat.mat')
load('lon.mat')



cd('E:\MOSEV_tiles\DD_all_unburned')
% load('DD_dSM_dt_interpsm_array.mat')
% load('DD_dTau_dt_interpsm_array.mat')
% load('DD_dVPD_dt_interpsm_array.mat')
% load('DD_TauC_As_interpsm_array.mat')
% load('DD_TauC_Ds_interpsm_array.mat')


load('DD_dSM_dt_interpsm_array_rndselect.mat')
load('DD_dTau_dt_interpsm_array_rndselect.mat')
load('DD_dTauC_Ds_dt_interpsm_array_rndselect.mat')
load('DD_dVPD_dt_interpsm_array_rndselect.mat')
load('DD_dVPD_dt_day_interpsm_array_rndselect.mat')
load('DD_TauC_As_interpsm_array_rndselect.mat')
load('DD_TauC_Ds_interpsm_array_rndselect.mat')
load('DD_Tau_interpsm_array_rndselect.mat')


load('Dist_to_low_array_rndselect.mat')
load('DD_row_rndselect.mat')
load('DD_col_rndselect.mat')

sminterp = [ 0.01 : 0.01 : 0.60 ]; 



% ad another step subsetting by area based on load of global firepixels
cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
% load('albedo_mean.mat')

% figure
% imagesc(albedo_mean)
% [xs, ys] = getpts() ; xs = round(xs) ; ys = round(ys) ; 
% close

  xs = [1 3856] ; ys = [1 1624] ; 

% cut datasets based on row and cols
latlon_logical_index = DD_row < max(ys) & DD_row > min(ys) & DD_col < max(xs) & DD_col > min(xs) ; 


threshold_samples = 1 ; 
loop_index = 1:48 ; 
day_threshold = 365/12 ; 


% tau

 for i = loop_index
 
tau_subset_post=  DD_Tau_interpsm_array( ...
          Dist_to_low_array < 0+i* day_threshold & Dist_to_low_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
tau_subset_pre=  DD_Tau_interpsm_array( ...
          Dist_to_low_array > 0-i* day_threshold & Dist_to_low_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   tau_subset_post(:,sum(~isnan(tau_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   tau_index_valid_post  = sum(~isnan(tau_subset_post),1,'omitnan') > threshold_samples  ;  
   tau_index_valid_post_cells{i} = tau_index_valid_post;
  
   tau_subset_pre(:,sum(~isnan(tau_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   tau_index_valid_pre  = sum(~isnan(tau_subset_pre),1,'omitnan') > threshold_samples  ;  
   tau_index_valid_pre_cells{i} = tau_index_valid_pre;   
   
   
 tau_subset_post_cells{i} =  tau_subset_post ; 
 tau_subset_pre_cells{i} =  tau_subset_pre ; 
    
 end
 
% tau C

DD_tau_As_Ds_intersm_mean_array = (DD_TauC_Ds_interpsm_array + DD_TauC_As_interpsm_array) ./2 ; 
DD_tau_C_Ds_As_difference_interpsm_array = DD_TauC_Ds_interpsm_array - DD_TauC_As_interpsm_array ; 

 for i = loop_index
 
tau_C_subset_post=  DD_tau_As_Ds_intersm_mean_array( ...
          Dist_to_low_array < 0+i* day_threshold & Dist_to_low_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
tau_C_subset_pre=  DD_tau_As_Ds_intersm_mean_array( ...
          Dist_to_low_array > 0-i* day_threshold & Dist_to_low_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   tau_C_subset_post(:,sum(~isnan(tau_C_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   tau_C_index_valid_post  = sum(~isnan(tau_C_subset_post),1,'omitnan') > threshold_samples  ;  
   tau_C_index_valid_post_cells{i} = tau_C_index_valid_post;
  
   tau_C_subset_pre(:,sum(~isnan(tau_C_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   tau_C_index_valid_pre  = sum(~isnan(tau_C_subset_pre),1,'omitnan') > threshold_samples  ;  
   tau_C_index_valid_pre_cells{i} = tau_C_index_valid_pre;   
   
   
 tau_C_subset_post_cells{i} =  tau_C_subset_post ; 
 tau_C_subset_pre_cells{i} =  tau_C_subset_pre ; 
    
 end
 
 
 
 

% dtau/dt
 for i = loop_index
 
dtau_dt_subset_post=  DD_dTau_dt_interpsm_array( ...
          Dist_to_low_array < 0+i* day_threshold & Dist_to_low_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
dtau_dt_subset_pre=  DD_dTau_dt_interpsm_array( ...
          Dist_to_low_array > 0-i* day_threshold & Dist_to_low_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   dtau_dt_subset_post(:,sum(~isnan(dtau_dt_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   dtau_dt_index_valid_post  = sum(~isnan(dtau_dt_subset_post),1,'omitnan') > threshold_samples  ;  
   dtau_dt_index_valid_post_cells{i} = dtau_dt_index_valid_post;
  
   dtau_dt_subset_pre(:,sum(~isnan(dtau_dt_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   dtau_dt_index_valid_pre  = sum(~isnan(dtau_dt_subset_pre),1,'omitnan') > threshold_samples  ;  
   dtau_dt_index_valid_pre_cells{i} = dtau_dt_index_valid_pre;   
   
   
 dtau_dt_subset_post_cells{i} =  dtau_dt_subset_post ; 
 dtau_dt_subset_pre_cells{i} =  dtau_dt_subset_pre ; 
    
 end

% dtau/dt  C-band
 for i = loop_index
 
dtauC_dt_subset_post=  DD_dTauC_Ds_dt_interpsm_array( ...
          Dist_to_low_array < 0+i* day_threshold & Dist_to_low_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
dtauC_dt_subset_pre=  DD_dTauC_Ds_dt_interpsm_array( ...
          Dist_to_low_array > 0-i* day_threshold & Dist_to_low_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   dtauC_dt_subset_post(:,sum(~isnan(dtauC_dt_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   dtauC_dt_index_valid_post  = sum(~isnan(dtauC_dt_subset_post),1,'omitnan') > threshold_samples  ;  
   dtauC_dt_index_valid_post_cells{i} = dtauC_dt_index_valid_post;
  
   dtauC_dt_subset_pre(:,sum(~isnan(dtauC_dt_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   dtauC_dt_index_valid_pre  = sum(~isnan(dtauC_dt_subset_pre),1,'omitnan') > threshold_samples  ;  
   dtauC_dt_index_valid_pre_cells{i} = dtauC_dt_index_valid_pre;   
   
   
 dtauC_dt_subset_post_cells{i} =  dtauC_dt_subset_post ; 
 dtauC_dt_subset_pre_cells{i} =  dtauC_dt_subset_pre ; 
    
 end

 
% dSM/dt
% DD_dSM_dt_interpsm_array = DD_dSM_dt_interpsm_array(1000000:2000000,:) ; 
% latlon_logical_index = latlon_logical_index(1000000:2000000,:) ; 
% Dist_to_low_array = Dist_to_low_array(1000000:2000000,:) ; 


 for i = loop_index
 
dSM_dt_subset_post=  DD_dSM_dt_interpsm_array( ...
          Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ; 
      
dSM_dt_subset_pre=  DD_dSM_dt_interpsm_array( ...
          Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
     
   dSM_dt_subset_post(:,sum(~isnan(dSM_dt_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   dSM_dt_index_valid_post  = sum(~isnan(dSM_dt_subset_post),1,'omitnan') > threshold_samples  ;
   dSM_dt_index_valid_post_cells{i} = dSM_dt_index_valid_post ; 
   
 dSM_dt_subset_post_cells{i} =  dSM_dt_subset_post ; 
 
   dSM_dt_subset_pre(:,sum(~isnan(dSM_dt_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   dSM_dt_index_valid_pre  = sum(~isnan(dSM_dt_subset_pre),1,'omitnan') > threshold_samples  ;
   dSM_dt_index_valid_pre_cells{i} = dSM_dt_index_valid_pre ; 
   
 dSM_dt_subset_pre_cells{i} =  dSM_dt_subset_pre ; 
 

 
   
 end 
 
 
 
% dVPD/dt 
 for i = loop_index
 
dVPD_dt_subset_post=  DD_dVPD_dt_interpsm_array( ...
          Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
                  
dVPD_dt_subset_pre=  DD_dVPD_dt_interpsm_array( ...
          Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dVPD_dt_subset_post(:,sum(~isnan(dVPD_dt_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   dVPD_dt_index_valid_post  = sum(~isnan(dVPD_dt_subset_post),1,'omitnan') > threshold_samples  ;  
   dVPD_dt_index_valid_post_cells{i} = dVPD_dt_index_valid_post ;
   
 dVPD_dt_subset_post_cells{i} =  dVPD_dt_subset_post ; 
 
 
   dVPD_dt_subset_pre(:,sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   dVPD_dt_index_valid_pre  = sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') > threshold_samples  ;  
   dVPD_dt_index_valid_pre_cells{i} = dVPD_dt_index_valid_pre ;
   
 dVPD_dt_subset_pre_cells{i} =  dVPD_dt_subset_pre ; 
 
   
 end  

 
 % dVPD/dt  day
 for i = loop_index
 
dVPD_dt_subset_post=  DD_dVPD_dt_day_interpsm_array( ...
          Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
                  
dVPD_dt_subset_pre=  DD_dVPD_dt_day_interpsm_array( ...
          Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dVPD_dt_subset_post(:,sum(~isnan(dVPD_dt_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   dVPD_dt_index_valid_post  = sum(~isnan(dVPD_dt_subset_post),1,'omitnan') > threshold_samples  ;  
   dVPD_dt_index_valid_post_cells{i} = dVPD_dt_index_valid_post ;
   
 dVPD_dt_day_subset_post_cells{i} =  dVPD_dt_subset_post ; 
 
 
   dVPD_dt_subset_pre(:,sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   dVPD_dt_index_valid_pre  = sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') > threshold_samples  ;  
   dVPD_dt_index_valid_pre_cells{i} = dVPD_dt_index_valid_pre ;
   
 dVPD_dt_day_subset_pre_cells{i} =  dVPD_dt_subset_pre ; 
 
   
 end  


% tau C diurnal cycle
 
DD_tau_As_Ds_intersm_mean_array = (DD_TauC_Ds_interpsm_array + DD_TauC_As_interpsm_array) ./2 ; 
DD_tau_C_Ds_As_difference_interpsm_array = DD_TauC_Ds_interpsm_array - DD_TauC_As_interpsm_array ; 


  for i = loop_index
         
 
DD_tau_C_Ds_As_mean_post=  DD_tau_As_Ds_intersm_mean_array( ...
          Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
DD_tau_C_Ds_As_mean_pre=   DD_tau_As_Ds_intersm_mean_array( ...
          Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   DD_tau_C_Ds_As_mean_post(:,sum(~isnan(DD_tau_C_Ds_As_mean_post),1,'omitnan') < threshold_samples) = NaN ; 
   DD_tau_C_Ds_As_mean_post_valid_post  = sum(~isnan(DD_tau_C_Ds_As_mean_post),1,'omitnan') > threshold_samples  ;  
  DD_tau_C_Ds_As_mean_post_valid_post_cells{i} = DD_tau_C_Ds_As_mean_post_valid_post;
   
   DD_tau_C_Ds_As_mean_pre(:,sum(~isnan(DD_tau_C_Ds_As_mean_pre),1,'omitnan') < threshold_samples) = NaN ; 
   DD_tau_C_Ds_As_mean_pre_valid_pre  = sum(~isnan(DD_tau_C_Ds_As_mean_pre),1,'omitnan') > threshold_samples  ;  
   DD_tau_C_Ds_As_mean_pre_valid_pre_cells{i} = DD_tau_C_Ds_As_mean_pre_valid_pre;   
   
   
DD_tau_C_Ds_As_mean_post_cells{i} =  DD_tau_C_Ds_As_mean_post ; 
DD_tau_C_Ds_As_mean_pre_cells{i} =  DD_tau_C_Ds_As_mean_pre ; 
    
  end  
  
  
  for i = loop_index
         
 
DD_tau_C_Ds_As_rel_difference_subset_post= DD_tau_C_Ds_As_difference_interpsm_array( ...
          Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
DD_tau_C_Ds_As_rel_difference_subset_pre=   DD_tau_C_Ds_As_difference_interpsm_array( ...
          Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   DD_tau_C_Ds_As_rel_difference_subset_post(:,sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   DD_tau_C_Ds_As_rel_difference_valid_post  = sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_post),1,'omitnan') > threshold_samples  ;  
  DD_tau_C_Ds_As_rel_difference_valid_post_cells{i} = DD_tau_C_Ds_As_rel_difference_valid_post;
   
   DD_tau_C_Ds_As_rel_difference_subset_pre(:,sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   DD_tau_C_Ds_As_rel_difference_valid_pre  = sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_pre),1,'omitnan') > threshold_samples  ;  
   DD_tau_C_Ds_As_rel_difference_pre_cells{i} = DD_tau_C_Ds_As_rel_difference_valid_pre;   
   
   
 DD_tau_C_Ds_As_rel_difference_subset_post_cells{i} =  DD_tau_C_Ds_As_rel_difference_subset_post ; 
 DD_tau_C_Ds_As_rel_difference_subset_pre_cells{i} =  DD_tau_C_Ds_As_rel_difference_subset_pre ; 
    
  end
  
  
 % row and col
  
  
  for i = loop_index
         
  D_col_post = DD_col(    Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index) ;
  D_row_post = DD_row(    Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index) ;
  
  D_col_pre = DD_col(  Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index )  ;
  D_row_pre = DD_row(  Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ) ; 
  


D_col_post_cells{i} =  D_col_post ;
D_row_post_cells{i} =  D_row_post ;
D_col_pre_cells{i}  =  D_col_pre ;
D_row_pre_cells{i}  =  D_row_pre ;   

D_lon_post_cells{i} =  lon(1,D_col_post) ;
D_lat_post_cells{i} =  lat(D_row_post,1) ;
D_lon_pre_cells{i}  =  lon(1,D_col_pre) ;
D_lat_pre_cells{i}  =  lat(D_row_pre,1) ;   


  end
  
  
  
 






%%%%%%%%   DD_tau_C_Ds_As_rel_difference_subset_post_cells
%%%%%%%%   dtau_dt_subset_post_cells
%%%%%%%%   dSM_dt_subset_post_cells
%%%%%%%%   dtauC_dt_subset_post_cells



%  select_cells_post = [3 6 9 12] ; 
 select_cells_pre = [12 24 36 48] ; 

post_anomaly = dtau_dt_subset_post_cells{1}  ;
% pre_anomaly = dtauC_dt_subset_pre_cells{select_cells_pre(1)} ; 


% C-band tau
post_anomaly_mean = DD_tau_C_Ds_As_mean_post_cells{1}  ;
% pre_anomaly_mean = DD_tau_C_Ds_As_mean_pre_cells{select_cells_post(1)} ; 
post_anomaly_mean = tau_C_subset_post_cells{1} ; 

% % L-band tau
 post_anomaly_mean = tau_subset_post_cells{1}  ;
 % pre_anomaly_mean = tau_subset_pre_cells{select_cells_pre(1)} ; 

 


 pre_anomaly =  vertcat( dtau_dt_subset_pre_cells{select_cells_pre(1)}, ...
                         dtau_dt_subset_pre_cells{select_cells_pre(2)}, ...
                         dtau_dt_subset_pre_cells{select_cells_pre(3)}, ...
                         dtau_dt_subset_pre_cells{select_cells_pre(4)})  ;


% normal L tau
pre_anomaly_mean =  vertcat(tau_subset_pre_cells{select_cells_pre(1)}, ...
                        tau_subset_pre_cells{select_cells_pre(2)}, ...
                        tau_subset_pre_cells{select_cells_pre(3)}, ...
                        tau_subset_pre_cells{select_cells_pre(4)})  ;

% tau C 
pre_anomaly_mean =  vertcat(tau_C_subset_pre_cells{select_cells_pre(1)}, ...
                        tau_C_subset_pre_cells{select_cells_pre(2)}, ...
                        tau_C_subset_pre_cells{select_cells_pre(3)}, ...
                        tau_C_subset_pre_cells{select_cells_pre(4)})  ;

% VODCA tau
pre_anomaly_mean =  vertcat(tau_VODCA_subset_pre_cells{select_cells_pre(1)}, ...
                        tau_VODCA_subset_pre_cells{select_cells_pre(2)}, ...
                        tau_VODCA_subset_pre_cells{select_cells_pre(3)}, ...
                        tau_VODCA_subset_pre_cells{select_cells_pre(4)})  ;




sminterp = linspace( 0.001,0.5999,31 ); 
sminterp_60 = linspace( 0.001,0.5999,60 ); 
tauinterp = linspace(0.001,0.9999,31) ; 




DD_day_night_diff_3_D_pre = NaN(30,30,20000)  ; 
DD_day_night_diff_3_D_post = NaN(30,30,20000)  ; 


for sm = 1:30
    
    cur_sm = sminterp(sm:sm+1) ; 
    sm_true = sminterp_60 > cur_sm(1) & sminterp_60 < cur_sm(2) ; 
    
    for tau = 1:30
        
    cur_tau = tauinterp(tau:tau+1) ;         
      
    dummypre = pre_anomaly(:,sm_true) ; 
    tau_diff_dummy_pre = dummypre(pre_anomaly_mean(:,sm_true) > cur_tau(1) & pre_anomaly_mean(:,sm_true) < cur_tau(2)) ; 
    dummypost = post_anomaly(:,sm_true) ; 
    tau_diff_dummy_post = dummypost(post_anomaly_mean(:,sm_true) > cur_tau(1) & post_anomaly_mean(:,sm_true) < cur_tau(2)) ;    
    
     DD_day_night_diff_3_D_pre(sm,tau,1:length(tau_diff_dummy_pre)) = tau_diff_dummy_pre ; 
     DD_day_night_diff_3_D_post(sm,tau,1:length(tau_diff_dummy_post)) = tau_diff_dummy_post ;    
    
        
    end


sm
end




DD_day_night_diff_3_D_pre(DD_day_night_diff_3_D_pre <= 0) = NaN ; 
DD_day_night_diff_3_D_post(DD_day_night_diff_3_D_post <= 0) = NaN ; 




mask_sample_post =  (sum(~isnan(DD_day_night_diff_3_D_post),3,'omitnan')  < 20)  ; 
mask_sample_pre =  (sum(~isnan(DD_day_night_diff_3_D_pre),3,'omitnan')  < 20)  ; 

mask_sample_post = repmat(mask_sample_post,[1,1,20000]) ; 
mask_sample_pre = repmat(mask_sample_pre,[1,1,20000]) ; 


DD_day_night_diff_3_D_pre(mask_sample_pre) = NaN ; 
DD_day_night_diff_3_D_post(mask_sample_post) = NaN ; 



test_pre = mean(DD_day_night_diff_3_D_pre,3,'omitnan') ; 
test_post = mean(DD_day_night_diff_3_D_post,3,'omitnan') ; 





% always convert y axis to VWC
tauinterp = tauinterp ./ 0.11 ; 

% for C-band
tauinterp = tauinterp ./0.2046  ; 


% convert to VWC comment out if not wanted

test_pre = test_pre ./0.11 ; 
test_post = test_post ./ 0.11 ; 


% for C-band convert based on b from 
test_pre = test_pre ./0.2046 ; 
test_post = test_post ./ 0.2046 ; 



% 1 sample  Kolmogorov Smirnov for normal distribution
% koltestpre = NaN(30,30) ; koltestppre = NaN(30,300) ; 
% koltestpost = NaN(30,30) ; koltestppost = NaN(30,300) ; 
% 
% for r = 1:30
%     for c = 1:30
% 
%        if (   ~all(isnan(squeeze(DD_day_night_diff_3_D_pre(r,c,:))))  ) 
%       [koltestpre(r,c), koltestppre(1,i)]= kstest(squeeze(DD_day_night_diff_3_D_pre(r,c,:))) ; 
%        end
% 
%        if (   ~all(isnan(squeeze(DD_day_night_diff_3_D_post(r,c,:))))  )       
%       [koltestpost(r,c), koltestppost(1,i)]= kstest(squeeze(DD_day_night_diff_3_D_post(r,c,:))) ;   
%        end
% 
%     end
% end


% normally all non normal .. no surprising .. do man whithnes u
% nonparametric


% 2 sample Kolmogorov Smirnov nonparam test
MWUtesth_post = NaN(30,30) ; MWUtestp_post = NaN(30,30) ; 


for r = 1:30
    for c = 1:30
      
        dummy_pre =  squeeze(DD_day_night_diff_3_D_pre(r,c,:))  ;
        dummy_post = squeeze(DD_day_night_diff_3_D_post(r,c,:))  ;
        dummy_pre(isnan(dummy_pre)) = [] ; 
        dummy_post(isnan(dummy_post)) = [] ;         
 
         if (   ~all(isnan(dummy_pre))  &&   ~all(isnan(dummy_post))   ) 
        [MWUtestp_post(r,c),MWUtesth_post(r,c)] = ranksum(dummy_pre,dummy_post) ; 
        end
    
  
    end
end


% save final results for plot here

dVWC_dt_fully_binned_pre  =   test_pre ; 
dVWC_dt_fully_binned_post =   test_post;
dVWC_dt_MWUtestp_post = MWUtestp_post ; 


save('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref\dVWC_dt_fully_binned_pre','dVWC_dt_fully_binned_pre')
save('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref\dVWC_dt_fully_binned_post','dVWC_dt_fully_binned_post')
save('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref\dVWC_dt_MWUtestp_post','dVWC_dt_MWUtestp_post')




%% Step 9 binning into 5 degree boxes for unburned reference
clear



cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('lat.mat')
load('lon.mat')



cd('E:\MOSEV_tiles\DD_all_unburned')
% load('DD_dSM_dt_interpsm_array.mat')
% load('DD_dTau_dt_interpsm_array.mat')
% load('DD_dVPD_dt_interpsm_array.mat')
% load('DD_TauC_As_interpsm_array.mat')
% load('DD_TauC_Ds_interpsm_array.mat')


load('DD_dSM_dt_interpsm_array_rndselect.mat')
load('DD_dTau_dt_interpsm_array_rndselect.mat')
load('DD_dTauC_Ds_dt_interpsm_array_rndselect.mat')
load('DD_dVPD_dt_interpsm_array_rndselect.mat')
load('DD_dVPD_dt_day_interpsm_array_rndselect.mat')
load('DD_TauC_As_interpsm_array_rndselect.mat')
load('DD_TauC_Ds_interpsm_array_rndselect.mat')
load('DD_Tau_interpsm_array_rndselect.mat')


load('Dist_to_low_array_rndselect.mat')
load('DD_row_rndselect.mat')
load('DD_col_rndselect.mat')

sminterp = [ 0.01 : 0.01 : 0.60 ]; 


% ad another step subsetting by area based on load of global firepixels
cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
% load('albedo_mean.mat')

% figure
% imagesc(albedo_mean)
% [xs, ys] = getpts() ; xs = round(xs) ; ys = round(ys) ; 
% close

  xs = [1 3856] ; ys = [1 1624] ; 

% cut datasets based on row and cols
latlon_logical_index = DD_row < max(ys) & DD_row > min(ys) & DD_col < max(xs) & DD_col > min(xs) ; 


threshold_samples = 1 ; 
loop_index = 1:48 ; 
day_threshold = 365/12 ; 


% tau

 for i = loop_index
 
tau_subset_post=  DD_Tau_interpsm_array( ...
          Dist_to_low_array < 0+i* day_threshold & Dist_to_low_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
tau_subset_pre=  DD_Tau_interpsm_array( ...
          Dist_to_low_array > 0-i* day_threshold & Dist_to_low_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   tau_subset_post(:,sum(~isnan(tau_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   tau_index_valid_post  = sum(~isnan(tau_subset_post),1,'omitnan') > threshold_samples  ;  
   tau_index_valid_post_cells{i} = tau_index_valid_post;
  
   tau_subset_pre(:,sum(~isnan(tau_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   tau_index_valid_pre  = sum(~isnan(tau_subset_pre),1,'omitnan') > threshold_samples  ;  
   tau_index_valid_pre_cells{i} = tau_index_valid_pre;   
   
   
 tau_subset_post_cells{i} =  tau_subset_post ; 
 tau_subset_pre_cells{i} =  tau_subset_pre ; 
    
 end
 
% tau C

DD_tau_As_Ds_intersm_mean_array = (DD_TauC_Ds_interpsm_array + DD_TauC_As_interpsm_array) ./2 ; 
DD_tau_C_Ds_As_difference_interpsm_array = DD_TauC_Ds_interpsm_array - DD_TauC_As_interpsm_array ; 

 for i = loop_index
 
tau_C_subset_post=  DD_tau_As_Ds_intersm_mean_array( ...
          Dist_to_low_array < 0+i* day_threshold & Dist_to_low_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
tau_C_subset_pre=  DD_tau_As_Ds_intersm_mean_array( ...
          Dist_to_low_array > 0-i* day_threshold & Dist_to_low_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   tau_C_subset_post(:,sum(~isnan(tau_C_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   tau_C_index_valid_post  = sum(~isnan(tau_C_subset_post),1,'omitnan') > threshold_samples  ;  
   tau_C_index_valid_post_cells{i} = tau_C_index_valid_post;
  
   tau_C_subset_pre(:,sum(~isnan(tau_C_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   tau_C_index_valid_pre  = sum(~isnan(tau_C_subset_pre),1,'omitnan') > threshold_samples  ;  
   tau_C_index_valid_pre_cells{i} = tau_C_index_valid_pre;   
   
   
 tau_C_subset_post_cells{i} =  tau_C_subset_post ; 
 tau_C_subset_pre_cells{i} =  tau_C_subset_pre ; 
    
 end
 
 
 
 

% dtau/dt
 for i = loop_index
 
dtau_dt_subset_post=  DD_dTau_dt_interpsm_array( ...
          Dist_to_low_array < 0+i* day_threshold & Dist_to_low_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
dtau_dt_subset_pre=  DD_dTau_dt_interpsm_array( ...
          Dist_to_low_array > 0-i* day_threshold & Dist_to_low_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   dtau_dt_subset_post(:,sum(~isnan(dtau_dt_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   dtau_dt_index_valid_post  = sum(~isnan(dtau_dt_subset_post),1,'omitnan') > threshold_samples  ;  
   dtau_dt_index_valid_post_cells{i} = dtau_dt_index_valid_post;
  
   dtau_dt_subset_pre(:,sum(~isnan(dtau_dt_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   dtau_dt_index_valid_pre  = sum(~isnan(dtau_dt_subset_pre),1,'omitnan') > threshold_samples  ;  
   dtau_dt_index_valid_pre_cells{i} = dtau_dt_index_valid_pre;   
   
   
 dtau_dt_subset_post_cells{i} =  dtau_dt_subset_post ; 
 dtau_dt_subset_pre_cells{i} =  dtau_dt_subset_pre ; 
    
 end

% dtau/dt  C-band
 for i = loop_index
 
dtauC_dt_subset_post=  DD_dTauC_Ds_dt_interpsm_array( ...
          Dist_to_low_array < 0+i* day_threshold & Dist_to_low_array > 0+(i-1)* day_threshold & latlon_logical_index ,:) ; 
     
dtauC_dt_subset_pre=  DD_dTauC_Ds_dt_interpsm_array( ...
          Dist_to_low_array > 0-i* day_threshold & Dist_to_low_array < 0-(i-1)* day_threshold & latlon_logical_index  ,:) ; 
     
   dtauC_dt_subset_post(:,sum(~isnan(dtauC_dt_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   dtauC_dt_index_valid_post  = sum(~isnan(dtauC_dt_subset_post),1,'omitnan') > threshold_samples  ;  
   dtauC_dt_index_valid_post_cells{i} = dtauC_dt_index_valid_post;
  
   dtauC_dt_subset_pre(:,sum(~isnan(dtauC_dt_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   dtauC_dt_index_valid_pre  = sum(~isnan(dtauC_dt_subset_pre),1,'omitnan') > threshold_samples  ;  
   dtauC_dt_index_valid_pre_cells{i} = dtauC_dt_index_valid_pre;   
   
   
 dtauC_dt_subset_post_cells{i} =  dtauC_dt_subset_post ; 
 dtauC_dt_subset_pre_cells{i} =  dtauC_dt_subset_pre ; 
    
 end

 
% dSM/dt
% DD_dSM_dt_interpsm_array = DD_dSM_dt_interpsm_array(1000000:2000000,:) ; 
% latlon_logical_index = latlon_logical_index(1000000:2000000,:) ; 
% Dist_to_low_array = Dist_to_low_array(1000000:2000000,:) ; 


 for i = loop_index
 
dSM_dt_subset_post=  DD_dSM_dt_interpsm_array( ...
          Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index ,:) ; 
      
dSM_dt_subset_pre=  DD_dSM_dt_interpsm_array( ...
          Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
     
   dSM_dt_subset_post(:,sum(~isnan(dSM_dt_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   dSM_dt_index_valid_post  = sum(~isnan(dSM_dt_subset_post),1,'omitnan') > threshold_samples  ;
   dSM_dt_index_valid_post_cells{i} = dSM_dt_index_valid_post ; 
   
 dSM_dt_subset_post_cells{i} =  dSM_dt_subset_post ; 
 
   dSM_dt_subset_pre(:,sum(~isnan(dSM_dt_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   dSM_dt_index_valid_pre  = sum(~isnan(dSM_dt_subset_pre),1,'omitnan') > threshold_samples  ;
   dSM_dt_index_valid_pre_cells{i} = dSM_dt_index_valid_pre ; 
   
 dSM_dt_subset_pre_cells{i} =  dSM_dt_subset_pre ; 
 

 
   
 end 
 
 
 
% dVPD/dt 
 for i = loop_index
 
dVPD_dt_subset_post=  DD_dVPD_dt_interpsm_array( ...
          Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
                  
dVPD_dt_subset_pre=  DD_dVPD_dt_interpsm_array( ...
          Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dVPD_dt_subset_post(:,sum(~isnan(dVPD_dt_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   dVPD_dt_index_valid_post  = sum(~isnan(dVPD_dt_subset_post),1,'omitnan') > threshold_samples  ;  
   dVPD_dt_index_valid_post_cells{i} = dVPD_dt_index_valid_post ;
   
 dVPD_dt_subset_post_cells{i} =  dVPD_dt_subset_post ; 
 
 
   dVPD_dt_subset_pre(:,sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   dVPD_dt_index_valid_pre  = sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') > threshold_samples  ;  
   dVPD_dt_index_valid_pre_cells{i} = dVPD_dt_index_valid_pre ;
   
 dVPD_dt_subset_pre_cells{i} =  dVPD_dt_subset_pre ; 
 
   
 end  

 
 % dVPD/dt  day
 for i = loop_index
 
dVPD_dt_subset_post=  DD_dVPD_dt_day_interpsm_array( ...
          Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
                  
dVPD_dt_subset_pre=  DD_dVPD_dt_day_interpsm_array( ...
          Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   dVPD_dt_subset_post(:,sum(~isnan(dVPD_dt_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   dVPD_dt_index_valid_post  = sum(~isnan(dVPD_dt_subset_post),1,'omitnan') > threshold_samples  ;  
   dVPD_dt_index_valid_post_cells{i} = dVPD_dt_index_valid_post ;
   
 dVPD_dt_day_subset_post_cells{i} =  dVPD_dt_subset_post ; 
 
 
   dVPD_dt_subset_pre(:,sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   dVPD_dt_index_valid_pre  = sum(~isnan(dVPD_dt_subset_pre),1,'omitnan') > threshold_samples  ;  
   dVPD_dt_index_valid_pre_cells{i} = dVPD_dt_index_valid_pre ;
   
 dVPD_dt_day_subset_pre_cells{i} =  dVPD_dt_subset_pre ; 
 
   
 end  


% tau C diurnal cycle
 
DD_tau_As_Ds_intersm_mean_array = (DD_TauC_Ds_interpsm_array + DD_TauC_As_interpsm_array) ./2 ; 
DD_tau_C_Ds_As_difference_interpsm_array = DD_TauC_Ds_interpsm_array - DD_TauC_As_interpsm_array ; 


  for i = loop_index
         
 
DD_tau_C_Ds_As_mean_post=  DD_tau_As_Ds_intersm_mean_array( ...
          Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
DD_tau_C_Ds_As_mean_pre=   DD_tau_As_Ds_intersm_mean_array( ...
          Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   DD_tau_C_Ds_As_mean_post(:,sum(~isnan(DD_tau_C_Ds_As_mean_post),1,'omitnan') < threshold_samples) = NaN ; 
   DD_tau_C_Ds_As_mean_post_valid_post  = sum(~isnan(DD_tau_C_Ds_As_mean_post),1,'omitnan') > threshold_samples  ;  
  DD_tau_C_Ds_As_mean_post_valid_post_cells{i} = DD_tau_C_Ds_As_mean_post_valid_post;
   
   DD_tau_C_Ds_As_mean_pre(:,sum(~isnan(DD_tau_C_Ds_As_mean_pre),1,'omitnan') < threshold_samples) = NaN ; 
   DD_tau_C_Ds_As_mean_pre_valid_pre  = sum(~isnan(DD_tau_C_Ds_As_mean_pre),1,'omitnan') > threshold_samples  ;  
   DD_tau_C_Ds_As_mean_pre_valid_pre_cells{i} = DD_tau_C_Ds_As_mean_pre_valid_pre;   
   
   
DD_tau_C_Ds_As_mean_post_cells{i} =  DD_tau_C_Ds_As_mean_post ; 
DD_tau_C_Ds_As_mean_pre_cells{i} =  DD_tau_C_Ds_As_mean_pre ; 
    
  end  
  
  
  for i = loop_index
         
 
DD_tau_C_Ds_As_rel_difference_subset_post= DD_tau_C_Ds_As_difference_interpsm_array( ...
          Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index  ,:) ; 
     
DD_tau_C_Ds_As_rel_difference_subset_pre=   DD_tau_C_Ds_As_difference_interpsm_array( ...
          Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ,:) ; 
     
   DD_tau_C_Ds_As_rel_difference_subset_post(:,sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_post),1,'omitnan') < threshold_samples) = NaN ; 
   DD_tau_C_Ds_As_rel_difference_valid_post  = sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_post),1,'omitnan') > threshold_samples  ;  
  DD_tau_C_Ds_As_rel_difference_valid_post_cells{i} = DD_tau_C_Ds_As_rel_difference_valid_post;
   
   DD_tau_C_Ds_As_rel_difference_subset_pre(:,sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_pre),1,'omitnan') < threshold_samples) = NaN ; 
   DD_tau_C_Ds_As_rel_difference_valid_pre  = sum(~isnan(DD_tau_C_Ds_As_rel_difference_subset_pre),1,'omitnan') > threshold_samples  ;  
   DD_tau_C_Ds_As_rel_difference_pre_cells{i} = DD_tau_C_Ds_As_rel_difference_valid_pre;   
   
   
 DD_tau_C_Ds_As_rel_difference_subset_post_cells{i} =  DD_tau_C_Ds_As_rel_difference_subset_post ; 
 DD_tau_C_Ds_As_rel_difference_subset_pre_cells{i} =  DD_tau_C_Ds_As_rel_difference_subset_pre ; 
    
  end
  
  
 % row and col
  
  
  for i = loop_index
         
  D_col_post = DD_col(    Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index) ;
  D_row_post = DD_row(    Dist_to_low_array < 0+i*day_threshold & Dist_to_low_array > 0+(i-1)*day_threshold & latlon_logical_index) ;
  
  D_col_pre = DD_col(  Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index )  ;
  D_row_pre = DD_row(  Dist_to_low_array > 0-i*day_threshold & Dist_to_low_array < 0-(i-1)*day_threshold & latlon_logical_index ) ; 
  


D_col_post_cells{i} =  D_col_post ;
D_row_post_cells{i} =  D_row_post ;
D_col_pre_cells{i}  =  D_col_pre ;
D_row_pre_cells{i}  =  D_row_pre ;   

D_lon_post_cells{i} =  lon(1,D_col_post) ;
D_lat_post_cells{i} =  lat(D_row_post,1) ;
D_lon_pre_cells{i}  =  lon(1,D_col_pre) ;
D_lat_pre_cells{i}  =  lat(D_row_pre,1) ;   


  end
  
 



cell_select = [12 24 36 48] ;
% cell_select = [3 6 9 12] ;

  dSM_dt_post_array  = dSM_dt_subset_post_cells{1} ; 
  % dSM_dt_pre_array =  dSM_dt_subset_pre_cells{cell_select(1)} ; 
  dSM_dt_pre_array =  vertcat(dSM_dt_subset_pre_cells{cell_select(1)}, dSM_dt_subset_pre_cells{cell_select(2)},...
      dSM_dt_subset_pre_cells{cell_select(3)},dSM_dt_subset_pre_cells{cell_select(4)}) ; 
 
  dtau_dt_post_array  = dtau_dt_subset_post_cells{1} ; 
  % dtau_dt_pre_array  = dtau_dt_subset_pre_cells{cell_select(1)} ;  
  dtau_dt_pre_array =  vertcat(dtau_dt_subset_pre_cells{cell_select(1)}, dtau_dt_subset_pre_cells{cell_select(2)},...
      dtau_dt_subset_pre_cells{cell_select(3)},dtau_dt_subset_pre_cells{cell_select(4)}) ;  

  dVPD_dt_post_array  = dVPD_dt_day_subset_post_cells{1} ; 
  % dVPD_dt_pre_array  = dVPD_dt_day_subset_pre_cells{cell_select(1)} ; 
    dVPD_dt_pre_array =  vertcat(dVPD_dt_day_subset_pre_cells{cell_select(1)}, dVPD_dt_day_subset_pre_cells{cell_select(2)},...
      dVPD_dt_day_subset_pre_cells{cell_select(3)},dVPD_dt_day_subset_pre_cells{cell_select(4)}) ;
  
%  dVPD_dt_pre_array =  vertcat(dVPD_dt_subset_pre_cells{cell_select(1)}, dVPD_dt_subset_pre_cells{cell_select(2)},...
%      dVPD_dt_subset_pre_cells{cell_select(3)},dVPD_dt_subset_pre_cells{cell_select(4)}) ;  
%  
 VWC_diurnal_post_array  = DD_tau_C_Ds_As_rel_difference_subset_post_cells{1} ; 
 % VWC_diurnal_pre_array  = DD_tau_C_Ds_As_rel_difference_subset_pre_cells{cell_select(1)} ; 
  VWC_diurnal_pre_array =  vertcat(DD_tau_C_Ds_As_rel_difference_subset_pre_cells{cell_select(1)}, DD_tau_C_Ds_As_rel_difference_subset_pre_cells{cell_select(2)},...
      DD_tau_C_Ds_As_rel_difference_subset_pre_cells{cell_select(3)},DD_tau_C_Ds_As_rel_difference_subset_pre_cells{cell_select(4)}) ;     
 
 VWC_diurnal_post_array(VWC_diurnal_post_array <= 0) = NaN ; 
 VWC_diurnal_pre_array(VWC_diurnal_pre_array <= 0) = NaN ; 


%  D_tau_subset_post_array =  D_tau_subset_post_cells{1} ; 
%  
%  D_tau_subset_pre_array =  vertcat(D_tau_subset_pre_cells{3}, D_tau_subset_pre_cells{6},...
%      D_tau_subset_pre_cells{9},D_tau_subset_pre_cells{12}) ;
 
 tau_post_array =  tau_subset_post_cells{1} ; 
 % tau_pre_array =   tau_subset_pre_cells{cell_select(1)} ;  
  tau_pre_array =  vertcat(tau_subset_pre_cells{cell_select(1)}, tau_subset_pre_cells{cell_select(2)},...
      tau_subset_pre_cells{cell_select(3)},tau_subset_pre_cells{cell_select(4)}) ;
 
  tau_C_post_array =  tau_C_subset_post_cells{1} ; 
  % tau_C_pre_array  =  tau_C_subset_pre_cells{cell_select(1)} ; 
  tau_C_pre_array =  vertcat(tau_C_subset_pre_cells{cell_select(1)}, tau_C_subset_pre_cells{cell_select(2)},...
      tau_C_subset_pre_cells{cell_select(3)},tau_C_subset_pre_cells{cell_select(4)}) ;
 
 
 
 D_col_post_array = D_col_post_cells{1} ; 
 % D_col_pre_array = D_col_pre_cells{cell_select(1)} ;  
%  
  D_col_pre_array =  vertcat(D_col_pre_cells{cell_select(1)}, D_col_pre_cells{cell_select(2)},...
      D_col_pre_cells{cell_select(3)},D_col_pre_cells{cell_select(4)}) ; 

 
 D_row_post_array = D_row_post_cells{1} ; 
 % D_row_pre_array = D_row_pre_cells{cell_select(1)} ; 
%  
  D_row_pre_array =  vertcat(D_row_pre_cells{cell_select(1)}, D_row_pre_cells{cell_select(2)},...
      D_row_pre_cells{cell_select(3)},D_row_pre_cells{cell_select(4)}) ; 
%  
 







% conversion to VWC


dtau_dt_post_array  = dtau_dt_post_array ./ 0.11 ; 
dtau_dt_pre_array =    dtau_dt_pre_array ./ 0.11 ; 



VWC_diurnal_post_array = VWC_diurnal_post_array ./ 0.2046  ;
VWC_diurnal_pre_array = VWC_diurnal_pre_array ./ 0.2046  ; 

%D_tau_subset_post_array = D_tau_subset_post_array ./ 0.11 ; 

tau_post_array = tau_post_array ./ 0.11  ; 
tau_pre_array = tau_pre_array ./ 0.11  ; 

tau_C_post_array = tau_post_array ./ 0.2046  ; 
tau_C_pre_array = tau_pre_array ./ 0.2046  ; 






 
% build matching matrix for lat and lon 
lons_2_5 = (-180+2.5):5:(180-2.5)   ; 
lons_2_5 = repmat(lons_2_5,[36, 1]) ; 

lats_2_5 = fliplr((-90+2.5):5:(90-2.5))   ; 
lats_2_5 = repmat(lats_2_5',[1, 72]) ; 

lats_matching_vector = NaN(1624,1) ; 
lons_matching_vector = NaN(3856,1) ; 
for r = 1:1624

    curlat = lat(r,1) ; 
    [mins locs] =  min(abs(lats_2_5(:,1) - curlat) )  ; 
    
    lats_matching_vector(r) = locs ;  
        
  
end

  for c = 1:3856
      
    curlon = lon(1,c) ; 
    [mins locs] =  min(abs(lons_2_5(1,:) - curlon) )  ; 
    
    lons_matching_vector(c) = locs ;  

  end 

 
lats_Ease_2_5_match = repmat(lats_matching_vector ,[1, 3856]) ; 
lons_Ease_2_5_match = repmat(lons_matching_vector' ,[1624, 1]) ; 





% now do binning into 2.5 degree array



dSM_dt_diff_sampling_array = NaN(size(lats_2_5,1),size(lats_2_5,2),60) ; 
%    r = 50 ; c = 120 ; 
tauinterp = linspace(0,1.2,21) ; 
tauinterp = tauinterp ./ 0.11  ; 
sminterp = linspace( 0,0.60,21 ); 
sminterp_60 = linspace( 0,0.60,60 ); 



dSM_dt_diff_global_array = NaN(size(lats_2_5,1),size(lats_2_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_dt_diff_global_array = NaN(size(lats_2_5,1),size(lats_2_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dVPD_dt_diff_global_array = NaN(size(lats_2_5,1),size(lats_2_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
VWC_diurnal_diff_global_array = NaN(size(lats_2_5,1),size(lats_2_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_fire_global_array = NaN(size(lats_2_5,1),size(lats_2_5,2),5000) ; 

dSM_dt_diff_global_array_nomask = NaN(size(lats_2_5,1),size(lats_2_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dtau_dt_diff_global_array_nomask = NaN(size(lats_2_5,1),size(lats_2_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
dVPD_dt_diff_global_array_nomask = NaN(size(lats_2_5,1),size(lats_2_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 
VWC_diurnal_diff_global_array_nomask = NaN(size(lats_2_5,1),size(lats_2_5,2),(length(sminterp)-1)*(length(tauinterp)-1)) ; 




% defin eoutput arrays 
dtau_dt_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dtau_dt_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

dSM_dt_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dSM_dt_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

dVPD_dt_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
dVPD_dt_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;

VWC_diurnal_pre_3D  = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;
VWC_diurnal_post_3D = NaN(length(tauinterp)-1,length(sminterp)-1,5000) ;


%   test     r = 45 ; c = 125   ; 

for r = 1:size(lats_2_5,1)  
    for c = 1:size(lats_2_5,2)  
        
        % find matching EASE row and cols
        [EASE_row, ~ ]= find(lats_Ease_2_5_match(:,1) == r) ; 
        [~, EASE_col ]= find(lons_Ease_2_5_match(1,:) == c) ;    
        
        % get dSM/dt
        dSM_dt_pre_dummy = dSM_dt_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        dSM_dt_post_dummy =  dSM_dt_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;
        % dtau/dt
        dtau_dt_pre_dummy =   dtau_dt_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        dtau_dt_post_dummy =  dtau_dt_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;        
        % dVPD/dt
        dVPD_dt_pre_dummy =   dVPD_dt_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        dVPD_dt_post_dummy =  dVPD_dt_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;   
        % VWC diurnal
        VWC_diurnal_pre_dummy =   VWC_diurnal_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        VWC_diurnal_post_dummy =  VWC_diurnal_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;  
        % dtau change fire
        %dtau_dummy_post =   D_tau_subset_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;
        % get tau 
        tau_pre_dummy =   tau_pre_array(ismember(D_col_pre_array,EASE_col ) & ismember(D_row_pre_array,EASE_row ),:)   ;
        tau_post_dummy =  tau_post_array(ismember(D_col_post_array,EASE_col ) & ismember(D_row_post_array,EASE_row ),:)   ;        
       
      
        
        if(isempty(dSM_dt_pre_dummy) || isempty(dSM_dt_post_dummy))
            continue
        end
        
        
         dSM_dt_diff_sampling_array(r,c,:) = sum(~isnan(dSM_dt_post_dummy),1,'omitnan') ; 
   
        
      dSM_dt_pre_3D(:,:,:) = NaN ; 
      dSM_dt_post_3D(:,:,:) = NaN ; 
      dtau_dt_pre_3D(:,:,:) = NaN ; 
      dtau_dt_post_3D(:,:,:) = NaN ; 
      dVPD_dt_pre_3D(:,:,:) = NaN ; 
      dVPD_dt_post_3D(:,:,:) = NaN ; 
      VWC_diurnal_pre_3D(:,:,:) = NaN ;
      VWC_diurnal_post_3D(:,:,:) = NaN ;
         
        % add addiitonal step for binning into VWC as well  
  for sm = 1:length(sminterp)-1
        cur_sm = sminterp(sm:sm+1) ; 
    
        sminterp_true = sminterp_60 > cur_sm(1) & sminterp_60 < cur_sm(2)  ;
        
    for tau = 1:length(tauinterp)-1        
    cur_tau = tauinterp(tau:tau+1) ;         
    
    % dtau / dt
    dtau_dt_pre_dummy_cut = dtau_dt_pre_dummy(:,sminterp_true) ;
    tau_pre_2D_dummy = dtau_dt_pre_dummy_cut(tau_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 

    dtau_dt_post_dummy_cut = dtau_dt_post_dummy(:,sminterp_true) ;    
    tau_post_2D_dummy = dtau_dt_post_dummy_cut(tau_post_dummy(:,sminterp_true) > cur_tau(1) & tau_post_dummy(:,sminterp_true) < cur_tau(2)) ;    
    
    dtau_dt_pre_3D(sm,tau,1:length(tau_pre_2D_dummy)) = tau_pre_2D_dummy ; 
    dtau_dt_post_3D(sm,tau,1:length(tau_post_2D_dummy)) = tau_post_2D_dummy ;    
    
    % dSM/dt
    dSM_dt_pre_dummy_cut = dSM_dt_pre_dummy(:,sminterp_true) ;
    dSM_pre_2D_dummy = dSM_dt_pre_dummy_cut(tau_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 

    dSM_dt_post_dummy_cut = dSM_dt_post_dummy(:,sminterp_true) ;    
    dSM_dt_post_2D_dummy = dSM_dt_post_dummy_cut(tau_post_dummy(:,sminterp_true) > cur_tau(1) & tau_post_dummy(:,sminterp_true) < cur_tau(2)) ;    
    
    dSM_dt_pre_3D(sm,tau,1:length(dSM_pre_2D_dummy)) = dSM_pre_2D_dummy ; 
    dSM_dt_post_3D(sm,tau,1:length(dSM_dt_post_2D_dummy)) = dSM_dt_post_2D_dummy ;      

%     imagesc(median(dSM_dt_pre_3D,3,'omitnan'))
%     imagesc(median(dSM_dt_post_3D,3,'omitnan'))
    
    
    % dVPD/dt
    dVPD_dt_pre_dummy_cut = dVPD_dt_pre_dummy(:,sminterp_true) ;
    dVPD_pre_2D_dummy = dVPD_dt_pre_dummy_cut(tau_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 

    dVPD_dt_post_dummy_cut = dVPD_dt_post_dummy(:,sminterp_true) ;    
    dVPD_dt_post_2D_dummy = dVPD_dt_post_dummy_cut(tau_post_dummy(:,sminterp_true) > cur_tau(1) & tau_post_dummy(:,sminterp_true) < cur_tau(2)) ;    
    
    dVPD_dt_pre_3D(sm,tau,1:length(dVPD_pre_2D_dummy)) = dVPD_pre_2D_dummy ; 
    dVPD_dt_post_3D(sm,tau,1:length(dVPD_dt_post_2D_dummy)) = dVPD_dt_post_2D_dummy ;  
    
    % VWC diurnal
    VWC_diurnal_pre_dummy_cut = VWC_diurnal_pre_dummy(:,sminterp_true) ;
     VWC_diurnal_pre_2D_dummy = VWC_diurnal_pre_dummy_cut(tau_pre_dummy(:,sminterp_true) > cur_tau(1) & tau_pre_dummy(:,sminterp_true) < cur_tau(2)) ; 

    VWC_diurnal_post_dummy_cut = VWC_diurnal_post_dummy(:,sminterp_true) ;    
    VWC_diurnal_post_2D_dummy = VWC_diurnal_post_dummy_cut(tau_post_dummy(:,sminterp_true) > cur_tau(1) & tau_post_dummy(:,sminterp_true) < cur_tau(2)) ;    
    
    VWC_diurnal_pre_3D(sm,tau,1:length(VWC_diurnal_pre_2D_dummy)) = VWC_diurnal_pre_2D_dummy ; 
    VWC_diurnal_post_3D(sm,tau,1:length(VWC_diurnal_post_2D_dummy)) = VWC_diurnal_post_2D_dummy ;  
    
        
    end
  sm;
  end

           
        
% without any filtering


        dSM_dt_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(median(dSM_dt_post_3D,3,'omitnan') - median(dSM_dt_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        
        dtau_dt_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(median(dtau_dt_post_3D,3,'omitnan') - median(dtau_dt_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        
        
        dVPD_dt_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(median(dVPD_dt_post_3D,3,'omitnan') - median(dVPD_dt_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        
        
        VWC_diurnal_diff_global_array_nomask(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape(median(VWC_diurnal_post_3D,3,'omitnan') - median(VWC_diurnal_pre_3D,3,'omitnan'),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        


%
    
% based on sampling
sampling_threshold = 10 ; 

mask_samples_pre = sum(~isnan(dSM_dt_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dSM_dt_post_3D),3,'omitnan') < sampling_threshold ;
dSM_dt_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dSM_dt_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ; 

mask_samples_pre = sum(~isnan(dtau_dt_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dtau_dt_post_3D),3,'omitnan') < sampling_threshold ;
dtau_dt_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dtau_dt_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;

mask_samples_pre = sum(~isnan(dVPD_dt_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(dVPD_dt_post_3D),3,'omitnan') < sampling_threshold ;
dVPD_dt_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
dVPD_dt_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;

mask_samples_pre = sum(~isnan(VWC_diurnal_pre_3D),3,'omitnan') < sampling_threshold ;
mask_samples_post = sum(~isnan(VWC_diurnal_post_3D),3,'omitnan') < sampling_threshold ;
VWC_diurnal_pre_3D(repmat(mask_samples_pre,[1 1 5000])) = NaN ; 
VWC_diurnal_post_3D(repmat(mask_samples_post,[1 1 5000])) = NaN ;


 %   
        
 
        %        plot(sminterp,dSM_dt_pre_dummy) ; hold on ;  plot(sminterp,dSM_dt_post_dummy)
        
        dSM_dt_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape((median(dSM_dt_post_3D,3,'omitnan') - median(dSM_dt_pre_3D,3,'omitnan')),[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        
        dtau_dt_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape((median(dtau_dt_post_3D,3,'omitnan') - median(dtau_dt_pre_3D,3,'omitnan')) ,[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        
        
        dVPD_dt_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape((median(dVPD_dt_post_3D,3,'omitnan') - median(dVPD_dt_pre_3D,3,'omitnan')) ,[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        
        
        VWC_diurnal_diff_global_array(r,c,1:(length(sminterp)-1)*(length(tauinterp)-1)) = ...
            reshape((median(VWC_diurnal_post_3D,3,'omitnan') - median(VWC_diurnal_pre_3D,3,'omitnan')) ,[(length(sminterp)-1)*(length(tauinterp)-1),1]) ;  
        

        
       % dtau_fire_global_array(r,c,1:length(dtau_dummy_post)) = dtau_dummy_post ; 
        
    
        
        
        
    end
end


dSM_dt_diff_global_array(dSM_dt_diff_global_array == 0) = NaN ; 
dtau_dt_diff_global_array(dtau_dt_diff_global_array == 0) = NaN ; 
dVPD_dt_diff_global_array(dVPD_dt_diff_global_array == 0) = NaN ; 
VWC_diurnal_diff_global_array(VWC_diurnal_diff_global_array == 0) = NaN ; 

dSM_dt_diff_global_array_nomask(dSM_dt_diff_global_array_nomask == 0) = NaN ; 
dtau_dt_diff_global_array_nomask(dtau_dt_diff_global_array_nomask == 0) = NaN ; 
dVPD_dt_diff_global_array_nomask(dVPD_dt_diff_global_array_nomask == 0) = NaN ; 
VWC_diurnal_diff_global_array_nomask(VWC_diurnal_diff_global_array_nomask == 0) = NaN ; 



% convert to prct
dSM_dt_diff_global_array_median = dSM_dt_diff_global_array ; 
dtau_dt_diff_global_array_median = dtau_dt_diff_global_array ; 
% dtau_C_dt_diff_global_array_prct = dtau_C_dt_diff_global_array ; 
dVPD_dt_diff_global_array_median = dVPD_dt_diff_global_array ; 
%  VPD_diff_global_array_median = VPD_diff_global_array ; 
VWC_diurnal_diff_global_array_median = VWC_diurnal_diff_global_array ; 



% save to unburned all previous years as reference
save('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref\dSM_dt_diff_global_array','dSM_dt_diff_global_array','-v7.3')     
save('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref\dtau_dt_diff_global_array','dtau_dt_diff_global_array','-v7.3')     
save('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref\dVPD_dt_diff_global_array','dVPD_dt_diff_global_array','-v7.3')     
save('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref\VWC_diurnal_diff_global_array','VWC_diurnal_diff_global_array','-v7.3')     

save('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref\dSM_dt_diff_global_array_nomask','dSM_dt_diff_global_array_nomask','-v7.3')     
save('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref\dtau_dt_diff_global_array_nomask','dtau_dt_diff_global_array_nomask','-v7.3')     
save('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref\dVPD_dt_diff_global_array_nomask','dVPD_dt_diff_global_array_nomask','-v7.3')     
save('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref\VWC_diurnal_diff_global_array_nomask','VWC_diurnal_diff_global_array_nomask','-v7.3')     





%%



















