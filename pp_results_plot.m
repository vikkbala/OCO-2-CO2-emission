clear; clc
%% plot power plant emission (CB vs GP)
pp_results = readtable('C:\India_OCO2_emission\power plant emission\PP_results.xlsx');
pp_results.sf = pp_results.GP./pp_results.CB;

GP_with_25  = length(find(pp_results.sf < 1.25 & pp_results.sf > 0.75));
GP_with_50  = length(find(pp_results.sf < 1.5 & pp_results.sf > 0.5));
GP_above_50  = length(find(pp_results.sf > 2));

gp_corr_cs_results = pp_results.GP(find(~isnan(pp_results.CS)));
cs_results = pp_results.CS(find(~isnan(pp_results.CS)));

r_CS_GP = corr(gp_corr_cs_results,cs_results,'rows','complete');
gp_corr_cs_results_sum = sum(gp_corr_cs_results);
cs_results_sum = sum(cs_results);
%% plot power plant emission (CB vs GP)
figure
for pp_results_xx = 1:height(pp_results)
    if pp_results.sf(pp_results_xx) > 1.5 || pp_results.sf(pp_results_xx) < 0.5
        errorbar (pp_results.CB(pp_results_xx),pp_results.GP(pp_results_xx),pp_results.GP_uncer(pp_results_xx),'o', 'Color', 'r', 'LineWidth', 2, 'MarkerSize', 8, 'CapSize', 7.5);
    else
        errorbar (pp_results.CB(pp_results_xx),pp_results.GP(pp_results_xx),pp_results.GP_uncer(pp_results_xx),'o', 'Color', 'k', 'LineWidth', 2, 'MarkerSize', 8, 'CapSize', 7.5);
    hold on
    end
end
xlim([0 max(pp_results.GP)+50])
ylim([0 max(pp_results.GP)+50])
hold on
plot(1:max(pp_results.GP)+50,1:max(pp_results.GP)+50,'--k','LineWidth',2)
hold on
plot(1:max(pp_results.GP)+50,(1:max(pp_results.GP)+50)*1.5,'--r','LineWidth',2)
hold on
plot(1:max(pp_results.GP)+50,(1:max(pp_results.GP)+50)*0.5,'--r','LineWidth',2)
hold on
plot(1:max(pp_results.GP)+50,(1:max(pp_results.GP)+50)*1.25,'--m','LineWidth',2)
hold on
plot(1:max(pp_results.GP)+50,(1:max(pp_results.GP)+50)*0.75,'--m','LineWidth',2)
grid minor
xlabel ('CB database (Mt year^-^1)')
ylabel ('GP emission estimate (Mt year^-^1)')
set(gca,'FontSize', 14,'fontweight','bold','FontName', 'Times New Roman','fontweight','bold')
ax1 = gca; set(ax1,'XTick',get(ax1,'YTick'));
%% plot power plant emission (GP vs CS)

for pp_results_xx = 1:height(pp_results)
    if pp_results.sf(pp_results_xx) > 1.5 || pp_results.sf(pp_results_xx) < 0.5
        errorbar (pp_results.GP(pp_results_xx),pp_results.CS(pp_results_xx),pp_results.CS_uncer(pp_results_xx),pp_results.CS_uncer(pp_results_xx),pp_results.GP_uncer(pp_results_xx),pp_results.GP_uncer(pp_results_xx),'o', 'Color', 'r', 'LineWidth', 2, 'MarkerSize', 8, 'CapSize', 7.5);
    else
        errorbar (pp_results.GP(pp_results_xx),pp_results.CS(pp_results_xx),pp_results.CS_uncer(pp_results_xx),pp_results.CS_uncer(pp_results_xx),pp_results.GP_uncer(pp_results_xx),pp_results.GP_uncer(pp_results_xx),'o', 'Color', 'k', 'LineWidth', 2, 'MarkerSize', 8, 'CapSize', 7.5);
    end
    hold on
end
hold on
plot(1:max(pp_results.GP)+50,1:max(pp_results.GP)+50,'--k','LineWidth',2)
hold on
grid minor
xlim([0 max(pp_results.GP)+25])
ylim([0 max(pp_results.GP)+25])
xlabel ('GP emission estimate (Mt year^-^1)')
ylabel ('CS emission estimate (Mt year^-^1)')
set(gca,'FontSize', 14,'fontweight','bold','FontName', 'Times New Roman','fontweight','bold')
ax1 = gca; set(ax1,'XTick',get(ax1,'YTick'));
%% plot power plant emission (CB vs EDGAR)
figure
for pp_results_xx = 1:height(pp_results)
    if pp_results.sf(pp_results_xx) > 1.5 || pp_results.sf(pp_results_xx) < 0.5
        errorbar (pp_results.EDGAR_50(pp_results_xx),pp_results.GP(pp_results_xx),pp_results.GP_uncer(pp_results_xx),'o', 'Color', 'r', 'LineWidth', 2, 'MarkerSize', 8, 'CapSize', 7.5);
    else
        errorbar (pp_results.EDGAR_50(pp_results_xx),pp_results.GP(pp_results_xx),pp_results.GP_uncer(pp_results_xx),'o', 'Color', 'k', 'LineWidth', 2, 'MarkerSize', 8, 'CapSize', 7.5);
    hold on
    end
end
xlim([0 180])
ylim([0 180])
hold on
plot(1:180,1:180,'--k','LineWidth',2)
hold on
grid minor
xlabel ('EDGAR database (Mt year^-^1)')
ylabel ('GP emission estimate (Mt year^-^1)')
set(gca,'FontSize', 14,'fontweight','bold','FontName', 'Times New Roman','fontweight','bold')
ax1 = gca; set(ax1,'XTick',get(ax1,'YTick'));
%% plot power plant emission (CB vs ODIAC)
figure
for pp_results_xx = 1:height(pp_results)
    if pp_results.sf(pp_results_xx) > 1.5 || pp_results.sf(pp_results_xx) < 0.5
        errorbar (pp_results.ODIAC_50(pp_results_xx),pp_results.GP(pp_results_xx),pp_results.GP_uncer(pp_results_xx),'o', 'Color', 'r', 'LineWidth', 2, 'MarkerSize', 8, 'CapSize', 7.5);
    else
        errorbar (pp_results.ODIAC_50(pp_results_xx),pp_results.GP(pp_results_xx),pp_results.GP_uncer(pp_results_xx),'o', 'Color', 'k', 'LineWidth', 2, 'MarkerSize', 8, 'CapSize', 7.5);
    hold on
    end
    
end
xlim([0 180])
ylim([0 180])
hold on
plot(1:180,1:180,'--k','LineWidth',2)
hold on
grid minor
xlabel ('ODIAC database (Mt year^-^1)')
ylabel ('GP emission estimate (Mt year^-^1)')
set(gca,'FontSize', 14,'fontweight','bold','FontName', 'Times New Roman','fontweight','bold')
ax1 = gca; set(ax1,'XTick',get(ax1,'YTick'));