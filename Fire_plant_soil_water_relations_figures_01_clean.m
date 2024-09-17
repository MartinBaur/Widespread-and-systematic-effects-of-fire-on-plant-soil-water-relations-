%% MJB plotting clean 

% MJB  Load data binned into phase space and binned into map
% then plot into final panels
clear

cd('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref')

% load all files
files = dir('*.mat');
for i=1:length(files)
    load(files(i).name);
end


cd('E:\Daten Baur\Matlab code')
col_L = hex2rgb('808080') ; 
col_L_light = hex2rgb('CDCDCD') ; 

col_C = hex2rgb('3399FF') ;
col_C_light = hex2rgb('80E6FF') ; 

col_X = hex2rgb('FF3333') ;
col_X_light = hex2rgb('FF8080') ; 

cd('E:\Daten Baur\Matlab code\redblue')
redblue_color = redblue(100) ; 
viridis_color = viridis(100) ; 
bam_color = crameri('bam') ;
cork_color = crameri('cork') ;
sminterp_60 = linspace( 0.001,0.5999,60 ); 

cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('Coastlines.mat')


lons_2_5 = (-180+2.5):5:(180-2.5)   ; 
lons_2_5 = repmat(lons_2_5,[36, 1]) ; 

lats_2_5 = fliplr((-90+2.5):5:(90-2.5))   ; 
lats_2_5 = repmat(lats_2_5',[1, 72]) ; 



% severity_chars_NBR_final{1} = '' ;
% severity_chars_NBR_final{2} = '' ;
% severity_chars_NBR_final{6} = '' ;
% severity_chars_NBR_final{7} = '' ;




%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New Figures 20.02.2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% Panel 1 dSM/dt


% diff_test_rel_prct = (test_post' - test_pre' ) ./ abs(test_pre') .* 100 ; 
% htest = pcolor(sminterp,tauinterp,diff_test_rel_prct) ;
% set(htest,'LineStyle','none')
% shading flat
% colormap(redblue_color) ; caxis([-80 80])
% median_prct = median(diff_test_rel_prct(:),'omitnan') ;
% std_prct = std(diff_test_rel_prct(:),'omitnan') ;




sminterp = linspace( 0.001,0.5999,31 ); 
tauinterp = linspace(0.001,0.9999,31) ; 

sminterp = sminterp + 0.0200/2 ; 
tauinterp = tauinterp + 0.0333/2 ; 

sminterp = sminterp(1:end-1) ; 
tauinterp = tauinterp(1:end-1) ; 
tauinterp = tauinterp ./  0.11 ; 



Fig_Panel = figure('units','centimeters','position',[10 2 40 26])  ;
test_pre = dSM_dt_phase_space_pre ; 
test_post = dSM_dt_phase_space_post ; 
% test_pre = dSM_dt_ESACCI_fully_binned_pre ; 
% test_post = dSM_dt_ESACCI_fully_binned_post ; 



sub1 = subplot(2,3,1) ; 
h1 = pcolor(sminterp,tauinterp,test_pre') ;
set(h1,'LineStyle','none')
shading flat
caxis([-0.07 0]) % dSM/dt
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color(1:128,:))) % dSM/dt
xticks([0:0.2:0.6])
xticklabels({'0','0.2','0.4','0.6'})
xtickangle(45)
xlabel('SM [m³/m³]')
%ylabel('\tau mean [Np]')
title('pre-fire')
yticks([0:1:9])
yticklabels({'0','1','2','3','4','5','6','7','8','9'})
ylabel('VWC mean [kg/m²]')
set(gca,'FontSize',15)
pbaspect([1 1 1])

%postfire
sub2 = subplot(2,3,2) ; 
h2 = pcolor(sminterp,tauinterp,test_post') ;
set(h2,'LineStyle','none')
shading flat
caxis([-0.07 0]) % dSM/dt
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color(1:128,:))) % VWC diurnal
hcb = colorbar ;
set(hcb, 'FontSize',15)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,'\DeltaSM/\Deltat [m³/m³/day]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post-fire')
xlabel('SM [m³/m³]')
xtickangle(45)
yticklabels('')
set(gca,'FontSize',16)
pbaspect([1 1 1])

%difference
sub3 = subplot(2,3,3) ; 
h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre')   ) ; 
set(h3,'LineStyle','none')
shading flat
colormap(sub3,redblue_color)
hcb = colorbar ; 
set(hcb, 'FontSize',16,'YTick',-0.06:0.03:0.06)
%set(hcb, 'FontSize',15,'YTick',-100:50:100)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylabel(hcb,' \DeltaSM/\Deltat change [m³/m³/day]','FontSize',16)
%ylabel(hcb,' \DeltaSM/\Deltat change [%]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
caxis([-0.06 0.06]) % dSM/dt diurnal
%caxis([-100 100]) % dSM/dt diurnal % 
ylim([-0.00 9])
xlim([-0.00 0.6])
xlabel('SM [m³/m³]')
%ylabel('\tau [Np]')
title('post - pre change')
yticklabels('')
xtickangle(45)
set(gca,'FontSize',16)
pbaspect([1 1 1])
hold on
dots_array = dSM_dt_phase_space_MWU < 0.05 ; 
[dotsr, dotsc] = find(dots_array) ; 
%plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.0834,'.k','MarkerSize',8)  % VWC diurnal
plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.1567,'.k','MarkerSize',8)


diff_test_rel_prct = (test_post' - test_pre' ) ./ abs(test_pre') .* 100 ;
nanmedian(diff_test_rel_prct(:))

% set positions
% figure('units','centimeters','position',[10 3 40 22])  ;
set(sub1,'units','centimeters','position',  [ 2.5, 16, 8,  8])
set(sub2,'units','centimeters','position',  [2.5+8+0.7, 16,  8,  8])
set(sub3,'units','centimeters','position',  [2.5+8+8+5+2.4 , 16,  8,  8])

% add labels
textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [2.5, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox2 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 20) ; 
set(textbox2,'Units','centimeters', 'Position', [2.5+8+0.75, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox3 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 20) ; 
set(textbox3,'Units','centimeters', 'Position', [2.5+8+8+5+2.4,16+8+0.25, 1, 1], 'EdgeColor', 'none')

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[25.9000+8+4.5 20.5   0  3.5]) ; 
 set(arrow2,'Position',[25.9000+8+4.5 19.5   0 -3.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','slower SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[25.9000+8+5 20.5   -3.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[25.9000+8+5 19.5   3.5  0]) ; 
set(gca,'Box','on');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(dSM_dt_diff_global_array_median,3,'omitnan');
xmap_nomask = median(dSM_dt_diff_global_array_nomask,3,'omitnan');
xmap_nomask(~isnan(xmap)) = NaN ; 

sum(xmap(:) < 0) ./ sum(~isnan(xmap(:)))  ; 

sub4 = subplot(2,3,4) ;
h = pcolor(lons_2_5 - 2.5, lats_2_5 + 2.5, xmap); 
set(h,'LineStyle','none')
shading flat
hold on
colormap(sub4,(redblue_color))
clim([-0.03 0.03])% dSM/dt diurnal
%caxis([-100 100])% dSM/dt diurnal prct
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-0.03:0.015:0.03)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'\DeltaSM/\Deltat change [m³/m³/day]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
set(gca,'Fontsize',16)
pbaspect([144 72 1])
% set position
set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25+1, 20,  10])
% inset with pdf
histoaxes = axes('units','centimeters','Position',[ 3.5, 16.5-8-4.25+1, 2.5,  2.5]) ; 
box on
 % Add crosses for pixels with not enough data
[rowfind colfind] = find(~isnan(xmap_nomask)) ; 
crosses1 = plot(sub4,lons_2_5(1,colfind),lats_2_5(rowfind,1),'xk','MarkerSize',7) ; 
histo2 = histogram(xmap,'FaceColor',[0.402, 0.402, 0.402],'EdgeColor','none') ;
set(histoaxes, 'FontSize',12)
xlim([-0.03 0.03])


% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions
% 2.5,2.75,20,10 are the pos of the map

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[2.5+20+4.5-0.4 2.75+5.5   0  4.5]) ; 
 set(arrow2,'Position',[2.5+20+4.5-0.4 2.75+4.5   0 -4.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','slower SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[2.5+20+5-0.4 2.75+5.5   -4.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[2.5+20+5-0.4 2.75+4.5   4.5 -0]) ; 
set(gca,'Box','on');

textbox_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'd)', 'FontSize', 20) ; 
set(textbox_label,'Units','centimeters', 'Position',[ 2.5, 15-5+2+1, 1,  1], 'EdgeColor', 'none')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% severity_chars_NBR_final{1} = '' ;
% severity_chars_NBR_final{2} = '' ;
% severity_chars_NBR_final{6} = '' ;
% severity_chars_NBR_final{7} = '' ;
n_samples_box = sum(~isnan(boxplot_data1NBRSM),1) ; 
positions_vec =  1:7 ; 

sub5 = subplot(2,3,6) ;
set(sub5, 'DefaultTextFontSize', 16);
Post_cur = boxplot(boxplot_data1NBRSM(:,n_samples_box > 10)  ,'Labels',severity_chars_NBR_final((n_samples_box > 10)), ...
    'Whisker', 1.5, 'Jitter', 0.000, 'Positions',positions_vec(n_samples_box > 10),'Width',0.65) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on

% add a 0 line not sure how to move it into the backgorund.
zeroline = yline(0) ; 
uistack(zeroline, 'bottom');


 for j=1:length(boxes1)
   patches1 =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_L,'FaceAlpha',.5);
 end
 hold on

Post_cur = boxplot(boxplot_data1NBRSM(:,n_samples_box > 10)  ,'Labels',severity_chars_NBR_final(n_samples_box > 10), ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10),'Width',0.65) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
xlim([0 8])
 ylim([-0.06 0.06])
yticks([-0.06 -0.03 0 0.03 0.06])

% add n for each box
for i = 1:length(n_samples_box)
    if (n_samples_box(i) > 10)
       n_sample_labels(i) =  text(i-0.35,0.05,strcat('(',num2str(n_samples_box(i)),')'),'FontSize',11)  ;
    end
end


%ylim([-50 50])
xtickangle(45)
ylabel('\DeltaSM/\Deltat change [m³/m³/day]','FontSize',16)
%ylabel('\DeltaSM/\Deltat change [%]','FontSize',16)  % % change
hold on
set(gca,'FontSize',16)
% set position
set(sub5,'units','centimeters','position',  [ 2.5+18+11, 15-8-4.25+1, 8,  8])
xlabel('fire severity \DeltaNBR [-]','FontSize',16)

%set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25, 20,  10])

textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'e)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [ 2.5+18+9+2, 15-3, 1,  1], 'EdgeColor', 'none')
 

% set global fontsize
 fontsize(Fig_Panel, 16, "points")

set(histoaxes, 'FontSize',12)
for i = 1:length(n_sample_labels)
    if  (n_samples_box(i) > 10)
        set(n_sample_labels(i),'FontSize',11)
    end
end

set(Fig_Panel,'PaperOrientation','landscape');
Fig_Panel.Units = 'centimeters';        % set figure units to cm
Fig_Panel.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
Fig_Panel.PaperSize = Fig_Panel.Position(3:4);  % assign to the pdf printing paper the size of the figur


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1','-dpdf')
% saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_04_pre_ref\Panel_1_rescale','svg')
% saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\svg_panels_05_pre_ref_nbox\Panel_1_rescale','svg')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_1','pdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_1','svg')
close 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-depsc')
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-dpdf')
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-dsvg')
% close 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%% Panel 2 dVWC/dt


% diff_test_rel_prct = (test_post' - test_pre' ) ./ abs(test_pre') .* 100 ; 
% % diff_test_rel_prct(dVWC_dt_MWUtestp_post' > 0.05) = NaN ;   
% htest = pcolor(sminterp,tauinterp,diff_test_rel_prct) ;
% set(htest,'LineStyle','none')
% shading flat
% colormap(redblue_color) ; caxis([-100 100])
% median_prct = median(diff_test_rel_prct(:),'omitnan') ;
% std_prct = std(diff_test_rel_prct(:),'omitnan') ;

diff_test_rel_prct = (test_post' - test_pre' ) ./ abs(test_pre') .* 100 ;
nanmedian(diff_test_rel_prct(:))


sminterp = linspace( 0.001,0.5999,31 ); 
tauinterp = linspace(0.001,0.9999,31) ; 

sminterp = sminterp + 0.0200/2 ; 
tauinterp = tauinterp + 0.0333/2 ; 

sminterp = sminterp(1:end-1) ; 
tauinterp = tauinterp(1:end-1) ; 
tauinterp = tauinterp ./  0.11 ; 


Fig_Panel = figure('units','centimeters','position',[10 2 40 26])  ;



test_pre = dVWC_dt_phase_space_pre ; 
test_post = dVWC_dt_phase_space_post ; 

sub1 = subplot(2,3,1) ; 
h1 = pcolor(sminterp,tauinterp,test_pre') ;
set(h1,'LineStyle','none')
shading flat
caxis([-0.2 0.2]) % dVWC/dt
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color)) % dVWC/dt
xticks([0:0.2:0.6])
xticklabels({'0','0.2','0.4','0.6'})
xtickangle(45)
xlabel('SM [m³/m³]','FontSize',16)
title('pre-fire')
%ylabel('\tau mean [Np]')
yticks([0:1:9])
yticklabels({'0','1','2','3','4','5','6','7','8','9'})
ylabel('VWC mean [kg/m²]','FontSize',16)
set(gca,'FontSize',16)
pbaspect([1 1 1])

%postfire
sub2 = subplot(2,3,2) ; 
h2 = pcolor(sminterp,tauinterp,test_post') ;
set(h2,'LineStyle','none')
shading flat
caxis([-0.2 0.2]) % dVWC/dt
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color)) % VWC diurnal
hcb = colorbar ;
set(hcb, 'FontSize',15)
set(hcb, 'FontSize',15,'YTick',-0.2:0.1:0.2)
set(hcb,'TickLabels',{ '-0.2','-0.1','0','0.1','0.2'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,'\DeltaVWC/\Deltat [kg/m²/day]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post-fire')
xlabel('SM [m³/m³]','FontSize',16)
xtickangle(45)
yticklabels('')
set(gca,'FontSize',16)
pbaspect([1 1 1])

%difference
sub3 = subplot(2,3,3) ; 
h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre')  ) ; 
set(h3,'LineStyle','none')
shading flat
colormap(sub3,redblue_color)
hcb = colorbar ; 
 set(hcb, 'FontSize',15,'YTick',-0.2:0.1:0.2)
%set(hcb, 'FontSize',15,'YTick',-500:250:500)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,' \DeltaVWC/\Deltat change [kg/m²/day]','FontSize',16)
% ylabel(hcb,' \DeltaVWC/\Deltat change [%]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post - pre change')
 caxis([-0.2 0.2]) % dVWC/dt
%caxis([-500 500]) % dVWC/dt prct
ylim([-0.00 9])
xlim([-0.00 0.6])
xlabel('SM [m³/m³]','FontSize',16)
%ylabel('\tau [Np]')
yticklabels('')
xtickangle(45)
set(gca,'FontSize',16)
pbaspect([1 1 1])
hold on
dots_array = dVWC_dt_phase_space_MWU < 0.05 ; 
[dotsr, dotsc] = find(dots_array) ; 
%plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.0834,'.k','MarkerSize',8)  % VWC diurnal
plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.1567,'.k','MarkerSize',8)



% set positions
% figure('units','centimeters','position',[10 3 40 22])  ;
set(sub1,'units','centimeters','position',  [ 2.5, 16, 8,  8])
set(sub2,'units','centimeters','position',  [2.5+8+0.7, 16,  8,  8])
set(sub3,'units','centimeters','position',  [2.5+8+8+5+2.4 , 16,  8,  8])

% add labels
textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [2.5, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox2 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 20) ; 
set(textbox2,'Units','centimeters', 'Position', [2.5+8+0.75, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox3 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 20) ; 
set(textbox3,'Units','centimeters', 'Position', [2.5+8+8+5+2.4,16+8+0.25, 1, 1], 'EdgeColor', 'none')

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[25.9000+8+4.5-0.5 20.5   0  3.5]) ; 
 set(arrow2,'Position',[25.9000+8+4.5-0.5 19.5   0 -3.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[25.9000+8+5-0.5 20.5   -3.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC gain' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[25.9000+8+5-0.5 19.5   3.5  0]) ; 
set(gca,'Box','on');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(dtau_dt_diff_global_array_median,3,'omitnan');
xmap_nomask = median(dtau_dt_diff_global_array_nomask,3,'omitnan');
xmap_nomask(~isnan(xmap)) = NaN ; 
sum(xmap(:) > 0) ./ sum(~isnan(xmap(:)))  ; 


sub4 = subplot(2,3,4) ;
h = pcolor(lons_2_5 - 2.5, lats_2_5 + 2.5, xmap); 
set(h,'LineStyle','none')
shading flat
hold on
colormap(sub4,(redblue_color))
caxis([-0.2 0.2])% VWC/dt 
%caxis([-500 500])% VWC/dt prct
hcb2=colorbar;
set(hcb2, 'FontSize',15,'YTick',-0.2:0.1:0.2)
set(hcb2, 'FontSize',16)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'\DeltaVWC/\Deltat change [kg/m²/day]','FontSize',16)
%ylabel(hcb2,'\DeltaVWC/\Deltat change [%]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
set(gca,'Fontsize',16)
pbaspect([144 72 1])
% set position
set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25+1, 20,  10])
% inset with pdf
histoaxes = axes('units','centimeters','Position',[ 3.5, 16.5-8-4.25+1, 2.5,  2.5]) ; 
box on
 % Add crosses for pixels with not enough data
[rowfind colfind] = find(~isnan(xmap_nomask)) ; 
crosses1 = plot(sub4,lons_2_5(1,colfind),lats_2_5(rowfind,1),'xk','MarkerSize',7) ; 

histo2 = histogram(xmap,'FaceColor',[0.402, 0.402, 0.402],'EdgeColor','none') ;
xlim([-0.2 0.2])
set(histoaxes, 'FontSize',12)

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions
% 2.5,2.75,20,10 are the pos of the map

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[2.5+20+4.5-0.9 2.75+5.5   0  4.5]) ; 
 set(arrow2,'Position',[2.5+20+4.5-0.9 2.75+4.5   0 -4.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[2.5+20+5-0.9 2.75+5.5   -4.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC gain' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[2.5+20+5-0.9 2.75+4.5   4.5 -0]) ; 
set(gca,'Box','on');

textbox_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'd)', 'FontSize', 20) ; 
set(textbox_label,'Units','centimeters', 'Position',[ 2.5, 15-5+2+1, 1,  1], 'EdgeColor', 'none')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_samples_box = sum(~isnan(boxplot_data2NBRVWC),1) ; 
positions_vec =  1:7 ; 


sub5 = subplot(2,3,6) ;
set(sub5, 'DefaultTextFontSize', 16);
Post_cur = boxplot(boxplot_data2NBRVWC(:,n_samples_box > 10)  ,'Labels',severity_chars_NBR_final(n_samples_box > 10), ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10),'Width',0.65) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patches1 =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_L,'FaceAlpha',.5);
 end

zeroline = yline(0) ; 
uistack(zeroline, 'bottom');

 hold on
Post_cur = boxplot(boxplot_data2NBRVWC(:,n_samples_box > 10)   ,'Labels',severity_chars_NBR_final(n_samples_box > 10), ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10),'Width',0.65) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
xlim([0 8])
 ylim([-0.4 0.4])
 % yticks([])
%ylim([-300 800])
xtickangle(45)
ylabel('\DeltaVWC/\Deltat change [kg/m²/day]','FontSize',16)
%ylabel('\DeltaVWC/\Deltat change [%]','FontSize',16)
hold on
set(gca,'FontSize',16)
% set position
set(sub5,'units','centimeters','position',  [ 2.5+18+11, 15-8-4.25+1, 8,  8])
xlabel('fire severity \DeltaNBR [-]','FontSize',16)

%set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25, 20,  10])

textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'e)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [ 2.5+18+9+2, 15-3, 1,  1], 'EdgeColor', 'none')
 

% set global fontsize
 fontsize(Fig_Panel, 16, "points")


% add n for each box
for i = 1:length(n_samples_box)
    if (n_samples_box(i) > 10)
       n_sample_labels(i) =  text(i-0.35,-0.25,strcat('(',num2str(n_samples_box(i)),')'),'FontSize',11)  ;
    end
end
set(histoaxes, 'FontSize',12)




set(Fig_Panel,'PaperOrientation','landscape');
Fig_Panel.Units = 'centimeters';        % set figure units to cm
Fig_Panel.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
Fig_Panel.PaperSize = Fig_Panel.Position(3:4);  % assign to the pdf printing paper the size of the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_2','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_2','-dpdf')
% saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_04_pre_ref\Panel_2','svg')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_2','pdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_2','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-depsc')
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-dpdf')
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-dsvg')
% close 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% Panel 3 redo with right proportions


% diff_test_rel_prct = (test_post' - test_pre' ) ./ abs(test_pre') .* 100 ; 
% % diff_test_rel_prct(dVWC_dt_MWUtestp_post' > 0.05) = NaN ;   
% htest = pcolor(sminterp,tauinterp,diff_test_rel_prct) ;
% set(htest,'LineStyle','none')
% shading flat
% colormap(redblue_color) ; caxis([-100 100])
% median_prct = median(diff_test_rel_prct(:),'omitnan') ;
% std_prct = std(diff_test_rel_prct(:),'omitnan') ;


sminterp = linspace( 0.001,0.5999,31 ); 
tauinterp = linspace(0.001,0.9999,31) ; 

sminterp = sminterp + 0.0200/2 ; 
tauinterp = tauinterp + 0.0333/2 ; 

sminterp = sminterp(1:end-1) ; 
tauinterp = tauinterp(1:end-1) ; 

tauinterp = tauinterp ./  0.2046 ; 


Fig_Panel = figure('units','centimeters','position',[10 2 42 26])  ;



test_pre = VWC_diurnal_phase_space_pre ; 
test_post = VWC_diurnal_phase_space_post ; 

sub1 = subplot(2,3,1) ; 
h1 = pcolor(sminterp,tauinterp,test_pre') ;
set(h1,'LineStyle','none')
shading flat
caxis([-0 0.8]) % VWC diurnal
ylim([-0.00 5])
xlim([-0.00 0.6])
colormap((bam_color(129:end,:))) % VWC diurnal
xticks([0:0.2:0.6])
xticklabels({'0','0.2','0.4','0.6'})
xtickangle(45)
title('pre-fire')
xlabel('SM [m³/m³]')
%ylabel('\tau mean [Np]')
yticks([0:1:9])
yticklabels({'0','1','2','3','4','5','6','7','8','9'})
ylabel('VWC_C mean [kg/m²]')
set(gca,'FontSize',15)
pbaspect([1 1 1])

%postfire
sub2 = subplot(2,3,2) ; 
h2 = pcolor(sminterp,tauinterp,test_post') ;
set(h2,'LineStyle','none')
shading flat
caxis([-0 0.8]) % VWC diurnal
ylim([-0.00 5])
xlim([-0.00 0.6])
colormap((bam_color(129:end,:))) % VWC diurnal
hcb = colorbar ;
set(hcb, 'FontSize',15)
set(hcb, 'FontSize',15,'YTick',-0:0.2:0.8)
% set(hcb,'TickLabels',{ '-0.2','-0.1','0','0.1','0.2'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,'\DeltaVWC_{diurnal} [kg/m²]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post-fire')
xlabel('SM [m³/m³]')
xtickangle(45)
yticklabels('')
set(gca,'FontSize',16)
pbaspect([1 1 1])

%difference
sub3 = subplot(2,3,3) ; 
h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre')) ; 
set(h3,'LineStyle','none')
shading flat
colormap(sub3,redblue_color)
hcb = colorbar ; 
set(hcb, 'FontSize',15,'YTick',-0.5:0.25:0.5)
%set(hcb, 'FontSize',15,'YTick',-100:50:100)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,' \DeltaVWC_{diurnal} change [kg/m²]','FontSize',16)
%ylabel(hcb,' \DeltaVWC change [%]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post - pre change')
caxis([-0.5 0.5]) % VWC diurnal
%caxis([-100 100]) % VWC % change
ylim([-0.00 5])
xlim([-0.00 0.6])
xlabel('SM [m³/m³]')
%ylabel('\tau [Np]')
yticklabels('')
xtickangle(45)
set(gca,'FontSize',16)
pbaspect([1 1 1])
hold on
dots_array = VWC_diurnal_phase_space_MWU < 0.05 ; 
[dotsr, dotsc] = find(dots_array) ; 
plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.0834,'.k','MarkerSize',8)  % VWC diurnal
%plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.1567,'.k','MarkerSize',8)


% set positions
% figure('units','centimeters','position',[10 3 40 22])  ;
set(sub1,'units','centimeters','position',  [ 2.5, 16, 8,  8])
set(sub2,'units','centimeters','position',  [2.5+8+0.7, 16,  8,  8])
set(sub3,'units','centimeters','position',  [2.5+8+8+5+2.4 , 16,  8,  8])

% add labels
textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [2.5, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox2 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 20) ; 
set(textbox2,'Units','centimeters', 'Position', [2.5+8+0.75, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox3 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 20) ; 
set(textbox3,'Units','centimeters', 'Position', [2.5+8+8+5+2.4,16+8+0.25, 1, 1], 'EdgeColor', 'none')

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[25.9000+8+4.5-0.5 20.5   0  3.5]) ; 
 set(arrow2,'Position',[25.9000+8+4.5-0.5 19.5   0 -3.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','lower variation' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[25.9000+8+5-0.5 20.5   -3.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','higher variation' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[25.9000+8+5-0.5 19.5   3.5  0]) ; 
set(gca,'Box','on');


 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(VWC_diurnal_diff_global_array_median,3,'omitnan');
xmap_nomask = median(VWC_diurnal_diff_global_array_nomask,3,'omitnan');
xmap_nomask(~isnan(xmap)) = NaN ; 
sum(xmap(:) < 0) ./ sum(~isnan(xmap(:)))  ; 


sub4 = subplot(2,3,4) ;
h = pcolor(lons_2_5 - 2.5, lats_2_5 + 2.5, xmap); 
set(h,'LineStyle','none')
shading flat
hold on
colormap(sub4,(redblue_color))
 caxis([-0.5 0.5])% VWC diurnal
%caxis([-100 100])% VWC % change
hcb2=colorbar;
 set(hcb2, 'FontSize',16,'YTick',-0.5:0.25:0.5)
% set(hcb2, 'FontSize',16,'YTick',-100:50:100)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
 ylabel(hcb2,'\DeltaVWC_{diurnal} change [kg/m²]','FontSize',16)
%ylabel(hcb2,'\DeltaVWC change [%]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
set(gca,'Fontsize',16)
pbaspect([144 72 1])
% set position
set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25+1, 20,  10])
% inset with pdf
histoaxes = axes('units','centimeters','Position',[ 3.5, 16.5-8-4.25+1, 2.5,  2.5]) ; 
box on
 % Add crosses for pixels with not enough data
[rowfind colfind] = find(~isnan(xmap_nomask)) ; 
crosses1 = plot(sub4,lons_2_5(1,colfind),lats_2_5(rowfind,1),'xk','MarkerSize',7) ; 
histo2 = histogram(xmap,'FaceColor',[0.402, 0.402, 0.402],'EdgeColor','none') ;
%xlim([-150 150])
set(histoaxes, 'FontSize',12)

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions
% 2.5,2.75,20,10 are the pos of the map

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[2.5+20+4.5-0.9 2.75+5.5   0  4.5]) ; 
 set(arrow2,'Position',[2.5+20+4.5-0.9 2.75+4.5   0 -4.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','lower variation' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[2.5+20+5-0.9 2.75+5.5   -4.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','higher variation' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[2.5+20+5-0.9 2.75+4.5   4.5 -0]) ; 
set(gca,'Box','on');

textbox_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'd)', 'FontSize', 20) ; 
set(textbox_label,'Units','centimeters', 'Position',[ 2.5, 15-5+2+1, 1,  1], 'EdgeColor', 'none')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[f_pre,xi_pre] = ksdensity(isohydricity_slope_pre,linspace(0,2,200)) ; 
[f_post,xi_post] = ksdensity(isohydricity_slope_post,linspace(0,2,200)) ; 

% man w u test on iso
[MWUtestp_iso,MWUtesth_iso] = ranksum(isohydricity_slope_pre,isohydricity_slope_post) ; 

sub6 = subplot(2,3,6) ; 
histogram(isohydricity_slope_pre,40,'FaceColor',col_C)
hold on
histogram(isohydricity_slope_post,40,'FaceColor',col_X)
ylabel('histogram count [-]')
yyaxis right
plot(xi_pre,f_pre,'-','LineWidth',2.5,'Color',col_C)
hold on
plot(xi_post,f_post,'-','LineWidth',2.5,'Color',col_X)
xlabel('isohydricity slope \sigma [-]')
ylabel('pdf [-]')
lgd = legend('pre fire','post fire','pre fire pdf','post fire pdf') ; 
set(gca,'YColor',[0 0 0]);
set(lgd,'FontSize',12)
xlim([0 2])
% set position
set(sub6,'units','centimeters','position',  [ 2.5+18+11, 15-8-4.25+1, 8,  8])

textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'e)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [ 2.5+18+9+2, 15-3, 1,  1], 'EdgeColor', 'none')
 

% set global fontsize
 fontsize(Fig_Panel, 16, "points")
set(lgd,'FontSize',12)
set(histoaxes, 'FontSize',12)


set(Fig_Panel,'PaperOrientation','landscape');
Fig_Panel.Units = 'centimeters';        % set figure units to cm
Fig_Panel.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
Fig_Panel.PaperSize = Fig_Panel.Position(3:4);  % assign to the pdf printing paper the size of the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_3','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_3','-dpdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_3','pdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_3','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_3_unburned','-depsc')
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_3_unburned','-dpdf')
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_3_unburned','-dsvg')
% close 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%% Extended data panel 1 VWC C-band

% diff_test_rel_prct = (test_post' - test_pre' ) ./ abs(test_pre') .* 100 ; 
% % diff_test_rel_prct(dVWC_dt_MWUtestp_post' > 0.05) = NaN ;   
% htest = pcolor(sminterp,tauinterp,diff_test_rel_prct) ;
% set(htest,'LineStyle','none')
% shading flat
% colormap(redblue_color) ; caxis([-100 100])
% median_prct = median(diff_test_rel_prct(:),'omitnan') ;
% std_prct = std(diff_test_rel_prct(:),'omitnan') ;


sminterp = linspace( 0.001,0.5999,31 ); 
tauinterp = linspace(0.001,0.9999,31) ; 

sminterp = sminterp + 0.0200/2 ; 
tauinterp = tauinterp + 0.0333/2 ; 

sminterp = sminterp(1:end-1) ; 
tauinterp = tauinterp(1:end-1) ; 
tauinterp = tauinterp ./  0.2046 ; 


Fig_Panel = figure('units','centimeters','position',[10 2 40 26])  ;



test_pre = dVWC_dt_C_phase_space_pre ; 
test_post = dVWC_dt_C_phase_space_post ; 

diff_test_rel_prct = (test_post' - test_pre' ) ./ abs(test_pre') .* 100 ;
nanmedian(diff_test_rel_prct(:))

sub1 = subplot(2,3,1) ; 
h1 = pcolor(sminterp,tauinterp,test_pre') ;
set(h1,'LineStyle','none')
shading flat
caxis([-0.2 0.2]) % dVWC/dt
ylim([-0.00 5])
xlim([-0.00 0.6])
colormap((bam_color)) % dVWC/dt
xticks([0:0.2:0.6])
xticklabels({'0','0.2','0.4','0.6'})
xtickangle(45)
xlabel('SM [m³/m³]','FontSize',16)
%ylabel('\tau mean [Np]')
title('pre-fire')
yticks([0:1:9])
yticklabels({'0','1','2','3','4','5','6','7','8','9'})
ylabel('VWC_C mean [kg/m²]','FontSize',16)
set(gca,'FontSize',16)
pbaspect([1 1 1])

%postfire
sub2 = subplot(2,3,2) ; 
h2 = pcolor(sminterp,tauinterp,test_post') ;
set(h2,'LineStyle','none')
shading flat
caxis([-0.2 0.2]) % dVWC/dt
ylim([-0.00 5])
xlim([-0.00 0.6])
colormap((bam_color)) % VWC diurnal
hcb = colorbar ;
set(hcb, 'FontSize',15)
set(hcb, 'FontSize',15,'YTick',-0.2:0.1:0.2)
set(hcb,'TickLabels',{ '-0.2','-0.1','0','0.1','0.2'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,'\DeltaVWC_C/\Deltat [kg/m²/day]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post-fire')
xlabel('SM [m³/m³]','FontSize',16)
xtickangle(45)
yticklabels('')
set(gca,'FontSize',16)
pbaspect([1 1 1])

%difference
sub3 = subplot(2,3,3) ; 
h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre')) ; 
set(h3,'LineStyle','none')
shading flat
colormap(sub3,redblue_color)
hcb = colorbar ; 
 set(hcb, 'FontSize',15,'YTick',-0.2:0.1:0.2)
%set(hcb, 'FontSize',16,'YTick',-500:250:500)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,' \DeltaVWC_C/\Deltat change [kg/m²/day]','FontSize',16)
% ylabel(hcb,' \DeltaVWC_C/\Deltat change [%]','FontSize',16)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post - pre change')
caxis([-0.2 0.2]) % dVWC/dt
%caxis([-500 500]) % dVWC/dt %
ylim([-0.00 5])
xlim([-0.00 0.6])
xlabel('SM [m³/m³]','FontSize',16)
%ylabel('\tau [Np]')
yticklabels('')
xtickangle(45)
set(gca,'FontSize',16)
pbaspect([1 1 1])
hold on
dots_array = dVWC_dt_C_phase_space_MWU < 0.05 ; 
[dotsr, dotsc] = find(dots_array) ; 
plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.0834,'.k','MarkerSize',8)  % VWC diurnal
%plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.1567,'.k','MarkerSize',8)


% set positions
% figure('units','centimeters','position',[10 3 40 22])  ;
set(sub1,'units','centimeters','position',  [ 2.5, 16, 8,  8])
set(sub2,'units','centimeters','position',  [2.5+8+0.7, 16,  8,  8])
set(sub3,'units','centimeters','position',  [2.5+8+8+5+2.4 , 16,  8,  8])

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions

% add labels
textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [2.5, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox2 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 20) ; 
set(textbox2,'Units','centimeters', 'Position', [2.5+8+0.75, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox3 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 20) ; 
set(textbox3,'Units','centimeters', 'Position', [2.5+8+8+5+2.4,16+8+0.25, 1, 1], 'EdgeColor', 'none')

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[25.9000+8+4.5-0.5 20.5   0  3.5]) ; 
 set(arrow2,'Position',[25.9000+8+4.5-0.5 19.5   0 -3.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC gain' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[25.9000+8+5-0.5 20.5   -3.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[25.9000+8+5-0.5 19.5   3.5  0]) ; 
set(gca,'Box','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(dtau_C_dt_diff_global_array_median,3,'omitnan');
xmap_nomask = median(dtau_C_dt_diff_global_array_nomask,3,'omitnan');
xmap_nomask(~isnan(xmap)) = NaN ; 
sum(xmap(:) > 0) ./ sum(~isnan(xmap(:)))  ; 


sub4 = subplot(2,3,4) ;
h = pcolor(lons_2_5 - 2.5, lats_2_5 + 2.5, xmap); 
set(h,'LineStyle','none')
shading flat
hold on
colormap(sub4,(redblue_color))
 caxis([-0.2 0.2])% VWC/dt diurnal
%caxis([-500 500])% VWC/dt diurnal
hcb2=colorbar;
set(hcb2, 'FontSize',16)
% set(hcb2, 'FontSize',15,'YTick',-500:250:500)
set(hcb2, 'FontSize',15,'YTick',-0.2:0.1:0.2)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'\DeltaVWC_C/\Deltat change [kg/m²/day]','FontSize',16)
%ylabel(hcb2,'\DeltaVWC_C/\Deltat change [%]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
set(gca,'Fontsize',16)
pbaspect([144 72 1])
% set position
set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25+1, 20,  10])
% inset with pdf
histoaxes = axes('units','centimeters','Position',[ 3.5, 16.5-8-4.25+1, 2.5,  2.5]) ; 
box on
 % Add crosses for pixels with not enough data
[rowfind colfind] = find(~isnan(xmap_nomask)) ; 
crosses1 = plot(sub4,lons_2_5(1,colfind),lats_2_5(rowfind,1),'xk','MarkerSize',7) ; 
histo2 = histogram(xmap,'FaceColor',[0.402, 0.402, 0.402],'EdgeColor','none') ;
xlim([-0.2 0.2])
set(histoaxes, 'FontSize',12)

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[2.5+20+4.5-0.9 2.75+5.5   0  4.5]) ; 
 set(arrow2,'Position',[2.5+20+4.5-0.9 2.75+4.5   0 -4.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC gain' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[2.5+20+5-0.9 2.75+5.5   -4.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[2.5+20+5-0.9 2.75+4.5   4.5 -0]) ; 
set(gca,'Box','on');

textbox_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'd)', 'FontSize', 20) ; 
set(textbox_label,'Units','centimeters', 'Position',[ 2.5, 15-5+2+1, 1,  1], 'EdgeColor', 'none')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_samples_box = sum(~isnan(boxplot_data5NBRVWC_C),1) ; 
positions_vec =  1:7 ; 


sub5 = subplot(2,3,6) ;
set(sub5, 'DefaultTextFontSize', 16);
Post_cur = boxplot(boxplot_data5NBRVWC_C(:,n_samples_box > 10)  ,'Labels',severity_chars_NBR_final(n_samples_box > 10), ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10),'Width',0.65) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patches1 =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_L,'FaceAlpha',.5);
 end
 hold on
Post_cur = boxplot(boxplot_data5NBRVWC_C(:,n_samples_box > 10)  ,'Labels',severity_chars_NBR_final(n_samples_box > 10), ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10),'Width',0.65) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
xlim([0 8])
 ylim([-0.4 0.4])
% ylim([-500 500]) % %
 % yticks(-0.2:0.1:0.2)
xtickangle(45)
ylabel('\DeltaVWC_C/\Deltat change  [kg/m^2/day]','FontSize',16)
hold on
set(gca,'FontSize',16)
% set position
set(sub5,'units','centimeters','position',  [ 2.5+18+11, 15-8-4.25+1, 8,  8])
xlabel('fire severity \DeltaNBR [-]','FontSize',16)

zeroline = yline(0) ; 
uistack(zeroline, 'bottom');

%set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25, 20,  10])

textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'e)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [ 2.5+18+9+2, 15-3, 1,  1], 'EdgeColor', 'none')
 
% set global fontsize
 fontsize(Fig_Panel, 16, "points")


set(histoaxes, 'FontSize',12)
% add n for each box
for i = 1:length(n_samples_box)
    if (n_samples_box(i) > 10)
       n_sample_labels(i) =  text(i-0.35,-0.3,strcat('(',num2str(n_samples_box(i)),')'),'FontSize',11)  ;
    end
end


set(Fig_Panel,'PaperOrientation','landscape');
Fig_Panel.Units = 'centimeters';        % set figure units to cm
Fig_Panel.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
Fig_Panel.PaperSize = Fig_Panel.Position(3:4);  % assign to the pdf printing paper the size of the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Extended_Data_Panel_1','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Extended_Data_Panel_1','-dpdf')
% saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_04_pre_ref\Extended_Data_Panel_1','svg')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Extended_Data_Panel_1','pdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Extended_Data_Panel_1','svg')


close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-depsc')
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-dpdf')
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-dsvg')
% close 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Same figures based on unburned reference data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

cd('E:\MOSEV_tiles\datasets_for_final_plots_unburned_all_pre_years_ref')

% load all files
files = dir('*.mat');
for i=1:length(files)
    load(files(i).name);
end



% load ancillaries here 

cd('E:\Daten Baur\Matlab code')
col_L = hex2rgb('808080') ; 
col_L_light = hex2rgb('CDCDCD') ; 

col_C = hex2rgb('3399FF') ;
col_C_light = hex2rgb('80E6FF') ; 

col_X = hex2rgb('FF3333') ;
col_X_light = hex2rgb('FF8080') ; 

cd('E:\Daten Baur\Matlab code\redblue')
redblue_color = redblue(100) ; 
viridis_color = viridis(100) ; 
bam_color = crameri('bam') ;
cork_color = crameri('cork') ;

sminterp = linspace( 0.001,0.5999,30 ); 
sminterp_60 = linspace( 0.001,0.5999,60 ); 
tauinterp = linspace(0.001,0.9999,30) ; 

cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('Coastlines.mat')


lons_2_5 = (-180+2.5):5:(180-2.5)   ; 
lons_2_5 = repmat(lons_2_5,[36, 1]) ; 

lats_2_5 = fliplr((-90+2.5):5:(90-2.5))   ; 
lats_2_5 = repmat(lats_2_5',[1, 72]) ; 







%% Extended Data Panel 1 unburned 




sminterp = linspace( 0.001,0.5999,31 ); 
tauinterp = linspace(0.001,0.9999,31) ; 

sminterp = sminterp + 0.0200/2 ; 
tauinterp = tauinterp + 0.0333/2 ; 

sminterp = sminterp(1:end-1) ; 
tauinterp = tauinterp(1:end-1) ; 
tauinterp = tauinterp ./  0.11 ; 




Fig_Panel = figure('units','centimeters','position',[10 2 40 26])  ;



test_pre = dSM_dt_fully_binned_pre ; 
test_post = dSM_dt_fully_binned_post ; 

sub1 = subplot(2,3,1) ; 
h1 = pcolor(sminterp,tauinterp,test_pre') ;
set(h1,'LineStyle','none')
shading flat
caxis([-0.07 0]) % dSM/dt
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color(1:128,:))) % dSM/dt
xticks([0:0.2:0.6])
xticklabels({'0','0.2','0.4','0.6'})
xtickangle(45)
xlabel('SM [m³/m³]')
%ylabel('\tau mean [Np]')
title('pre')
yticks([0:1:9])
yticklabels({'0','1','2','3','4','5','6','7','8','9'})
ylabel('VWC mean [kg/m²]')
set(gca,'FontSize',15)
pbaspect([1 1 1])

%postfire
sub2 = subplot(2,3,2) ; 
h2 = pcolor(sminterp,tauinterp,test_post') ;
set(h2,'LineStyle','none')
shading flat
caxis([-0.07 0]) % dSM/dt
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color(1:128,:))) % VWC diurnal
hcb = colorbar ;
set(hcb, 'FontSize',15)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,'\DeltaSM/\Deltat [m³/m³/day]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post')
xlabel('SM [m³/m³]')
xtickangle(45)
yticklabels('')
set(gca,'FontSize',16)
pbaspect([1 1 1])

%difference
sub3 = subplot(2,3,3) ; 
h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre') ) ; 
set(h3,'LineStyle','none')
shading flat
colormap(sub3,redblue_color)
hcb = colorbar ; 
 set(hcb, 'FontSize',15,'YTick',-0.06:0.03:0.06)
%set(hcb, 'FontSize',15,'YTick',-100:50:100)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,' \DeltaSM/\Deltat change [m³/m³/day]','FontSize',16)
%ylabel(hcb,' \DeltaSM/\Deltat change [%]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post - pre change')
 caxis([-0.06 0.06]) % dSM/dt diurnal
%caxis([-100 100]) %   % 

ylim([-0.00 9])
xlim([-0.00 0.6])
xlabel('SM [m³/m³]')
%ylabel('\tau [Np]')
yticklabels('')
xtickangle(45)
set(gca,'FontSize',16)
pbaspect([1 1 1])
hold on
dots_array = dSM_dt_MWUtestp_post < 0.05 ; 
[dotsr, dotsc] = find(dots_array) ; 
%plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.0834,'.k','MarkerSize',8)  % VWC diurnal
plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.1567,'.k','MarkerSize',8)


% set positions
% figure('units','centimeters','position',[10 3 40 22])  ;
set(sub1,'units','centimeters','position',  [ 2.5, 16, 8,  8])
set(sub2,'units','centimeters','position',  [2.5+8+0.7, 16,  8,  8])
set(sub3,'units','centimeters','position',  [2.5+8+8+5+2.4 , 16,  8,  8])

% add labels
textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [2.5, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox2 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 20) ; 
set(textbox2,'Units','centimeters', 'Position', [2.5+8+0.75, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox3 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 20) ; 
set(textbox3,'Units','centimeters', 'Position', [2.5+8+8+5+2.4,16+8+0.25, 1, 1], 'EdgeColor', 'none')

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[25.9000+8+4.5 20.5   0  3.5]) ; 
 set(arrow2,'Position',[25.9000+8+4.5 19.5   0 -3.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','slower SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[25.9000+8+5 20.5   -3.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[25.9000+8+5 19.5   3.5  0]) ; 
set(gca,'Box','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(dSM_dt_diff_global_array,3,'omitnan');
xmap_nomask = median(dSM_dt_diff_global_array_nomask,3,'omitnan');
xmap_nomask(~isnan(xmap)) = NaN ; 

% sum(xmap(:) < 0) ./ sum(~isnan(xmap(:)))



sub4 = subplot(2,3,4) ;
h = pcolor(lons_2_5 - 2.5, lats_2_5 + 2.5, xmap); 
set(h,'LineStyle','none')
shading flat
hold on
colormap(sub4,(redblue_color))
 caxis([-0.03 0.03])% dSM/dt diurnal
%caxis([-100 100])% dSM/dt %
hcb2=colorbar;
set(hcb2, 'FontSize',15,'YTick',-0.03:0.015:0.03)
set(hcb2, 'FontSize',16)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'\DeltaSM/\Deltat change [m³/m³/day]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
set(gca,'Fontsize',16)
pbaspect([144 72 1])
% set position
set(sub4,'units','centimeters','position',  [ 8, 15-8-5.25+1, 20,  10])
% inset with pdf
histoaxes = axes('units','centimeters','Position',[ 8+1.5, 16.5-8-4.25+1, 2.5,  2.5]) ; 
box on
 % Add crosses for pixels with not enough data
[rowfind colfind] = find(~isnan(xmap_nomask)) ; 
crosses1 = plot(sub4,lons_2_5(1,colfind),lats_2_5(rowfind,1),'xk','MarkerSize',7) ; 
histo2 = histogram(xmap,'FaceColor',[0.402, 0.402, 0.402],'EdgeColor','none') ;
xlim([-0.03 0.03])
set(histoaxes, 'FontSize',12)

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions
% 8,2.75,20,10 are the pos of the map

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[8+20+4.5-0.4 2.75+5.5   0  4.5]) ; 
 set(arrow2,'Position',[8+20+4.5-0.4 2.75+4.5   0 -4.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','slower SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[8+20+5-0.4 2.75+5.5   -4.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[8+20+5-0.4 2.75+4.5   4.5 -0]) ; 
set(gca,'Box','on');

textbox_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'd)', 'FontSize', 20) ; 
set(textbox_label,'Units','centimeters', 'Position',[ 2.5+5.5, 15-5+2+1, 1,  1], 'EdgeColor', 'none')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 fontsize(Fig_Panel, 16, "points")
set(histoaxes, 'FontSize',12)




set(Fig_Panel,'PaperOrientation','landscape');
Fig_Panel.Units = 'centimeters';        % set figure units to cm
Fig_Panel.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
Fig_Panel.PaperSize = Fig_Panel.Position(3:4);  % assign to the pdf printing paper the size of the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_04_pre_ref\Panel_1_unburned','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-dpdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_1_unburned','pdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_1_unburned','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Extended Data Panel 2 VWC unburned


sminterp = linspace( 0.001,0.5999,31 ); 
tauinterp = linspace(0.001,0.9999,31) ; 

sminterp = sminterp + 0.0200/2 ; 
tauinterp = tauinterp + 0.0333/2 ; 

sminterp = sminterp(1:end-1) ; 
tauinterp = tauinterp(1:end-1) ; 
tauinterp = tauinterp ./  0.11 ; 



Fig_Panel = figure('units','centimeters','position',[10 2 40 26])  ;



test_pre = dVWC_dt_fully_binned_pre ; 
test_post = dVWC_dt_fully_binned_post ; 

sub1 = subplot(2,3,1) ; 
h1 = pcolor(sminterp,tauinterp,test_pre') ;
set(h1,'LineStyle','none')
shading flat
caxis([-0.2 0.2]) % dVWC/dt
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color(1:128,:))) % dVWC/dt
xticks([0:0.2:0.6])
xticklabels({'0','0.2','0.4','0.6'})
xtickangle(45)
xlabel('SM [m³/m³]')
%ylabel('\tau mean [Np]')
title('pre')
yticks([0:1:9])
yticklabels({'0','1','2','3','4','5','6','7','8','9'})
ylabel('VWC mean [kg/m²]')
set(gca,'FontSize',15)
pbaspect([1 1 1])

%postfire
sub2 = subplot(2,3,2) ; 
h2 = pcolor(sminterp,tauinterp,test_post') ;
set(h2,'LineStyle','none')
shading flat
caxis([-0.2 0.2]) % dVWC/dt
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color)) % dVWC/dt
hcb = colorbar ;
set(hcb, 'FontSize',15)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,'\DeltaVWC/\Deltat [kg/m²/day]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post')
xlabel('SM [m³/m³]')
xtickangle(45)
yticklabels('')
set(gca,'FontSize',16)
pbaspect([1 1 1])

%difference
sub3 = subplot(2,3,3) ; 
h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre')) ; 
set(h3,'LineStyle','none')
shading flat
colormap(sub3,redblue_color)
hcb = colorbar ; 
 set(hcb, 'FontSize',15,'YTick',-0.2:0.1:0.2)
%set(hcb, 'FontSize',15,'YTick',-500:250:500)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylabel(hcb,' \DeltaVWC/\Deltat change [kg/m²/day]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post - pre change')
caxis([-0.2 0.2]) % dVWC/dt
%caxis([-500 500]) %  %
ylim([-0.00 9])
xlim([-0.00 0.6])
xlabel('SM [m³/m³]')
%ylabel('\tau [Np]')
yticklabels('')
xtickangle(45)
set(gca,'FontSize',16)
pbaspect([1 1 1])
hold on
dots_array = dSM_dt_MWUtestp_post < 0.05 ; 
[dotsr, dotsc] = find(dots_array) ; 
%plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.0834,'.k','MarkerSize',8)  % VWC diurnal
plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.1567,'.k','MarkerSize',8)


% set positions
% figure('units','centimeters','position',[10 3 40 22])  ;
set(sub1,'units','centimeters','position',  [ 2.5, 16, 8,  8])
set(sub2,'units','centimeters','position',  [2.5+8+0.7, 16,  8,  8])
set(sub3,'units','centimeters','position',  [2.5+8+8+5+2.4 , 16,  8,  8])

% add labels
textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [2.5, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox2 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 20) ; 
set(textbox2,'Units','centimeters', 'Position', [2.5+8+0.75, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox3 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 20) ; 
set(textbox3,'Units','centimeters', 'Position', [2.5+8+8+5+2.4,16+8+0.25, 1, 1], 'EdgeColor', 'none')


 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[25.9000+8+4.5-0.4 20.5   0  3.5]) ; 
 set(arrow2,'Position',[25.9000+8+4.5-0.4 19.5   0 -3.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC gain' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[25.9000+8+5-0.4 20.5   -3.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[25.9000+8+5-0.4 19.5   3.5  0]) ; 
set(gca,'Box','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(dtau_dt_diff_global_array,3,'omitnan');
xmap_nomask = median(dtau_dt_diff_global_array_nomask,3,'omitnan');
xmap_nomask(~isnan(xmap)) = NaN ; 


sub4 = subplot(2,3,4) ;
h = pcolor(lons_2_5 - 2.5, lats_2_5 + 2.5, xmap); 
set(h,'LineStyle','none')
shading flat
hold on
colormap(sub4,(redblue_color))
 caxis([-0.2 0.2])% dVWC/dt diurnal
%caxis([-500 500])%  %
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',15,'YTick',-0.2:0.1:0.2)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
 ylabel(hcb2,'\DeltaVWC/\Deltat change [kg/m²/day]','FontSize',16)
%ylabel(hcb2,'\DeltaVWC/\Deltat change [%]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
set(gca,'Fontsize',16)
pbaspect([144 72 1])
% set position
set(sub4,'units','centimeters','position',  [ 8, 15-8-5.25+1, 20,  10])
% inset with pdf
histoaxes = axes('units','centimeters','Position',[ 8+1.5, 16.5-8-4.25+1, 2.5,  2.5]) ; 
box on
 % Add crosses for pixels with not enough data
[rowfind colfind] = find(~isnan(xmap_nomask)) ; 
crosses1 = plot(sub4,lons_2_5(1,colfind),lats_2_5(rowfind,1),'xk','MarkerSize',7) ; 
histo2 = histogram(xmap,'FaceColor',[0.402, 0.402, 0.402],'EdgeColor','none') ;
xlim([- 0.2 0.2])
set(histoaxes, 'FontSize',12)

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions
% 8,2.75,20,10 are the pos of the map

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[8+20+4.5-0.8 2.75+5.5   0  4.5]) ; 
 set(arrow2,'Position',[8+20+4.5-0.8 2.75+4.5   0 -4.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC gain' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[8+20+5-0.8 2.75+5.5   -4.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[8+20+5-0.8 2.75+4.5  4.5 -0]) ; 
set(gca,'Box','on');

textbox_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'd)', 'FontSize', 20) ; 
set(textbox_label,'Units','centimeters', 'Position',[ 2.5+5.5, 15-5+2+1, 1,  1], 'EdgeColor', 'none')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 fontsize(Fig_Panel, 16, "points")
 set(histoaxes, 'FontSize',12)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



set(Fig_Panel,'PaperOrientation','landscape');
Fig_Panel.Units = 'centimeters';        % set figure units to cm
Fig_Panel.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
Fig_Panel.PaperSize = Fig_Panel.Position(3:4);  % assign to the pdf printing paper the size of the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_2_unburned','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_2_unburned','-dpdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_2_unburned','pdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_2_unburned','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% Extended Data Panel 3 unburned

sminterp = linspace( 0.001,0.5999,31 ); 
tauinterp = linspace(0.001,0.9999,31) ; 

sminterp = sminterp + 0.0200/2 ; 
tauinterp = tauinterp + 0.0333/2 ; 

sminterp = sminterp(1:end-1) ; 
tauinterp = tauinterp(1:end-1) ; 
tauinterp = tauinterp ./  0.2046 ; 


Fig_Panel = figure('units','centimeters','position',[10 2 42 26])  ;



test_pre = VWC_diurnal_fully_binned_pre ; 
test_post = VWC_diurnal_fully_binned_post ; 

sub1 = subplot(2,3,1) ; 
h1 = pcolor(sminterp,tauinterp,test_pre') ;
set(h1,'LineStyle','none')
shading flat
caxis([-0 0.8]) % VWC diurnal
ylim([-0.00 5])
xlim([-0.00 0.6])
colormap((bam_color(129:end,:))) % VWC diurnal
xticks([0:0.2:0.6])
xticklabels({'0','0.2','0.4','0.6'})
xtickangle(45)
xlabel('SM [m³/m³]')
%ylabel('\tau mean [Np]')
title('pre')
yticks([0:1:9])
yticklabels({'0','1','2','3','4','5','6','7','8','9'})
ylabel('VWC_C mean [kg/m²]')
set(gca,'FontSize',15)
pbaspect([1 1 1])

%postfire
sub2 = subplot(2,3,2) ; 
h2 = pcolor(sminterp,tauinterp,test_post') ;
set(h2,'LineStyle','none')
shading flat
caxis([-0 0.8]) % VWC diurnal
ylim([-0.00 5])
xlim([-0.00 0.6])
colormap((bam_color(129:end,:))) % VWC diurnal
hcb = colorbar ;
set(hcb, 'FontSize',15)
set(hcb, 'FontSize',15,'YTick',-0:0.2:0.8)
% set(hcb,'TickLabels',{ '-0.2','-0.1','0','0.1','0.2'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,'\DeltaVWC diurnal [kg/m²]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post')
xlabel('SM [m³/m³]')
xtickangle(45)
yticklabels('')
set(gca,'FontSize',16)
pbaspect([1 1 1])

%difference
sub3 = subplot(2,3,3) ; 
h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre')) ; 
set(h3,'LineStyle','none')
shading flat
colormap(sub3,redblue_color)
hcb = colorbar ; 
 set(hcb, 'FontSize',15,'YTick',-0.5:0.25:0.5)
%set(hcb, 'FontSize',15,'YTick',-100:50:100)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,' \DeltaVWC change [kg/m²]','FontSize',16)
%ylabel(hcb,' \DeltaVWC change [%]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post - pre change')
 caxis([-0.5 0.5]) % VWC diurnal
% caxis([-100 100]) % VWC %
ylim([-0.00 5])
xlim([-0.00 0.6])
xlabel('SM [m³/m³]')
%ylabel('\tau [Np]')
yticklabels('')
xtickangle(45)
set(gca,'FontSize',16)
pbaspect([1 1 1])
hold on
dots_array = VWC_diurnal_MWUtestp_post < 0.05 ; 
[dotsr, dotsc] = find(dots_array) ; 
plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.0834,'.k','MarkerSize',8)  % VWC diurnal
%plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.1567,'.k','MarkerSize',8)


% set positions
% figure('units','centimeters','position',[10 3 40 22])  ;
set(sub1,'units','centimeters','position',  [ 2.5, 16, 8,  8])
set(sub2,'units','centimeters','position',  [2.5+8+0.7, 16,  8,  8])
set(sub3,'units','centimeters','position',  [2.5+8+8+5+2.4 , 16,  8,  8])

% add labels
textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [2.5, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox2 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 20) ; 
set(textbox2,'Units','centimeters', 'Position', [2.5+8+0.75, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox3 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 20) ; 
set(textbox3,'Units','centimeters', 'Position', [2.5+8+8+5+2.4,16+8+0.25, 1, 1], 'EdgeColor', 'none')

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[25.9000+8+4.5-0.5 20.5   0  3.5]) ; 
 set(arrow2,'Position',[25.9000+8+4.5-0.5 19.5   0 -3.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','lower variation' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[25.9000+8+5-0.5 20.5   -3.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','higher variation' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[25.9000+8+5-0.5 19.5   3.5  0]) ; 
set(gca,'Box','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(VWC_diurnal_diff_global_array,3,'omitnan');
xmap_nomask = median(VWC_diurnal_diff_global_array_nomask,3,'omitnan');
xmap_nomask(~isnan(xmap)) = NaN ; 


sub4 = subplot(2,3,4) ;
h = pcolor(lons_2_5 - 2.5, lats_2_5 + 2.5, xmap); 
set(h,'LineStyle','none')
shading flat
hold on
colormap(sub4,(redblue_color))
 caxis([-0.5 0.5])% VWC diurnal
%caxis([-100 100])% VWC %
hcb2=colorbar;
 set(hcb2, 'FontSize',16,'YTick',-0.5:0.25:0.5)
%set(hcb2, 'FontSize',16,'YTick',-100:50:100)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
 ylabel(hcb2,'\DeltaVWC change [kg/m²]','FontSize',16)
%ylabel(hcb2,'\DeltaVWC change [%]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
set(gca,'Fontsize',16)
pbaspect([144 72 1])
% set position
set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25+1, 20,  10])
% inset with pdf
histoaxes = axes('units','centimeters','Position',[ 3.5, 16.5-8-4.25+1, 2.5,  2.5]) ; 
box on
 % Add crosses for pixels with not enough data
[rowfind colfind] = find(~isnan(xmap_nomask)) ; 
crosses1 = plot(sub4,lons_2_5(1,colfind),lats_2_5(rowfind,1),'xk','MarkerSize',7) ; 
histo2 = histogram(xmap,'FaceColor',[0.402, 0.402, 0.402],'EdgeColor','none') ;
set(histoaxes, 'FontSize',12)

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions
% 8,2.75,20,10 are the pos of the map


 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[2.5+20+4.5-0.9 2.75+5.5   0  4.5]) ; 
 set(arrow2,'Position',[2.5+20+4.5-0.9 2.75+4.5   0 -4.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','lower variation' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[2.5+20+5-0.9 2.75+5.5   -4.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','higher variation' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[2.5+20+5-0.9 2.75+4.5   4.5 -0]) ; 
set(gca,'Box','on');

textbox_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'd)', 'FontSize', 20) ; 
set(textbox_label,'Units','centimeters', 'Position',[ 2.5, 15-5+2+1, 1,  1], 'EdgeColor', 'none')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[f_pre,xi_pre] = ksdensity(isohydricity_slope_pre,linspace(0,2,200)) ; 
[f_post,xi_post] = ksdensity(isohydricity_slope_post,linspace(0,2,200)) ; 


sub6 = subplot(2,3,6) ; 
histogram(isohydricity_slope_pre,40,'FaceColor',col_C)
hold on
histogram(isohydricity_slope_post,40,'FaceColor',col_X)
ylabel('histogram count [-]')
yyaxis right
plot(xi_pre,f_pre,'-','LineWidth',2.5,'Color',col_C)
hold on
plot(xi_post,f_post,'-','LineWidth',2.5,'Color',col_X)
xlabel('isohydricity slope \sigma [-]')
ylabel('pdf [-]')
lgd = legend('pre','post','pre pdf','post pdf') ; 
set(gca,'YColor',[0 0 0]);
set(lgd,'FontSize',12)
xlim([0 2])
% set position
set(sub6,'units','centimeters','position',  [ 2.5+18+11, 15-8-4.25+1, 8,  8])

textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'e)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [ 2.5+18+9+2, 15-3, 1,  1], 'EdgeColor', 'none')
 

 fontsize(Fig_Panel, 16, "points")
set(lgd,'FontSize',12)
set(histoaxes, 'FontSize',12)


set(Fig_Panel,'PaperOrientation','landscape');
Fig_Panel.Units = 'centimeters';        % set figure units to cm
Fig_Panel.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
Fig_Panel.PaperSize = Fig_Panel.Position(3:4);  % assign to the pdf printing paper the size of the figure



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_3_unburned','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_3_unburned','-dpdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_3_unburned','pdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Panel_3_unburned','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%% Extended data panel 5 VPD


% then plot into final panels
clear

cd('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref')

% load all files
files = dir('*.mat');
for i=1:length(files)
    load(files(i).name);
end


cd('E:\Daten Baur\Matlab code')
col_L = hex2rgb('808080') ; 
col_L_light = hex2rgb('CDCDCD') ; 

col_C = hex2rgb('3399FF') ;
col_C_light = hex2rgb('80E6FF') ; 

col_X = hex2rgb('FF3333') ;
col_X_light = hex2rgb('FF8080') ; 

cd('E:\Daten Baur\Matlab code\redblue')
redblue_color = redblue(100) ; 
viridis_color = viridis(100) ; 
bam_color = crameri('bam') ;
cork_color = crameri('cork') ;

% sminterp = linspace( 0.001,0.5999,30 ); 
sminterp_60 = linspace( 0.001,0.5999,60 ); 
% tauinterp = linspace(0.001,0.9999,30) ; 

cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('Coastlines.mat')


lons_2_5 = (-180+2.5):5:(180-2.5)   ; 
lons_2_5 = repmat(lons_2_5,[36, 1]) ; 

lats_2_5 = fliplr((-90+2.5):5:(90-2.5))   ; 
lats_2_5 = repmat(lats_2_5',[1, 72]) ; 



% severity_chars_NBR_final{1} = '' ;
% severity_chars_NBR_final{2} = '' ;
% severity_chars_NBR_final{6} = '' ;
% severity_chars_NBR_final{7} = '' ;



sminterp = linspace( 0.001,0.5999,31 ); 
tauinterp = linspace(0.001,0.9999,31) ; 

sminterp = sminterp + 0.0200/2 ; 
tauinterp = tauinterp + 0.0333/2 ; 

sminterp = sminterp(1:end-1) ; 
tauinterp = tauinterp(1:end-1) ; 
tauinterp = tauinterp ./  0.11 ; 


Fig_Panel = figure('units','centimeters','position',[10 2 40 26])  ;



test_pre = VPD_phase_space_pre ; 
test_post = VPD_phase_space_post ; 


diff_test_rel_prct = (test_post' - test_pre' ) ./ abs(test_pre') .* 100 ;
nanmedian(diff_test_rel_prct(:))


sub1 = subplot(2,3,1) ; 
h1 = pcolor(sminterp,tauinterp,test_pre') ;
set(h1,'LineStyle','none')
shading flat
caxis([0 5]) % VPD
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color(129:end,:))) % dVWC/dt
xticks([0:0.2:0.6])
xticklabels({'0','0.2','0.4','0.6'})
xtickangle(45)
xlabel('SM [m³/m³]')
title('pre-fire')
%ylabel('\tau mean [Np]')
yticks([0:1:9])
yticklabels({'0','1','2','3','4','5','6','7','8','9'})
ylabel('VWC mean [kg/m²]')
set(gca,'FontSize',15)
pbaspect([1 1 1])

%postfire
sub2 = subplot(2,3,2) ; 
h2 = pcolor(sminterp,tauinterp,test_post') ;
set(h2,'LineStyle','none')
shading flat
caxis([0 5]) % VPD
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color(129:end,:))) % dVWC/dt
hcb = colorbar ;
set(hcb, 'FontSize',15)
set(hcb, 'FontSize',15,'YTick',-0:1:5)
%set(hcb,'TickLabels',{ '-0.2','-0.1','0','0.1','0.2'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,'VPD [kPa]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post-fire')
xlabel('SM [m³/m³]')
xtickangle(45)
yticklabels('')
set(gca,'FontSize',16)
pbaspect([1 1 1])

%difference
sub3 = subplot(2,3,3) ; 
% h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre') ./ abs(test_pre') .* 100) ; 
h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre')) ; 
set(h3,'LineStyle','none')
shading flat
colormap(sub3,redblue_color)
hcb = colorbar ; 
 set(hcb, 'FontSize',15,'YTick',-2:1:2)
%set(hcb, 'FontSize',15,'YTick',-100:50:100)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylabel(hcb,' VPD change [kPa]','FontSize',16)
% ylabel(hcb,' VPD change [%]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post - pre change')
 caxis([-2 2]) % VPD
% caxis([-100 100]) % VPD
ylim([-0.00 9])
xlim([-0.00 0.6])
xlabel('SM [m³/m³]')
%ylabel('\tau [Np]')
yticklabels('')
xtickangle(45)
set(gca,'FontSize',16)
pbaspect([1 1 1])
hold on
dots_array = VPD_phase_space_MWU < 0.05 ; 
[dotsr, dotsc] = find(dots_array) ; 
%plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.0834,'.k','MarkerSize',8)  % VWC diurnal
plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.1567,'.k','MarkerSize',8)


% set positions
% figure('units','centimeters','position',[10 3 40 22])  ;
set(sub1,'units','centimeters','position',  [ 2.5, 16, 8,  8])
set(sub2,'units','centimeters','position',  [2.5+8+0.7, 16,  8,  8])
set(sub3,'units','centimeters','position',  [2.5+8+8+5+2.4 , 16,  8,  8])

% add labels
textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [2.5, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox2 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 20) ; 
set(textbox2,'Units','centimeters', 'Position', [2.5+8+0.75, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox3 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 20) ; 
set(textbox3,'Units','centimeters', 'Position', [2.5+8+8+5+2.4,16+8+0.25, 1, 1], 'EdgeColor', 'none')

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[25.9000+8+4.5-1.1 20.5   0  3.5]) ; 
 set(arrow2,'Position',[25.9000+8+4.5-1.1 19.5   0 -3.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','VPD increase' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[25.9000+8+5-1.1 20.5   -3.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','VPD decrease' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[25.9000+8+5-1.1 19.5   3.5  0]) ; 
set(gca,'Box','on');
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(VPD_diff_global_array_median,3,'omitnan');
xmap_nomask = median(VPD_diff_global_array_nomask,3,'omitnan');
xmap_nomask(~isnan(xmap)) = NaN ; 

sum(xmap(:) > 0) ./ sum(~isnan(xmap(:)))  ; 


sub4 = subplot(2,3,4) ;
h = pcolor(lons_2_5 - 2.5, lats_2_5 + 2.5, xmap); 
set(h,'LineStyle','none')
shading flat
hold on
colormap(sub4,(redblue_color))
caxis([-2 2])% VPD
% caxis([-100 100])% VPD
hcb2=colorbar;
set(hcb2, 'FontSize',16)
 set(hcb2, 'FontSize',16,'YTick',-2:1:2)
%set(hcb2, 'FontSize',16,'YTick',-100:50:100)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
% ylabel(hcb2,'VPD post - VPD pre [kPa]','FontSize',16)
ylabel(hcb2,'VPD change [kPa]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
set(gca,'Fontsize',16)
pbaspect([144 72 1])
% set position
set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25+1, 20,  10]) ; 
% inset with pdf
histoaxes = axes('units','centimeters','Position',[ 3.5, 16.5-8-4.25+1, 2.5,  2.5])
box on
 % Add crosses for pixels with not enough data
[rowfind colfind] = find(~isnan(xmap_nomask)) ; 
crosses1 = plot(sub4,lons_2_5(1,colfind),lats_2_5(rowfind,1),'xk','MarkerSize',7) ; 
histo2 = histogram(xmap,'FaceColor',[0.402, 0.402, 0.402],'EdgeColor','none') ;
set(histoaxes, 'FontSize',12)


 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[2.5+20+4.5-1.5 2.75+5.5   0  4.5]) ; 
 set(arrow2,'Position',[2.5+20+4.5-1.5 2.75+4.5   0 -4.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','VPD increase' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[2.5+20+5-1.5 2.75+5.5   -4.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','VPD decrease' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[2.5+20+5-1.5 2.75+4.5   4.5 -0]) ; 
set(gca,'Box','on');

textbox_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'd)', 'FontSize', 20) ; 
set(textbox_label,'Units','centimeters', 'Position',[ 2.5, 15-5+2+1, 1,  1], 'EdgeColor', 'none')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_samples_box = sum(~isnan(boxplot_data6NBRVPD_day),1) ; 
positions_vec =  1:7 ; 


sub5 = subplot(2,3,6) ;
set(sub5, 'DefaultTextFontSize', 16);
Post_cur = boxplot(boxplot_data6NBRVPD_day(:,n_samples_box > 10)   ,'Labels',severity_chars_NBR_final(n_samples_box > 10) , ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10) ,'Width',0.65) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patches1 =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_L,'FaceAlpha',.5);
 end
 hold on

 zeroline = yline(0) ; 
uistack(zeroline, 'bottom');


Post_cur = boxplot(boxplot_data6NBRVPD_day(:,n_samples_box > 10)   ,'Labels',severity_chars_NBR_final(n_samples_box > 10) , ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10) ,'Width',0.65) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
xlim([0 8])
 ylim([-2 2])
%ylim([-100 100])
xtickangle(45)
ylabel('VPD change [kPa]','FontSize',16)
hold on
set(gca,'FontSize',16)
% set position
set(sub5,'units','centimeters','position',  [ 2.5+18+11, 15-8-4.25+1, 8,  8])
xlabel('fire severity\DeltaNBR [-]','FontSize',16)

%set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25, 20,  10])

textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'e)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [ 2.5+18+9+2, 15-3, 1,  1], 'EdgeColor', 'none')
 
 fontsize(Fig_Panel, 16, "points")


set(histoaxes, 'FontSize',12)
% add n for each box
for i = 1:length(n_samples_box)
    if (n_samples_box(i) > 10)
       n_sample_labels(i) =  text(i-0.35,-1.75,strcat('(',num2str(n_samples_box(i)),')'),'FontSize',11)  ;
    end
end


set(Fig_Panel,'PaperOrientation','landscape');
Fig_Panel.Units = 'centimeters';        % set figure units to cm
Fig_Panel.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
Fig_Panel.PaperSize = Fig_Panel.Position(3:4);  % assign to the pdf printing paper the size of the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Extended_Data_Panel_3_VPD','-depsc')
% print('-image','E:\MOSEV_tiles\MOrSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Extended_Data_Panel_3_VPD','-dpdf')
% saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_04_pre_ref\Extended_Data_Panel_3_VPD','svg')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Extended_Data_Panel_3_VPD','pdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Extended_Data_Panel_3_VPD','svg')

close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%









%% Extended data panel 6 dVWC/dSM shift towards more pulse reserve system



sminterp = linspace( 0.001,0.5999,31 ); 
tauinterp = linspace(0.001,0.9999,31) ; 

sminterp = sminterp + 0.0200/2 ; 
tauinterp = tauinterp + 0.0333/2 ; 

sminterp = sminterp(1:end-1) ; 
tauinterp = tauinterp(1:end-1) ; 
tauinterp = tauinterp ./  0.11 ; 


Fig_Panel = figure('units','centimeters','position',[10 2 40 26])  ;



test_pre = dVWC_dSM_C_phase_space_pre ; 
test_post = dVWC_dSM_C_phase_space_post ; 

sub1 = subplot(2,3,1) ; 
h1 = pcolor(sminterp,tauinterp,test_pre') ;
set(h1,'LineStyle','none')
shading flat
caxis([-8 8]) % dVWC/dSM
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color)) % dVWC/dSM
xticks([0:0.2:0.6])
xticklabels({'0','0.2','0.4','0.6'})
xtickangle(45)
xlabel('SM [m³/m³]')
%ylabel('\tau mean [Np]')
title('pre-fire')
yticks([0:1:9])
yticklabels({'0','1','2','3','4','5','6','7','8','9'})
ylabel('VWC mean [kg/m²]')
set(gca,'FontSize',15)
pbaspect([1 1 1])

%postfire
sub2 = subplot(2,3,2) ; 
h2 = pcolor(sminterp,tauinterp,test_post') ;
set(h2,'LineStyle','none')
shading flat
caxis([-8 8]) % VPD
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color)) % dVWC/dSM
hcb = colorbar ;
set(hcb, 'FontSize',15)
set(hcb, 'FontSize',15,'YTick',-8:4:8)
%set(hcb,'TickLabels',{ '-0.2','-0.1','0','0.1','0.2'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,'\DeltaVWC/\DeltaSM [kgm² per m³/m³]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post-fire')
xlabel('SM [m³/m³]')
xtickangle(45)
yticklabels('')
set(gca,'FontSize',16)
pbaspect([1 1 1])

%difference
sub3 = subplot(2,3,3) ; 
% h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre') ./ abs(test_pre') .* 100) ; 
h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre')) ; 
set(h3,'LineStyle','none')
shading flat
colormap(sub3,redblue_color)
hcb = colorbar ; 
 set(hcb, 'FontSize',15,'YTick',-8:4:8)
%set(hcb, 'FontSize',15,'YTick',-100:50:100)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylabel(hcb,'\DeltaVWC/\DeltaSM change [kgm² per m³/m³]','FontSize',16)
% ylabel(hcb,' VPD change [%]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post - pre change')
 caxis([-8 8]) % dVWC/dSM
% caxis([-100 100]) % 
ylim([-0.00 9])
xlim([-0.00 0.6])
xlabel('SM [m³/m³]')
%ylabel('\tau [Np]')
yticklabels('')
xtickangle(45)
set(gca,'FontSize',16)
pbaspect([1 1 1])
hold on
dots_array = dVWC_dSM_C_phase_space_MWU < 0.05 ; 
[dotsr, dotsc] = find(dots_array) ; 
%plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.0834,'.k','MarkerSize',8)  % VWC diurnal
plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.1567,'.k','MarkerSize',8)

% add labels
textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [2.5, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox2 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 20) ; 
set(textbox2,'Units','centimeters', 'Position', [2.5+8+0.75, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox3 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 20) ; 
set(textbox3,'Units','centimeters', 'Position', [2.5+8+8+5+2.4,16+8+0.25, 1, 1], 'EdgeColor', 'none')



% set positions
% figure('units','centimeters','position',[10 3 40 22])  ;
set(sub1,'units','centimeters','position',  [ 2.5, 16, 8,  8])
set(sub2,'units','centimeters','position',  [2.5+8+0.7, 16,  8,  8])
set(sub3,'units','centimeters','position',  [2.5+8+8+5+2.4 , 16,  8,  8])

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[25.9000+8+4.5-1 20.5   0  3.5]) ; 
 set(arrow2,'Position',[25.9000+8+4.5-1 19.5   0 -3.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','\downarrow SM-VWC coupling' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[25.9000+8+5-1 20.5   -3.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','\uparrow SM-VWC coupling' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[25.9000+8+5-1 19.5   3.5  0]) ; 
set(gca,'Box','on');
 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(dVWC_dSM_dt_diff_global_array_median,3,'omitnan');
xmap_nomask = median(dVWC_dSM_dt_diff_global_array_nomask,3,'omitnan');
xmap_nomask(~isnan(xmap)) = NaN ; 


sub4 = subplot(2,3,4) ;
h = pcolor(lons_2_5 - 2.5, lats_2_5 + 2.5, xmap); 
set(h,'LineStyle','none')
shading flat
hold on
colormap(sub4,(redblue_color))
caxis([-8 8])% VPD
% caxis([-100 100])% VPD
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-8:4:8)
%set(hcb2, 'FontSize',16,'YTick',-100:50:100)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
% ylabel(hcb2,'VPD post - VPD pre [kPa]','FontSize',16)
ylabel(hcb2,'\DeltaVWC/\DeltaSM change [kgm² per m³/m³]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
set(gca,'Fontsize',16)
pbaspect([144 72 1])
% set position
set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25+1, 20,  10])
% inset with pdf
histoaxes = axes('units','centimeters','Position',[ 3.5, 16.5-8-4.25+1, 2.5,  2.5]) ; 
box on
 % Add crosses for pixels with not enough data
[rowfind colfind] = find(~isnan(xmap_nomask)) ; 
crosses1 = plot(sub4,lons_2_5(1,colfind),lats_2_5(rowfind,1),'xk','MarkerSize',7) ; 
histo2 = histogram(xmap,'FaceColor',[0.402, 0.402, 0.402],'EdgeColor','none') ;
xlim([-8 8])
set(histoaxes, 'FontSize',12)

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[2.5+20+4.5-1.3 2.75+5.5   0  4.5]) ; 
 set(arrow2,'Position',[2.5+20+4.5-1.3 2.75+4.5   0 -4.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','\downarrow SM-VWC coupling' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[2.5+20+5-1.3 2.75+5.5   -4.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','\uparrow SM-VWC coupling' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[2.5+20+5-1.3 2.75+4.5   4.5 -0]) ; 
set(gca,'Box','on');

textbox_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'd)', 'FontSize', 20) ; 
set(textbox_label,'Units','centimeters', 'Position',[ 2.5, 15-5+2+1, 1,  1], 'EdgeColor', 'none')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_samples_box = sum(~isnan(boxplot_data7dVWCdSM),1) ; 
positions_vec =  1:7 ; 

sub5 = subplot(2,3,6) ;
set(sub5, 'DefaultTextFontSize', 16);
Post_cur = boxplot(boxplot_data7dVWCdSM(:,n_samples_box > 10)  ,'Labels',severity_chars_NBR_final(n_samples_box > 10), ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10),'Width',0.65) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patches1 =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_L,'FaceAlpha',.5);
 end
 hold on

  zeroline = yline(0) ; 
uistack(zeroline, 'bottom');


Post_cur = boxplot(boxplot_data7dVWCdSM(:,n_samples_box > 10)  ,'Labels',severity_chars_NBR_final(n_samples_box > 10), ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10),'Width',0.65) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
xlim([0 8])
ylim([-9 9])
yticks(-8:4:8)
%ylim([-100 100])
xtickangle(45)
ylabel('\DeltaVWC/\DeltaSM change [kgm^{2} per m³/m³]','FontSize',16)
hold on
set(gca,'FontSize',16)
% set position
set(sub5,'units','centimeters','position',  [ 2.5+18+11, 15-8-4.25+1, 8,  8])
xlabel('fire severity \DeltaNBR [-]','FontSize',16)

%set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25, 20,  10])

textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'e)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [ 2.5+18+9+2, 15-3, 1,  1], 'EdgeColor', 'none')

fontsize(Fig_Panel, 16, "points")


set(histoaxes, 'FontSize',12)
% add n for each box
for i = 1:length(n_samples_box)
    if (n_samples_box(i) > 10)
       n_sample_labels(i) =  text(i-0.35,6,strcat('(',num2str(n_samples_box(i)),')'),'FontSize',11)  ;
    end
end



set(Fig_Panel,'PaperOrientation','landscape');
Fig_Panel.Units = 'centimeters';        % set figure units to cm
Fig_Panel.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
Fig_Panel.PaperSize = Fig_Panel.Position(3:4);  % assign to the pdf printing paper the size of the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Extended_Data_Panel_4_dVWC_dSM','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Extended_Data_Panel_4_dVWC_dSM','-dpdf')
% saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_04_pre_ref\Extended_Data_Panel_4_dVWC_dSM','svg')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Extended_Data_Panel_4_dVWC_dSM','pdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Extended_Data_Panel_4_dVWC_dSM','svg')

close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Review Panel 7 VPD from ERA5 land




sminterp = linspace( 0.001,0.5999,31 ); 
tauinterp = linspace(0.001,0.9999,31) ; 

sminterp = sminterp + 0.0200/2 ; 
tauinterp = tauinterp + 0.0333/2 ; 

sminterp = sminterp(1:end-1) ; 
tauinterp = tauinterp(1:end-1) ; 
tauinterp = tauinterp ./  0.11 ; 


Fig_Panel = figure('units','centimeters','position',[10 2 40 26])  ;



test_pre = VPD_ERA_phase_space_pre ; 
test_post = VPD_ERA_phase_space_post ; 

sub1 = subplot(2,3,1) ; 
h1 = pcolor(sminterp,tauinterp,test_pre') ;
set(h1,'LineStyle','none')
shading flat
caxis([0 5]) % VPD
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color(129:end,:))) % dVWC/dt
xticks([0:0.2:0.6])
xticklabels({'0','0.2','0.4','0.6'})
xtickangle(45)
xlabel('SM [m³/m³]')
title('pre-fire')
%ylabel('\tau mean [Np]')
yticks([0:1:9])
yticklabels({'0','1','2','3','4','5','6','7','8','9'})
ylabel('VWC mean [kg/m²]')
set(gca,'FontSize',15)
pbaspect([1 1 1])

%postfire
sub2 = subplot(2,3,2) ; 
h2 = pcolor(sminterp,tauinterp,test_post') ;
set(h2,'LineStyle','none')
shading flat
caxis([0 5]) % VPD
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color(129:end,:))) % dVWC/dt
hcb = colorbar ;
set(hcb, 'FontSize',15)
set(hcb, 'FontSize',15,'YTick',-0:1:5)
%set(hcb,'TickLabels',{ '-0.2','-0.1','0','0.1','0.2'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,'ERA5 VPD [kPa]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post-fire')
xlabel('SM [m³/m³]')
xtickangle(45)
yticklabels('')
set(gca,'FontSize',16)
pbaspect([1 1 1])

%difference
sub3 = subplot(2,3,3) ; 
% h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre') ./ abs(test_pre') .* 100) ; 
h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre')) ; 
set(h3,'LineStyle','none')
shading flat
colormap(sub3,redblue_color)
hcb = colorbar ; 
 set(hcb, 'FontSize',15,'YTick',-2:1:2)
%set(hcb, 'FontSize',15,'YTick',-100:50:100)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylabel(hcb,'ERA5 VPD change [kPa]','FontSize',16)
% ylabel(hcb,' VPD change [%]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post - pre change')
 caxis([-2 2]) % VPD
% caxis([-100 100]) % VPD
ylim([-0.00 9])
xlim([-0.00 0.6])
xlabel('SM [m³/m³]')
%ylabel('\tau [Np]')
yticklabels('')
xtickangle(45)
set(gca,'FontSize',16)
pbaspect([1 1 1])
hold on
dots_array = VPD_ERA_phase_space_MWU < 0.05 ; 
[dotsr, dotsc] = find(dots_array) ; 
%plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.0834,'.k','MarkerSize',8)  % VWC diurnal
plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.1567,'.k','MarkerSize',8)


% set positions
% figure('units','centimeters','position',[10 3 40 22])  ;
set(sub1,'units','centimeters','position',  [ 2.5, 16, 8,  8])
set(sub2,'units','centimeters','position',  [2.5+8+0.7, 16,  8,  8])
set(sub3,'units','centimeters','position',  [2.5+8+8+5+2.4 , 16,  8,  8])



% add labels
textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [2.5, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox2 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 20) ; 
set(textbox2,'Units','centimeters', 'Position', [2.5+8+0.75, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox3 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 20) ; 
set(textbox3,'Units','centimeters', 'Position', [2.5+8+8+5+2.4,16+8+0.25, 1, 1], 'EdgeColor', 'none')


 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[25.9000+8+4.5-1.1 20.5   0  3.5]) ; 
 set(arrow2,'Position',[25.9000+8+4.5-1.1 19.5   0 -3.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','VPD increase' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[25.9000+8+5-1.1 20.5   -3.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','VPD decrease' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[25.9000+8+5-1.1 19.5   3.5  0]) ; 
set(gca,'Box','on');
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(ERAVPD_diff_global_array_median,3,'omitnan');
xmap_nomask = median(ERAVPD_diff_global_array_nomask,3,'omitnan');
xmap_nomask(~isnan(xmap)) = NaN ; 


sum(xmap(:) > 0) ./ sum(~isnan(xmap(:)))  ; 


sub4 = subplot(2,3,4) ;
h = pcolor(lons_2_5 - 2.5, lats_2_5 + 2.5, xmap); 
set(h,'LineStyle','none')
shading flat
hold on
colormap(sub4,(redblue_color))
caxis([-2 2])% VPD
% caxis([-100 100])% VPD
hcb2=colorbar;
set(hcb2, 'FontSize',16)
 set(hcb2, 'FontSize',16,'YTick',-2:1:2)
%set(hcb2, 'FontSize',16,'YTick',-100:50:100)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
% ylabel(hcb2,'VPD post - VPD pre [kPa]','FontSize',16)
ylabel(hcb2,'ERA5 VPD change [kPa]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
set(gca,'Fontsize',16)
pbaspect([144 72 1])
% set position
set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25+1, 20,  10])
% inset with pdf
histoaxes = axes('units','centimeters','Position',[ 3.5, 16.5-8-4.25+1, 2.5,  2.5]) ;
box on
 % Add crosses for pixels with not enough data
[rowfind colfind] = find(~isnan(xmap_nomask)) ; 
crosses1 = plot(sub4,lons_2_5(1,colfind),lats_2_5(rowfind,1),'xk','MarkerSize',7) ; 
histo2 = histogram(xmap,'FaceColor',[0.402, 0.402, 0.402],'EdgeColor','none') ;
set(histoaxes, 'FontSize',12)

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[2.5+20+4.5-1.5 2.75+5.5   0  4.5]) ; 
 set(arrow2,'Position',[2.5+20+4.5-1.5 2.75+4.5   0 -4.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','VPD increase' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[2.5+20+5-1.5 2.75+5.5   -4.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','VPD decrease' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[2.5+20+5-1.5 2.75+4.5   4.5 -0]) ; 
set(gca,'Box','on');

textbox_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'd)', 'FontSize', 20) ; 
set(textbox_label,'Units','centimeters', 'Position',[ 2.5, 15-5+2+1, 1,  1], 'EdgeColor', 'none')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_samples_box = sum(~isnan(boxplot_data7NBRERAVPD),1) ; 
positions_vec =  1:7 ; 



sub5 = subplot(2,3,6) ;
set(sub5, 'DefaultTextFontSize', 16);
Post_cur = boxplot(boxplot_data7NBRERAVPD(:,n_samples_box > 10)   ,'Labels',severity_chars_NBR_final(n_samples_box > 10) , ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10) ,'Width',0.65) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patches1 =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_L,'FaceAlpha',.5);
 end
 hold on
Post_cur = boxplot(boxplot_data7NBRERAVPD(:,n_samples_box > 10)   ,'Labels',severity_chars_NBR_final(n_samples_box > 10) , ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(:,n_samples_box > 10) ,'Width',0.65) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
xlim([0 8])
 ylim([-2 2])
%ylim([-100 100])
 zeroline = yline(0) ; 
uistack(zeroline, 'bottom');
xtickangle(45)
ylabel('ERA5 VPD change [kPa]','FontSize',16)
hold on
set(gca,'FontSize',16)
% set position
set(sub5,'units','centimeters','position',  [ 2.5+18+11, 15-8-4.25+1, 8,  8])
xlabel('fire severity\DeltaNBR [-]','FontSize',16)

%set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25, 20,  10])

textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'e)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [ 2.5+18+9+2, 15-3, 1,  1], 'EdgeColor', 'none')
 
fontsize(Fig_Panel, 16, "points")



set(histoaxes, 'FontSize',12)
% add n for each box
for i = 1:length(n_samples_box)
    if (n_samples_box(i) > 10)
       n_sample_labels(i) =  text(i-0.35,-1.5,strcat('(',num2str(n_samples_box(i)),')'),'FontSize',11)  ;
    end
end




set(Fig_Panel,'PaperOrientation','landscape');
Fig_Panel.Units = 'centimeters';        % set figure units to cm
Fig_Panel.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
Fig_Panel.PaperSize = Fig_Panel.Position(3:4);  % assign to the pdf printing paper the size of the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Extended_Data_Panel_5_ERAVPD','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Extended_Data_Panel_5_ERAVPD','-dpdf')
% saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_04_pre_ref\Extended_Data_Panel_5_ERAVPD','svg')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Extended_Data_Panel_5_ERAVPD','pdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Extended_Data_Panel_5_ERAVPD','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%% Panel 8 Review questions .. reprodcue dSM/dt results using ESACCI over SMAP period



sminterp = linspace( 0.001,0.5999,31 ); 
tauinterp = linspace(0.001,0.9999,31) ; 

sminterp = sminterp + 0.0200/2 ; 
tauinterp = tauinterp + 0.0333/2 ; 

sminterp = sminterp(1:end-1) ; 
tauinterp = tauinterp(1:end-1) ; 
tauinterp = tauinterp ./  0.11 ; 

Fig_Panel = figure('units','centimeters','position',[10 2 40 26])  ;
 test_pre = dSM_dt_ESACCI_phase_space_pre ; 
 test_post = dSM_dt_ESACCI_phase_space_post ; 
% test_pre = dSM_dt_ESACCI_fully_binned_pre ; 
% test_post = dSM_dt_ESACCI_fully_binned_post ; 


% diff_test_rel_prct = (test_post' - test_pre' ) ./ abs(test_pre') .* 100 ;
% nanmedian(diff_test_rel_prct(:))


sub1 = subplot(2,3,1) ; 
h1 = pcolor(sminterp,tauinterp,test_pre') ;
set(h1,'LineStyle','none')
shading flat
caxis([-0.07 0]) % dSM/dt
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color(1:128,:))) % dSM/dt
xticks([0:0.2:0.6])
xticklabels({'0','0.2','0.4','0.6'})
xtickangle(45)
xlabel('SM [m³/m³]')
%ylabel('\tau mean [Np]')
title('pre-fire')
yticks([0:1:9])
yticklabels({'0','1','2','3','4','5','6','7','8','9'})
ylabel('VWC mean [kg/m²]')
set(gca,'FontSize',15)
pbaspect([1 1 1])

%postfire
sub2 = subplot(2,3,2) ; 
h2 = pcolor(sminterp,tauinterp,test_post') ;
set(h2,'LineStyle','none')
shading flat
caxis([-0.07 0]) % dSM/dt
ylim([-0.00 9])
xlim([-0.00 0.6])
colormap((bam_color(1:128,:))) % VWC diurnal
hcb = colorbar ;
set(hcb, 'FontSize',15)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ylabel(hcb,'\DeltaSM/\Deltat [m³/m³/day]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('post-fire')
xlabel('SM [m³/m³]')
xtickangle(45)
yticklabels('')
set(gca,'FontSize',16)
pbaspect([1 1 1])

%difference
sub3 = subplot(2,3,3) ; 
h3 = pcolor(sminterp,tauinterp,(test_post' - test_pre')   ) ; 
set(h3,'LineStyle','none')
shading flat
colormap(sub3,redblue_color)
hcb = colorbar ; 
set(hcb, 'FontSize',15,'YTick',-0.06:0.03:0.06)
%set(hcb, 'FontSize',15,'YTick',-100:50:100)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylabel(hcb,' \DeltaSM/\Deltat change [m³/m³/day]','FontSize',16)
%ylabel(hcb,' \DeltaSM/\Deltat change [%]','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
caxis([-0.06 0.06]) % dSM/dt diurnal
%caxis([-100 100]) % dSM/dt diurnal % 
ylim([-0.00 9])
xlim([-0.00 0.6])
xlabel('SM [m³/m³]')
%ylabel('\tau [Np]')
title('post - pre change')
yticklabels('')
xtickangle(45)
set(gca,'FontSize',16)
pbaspect([1 1 1])
hold on
% dots_array = dSM_dt_ESACCI_MWUtestp_post < 0.05 ;   
dots_array = dSM_dt_ESACCI_phase_space_MWU < 0.05 ; 
[dotsr, dotsc] = find(dots_array) ; 
%plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.0834,'.k','MarkerSize',8)  % VWC diurnal
plot(sminterp(dotsr)+0.0103 ,tauinterp(dotsc)+0.1567,'.k','MarkerSize',8)


% set positions
% figure('units','centimeters','position',[10 3 40 22])  ;
set(sub1,'units','centimeters','position',  [ 2.5, 16, 8,  8])
set(sub2,'units','centimeters','position',  [2.5+8+0.7, 16,  8,  8])
set(sub3,'units','centimeters','position',  [2.5+8+8+5+2.4 , 16,  8,  8])


% add labels
textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [2.5, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox2 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 20) ; 
set(textbox2,'Units','centimeters', 'Position', [2.5+8+0.75, 16+8+0.25, 1, 1], 'EdgeColor', 'none')
textbox3 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 20) ; 
set(textbox3,'Units','centimeters', 'Position', [2.5+8+8+5+2.4,16+8+0.25, 1, 1], 'EdgeColor', 'none')


% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[25.9000+8+4.5 20.5   0  3.5]) ; 
 set(arrow2,'Position',[25.9000+8+4.5 19.5   0 -3.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','slower SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[25.9000+8+5 20.5   -3.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[25.9000+8+5 19.5   3.5  0]) ; 
set(gca,'Box','on');



 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(dSM_dt_ESACCI_diff_global_array,3,'omitnan');
xmap_nomask = median(dSM_dt_ESACCI_diff_global_array_nomask,3,'omitnan');
xmap_nomask(~isnan(xmap)) = NaN ; 

sum(xmap(:) < 0) ./ sum(~isnan(xmap(:)))  ; 

sub4 = subplot(2,3,4) ;
h = pcolor(lons_2_5 - 2.5, lats_2_5 + 2.5, xmap); 
set(h,'LineStyle','none')
shading flat
hold on
colormap(sub4,(redblue_color))
caxis([-0.03 0.03])% dSM/dt diurnal
%caxis([-100 100])% dSM/dt diurnal prct
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',15,'YTick',-0.03:0.015:0.03)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'\DeltaSM/\Deltat change [m³/m³/day]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
set(gca,'Fontsize',16)
pbaspect([144 72 1])
% set position
set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25+1, 20,  10])
% inset with pdf
histoaxes = axes('units','centimeters','Position',[ 3.5, 16.5-8-4.25+1, 2.5,  2.5]) ; 
box on
 % Add crosses for pixels with not enough data
[rowfind colfind] = find(~isnan(xmap_nomask)) ; 
crosses1 = plot(sub4,lons_2_5(1,colfind),lats_2_5(rowfind,1),'xk','MarkerSize',7) ; 
histo2 = histogram(xmap,'FaceColor',[0.402, 0.402, 0.402],'EdgeColor','none') ;
set(histoaxes, 'FontSize',12)
xlim([-0.03 0.03])

% % add arrow with description do it properly now based on position of axes
axes_diff_Position = get(gca, 'Position');
% calc positions
% 2.5,2.75,20,10 are the pos of the map

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',5,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[2.5+20+4.5-0.4 2.75+5.5   0  4.5]) ; 
 set(arrow2,'Position',[2.5+20+4.5-0.4 2.75+4.5   0 -4.5]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','slower SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[2.5+20+5-0.4 2.75+5.5   -4.5  0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[2.5+20+5-0.4 2.75+4.5   4.5 -0]) ; 
set(gca,'Box','on');

textbox_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'd)', 'FontSize', 20) ; 
set(textbox_label,'Units','centimeters', 'Position',[ 2.5, 15-5+2+1, 1,  1], 'EdgeColor', 'none')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
severity_chars_NBR_final{1} = '' ;
severity_chars_NBR_final{2} = '' ;
severity_chars_NBR_final{6} = '' ;
severity_chars_NBR_final{7} = '' ;

n_samples_box = sum(~isnan(boxplot_data1SM_ESACCI_NBR),1) ; 
positions_vec =  1:7 ; 


sub5 = subplot(2,3,6) ;
set(sub5, 'DefaultTextFontSize', 16);
Post_cur = boxplot(boxplot_data1SM_ESACCI_NBR(:,n_samples_box > 10)  ,'Labels',severity_chars_NBR_final(n_samples_box > 10), ...
    'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10),'Width',0.65) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patches1 =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_L,'FaceAlpha',.5);
 end
 hold on

 zeroline = yline(0) ; 
uistack(zeroline, 'bottom');


Post_cur = boxplot(boxplot_data1SM_ESACCI_NBR(:,n_samples_box > 10)  ,'Labels',severity_chars_NBR_final(n_samples_box > 10), ...
     'Whisker', 1.5, 'Jitter', 0.0001, 'Positions',positions_vec(n_samples_box > 10),'Width',0.65) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.3);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
xlim([0 8])
 % ylim([-0.02 0.02])
 ylim([-0.06 0.06])
 yticks([-0.06 -0.03 0 0.03 0.06])

%ylim([-50 50])
xtickangle(45)
ylabel('\DeltaSM/\Deltat change [m³/m³/day]','FontSize',16)
%ylabel('\DeltaSM/\Deltat change [%]','FontSize',16)  % % change
hold on
set(gca,'FontSize',16)
% set position
set(sub5,'units','centimeters','position',  [ 2.5+18+11, 15-8-4.25+1, 8,  8])
xlabel('fire severity \DeltaNBR [-]','FontSize',16)

%set(sub4,'units','centimeters','position',  [ 2.5, 15-8-5.25, 20,  10])

textbox1 = annotation('textbox', [0, 0.2, 0, 0],  'string', 'e)', 'FontSize', 20) ; 
set(textbox1,'Units','centimeters', 'Position', [ 2.5+18+9+2, 15-3, 1,  1], 'EdgeColor', 'none')
 
% set global fontsize
 fontsize(Fig_Panel, 16, "points")


set(histoaxes, 'FontSize',12)
% add n for each box
for i = 1:length(n_samples_box)
    if (n_samples_box(i) > 10)
       n_sample_labels(i) =  text(i-0.35,0.04,strcat('(',num2str(n_samples_box(i)),')'),'FontSize',11)  ;
    end
end



set(Fig_Panel,'PaperOrientation','landscape');
Fig_Panel.Units = 'centimeters';        % set figure units to cm
Fig_Panel.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
Fig_Panel.PaperSize = Fig_Panel.Position(3:4);  % assign to the pdf printing paper the size of the figure



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Extended_Data_Panel_6_ESACCI','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Extended_Data_Panel_6_ESACCI','-dpdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Extended_Data_Panel_6_ESACCI','pdf')
saveas(Fig_Panel,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Extended_Data_Panel_6_ESACCI','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-depsc')
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-dpdf')
% print('-opengl','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\eps_panels_03\Panel_1_unburned','-dsvg')
% close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% 
clear
% do multiplot of dSM/dt, dVWC/dt, dVOD/dt and water balance impact...
% claculate water balance impact time corrected
sminterp = [ 0.01 : 0.01 : 0.60 ]; 
timeinterp = 1:100 ; 

cd('E:\Daten Baur\Matlab code')
col_L = hex2rgb('808080') ; 
col_L_light = hex2rgb('CDCDCD') ; 

col_C = hex2rgb('3399FF') ;
col_C_light = hex2rgb('80E6FF') ; 

col_X = hex2rgb('FF3333') ;
col_X_light = hex2rgb('FF8080') ; 

cd('E:\Daten Baur\Matlab code\redblue')
redblue_color = redblue(100) ; 
viridis_color = viridis(100) ; 
bam_color = crameri('bam') ;
cork_color = crameri('cork') ;

sminterp = linspace( 0.001,0.5999,30 ); 
sminterp_60 = linspace( 0.001,0.5999,60 ); 
tauinterp = linspace(0.001,0.9999,30) ; 

cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('Coastlines.mat')


lons_2_5 = (-180+2.5):5:(180-2.5)   ; 
lons_2_5 = repmat(lons_2_5,[36, 1]) ; 

lats_2_5 = fliplr((-90+2.5):5:(90-2.5))   ; 
lats_2_5 = repmat(lats_2_5',[1, 72]) ; 

% nboxes = sum(~isnan(dSM_dt_phase_spaces_difference_box),1) ; 
IGBP_char_vec = {'Evergreen needleleaf','Evergreen broadleaf', 'Deciduous needleleaf', 'Deciduous broadleaf', 'Mixed forest',...
    'Closed shrublands','Open shrublands','Woody savanna','Savanna','Grassland','Permanent wetlands','croplands',...
    'Urban','Crop/natural vegetation','Snow and Ice','Barren land','water bodies'} ;

IGBP_char_vec2 = {'Evergreen needleleaf','Evergreen broadleaf', 'Deciduous needleleaf', 'Deciduous broadleaf', 'Mixed forest',...
    'Closed shrublands','Open shrublands','Woody savanna','Savanna','Grassland','Permanent wetlands','croplands',...
     'Crop/natural vegetation','Barren land'} ;



cd('E:\MOSEV_tiles\DD_all_01')

load('DD_Tau_interpSM_array.mat')
load('DD_VPD_interpsm_array.mat')

load('DD_dSM_dt_interpsm_array.mat')
load('DD_SM_interptime_array.mat')
load('DD_Tau_interptime_array.mat')


load('DD_dTau_dt_interpsm_array.mat')
load('DD_dVPD_dt_interpsm_array.mat')
load('DD_dVPD_dt_day_interpsm_array.mat')
load('DD_dtauC_dt_interpsm_array.mat')

load('DD_tauC_Ds_interpsm_array')
load('DD_tauC_As_interpsm_array')


load('DD_dERAVPD_dt_interpsm_array.mat')
load('DD_ERAVPD_interpsm_array.mat')

load('IGBP_DD_array.mat')

load('DD_row.mat')
load('DD_col.mat')
load('D_tau_DD_array.mat')
load('Dist_to_f__min_array.mat')

cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('lat.mat')
load('lon.mat')


% get ESA CCI
cd('F:\ESA_CCI\global_SMAP_time')

load('dSM_dt_interpsm_2D_array.mat')
load('dist_DD_after_previous_f_array.mat')
load('npixelf_previous_f_array.mat')
load('VODCA_interpsm_array.mat')
load('dist_DD_before_next_f_array.mat')
load('rowcol_2D_array.mat')


% get isohydricity and tau index 
cd('E:\MOSEV_tiles\datasets_for_final_plots')
load('isohydricity_slope_post.mat')
load('isohydricity_slope_pre.mat')
cd('E:\MOSEV_tiles\DD_all_01')
load('index_tau_unique.mat')



Isohydricity_difference_array = NaN(661605,1) ; 
Isohydricity_prearray = NaN(661605,1) ; 
Isohydricity_postarray = NaN(661605,1) ; 


for i = 1:length(Isohydricity_difference_array)

iso_pre_dummy =  isohydricity_slope_pre(find(i >= index_tau_unique, 1, 'last' ) ,:) ; 
iso_post_dummy = isohydricity_slope_post(find(i >= index_tau_unique, 1, 'last' ) ,:) ; 
Isohydricity_difference_array(i,:) = iso_post_dummy - iso_pre_dummy ; 
Isohydricity_prearray(i,:) =  iso_pre_dummy ; 
Isohydricity_postarray(i,:) =  iso_post_dummy ; 

i
end




% plot(sum(~isnan(VODCA_interpsm_array),1))
% hold on
% plot(sum(~isnan(dSM_dt_interpsm_2D_array),1))



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
sample_threshold = 1 ;
day_threshold = 365/12 ;
loop_index = 1:48 ; 



% do temporal binning mayb euse 121 days bpost fire
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
 

% dSM/dt ESA CCI 

dSM_dt_ESACCI_subset_post=  dSM_dt_interpsm_2D_array( ...
          dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold  ,:) ;     
   dSM_dt_ESACCI_subset_post(:,sum(~isnan(dSM_dt_ESACCI_subset_post),1,'omitnan') < sample_threshold) = NaN ;   
 dSM_dt_ESACCI_subset_post_cells{i} =  dSM_dt_ESACCI_subset_post ; 
 
 
 dSM_dt_subset_pre=  dSM_dt_interpsm_2D_array( ...
          dist_DD_before_next_f_array < 0+i*day_threshold & dist_DD_before_next_f_array > 0+(i-1)*day_threshold  ,:) ;      
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
           dist_DD_after_previous_f_array < 0+i* day_threshold & dist_DD_after_previous_f_array > 0+(i-1)* day_threshold  ,:) ; 
 tau_VODCA_subset_post(:,sum(~isnan(tau_VODCA_subset_post),1,'omitnan') < sample_threshold) = NaN ; 
    
 tau_VODCA_subset_pre=  VODCA_interpsm_array( ...
           dist_DD_before_next_f_array < 0+i* day_threshold & dist_DD_before_next_f_array > 0+(i-1)* day_threshold   ,:) ; 
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

  D_col_ESACCI_post = rowcol_2D_array( dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold ,2) ;
  D_row_ESACCI_post = rowcol_2D_array( dist_DD_after_previous_f_array < 0+i*day_threshold & dist_DD_after_previous_f_array > 0+(i-1)*day_threshold ,1) ;
  
  D_col_ESACCI_pre = rowcol_2D_array(dist_DD_before_next_f_array < 0+i*day_threshold & dist_DD_before_next_f_array > 0+(i-1)*day_threshold ,2 )  ;
  D_row_ESACCI_pre = rowcol_2D_array( dist_DD_before_next_f_array < 0+i*day_threshold & dist_DD_before_next_f_array > 0+(i-1)*day_threshold,1 ) ; 
 


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



% IGBP
IGBP_post{i} = IGBP_DD_array(D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index) ;
IGBP_pre{i}  = IGBP_DD_array( D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index) ;
 

% do iso pre and post
Iso_post{i} = Isohydricity_postarray(D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index) ;
Iso_pre{i}  = Isohydricity_prearray( D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index) ;
% do iso diff
Iso_diff_pre_cells{i} = Isohydricity_difference_array( D_tau_DD_array  < 10 & Dist_to_f__min_array > 0-i*day_threshold & Dist_to_f__min_array < 0-(i-1)*day_threshold & latlon_logical_index) ;
Iso_diff_post_cells{i} = Isohydricity_difference_array(D_tau_DD_array  <  10 & Dist_to_f__min_array < 0+i*day_threshold & Dist_to_f__min_array > 0+(i-1)*day_threshold & latlon_logical_index) ;






 end 
 
 

 % 121 day
%  select_cells_post = [3 6 9 12] ; 
% 30 day
  select_cells_pre = [12 24 36 48] ; 
 
 % 90 days
 % select_cells_post = [4 8 12 16] ; 


  dSM_dt_post_array  = dSM_dt_subset_post_cells{1} ; 
   % dSM_dt_pre_array  = dSM_dt_subset_pre_cells{select_cells_pre(1)} ; 
 dSM_dt_pre_array =  vertcat(dSM_dt_subset_pre_cells{select_cells_pre(1)}, dSM_dt_subset_pre_cells{select_cells_pre(2)},...
     dSM_dt_subset_pre_cells{select_cells_pre(3)},dSM_dt_subset_pre_cells{select_cells_pre(4)}) ; 

  dSM_dt_ESACCI_post_array  = dSM_dt_ESACCI_subset_post_cells{1} ; 
  % dSM_dt_ESACCI_pre_array  = dSM_dt_ESACCI_subset_pre_cells{select_cells_pre(1)} ; 
  dSM_dt_ESACCI_pre_array =  vertcat(dSM_dt_ESACCI_subset_pre_cells{select_cells_pre(1)}, dSM_dt_ESACCI_subset_pre_cells{select_cells_pre(2)},...
     dSM_dt_ESACCI_subset_pre_cells{select_cells_pre(3)},dSM_dt_ESACCI_subset_pre_cells{select_cells_pre(4)}) ; 


  dtau_dt_post_array  = dtau_dt_subset_post_cells{1} ; 
   % dtau_dt_pre_array  = dtau_dt_subset_pre_cells{select_cells_pre(1)} ;  
  dtau_dt_pre_array =  vertcat(dtau_dt_subset_pre_cells{select_cells_pre(1)}, dtau_dt_subset_pre_cells{select_cells_pre(2)},...
      dtau_dt_subset_pre_cells{select_cells_pre(3)},dtau_dt_subset_pre_cells{select_cells_pre(4)}) ;  

  dtau_C_dt_post_array  = dtau_C_dt_subset_post_cells{1} ; 
   % dtau_C_dt_pre_array  = dtau_C_dt_subset_pre_cells{select_cells_pre(1)} ;
  dtau_C_dt_pre_array =  vertcat(dtau_C_dt_subset_pre_cells{select_cells_pre(1)}, dtau_C_dt_subset_pre_cells{select_cells_pre(2)},...
      dtau_C_dt_subset_pre_cells{select_cells_pre(3)},dtau_C_dt_subset_pre_cells{select_cells_pre(4)}) ;  



  dVPD_dt_post_array  = dVPD_dt_subset_post_cells{1} ; 
  % dVPD_dt_pre_array  = dVPD_dt_subset_pre_cells{select_cells_pre(1)} ;  
  dVPD_dt_pre_array =  vertcat(dVPD_dt_subset_pre_cells{select_cells_pre(1)}, dVPD_dt_subset_pre_cells{select_cells_pre(2)},...
      dVPD_dt_subset_pre_cells{select_cells_pre(3)},dVPD_dt_subset_pre_cells{select_cells_pre(4)}) ;  
 

  VPD_post_array  = VPD_subset_post_cells{1} ; 
  % VPD_pre_array  = VPD_subset_pre_cells{select_cells_pre(1)} ;  
  VPD_pre_array =  vertcat(VPD_subset_pre_cells{select_cells_pre(1)}, VPD_subset_pre_cells{select_cells_pre(2)},...
      VPD_subset_pre_cells{select_cells_pre(3)},VPD_subset_pre_cells{select_cells_pre(4)}) ;  

    dERAVPD_dt_post_array  = dERAVPD_dt_subset_post_cells{1} ; 
  % dERAVPD_dt_pre_array  = dERAVPD_dt_subset_pre_cells{select_cells_pre(1)} ;  
  dVPD_dt_pre_array =  vertcat(dVPD_dt_subset_pre_cells{select_cells_pre(1)}, dVPD_dt_subset_pre_cells{select_cells_pre(2)},...
      dVPD_dt_subset_pre_cells{select_cells_pre(3)},dVPD_dt_subset_pre_cells{select_cells_pre(4)}) ;  
 

  ERAVPD_post_array  = ERAVPD_subset_post_cells{1} ; 
  % ERAVPD_pre_array  = ERAVPD_subset_pre_cells{select_cells_pre(1)} ;  
  ERAVPD_pre_array =  vertcat(ERAVPD_subset_pre_cells{select_cells_pre(1)}, ERAVPD_subset_pre_cells{select_cells_pre(2)},...
      ERAVPD_subset_pre_cells{select_cells_pre(3)},ERAVPD_subset_pre_cells{select_cells_pre(4)}) ;  
 


 VWC_diurnal_post_array  = tauC_diff_subset_post_cells{1} ; 
 % VWC_diurnal_pre_array  = tauC_diff_subset_pre_cells{select_cells_pre(1)} ;  
  VWC_diurnal_pre_array =  vertcat(tauC_diff_subset_pre_cells{select_cells_pre(1)}, tauC_diff_subset_pre_cells{select_cells_pre(2)},...
      tauC_diff_subset_pre_cells{select_cells_pre(3)},tauC_diff_subset_pre_cells{select_cells_pre(4)}) ;     
 
 VWC_diurnal_post_array(VWC_diurnal_post_array <= 0) = NaN ; 
 VWC_diurnal_pre_array(VWC_diurnal_pre_array <= 0) = NaN ; 


 D_tau_subset_post_array =  D_tau_subset_post_cells{1} ; 
 % D_tau_subset_pre_array =  D_tau_subset_pre_cells{select_cells_pre(1)} ; 
  D_tau_subset_pre_array =  vertcat(D_tau_subset_pre_cells{select_cells_pre(1)}, D_tau_subset_pre_cells{select_cells_pre(2)},...
      D_tau_subset_pre_cells{select_cells_pre(3)},D_tau_subset_pre_cells{select_cells_pre(4)}) ;
 
 tau_post_array =  tau_subset_post_cells{1} ; 
 % tau_pre_array =  tau_subset_pre_cells{select_cells_pre(1)} ;  
  tau_pre_array =  vertcat(tau_subset_pre_cells{select_cells_pre(1)}, tau_subset_pre_cells{select_cells_pre(2)},...
      tau_subset_pre_cells{select_cells_pre(3)},tau_subset_pre_cells{select_cells_pre(4)}) ;
%  

 tau_VODCA_post_array =  tau_VODCA_subset_post_cells{1} ; 
 % tau_VODCA_pre_array =  tau_VODCA_subset_pre_cells{select_cells_pre(1)} ;  
  tau_VODCA_pre_array =  vertcat(tau_VODCA_subset_pre_cells{select_cells_pre(1)}, tau_VODCA_subset_pre_cells{select_cells_pre(2)},...
      tau_VODCA_subset_pre_cells{select_cells_pre(3)},tau_VODCA_subset_pre_cells{select_cells_pre(4)}) ;


 tau_C_post_array =  tau_C_subset_post_cells{1} ; 
 % tau_C_pre_array =   tau_C_subset_pre_cells{select_cells_pre(1)} ; 
   tau_C_pre_array =  vertcat(tau_C_subset_pre_cells{select_cells_pre(1)}, tau_C_subset_pre_cells{select_cells_pre(2)},...
      tau_C_subset_pre_cells{select_cells_pre(3)},tau_C_subset_pre_cells{select_cells_pre(4)}) ;

 
 D_col_post_array = D_col_post_cells{1} ; 
 % D_col_pre_array = D_col_pre_cells{select_cells_pre(1)} ; 
  D_col_pre_array =  vertcat(D_col_pre_cells{select_cells_pre(1)}, D_col_pre_cells{select_cells_pre(2)},...
      D_col_pre_cells{select_cells_pre(3)},D_col_pre_cells{select_cells_pre(4)}) ; 

 
 D_row_post_array = D_row_post_cells{1} ; 
 % D_row_pre_array = D_row_pre_cells{select_cells_pre(1)} ;   
  D_row_pre_array =  vertcat(D_row_pre_cells{select_cells_pre(1)}, D_row_pre_cells{select_cells_pre(2)},...
      D_row_pre_cells{select_cells_pre(3)},D_row_pre_cells{select_cells_pre(4)}) ; 


 IGBP_post_array = IGBP_post{1} ; 
 % IGBP_pre_array = IGBP_pre{select_cells_pre(1)} ;   
  IGBP_pre_array =  vertcat(IGBP_pre{select_cells_pre(1)}, IGBP_pre{select_cells_pre(2)},...
      IGBP_pre{select_cells_pre(3)},IGBP_pre{select_cells_pre(4)}) ; 




 Iso_post_array = Iso_post{1} ; 
 % Iso_pre_array = Iso_pre{select_cells_pre(1)} ;   
  Iso_pre_array =  vertcat(Iso_pre{select_cells_pre(1)}, Iso_pre{select_cells_pre(2)},...
      Iso_pre{select_cells_pre(3)},Iso_pre{select_cells_pre(4)}) ; 


Iso_diff_post_array = Iso_diff_post_cells{1} ; 
% Iso_diff_pre_array = Iso_diff_pre_cells{select_cells_pre(1)} ;   
  Iso_pre_array =  vertcat(Iso_diff_pre_cells{select_cells_pre(1)}, Iso_diff_pre_cells{select_cells_pre(2)},...
      Iso_diff_pre_cells{select_cells_pre(3)},Iso_diff_pre_cells{select_cells_pre(4)}) ; 


 D_col_ESACCI_post_array = D_col_ESACCI_post_cells{1} ; 
 % D_col_ESACCI_pre_array = D_col_ESACCI_pre_cells{select_cells_pre(1)} ; 
   D_col_ESACCI_pre_array =  vertcat(D_col_ESACCI_pre_cells{select_cells_pre(1)}, D_col_ESACCI_pre_cells{select_cells_pre(2)},...
      D_col_ESACCI_pre_cells{select_cells_pre(3)},D_col_ESACCI_pre_cells{select_cells_pre(4)}) ; 
 D_row_ESACCI_post_array = D_row_ESACCI_post_cells{1} ; 
 % D_row_ESACCI_pre_array = D_row_ESACCI_pre_cells{select_cells_pre(1)} ;   
   D_row_ESACCI_pre_array =  vertcat(D_row_ESACCI_pre_cells{select_cells_pre(1)}, D_row_ESACCI_pre_cells{select_cells_pre(2)},...
      D_row_ESACCI_pre_cells{select_cells_pre(3)},D_row_ESACCI_pre_cells{select_cells_pre(4)}) ; 



  dVWC_dSM_dt_post_array  =  (dtau_dt_subset_post_cells{1} ./ 0.11) ./ dSM_dt_subset_post_cells{1} ; 
   % dVWC_dSM_dt_pre_array  =  (dtau_dt_subset_pre_cells{select_cells_pre(1)} ./ 0.11)  ./ dSM_dt_subset_pre_cells{select_cells_pre(1)} ; 
  
   dVWC_dSM_dt_pre_array =  vertcat( (dtau_dt_subset_pre_cells{select_cells_pre(1)} ./ 0.11)  ./ dSM_dt_subset_pre_cells{select_cells_pre(1)},...
        (dtau_dt_subset_pre_cells{select_cells_pre(2)} ./ 0.11)  ./ dSM_dt_subset_pre_cells{select_cells_pre(2)},...
        (dtau_dt_subset_pre_cells{select_cells_pre(3)} ./ 0.11)  ./ dSM_dt_subset_pre_cells{select_cells_pre(3)},...
        (dtau_dt_subset_pre_cells{select_cells_pre(4)} ./ 0.11)  ./ dSM_dt_subset_pre_cells{select_cells_pre(4)}) ; 
 

 % SM interpt pre and post for drydown length analysis
 SM_interpt_post_array =  SM_interpt_post_cells{1} ; 
 % SM_interpt_pre_array =   SM_interpt_pre_cells{select_cells_pre(1)} ;   
  SM_interpt_pre_array =  vertcat(SM_interpt_pre_cells{select_cells_pre(1)}, SM_interpt_pre_cells{select_cells_pre(2)},...
      SM_interpt_pre_cells{select_cells_pre(3)},SM_interpt_pre_cells{select_cells_pre(4)}) ; 
 








sminterp = linspace( 0.001,0.5999,31 ); 
sminterp_60 = linspace( 0.001,0.5999,60 ); 
tauinterp = linspace(0.001,0.9999,31) ; 





dSM_dt_phase_spaces_post = NaN(30,30,48)  ; 
dSM_dt_phase_spaces_pre = NaN(30,30,48)  ;
dVWC_dt_phase_spaces_post = NaN(30,30,48)  ; 
dVWC_dt_phase_spaces_pre = NaN(30,30,48)  ;


for i = 1:48

dummy_dSM_dt_pre = dSM_dt_subset_pre_cells{i} ; 
dummy_dSM_dt_post = dSM_dt_subset_post_cells{i} ; 

dummy_dVWC_dt_pre = dtau_dt_subset_pre_cells{i} ./0.11 ; 
dummy_dVWC_dt_post = dtau_dt_subset_post_cells{i} ./0.11; 

dummy_tau_post = tau_subset_post_cells{i} ; 
dummy_tau_pre = tau_subset_pre_cells{i} ; 

dSM_dt_phase_space_dummy_post = NaN(30,30,20000)  ; 
dSM_dt_phase_space_dummy_pre = NaN(30,30,20000)  ;
dVWC_dt_phase_space_dummy_post = NaN(30,30,20000)  ; 
dVWC_dt_phase_space_dummy_pre = NaN(30,30,20000)  ;

for sm = 1:30
    
    cur_sm = sminterp(sm:sm+1) ; 
    sm_true = sminterp_60 > cur_sm(1) & sminterp_60 < cur_sm(2) ; 
    
    for tau = 1:30
        
    cur_tau = tauinterp(tau:tau+1) ;         
    
    % dSM/dt
    dummypre = dummy_dSM_dt_pre(:,sm_true) ; 
    tau_diff_dummy_pre = dummypre(dummy_tau_pre(:,sm_true) > cur_tau(1) & dummy_tau_pre(:,sm_true) < cur_tau(2)) ; 
    dummypost = dummy_dSM_dt_post(:,sm_true) ; 
    tau_diff_dummy_post = dummypost(dummy_tau_post(:,sm_true) > cur_tau(1) & dummy_tau_post(:,sm_true) < cur_tau(2)) ;    
    
     dSM_dt_phase_space_dummy_pre(sm,tau,1:length(tau_diff_dummy_pre)) = tau_diff_dummy_pre ; 
     dSM_dt_phase_space_dummy_post(sm,tau,1:length(tau_diff_dummy_post)) = tau_diff_dummy_post ;   

     %dVWC/dt
    dummypre = dummy_dVWC_dt_pre(:,sm_true) ; 
    tau_diff_dummy_pre = dummypre(dummy_tau_pre(:,sm_true) > cur_tau(1) & dummy_tau_pre(:,sm_true) < cur_tau(2)) ; 
    dummypost = dummy_dVWC_dt_post(:,sm_true) ; 
    tau_diff_dummy_post = dummypost(dummy_tau_post(:,sm_true) > cur_tau(1) & dummy_tau_post(:,sm_true) < cur_tau(2)) ;    
    
     dVWC_dt_phase_space_dummy_pre(sm,tau,1:length(tau_diff_dummy_pre)) = tau_diff_dummy_pre ; 
     dVWC_dt_phase_space_dummy_post(sm,tau,1:length(tau_diff_dummy_post)) = tau_diff_dummy_post ;       
        
    end
end

% now  filter
mask_sample_post =  (sum(~isnan(dSM_dt_phase_space_dummy_post),3,'omitnan')  < 20)  ; 
mask_sample_pre =  (sum(~isnan(dSM_dt_phase_space_dummy_pre),3,'omitnan')  < 20)  ; 
mask_sample_post = repmat(mask_sample_post,[1,1,20000]) ; 
mask_sample_pre = repmat(mask_sample_pre,[1,1,20000]) ; 
dSM_dt_phase_space_dummy_pre(mask_sample_pre) = NaN ; 
dSM_dt_phase_space_dummy_post(mask_sample_post) = NaN ; 
% average
dSM_dt_phase_spaces_pre(:,:,i) = median(dSM_dt_phase_space_dummy_pre,3,'omitnan') ; 
dSM_dt_phase_spaces_post(:,:,i) = median(dSM_dt_phase_space_dummy_post,3,'omitnan') ; 

% now  filter
mask_sample_post =  (sum(~isnan(dVWC_dt_phase_space_dummy_post),3,'omitnan')  < 20)  ; 
mask_sample_pre =  (sum(~isnan(dVWC_dt_phase_space_dummy_pre),3,'omitnan')  < 20)  ; 
mask_sample_post = repmat(mask_sample_post,[1,1,20000]) ; 
mask_sample_pre = repmat(mask_sample_pre,[1,1,20000]) ; 
dVWC_dt_phase_space_dummy_pre(mask_sample_pre) = NaN ; 
dVWC_dt_phase_space_dummy_post(mask_sample_post) = NaN ; 
% average
dVWC_dt_phase_spaces_pre(:,:,i) = median(dVWC_dt_phase_space_dummy_pre,3,'omitnan') ; 
dVWC_dt_phase_spaces_post(:,:,i) = median(dVWC_dt_phase_space_dummy_post,3,'omitnan') ; 





i
end





% create reference phasespace form all data

dSM_dt_phase_space_dummy = NaN(30,30,200000) ; 
dVWC_dt_phase_space_dummy = NaN(30,30,200000) ; 

for sm = 1:30
    
    cur_sm = sminterp(sm:sm+1) ; 
    sm_true = sminterp_60 > cur_sm(1) & sminterp_60 < cur_sm(2) ; 
    
    for tau = 1:30
        
    cur_tau = tauinterp(tau:tau+1) ;         
      
    dummy = DD_dSM_dt_interpsm_array(:,sm_true) ; 
    dummy_VWC = DD_dTau_dt_interpsm_array(:,sm_true) ./ 0.11; 

    tau_diff_dummy = dummy(DD_Tau_interpsm_array(:,sm_true) > cur_tau(1) & DD_Tau_interpsm_array(:,sm_true) < cur_tau(2)) ; 
    tau_diff_dummy_02 = dummy_VWC(DD_Tau_interpsm_array(:,sm_true) > cur_tau(1) & DD_Tau_interpsm_array(:,sm_true) < cur_tau(2)) ;     

     dSM_dt_phase_space_dummy(sm,tau,1:length(tau_diff_dummy)) = tau_diff_dummy ; 
     dVWC_dt_phase_space_dummy(sm,tau,1:length(tau_diff_dummy)) = tau_diff_dummy_02 ;    
          
    end

    sm
end

% now  filter
mask_sample =  (sum(~isnan(dSM_dt_phase_space_dummy),3,'omitnan')  < 20)  ; 
mask_sample = repmat(mask_sample,[1,1,200000]) ; 
dSM_dt_phase_space_dummy(mask_sample) = NaN ; 
% average
dSM_dt_phase_all = median(dSM_dt_phase_space_dummy,3,'omitnan') ; 

% now  filter
mask_sample =  (sum(~isnan(dVWC_dt_phase_space_dummy),3,'omitnan')  < 20)  ; 
mask_sample = repmat(mask_sample,[1,1,200000]) ; 
dVWC_dt_phase_space_dummy(mask_sample) = NaN ; 
% average
dVWC_dt_phase_all = median(dVWC_dt_phase_space_dummy,3,'omitnan') ; 


clear dVWC_dt_phase_space_dummy dSM_dt_phase_space_dummy

% calculate anomalies

dSM_dt_phase_spaces_post_anomaly = NaN(30,30,48)  ; 
dSM_dt_phase_spaces_pre_anomaly = NaN(30,30,48)  ;
dVWC_dt_phase_spaces_post_anomaly = NaN(30,30,48)  ; 
dVWC_dt_phase_spaces_pre_anomaly = NaN(30,30,48)  ;

for i = 1:48

dSM_dt_phase_spaces_post_anomaly(:,:,i) = dSM_dt_phase_spaces_post(:,:,i) - dSM_dt_phase_all  ; 
dSM_dt_phase_spaces_pre_anomaly(:,:,i)  = dSM_dt_phase_spaces_pre(:,:,i) - dSM_dt_phase_all  ;
dVWC_dt_phase_spaces_post_anomaly(:,:,i) = dVWC_dt_phase_spaces_post(:,:,i) - dVWC_dt_phase_all  ; 
dVWC_dt_phase_spaces_pre_anomaly(:,:,i)  = dVWC_dt_phase_spaces_pre(:,:,i) - dVWC_dt_phase_all  ;

end


for i = 1:48

dummy_post =  dSM_dt_phase_spaces_post_anomaly(:,:,i) ; 
dummy_pre  =  dSM_dt_phase_spaces_pre_anomaly(:,:,i) ; 
dSM_dt_phase_spaces_post_anomaly_box(:,i) =  dummy_post(:); 
dSM_dt_phase_spaces_pre_anomaly_box(:,i)  =  dummy_pre(:) ;

dummy_post =  dVWC_dt_phase_spaces_post_anomaly(:,:,i) ; 
dummy_pre  =  dVWC_dt_phase_spaces_pre_anomaly(:,:,i) ; 
dVWC_dt_phase_spaces_post_anomaly_box(:,i) =  dummy_post(:); 
dVWC_dt_phase_spaces_pre_anomaly_box(:,i)  =  dummy_pre(:) ;


end


% 
% boxplot(dVWC_dt_phase_spaces_post_anomaly_box)
% ylim([-0.2 0.2])
% yline(0)
% 
% figure
% boxplot(dVWC_dt_phase_spaces_pre_anomaly_box)
% ylim([-0.2 0.2])
% yline(0)





% plot boxes

cd('E:\Daten Baur\Matlab code')

col_L = hex2rgb('808080') ; 
col_L_light = hex2rgb('CDCDCD') ; 

col_C = hex2rgb('3399FF') ;
col_C_light = hex2rgb('80E6FF') ; 

col_X = hex2rgb('FF3333') ;
col_X_light = hex2rgb('FF8080') ; 




month_distance = calmonths(0:48) ; 
month_distance2 = calmonths(-48:-1) ; 
month_distance = string(month_distance) ; 
month_distance2 = string(month_distance2) ; 
month_distance_2side = [month_distance2 month_distance] ; 


samples_boxes_post = sum(~isnan(dSM_dt_phase_spaces_post_anomaly_box),1) ; 
samples_boxes_pre = sum(~isnan(dSM_dt_phase_spaces_pre_anomaly_box),1) ; 
min(samples_boxes_post)
min(samples_boxes_pre)




set(0, 'DefaultFigureRenderer', 'painters');

boxifig =  figure('units','centimeters','position',[4 2 42 16])  ;  
Post_cur = boxplot(dSM_dt_phase_spaces_post_anomaly_box  ,'Labels',month_distance2, ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:48,'Width',0.6) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patchespost(j) =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_X,'FaceAlpha',.5);
 end
 hold on
Post_cur = boxplot(dSM_dt_phase_spaces_post_anomaly_box  ,'Labels',month_distance2, ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:48,'Width',0.6) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')

xtickangle(45)
ylabel('dSM/dt anomaly [m³/m³/days]')
set(gca,'FontSize',16)

hold on

Pre_cur = boxplot(dSM_dt_phase_spaces_pre_anomaly_box  ,'Labels',month_distance2, ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',fliplr(-48:-1),'Width',0.6) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Pre_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_pre = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_pre,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patchespre(j) =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_C,'FaceAlpha',.5);
 end
 hold on
Pre_cur = boxplot(dSM_dt_phase_spaces_pre_anomaly_box  ,'Labels',month_distance2, ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',fliplr(-48:-1),'Width',0.6) ;
set(Pre_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_pre = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_pre,'DisplayName','MB')
xlim([-50 50])
ylim([-0.04 0.04])
xtickvector = [-48:4:48] ; 
xticks(xtickvector)
dummy_vector = [-48:1:48] ;
xticklabels(month_distance_2side(1:4:97) )
xtickangle(45)
ylabel('\DeltaSM/\Deltat anomaly [m³/m³/days]')
xlabel('Temporal distance relative to fire event')
%yline(0,'LineWidth',2,'Color',col_L)
xline(0,'-r','LineWidth',2)
set(gca,'FontSize',16)

% draw rectangles for boxes we compare. Get vertices of box to draw
% rectangle
Vertices_post_1m = get(patchespost(48),'Vertices') ; 
h = Vertices_post_1m(2,2) - Vertices_post_1m(1,2) ;
w = Vertices_post_1m(3,1) - Vertices_post_1m(2,1) ;
rectangle('Position',[Vertices_post_1m(1,:) w h ],'EdgeColor','r','LineWidth',1.5)

% draw for pre
Vertices_pre_1m = get(patchespre(11),'Vertices') ; 
h = Vertices_pre_1m(2,2) - Vertices_pre_1m(1,2) ;
w = Vertices_pre_1m(3,1) - Vertices_pre_1m(2,1) ;
rectangle('Position',[Vertices_pre_1m(1,:) w h ],'EdgeColor','r','LineWidth',1.5)
yline(0)


set(boxifig,'PaperOrientation','landscape');
boxifig.Units = 'centimeters';        % set figure units to cm
boxifig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
boxifig.PaperSize = boxifig.Position(3:4);  % assign to the pdf printing paper the size of the figure


axes = gca ; 
axes.Units = 'centimeters' ; 
axes_diff_Position = get(axes, 'Position');
% calc positions
%  3.6987    2.3080   22.0499   17.0999   are the pos 
% 5.4621    3.1195   32.5623   11.6628
% add arrows and text
 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[5.4621+32.5623+1 3.1195+(11.6628/2)+1   0  (11.6628/2)-1]) ; 
 set(arrow2,'Position',[5.4621+32.5623+1 3.1195+(11.6628/2)-1   0 -(11.6628/2)+1]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','slower SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[5.4621+32.5623+2, 3.1195+(11.6628/2)+1,    -(11.6628/2)+1, 0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[5.4621+32.5623+2, 3.1195+(11.6628/2)-1,    (11.6628/2)-1, 0]) ; 
set(gca,'Box','on');


set(boxifig,'PaperOrientation','landscape');
boxifig.Units = 'centimeters';        % set figure units to cm
boxifig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
boxifig.PaperSize = boxifig.Position(3:4);  % assign to the pdf printing paper the size of the figur
% boxifig.PaperSize = [18  8];  % assign to the pdf printing paper the size of the figur


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\DSM_Dt_anomaly_boxplots','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\DSM_Dt_anomaly_boxplots','-dpdf')
% saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\DSM_Dt_anomaly_boxplots','svg')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\DSM_Dt_anomaly_boxplots','pdf')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\DSM_Dt_anomaly_boxplots','svg')

close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





% same for dVWC/dt

samples_boxes_post = sum(~isnan(dVWC_dt_phase_spaces_post_anomaly_box),1) ; 
samples_boxes_pre = sum(~isnan(dVWC_dt_phase_spaces_pre_anomaly_box),1) ; 
min(samples_boxes_post)
min(samples_boxes_pre)



set(0, 'DefaultFigureRenderer', 'painters');

boxifig =  figure('units','centimeters','position',[4 2 42 16])  ;  
Post_cur = boxplot(dVWC_dt_phase_spaces_post_anomaly_box  ,'Labels',month_distance2, ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:48,'Width',0.6) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patchespost(j) =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_X,'FaceAlpha',.5);
 end
 hold on
Post_cur = boxplot(dVWC_dt_phase_spaces_post_anomaly_box  ,'Labels',month_distance2, ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:48,'Width',0.6) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')

xtickangle(45)
ylabel('dSM/dt anomaly [m³/m³/days]')
set(gca,'FontSize',16)

hold on

Pre_cur = boxplot(dVWC_dt_phase_spaces_pre_anomaly_box  ,'Labels',month_distance2, ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',fliplr(-48:-1),'Width',0.6) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Pre_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_pre = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_pre,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patchespre(j) =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_C,'FaceAlpha',.5);
 end
 hold on
Pre_cur = boxplot(dVWC_dt_phase_spaces_pre_anomaly_box  ,'Labels',month_distance2, ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',fliplr(-48:-1),'Width',0.6) ;
set(Pre_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_pre = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_pre,'DisplayName','MB')
xlim([-50 50])
ylim([-0.15 0.15])
yticks(-0.15:0.05:0.15)
xtickvector = [-48:4:48] ; 
xticks(xtickvector)
dummy_vector = [-48:1:48] ;
xticklabels(month_distance_2side(1:4:97) )
xtickangle(45)
ylabel('\DeltaVWC/\Deltat anomaly [Np/days]')
xlabel('Temporal distance relative to fire event')
%yline(0,'LineWidth',2,'Color',col_L)
xline(0,'-r','LineWidth',2)
set(gca,'FontSize',16)
yline(0)
% draw rectangles for boxes we compare. Get vertices of box to draw
% rectangle
Vertices_post_1m = get(patchespost(48),'Vertices') ; 
h = Vertices_post_1m(2,2) - Vertices_post_1m(1,2) ;
w = Vertices_post_1m(3,1) - Vertices_post_1m(2,1) ;
rectangle('Position',[Vertices_post_1m(1,:) w h ],'EdgeColor','r','LineWidth',1.5)

% draw for pre
Vertices_pre_1m = get(patchespre(11),'Vertices') ; 
h = Vertices_pre_1m(2,2) - Vertices_pre_1m(1,2) ;
w = Vertices_pre_1m(3,1) - Vertices_pre_1m(2,1) ;
rectangle('Position',[Vertices_pre_1m(1,:) w h ],'EdgeColor','r','LineWidth',1.5)


% 
% set(boxifig,'PaperOrientation','landscape');
% boxifig.Units = 'centimeters';        % set figure units to cm
% boxifig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
% boxifig.PaperSize = boxifig.Position(3:4);  % assign to the pdf printing paper the size of the figure


 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[5.4621+32.5623+1 3.1195+(11.6628/2)+1   0  (11.6628/2)-1]) ; 
 set(arrow2,'Position',[5.4621+32.5623+1 3.1195+(11.6628/2)-1   0 -(11.6628/2)+1]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC gain' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[5.4621+32.5623+2, 3.1195+(11.6628/2)+1,    -(11.6628/2)+1, 0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[5.4621+32.5623+2, 3.1195+(11.6628/2)-1,    (11.6628/2)-1, 0]) ; 
set(gca,'Box','on');

set(boxifig,'PaperOrientation','landscape');
boxifig.Units = 'centimeters';        % set figure units to cm
boxifig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
boxifig.PaperSize = boxifig.Position(3:4);  % assign to the pdf printing paper the size of the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\DVWC_Dt_anomaly_boxplots','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\DVWC_Dt_anomaly_boxplots','-dpdf')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\DVWC_Dt_anomaly_boxplots','pdf')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\DVWC_Dt_anomaly_boxplots','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%% Present soil moisture loss function before and after fire
% do without phase space normalization and do for IGBP classes




edges = linspace(-0.1,0,100) ; 
edges2 = linspace(-0.1,0.1,100) ;

histofig = figure('units','centimeters','position',[10 3 40 17]) ;
sub1 = subplot(1,2,1) ; 
h1 = histogram(dSM_dt_pre_array(:),'Normalization','probability','BinEdges',edges) ; 
hold on
 h2 = histogram(dSM_dt_post_array(:),'Normalization','probability','BinEdges',edges) ; 
% uistack(h2,'bottom')
xlim([-0.1 0.])
 legend('pre-fire','post-fire','Location','northwest')
xlabel('\DeltaSM/\Deltat [m³/m³/day]')
ylabel('relative probability [-]')


sub2 = subplot(1,2,2) ; 
h3 = histogram(dtau_dt_pre_array(:),'Normalization','probability','BinEdges',edges2) ; 
hold on
h4 = histogram(dtau_dt_post_array(:),'Normalization','probability','BinEdges',edges2) ; 
% uistack(h4,'bottom')
xlim([-0.1 0.1])
 legend('pre-fire','post-fire')
xlabel('\DeltaVWC/\Deltat [kg/m²/day]')
ylabel('relative probability [-]')

fontsize(histofig,17,'points')


set(histofig,'PaperOrientation','landscape');
histofig.Units = 'centimeters';        % set figure units to cm
histofig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
histofig.PaperSize = histofig.Position(3:4);  % assign to the pdf printing paper the size of the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\dSM_dt_dVWC_dt_histograms','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\dSM_dt_dVWC_dt_histograms','-dpdf')
saveas(histofig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\dSM_dt_dVWC_dt_histograms','pdf')
saveas(histofig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\dSM_dt_dVWC_dt_histograms','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%% Figure SM loss rate DSM/Dt for IGBP



sminterp = linspace( 0.001,0.5999,31 ); 
sminterp_60 = linspace( 0.001,0.5999,60 ); 
tauinterp = linspace(0.001,0.9999,31) ; 


dSM_dt_phase_spaces_post = NaN(30,30,14)  ; 
dSM_dt_phase_spaces_pre = NaN(30,30,14)  ;
dVWC_dt_phase_spaces_post = NaN(30,30,14)  ; 
dVWC_dt_phase_spaces_pre = NaN(30,30,14)  ;

dVWC_diurnal_phase_spaces_post = NaN(30,30,14)  ; 
dVWC_diurnal_phase_spaces_pre = NaN(30,30,14)  ;


IGBP_unique = unique(IGBP_DD_array) ; 



for IGBP = 1:length(unique(IGBP_DD_array))

    IGBP_dummy = IGBP_unique(IGBP) ; 


dtau_dt_post_array_IGBP_dummy = dtau_dt_post_array(IGBP_post_array   == IGBP_dummy, : ) ; 
dtau_dt_pre_array_IGBP_dummy = dtau_dt_pre_array(IGBP_pre_array   == IGBP_dummy, : ) ;

dtau_dt_post_array_IGBP_dummy =  dtau_dt_post_array_IGBP_dummy ./ 0.11 ; 
dtau_dt_pre_array_IGBP_dummy =  dtau_dt_pre_array_IGBP_dummy ./ 0.11 ; 

dSM_dt_post_array_IGBP_dummy = dSM_dt_post_array(IGBP_post_array   == IGBP_dummy, : ) ; 
dSM_dt_pre_array_IGBP_dummy = dSM_dt_pre_array(IGBP_pre_array   == IGBP_dummy, : ) ;

tau_post_array_IGBP_dummy = tau_post_array(IGBP_post_array   == IGBP_dummy, : ) ; 
tau_pre_array_IGBP_dummy = tau_pre_array(IGBP_pre_array   == IGBP_dummy, : ) ;

DVWC_diurnal_post_array_IGBP_dummy = VWC_diurnal_post_array(IGBP_post_array   == IGBP_dummy, : ) ;  
DVWC_diurnal_pre_array_IGBP_dummy = VWC_diurnal_pre_array(IGBP_pre_array   == IGBP_dummy, : ) ;  

DVWC_diurnal_post_array_IGBP_dummy =  DVWC_diurnal_post_array_IGBP_dummy ./ 0.11 ; 
DVWC_diurnal_pre_array_IGBP_dummy =  DVWC_diurnal_pre_array_IGBP_dummy ./ 0.11 ; 


dSM_dt_phase_space_dummy_post = NaN(30,30,20000)  ; 
dSM_dt_phase_space_dummy_pre = NaN(30,30,20000)  ;
dVWC_dt_phase_space_dummy_post = NaN(30,30,20000)  ; 
dVWC_dt_phase_space_dummy_pre = NaN(30,30,20000)  ;

DVWC_diurnal_phase_space_dummy_post = NaN(30,30,20000)  ; 
DVWC_diurnal_phase_space_dummy_pre = NaN(30,30,20000)  ;

for sm = 1:30
    
    cur_sm = sminterp(sm:sm+1) ; 
    sm_true = sminterp_60 > cur_sm(1) & sminterp_60 < cur_sm(2) ; 
    
    for tau = 1:30
        
    cur_tau = tauinterp(tau:tau+1) ;         
    
    % dSM/dt
    dummypre = dSM_dt_pre_array_IGBP_dummy(:,sm_true) ; 
    tau_diff_dummy_pre = dummypre(tau_pre_array_IGBP_dummy(:,sm_true) > cur_tau(1) & tau_pre_array_IGBP_dummy(:,sm_true) < cur_tau(2)) ; 
    dummypost = dSM_dt_post_array_IGBP_dummy(:,sm_true) ; 
    tau_diff_dummy_post = dummypost(tau_post_array_IGBP_dummy(:,sm_true) > cur_tau(1) & tau_post_array_IGBP_dummy(:,sm_true) < cur_tau(2)) ;    
    
     dSM_dt_phase_space_dummy_pre(sm,tau,1:length(tau_diff_dummy_pre)) = tau_diff_dummy_pre ; 
     dSM_dt_phase_space_dummy_post(sm,tau,1:length(tau_diff_dummy_post)) = tau_diff_dummy_post ;   

     %dVWC/dt
    dummypre = dtau_dt_pre_array_IGBP_dummy(:,sm_true) ; 
    tau_diff_dummy_pre = dummypre(tau_pre_array_IGBP_dummy(:,sm_true) > cur_tau(1) & tau_pre_array_IGBP_dummy(:,sm_true) < cur_tau(2)) ; 
    dummypost = dtau_dt_post_array_IGBP_dummy(:,sm_true) ; 
    tau_diff_dummy_post = dummypost(tau_post_array_IGBP_dummy(:,sm_true) > cur_tau(1) & tau_post_array_IGBP_dummy(:,sm_true) < cur_tau(2)) ;    
    
     dVWC_dt_phase_space_dummy_pre(sm,tau,1:length(tau_diff_dummy_pre)) = tau_diff_dummy_pre ; 
     dVWC_dt_phase_space_dummy_post(sm,tau,1:length(tau_diff_dummy_post)) = tau_diff_dummy_post ;   

     % VWC diurnal
    dummypre = DVWC_diurnal_pre_array_IGBP_dummy(:,sm_true) ; 
    tau_diff_dummy_pre = dummypre(tau_pre_array_IGBP_dummy(:,sm_true) > cur_tau(1) & tau_pre_array_IGBP_dummy(:,sm_true) < cur_tau(2)) ; 
    dummypost = DVWC_diurnal_post_array_IGBP_dummy(:,sm_true) ; 
    tau_diff_dummy_post = dummypost(tau_post_array_IGBP_dummy(:,sm_true) > cur_tau(1) & tau_post_array_IGBP_dummy(:,sm_true) < cur_tau(2)) ;    
    
     DVWC_diurnal_phase_space_dummy_pre(sm,tau,1:length(tau_diff_dummy_pre)) = tau_diff_dummy_pre ; 
     DVWC_diurnal_phase_space_dummy_post(sm,tau,1:length(tau_diff_dummy_post)) = tau_diff_dummy_post ;   
        
    end
end

% now  filter dSM/dt
mask_sample_post =  (sum(~isnan(dSM_dt_phase_space_dummy_post),3,'omitnan')  < 10)  ; 
mask_sample_pre =  (sum(~isnan(dSM_dt_phase_space_dummy_pre),3,'omitnan')  < 10)  ; 
mask_sample_post = repmat(mask_sample_post,[1,1,20000]) ; 
mask_sample_pre = repmat(mask_sample_pre,[1,1,20000]) ; 
dSM_dt_phase_space_dummy_pre(mask_sample_pre) = NaN ; 
dSM_dt_phase_space_dummy_post(mask_sample_post) = NaN ; 
% average
dSM_dt_phase_spaces_pre(:,:,IGBP) = median(dSM_dt_phase_space_dummy_pre,3,'omitnan') ; 
dSM_dt_phase_spaces_post(:,:,IGBP) = median(dSM_dt_phase_space_dummy_post,3,'omitnan') ; 

% now  filter dVWC/dt
mask_sample_post =  (sum(~isnan(dVWC_dt_phase_space_dummy_post),3,'omitnan')  < 10)  ; 
mask_sample_pre =  (sum(~isnan(dVWC_dt_phase_space_dummy_pre),3,'omitnan')  < 10)  ; 
mask_sample_post = repmat(mask_sample_post,[1,1,20000]) ; 
mask_sample_pre = repmat(mask_sample_pre,[1,1,20000]) ; 
dVWC_dt_phase_space_dummy_pre(mask_sample_pre) = NaN ; 
dVWC_dt_phase_space_dummy_post(mask_sample_post) = NaN ; 
% average
dVWC_dt_phase_spaces_pre(:,:,IGBP) = median(dVWC_dt_phase_space_dummy_pre,3,'omitnan') ; 
dVWC_dt_phase_spaces_post(:,:,IGBP) = median(dVWC_dt_phase_space_dummy_post,3,'omitnan') ; 

% now  filter DVWC diurnal
mask_sample_post =  (sum(~isnan(DVWC_diurnal_phase_space_dummy_post),3,'omitnan')  < 10)  ; 
mask_sample_pre =  (sum(~isnan(DVWC_diurnal_phase_space_dummy_pre),3,'omitnan')  < 10)  ; 
mask_sample_post = repmat(mask_sample_post,[1,1,20000]) ; 
mask_sample_pre = repmat(mask_sample_pre,[1,1,20000]) ; 
DVWC_diurnal_phase_space_dummy_pre(mask_sample_pre) = NaN ; 
DVWC_diurnal_phase_space_dummy_post(mask_sample_post) = NaN ; 
% average
dVWC_diurnal_phase_spaces_pre(:,:,IGBP) = median(DVWC_diurnal_phase_space_dummy_pre,3,'omitnan') ; 
dVWC_diurnal_phase_spaces_post(:,:,IGBP) = median(DVWC_diurnal_phase_space_dummy_post,3,'omitnan') ; 



IGBP
end


clear dSM_dt_phase_spaces_difference_box dVWC_dt_phase_spaces_difference_box DVWC_diurnal_phase_spaces_difference_box

for i = 1:14

dummy_post =  dSM_dt_phase_spaces_post(:,:,i) ; 
dummy_pre  =  dSM_dt_phase_spaces_pre(:,:,i) ; 
diff = dummy_post - dummy_pre ; 
dSM_dt_phase_spaces_difference_box(:,i) =  diff(:); 

dummy_post =  dVWC_dt_phase_spaces_post(:,:,i) ; 
dummy_pre  =  dVWC_dt_phase_spaces_pre(:,:,i) ; 
diff = dummy_post - dummy_pre ; 
dVWC_dt_phase_spaces_difference_box(:,i) =  diff(:); 

dummy_post =  dVWC_diurnal_phase_spaces_post(:,:,i) ; 
dummy_pre  =  dVWC_diurnal_phase_spaces_pre(:,:,i) ; 
diff = dummy_post - dummy_pre ; 
DVWC_diurnal_phase_spaces_difference_box(:,i) =  diff(:); 


end




IGBP_char_vec = {'Evergreen needleleaf','Evergreen broadleaf', 'Deciduous needleleaf', 'Deciduous broadleaf', 'Mixed forest',...
    'Closed shrublands','Open shrublands','Woody savanna','Savanna','Grassland','Permanent wetlands','croplands',...
    'Urban','Crop/natural vegetation','Snow and Ice','Barren land','water bodies'} ;

IGBP_char_vec2 = {'Evergreen needleleaf','Evergreen broadleaf', 'Deciduous needleleaf', 'Deciduous broadleaf', 'Mixed forest',...
    'Closed shrublands','Open shrublands','Woody savanna','Savanna','Grassland','Permanent wetlands','croplands',...
     'Crop/natural vegetation','Barren land'} ;





nboxes = sum(~isnan(dSM_dt_phase_spaces_difference_box),1) ; 


% histogram(IGBP_DD_array)

% now boxplots for IGBP classes
boxifig =  figure('units','centimeters','position',[4 2 42 16])  ;  
Post_cur = boxplot(dSM_dt_phase_spaces_difference_box(:,nboxes > 10)  ,'Labels',IGBP_char_vec2(:,nboxes > 10), ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:size(dSM_dt_phase_spaces_difference_box(:,nboxes > 10),2),'Width',0.6) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patchespost(j) =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_L,'FaceAlpha',.5);
 end
 hold on
Post_cur = boxplot(dSM_dt_phase_spaces_difference_box(:,nboxes > 10)  ,'Labels',IGBP_char_vec2(:,nboxes > 10), ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:size(dSM_dt_phase_spaces_difference_box(:,nboxes > 10),2),'Width',0.6) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')

xtickangle(45)
ylabel('dSM/dt anomaly [m³/m³/days]')
set(gca,'FontSize',16)

% xlim([-50 50])
ylim([-0.05 0.05])
yticks(-0.05:0.025:0.05)
xtickangle(45)
ylabel('\DeltaSM/\Deltat change [m³/m³/days]')
xlabel('IGBP landcover class')
%yline(0,'LineWidth',2,'Color',col_L)
xline(0,'-r','LineWidth',2)
set(gca,'FontSize',16)
yline(0,'--')

set(boxifig,'PaperOrientation','landscape');
boxifig.Units = 'centimeters';        % set figure units to cm
boxifig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
boxifig.PaperSize = boxifig.Position(3:4);  % assign to the pdf printing paper the size of the figure


set(gca,'Units','centimeters');
axes_diff_Position = get(gca, 'Position');

% pos in cm
 % 5.4621    4.3297   32.5623   10.4525

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[5.4621+32.5623+1 5.1588+(9.6235/2)+1   0  (9.6235/2)-1]) ; 
 set(arrow2,'Position',[5.4621+32.5623+1 5.1588+(9.6235/2)-1   0 -(9.6235/2)+1]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','slower SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[5.4621+32.5623+2, 5.1588+(9.6235/2)+1,    -(9.6235/2)+1, 0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster SM loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[5.4621+32.5623+2, 5.1588+(9.6235/2)-1,    (9.6235/2)-1, 0]) ; 
set(gca,'Box','on');

% set global fontsize
 fontsize(boxifig, 16, "points")

nboxes(nboxes < 10) = [] ; 
% add n for each box
for i = 1:length(nboxes)

       n_sample_labels(i) =  text(i-0.11,0.035,strcat('(',num2str(nboxes(i)),')'),'FontSize',11)  ;

end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\DSM_Dt_IGBP_boxplots','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\DSM_Dt_IGBP_boxplots','-dpdf')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\DSM_Dt_IGBP_boxplots','pdf')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\DSM_Dt_IGBP_boxplots','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%% DVWC/dt

nboxes = sum(~isnan(dVWC_dt_phase_spaces_difference_box),1) ; 



% now boxplots for IGBP classes
boxifig =  figure('units','centimeters','position',[4 2 42 16])  ;  
Post_cur = boxplot(dVWC_dt_phase_spaces_difference_box(:,nboxes > 10)  ,'Labels',IGBP_char_vec2(:,nboxes > 10), ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:size(dSM_dt_phase_spaces_difference_box(:,nboxes > 10),2),'Width',0.6) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patchespost(j) =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_L,'FaceAlpha',.5);
 end
 hold on
Post_cur = boxplot(dVWC_dt_phase_spaces_difference_box(:,nboxes > 10)  ,'Labels',IGBP_char_vec2(:,nboxes > 10), ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:size(dSM_dt_phase_spaces_difference_box(:,nboxes > 10),2),'Width',0.6) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')

xtickangle(45)
% ylabel('dSM/dt anomaly [m³/m³/days]')
set(gca,'FontSize',16)

% xlim([-50 50])
ylim([-0.4 0.4])
yticks(-0.4:0.2:0.4)
xtickangle(45)
ylabel('\DeltaVWC/\Deltat change [kg/m²/days]')
xlabel('IGBP landcover class')
%yline(0,'LineWidth',2,'Color',col_L)
xline(0,'-r','LineWidth',2)
set(gca,'FontSize',16)
yline(0,'--')

set(boxifig,'PaperOrientation','landscape');
boxifig.Units = 'centimeters';        % set figure units to cm
boxifig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
boxifig.PaperSize = boxifig.Position(3:4);  % assign to the pdf printing paper the size of the figure


set(gca,'Units','centimeters');
axes_diff_Position = get(gca, 'Position');

% pos in cm
 % 5.4621    4.3297   32.5623   10.4525

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[5.4621+32.5623+1 5.1588+(9.6235/2)+1   0  (9.6235/2)-1]) ; 
 set(arrow2,'Position',[5.4621+32.5623+1 5.1588+(9.6235/2)-1   0 -(9.6235/2)+1]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC gain' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[5.4621+32.5623+2, 5.1588+(9.6235/2)+1,    -(9.6235/2)+1, 0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','faster VWC loss' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[5.4621+32.5623+2, 5.1588+(9.6235/2)-1,    (9.6235/2)-1, 0]) ; 
set(gca,'Box','on');


% set global fontsize
 fontsize(boxifig, 16, "points")

nboxes(nboxes < 10) = [] ; 
% add n for each box
for i = 1:length(nboxes)

       n_sample_labels(i) =  text(i-0.11,-0.3,strcat('(',num2str(nboxes(i)),')'),'FontSize',11)  ;

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\DVWC_Dt_IGBP_boxplots','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\DVWC_Dt_IGBP_boxplots','-dpdf')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\DVWC_Dt_IGBP_boxplots','pdf')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\DVWC_Dt_IGBP_boxplots','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%% 


% load('E:\MOSEV_tiles\datasets_for_final_plots\isohydricity_slope_pre')
% load('E:\MOSEV_tiles\datasets_for_final_plots\isohydricity_slope_post')

load('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\isohydricity_slope_post_ref_period_30_sample.mat')
load('E:\MOSEV_tiles\datasets_for_final_plots_all_pre_years_ref\isohydricity_slope_pre_ref_period_30_sample.mat')

% now boxplots for IGBP classes
scatterfig =  figure('units','centimeters','position',[4 2 22 16])  ;  
 scatter(isohydricity_slope_pre, isohydricity_slope_post - isohydricity_slope_pre,25,'filled','Color',col_C)
% scatter(isohydricity_slope_pre, isohydricity_slope_post - isohydricity_slope_pre,25,IGBP_DD_pixel_unique,'filled')
xlabel('pre-fire isohydricity slope \sigma')
ylabel('pre to post change in isohydricity slope \sigma')
% set global fontsize
fontsize(scatterfig, 16, "points")
set(gca,'Units','centimeters');
axes_diff_Position = get(gca, 'Position');
yline(0,'--')

% pos in cm
 % 2.8617    1.7579   17.0603   13.0244

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[2.8617+17.0603+1 1.7579+(13.0244/2)+1   0  (13.0244/2)-1]) ; 
 set(arrow2,'Position',[2.8617+17.0603+1 1.7579+(13.0244/2)-1   0 -(13.0244/2)+1]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','more anisohydric' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[2.8617+17.0603+2, 1.7579+(13.0244/2)+1,    -(13.0244/2)+1, 0]) ; 
set(gca,'Box','on')

textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','more isohydric' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[2.8617+17.0603+2, 1.7579+(13.0244/2)-1,    (13.0244/2)-1, 0]) ; 
set(gca,'Box','on');

% set global fontsize
 fontsize(scatterfig, 16, "points")

set(scatterfig,'PaperOrientation','landscape');
scatterfig.Units = 'centimeters';        % set figure units to cm
scatterfig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
scatterfig.PaperSize = scatterfig.Position(3:4);  % assign to the pdf printing paper the size of the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\Isohydricity_change_scatter','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\Isohydricity_change_scatter','-dpdf')
saveas(scatterfig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Isohydricity_change_scatter','pdf')
saveas(scatterfig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Isohydricity_change_scatter','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%% now also do boxplots for IGBP isohydricity change?
cd('E:\MOSEV_tiles\DD_all_01')
load('index_tau_unique.mat')
load('IGBP_DD_array.mat')


IGBP_DD_pixel_unique = IGBP_DD_array(index_tau_unique) ; 


% group isohydricity into IGBP classes

Isohydricity_pre_boxplot  = NaN(10000,14) ; 
Isohydricity_post_boxplot = NaN(10000,14) ; 
Isohydricity_diff_boxplot = NaN(10000,14) ; 

for i = 1:14

dummy_pre =  isohydricity_slope_pre(IGBP_DD_pixel_unique == i) ; 
dummy_post = isohydricity_slope_post(IGBP_DD_pixel_unique == i) ; 
difference_isohydricity = isohydricity_slope_post(IGBP_DD_pixel_unique == i)  - isohydricity_slope_pre(IGBP_DD_pixel_unique == i) ;

Isohydricity_pre_boxplot(1:length(dummy_pre),i) = dummy_pre; 
Isohydricity_post_boxplot(1:length(dummy_post),i) = dummy_post; 
Isohydricity_diff_boxplot(1:length(dummy_post),i) = difference_isohydricity; 

end



% nboxes = sum(~isnan(Isohydricity_diff_boxplot),1,'omitnan') ; 

nboxes = sum(~isnan(Isohydricity_diff_boxplot),1) ; 


% now boxplots for IGBP classes
boxifig =  figure('units','centimeters','position',[4 2 42 16])  ;  
Post_cur = boxplot(Isohydricity_diff_boxplot(:,nboxes > 10)  ,'Labels',IGBP_char_vec2(:,nboxes > 10), ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:size(Isohydricity_diff_boxplot(:,nboxes > 10),2),'Width',0.6) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patchespost(j) =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_L,'FaceAlpha',.5);
 end
 hold on
Post_cur = boxplot(Isohydricity_diff_boxplot(:,nboxes > 10)  ,'Labels',IGBP_char_vec2(:,nboxes > 10), ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:size(Isohydricity_diff_boxplot(:,nboxes > 10),2),'Width',0.6) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')

xtickangle(45)
% ylabel('dSM/dt anomaly [m³/m³/days]')
set(gca,'FontSize',16)

% xlim([-50 50])
ylim([-1.5 1.5])
yticks(-1.5:0.75:1.5)
xtickangle(45)
ylabel('change in isohydricity [-]')
xlabel('IGBP landcover class')
%yline(0,'LineWidth',2,'Color',col_L)
xline(0,'-r','LineWidth',2)
set(gca,'FontSize',16)
yline(0,'--')

set(boxifig,'PaperOrientation','landscape');
boxifig.Units = 'centimeters';        % set figure units to cm
boxifig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
boxifig.PaperSize = boxifig.Position(3:4);  % assign to the pdf printing paper the size of the figure


set(gca,'Units','centimeters');
axes_diff_Position = get(gca, 'Position');

% pos in cm
 % 5.4621    4.3297   32.5623   10.4525

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[5.4621+32.5623+1 5.1588+(9.6235/2)+1   0  (9.6235/2)-1]) ; 
 set(arrow2,'Position',[5.4621+32.5623+1 5.1588+(9.6235/2)-1   0 -(9.6235/2)+1]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','more anisohydric' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[5.4621+32.5623+2, 5.1588+(9.6235/2)+1,    -(9.6235/2)+1, 0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','more isohydric' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[5.4621+32.5623+2, 5.1588+(9.6235/2)-1,    (9.6235/2)-1, 0]) ; 
set(gca,'Box','on');



% set global fontsize
 fontsize(boxifig, 16, "points")

nboxes(nboxes < 10) = [] ; 
% add n for each box
for i = 1:length(nboxes)

       n_sample_labels(i) =  text(i-0.13,1.33,strcat('(',num2str(nboxes(i)),')'),'FontSize',11)  ;

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\Isohydrictiy_change_IGBP_boxplots','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\Isohydrictiy_change_IGBP_boxplots','-dpdf')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Isohydrictiy_change_IGBP_boxplots','pdf')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Isohydrictiy_change_IGBP_boxplots','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% now also do boxplots for DNBR isohydricity change?

clear

load('E:\MOSEV_tiles\datasets_for_final_plots\isohydricity_slope_pre')
load('E:\MOSEV_tiles\datasets_for_final_plots\isohydricity_slope_post')


cd('E:\MOSEV_tiles\DD_all_01')
load('D_NBR_DD_array.mat')
load('index_tau_unique.mat')
load('IGBP_DD_array.mat')
D_NBR_DD_array_unique = D_NBR_DD_array(index_tau_unique) ; 
cd('E:\MOSEV_tiles\datasets_for_final_plots')
load('severity_chars_NBR_final.mat')
load('severity_chars_final.mat')



cd('E:\Daten Baur\Matlab code')
col_L = hex2rgb('808080') ; 
col_L_light = hex2rgb('CDCDCD') ; 




severity_bins_tau = linspace(-0.3,0.1,6) ; 
severity_bins_NBR = linspace(-200,600,6) ; 
severity_bins_tau = [-10 severity_bins_tau 10] ; 
severity_bins_NBR = [-10000 severity_bins_NBR 10000] ; 





% group isohydricity into IGBP classes

Isohydricity_pre_boxplot  = NaN(10000,7) ; 
Isohydricity_post_boxplot = NaN(10000,7) ; 
Isohydricity_diff_boxplot = NaN(10000,7) ; 

for i = 1:7

 bin_NBR_s = severity_bins_NBR(i) ;
 bin_NBR_e = severity_bins_NBR(i+1) ;



dummy_pre =  isohydricity_slope_pre(D_NBR_DD_array_unique > bin_NBR_s & D_NBR_DD_array_unique < bin_NBR_e) ; 
dummy_post = isohydricity_slope_post(D_NBR_DD_array_unique > bin_NBR_s & D_NBR_DD_array_unique < bin_NBR_e) ; 
difference_isohydricity = isohydricity_slope_post(D_NBR_DD_array_unique > bin_NBR_s & D_NBR_DD_array_unique < bin_NBR_e )  -  ...
                          isohydricity_slope_pre(D_NBR_DD_array_unique > bin_NBR_s & D_NBR_DD_array_unique < bin_NBR_e ) ;

Isohydricity_pre_boxplot(1:length(dummy_pre),i) = dummy_pre; 
Isohydricity_post_boxplot(1:length(dummy_post),i) = dummy_post; 
Isohydricity_diff_boxplot(1:length(dummy_post),i) = difference_isohydricity; 

end



nboxes = sum(~isnan(Isohydricity_diff_boxplot),1) ; 







% now boxplots for IGBP classes
boxifig =  figure('units','centimeters','position',[4 2 42 16])  ;  
Post_cur = boxplot(Isohydricity_diff_boxplot(:,nboxes > 10)  ,'Labels',severity_chars_NBR_final(:,nboxes > 10), ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:size(Isohydricity_diff_boxplot(:,nboxes > 10),2),'Width',0.6) ;
boxes1 = findobj(gcf,'tag','Box','-and','DisplayName','') ; 
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')
hold on
 for j=1:length(boxes1)
   patchespost(j) =  patch(get(boxes1(j),'XData'),get(boxes1(j),'YData'),col_L,'FaceAlpha',.5);
 end
 hold on
Post_cur = boxplot(Isohydricity_diff_boxplot(:,nboxes > 10)  ,'Labels',severity_chars_NBR_final(:,nboxes > 10), ...
    'Outliers', 1, 'Whisker', 1, 'Jitter', 0.0001, 'Positions',1:size(Isohydricity_diff_boxplot(:,nboxes > 10),2),'Width',0.6) ;
set(Post_cur(7,:),'Visible','off')
set(findobj(gcf,'tag','Box','-and','DisplayName',''), 'Color', [0.25 0.25 0.25],'DisplayName','xx','LineWidth',1.0);
set(findobj(gcf,'tag','Upper Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
set(findobj(gcf,'tag','Lower Whisker','-and','DisplayName',''), 'Color', [0 0 0],'DisplayName','xx');
h_post = findobj(gca,'Tag','Box','-and','DisplayName','');
set(h_post,'DisplayName','MB')

xtickangle(45)
% ylabel('dSM/dt anomaly [m³/m³/days]')
set(gca,'FontSize',16)

% xlim([-50 50])
ylim([-1.5 1.5])
yticks(-1.5:0.75:1.5)
xtickangle(45)
ylabel('change in isohydricity [-]')
xlabel('fire severity \DeltaNBR [-]')
%yline(0,'LineWidth',2,'Color',col_L)
xline(0,'-r','LineWidth',2)
set(gca,'FontSize',16)
yline(0,'--')

set(boxifig,'PaperOrientation','landscape');
boxifig.Units = 'centimeters';        % set figure units to cm
boxifig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
boxifig.PaperSize = boxifig.Position(3:4);  % assign to the pdf printing paper the size of the figure


set(gca,'Units','centimeters');
axes_diff_Position = get(gca, 'Position');

% pos in cm
 % 5.4621    4.3297   32.5623   10.4525

 arrow1 = annotation('arrow',[0.955 0.955],[0.7 0.9],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 arrow2 = annotation('arrow',[0.955 0.955],[0.8  0.6],'LineWidth',4,'HeadLength',15,'HeadWidth',15,'Units','centimeters') ;
 
 set(arrow1,'Position',[5.4621+32.5623+1 3.1569+(11.6253/2)+1   0  (11.6253/2)-1]) ; 
 set(arrow2,'Position',[5.4621+32.5623+1 3.1569+(11.6253/2)-1   0 -(11.6253/2)+1]) ; 
 
textbox1 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','more anisohydric' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox1,'Position',[5.4621+32.5623+2, 3.1569+(11.6253/2)+1,    -(11.6253/2)+1, 0]) ; 
set(gca,'Box','on');
 
textbox2 =  annotation('textarrow',[0.5 0.5],[0.5 0.5],'string','more isohydric' , ...
'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'Position',[.02 .6 0 0],'FontSize',16,'Units','centimeters');
set(textbox2,'Position',[5.4621+32.5623+2, 3.1569+(11.6253/2)-1,    (11.6253/2)-1, 0]) ; 
set(gca,'Box','on');

% set global fontsize
 fontsize(boxifig, 16, "points")

nboxes(nboxes < 10) = [] ; 
% add n for each box
for i = 1:length(nboxes)

       n_sample_labels(i) =  text(i-0.10,1.33,strcat('(',num2str(nboxes(i)),')'),'FontSize',11)  ;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\Isohydrictiy_change_DNBR_boxplots','-depsc')
% print('-image','E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\Review_figures\Isohydrictiy_change_DNBR_boxplots','-dpdf')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Isohydrictiy_change_DNBR_boxplots','pdf')
saveas(boxifig,'E:\MOSEV_tiles\MOSEV_project\figures\v02\simplified_noodle\2D_subplots\pdf_panels_05_pre_ref_box\Isohydrictiy_change_DNBR_boxplots','svg')
close 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







