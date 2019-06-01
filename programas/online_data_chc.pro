pro driver
;******************************************;  
nodb = 10
cmd = 'date +"%m-%d-%Y"'
spawn, cmd, date
month = strmid(date, 0, 2)
day = strmid(date, 3, 2)
year = strmid(date, 6, 4)

;year = 2018
;month = 6
;day = 30
jf = julday(month, day, year, 23, 59)
jf = jf[0]
j0 = jf-nodb+(1*0.0416667)

pw = '/home/fhertop/GAW/MAAP/plots/'
pr_icos = '/home/fhertop/GAW/meteoro/data/icos/'
pr_inlet = '/home/fhertop/GAW/Inlet/data'
pr_maap = '/home/fhertop/GAW/MAAP/data/'
pr_ae31 = '/home/fhertop/GAW/Aethalometer/data/raw_pc/'
pr_nephe = '/home/fhertop/GAW/Nephelometer/data/'
pr_ozono = '/home/fhertop/GAW/O3/data/'
pr_smps = '/home/fhertop/GAW/SMPS/data/inverted/'
pr_pica = '/home/fhertop/GAW/picarro_co2/data/474/'
read_raw_icos, pr_icos, j0, jf, icos
;YY MM DD hh mm  temp Pressure  RH  WS  WD
; 0  1  2  3  4   5      6      7    8   9
read_raw_inlet, pr_inlet, j0, jf, inlet
;YY MM DD hh mm  RH_A RH_i Temp_A Temp_I Pressure Flow Current(A) Flag
; 0  1  2  3  4   5    6     7      8       9      10      11      12
read_raw_maap, pr_maap, j0, jf, maap
; YY MM DD hh mm pressure temp flowV  flowS eBC mass
; 0  1  2  3   4   5        6   7     8      9   10
read_raw_ae31, pr_ae31, j0, jf, ae31
; YY MM DD hh mm eBC 370 470 520 590 660 880 950  flowS
; 0  1  2  3   4      5   6   7   8   9   10  11    12
read_raw_nephe, pr_nephe, j0, jf, nephe
; YY MM DD hh mm Scatter 450 525 635 BS 450 525 635  ST  ET  RH  pressure
; 0  1  2  3   4          5   6   7      8   9   10  11  12  13   14
read_raw_ozono, pr_ozono, j0, jf, ozo
; YY MM DD hh mm ozono  flowA  flowB  pressure
; 0  1  2  3   4   5       6      7      8
read_raw_smps, pr_smps, j0, jf, smps
; YY MM DD hh mm  (71 diameters)
; 0  1  2  3   4   5-75

plot_now_aerosoles = 1
plot_now_meteo = 1
plot_now_picarro = 0

if plot_now_picarro eq 1 then begin
cmd = 'bash /home/fhertop/GAW/picarro_co2/programas/bash/lftp_mirror.sh'
spawn, cmd
;read_picarro, pr_pica, j0, jf, pica
read_picarro0, pr_pica, j0, jf, pica
;YY MM DD hh mm  CavityPressure  CavityTemp  DasTemp  EtalonTemp  MPVPosition  CO ppb CO2 ppm CO2_dry ppm  CH4 ppm  CH4_dry ppm  H2O ppb  h2o_reported ppb
; 0  1  2  3  4        5              6         7         8           9          10     11        12         13         14          15          16         

;-------------- PLOT -------------------------------------------------------
position0 = [0.05, 0.80, 0.98, 0.99]
position1 = [0.05, 0.60, 0.98, 0.79]
position2 = [0.05, 0.40, 0.98, 0.59]
position3 = [0.05, 0.21, 0.98, 0.39]
position4 = [0.05, 0.030, 0.98, 0.20]

thick = 4
tama = 1.2
pw1 = strcompress(pw+'online_raw_chc_picarro.ps',/remove_all)
ps_start, filename=pw1, ysize=10, xsize=15

;---- CO ------
ymax = 180
ymin = 40
yint = 40
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, pica[10,*], position=position4, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='CO [ppb]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, pica[10,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, pica[5,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.1

;---- CO2 ------
ymax = 410
ymin = 400
yint = 2
plot, time, pica[11,*], position=position3, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='CO!d2!n [ppm]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, pica[11,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, pica[11,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.1

;---- CH4 ------
ymax = 2.00
ymin = 1.80
yint = 0.04
plot, time, pica[13,*], position=position2, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='CH!d4!n [ppm]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, pica[13,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, pica[14,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.1

;---- H2O ------
ymax = 1.5
ymin = 0
yint = 0.3
plot, time, pica[15,*], position=position1, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='H!d2!nO [ppm]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, pica[15,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.2

;------ H2O reported  -------
ymax = 1.5
ymin = 0
yint = 0.3
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, pica[16,*], position=position0, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='H!d2!nO reported [ppm]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, pica[16,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.2; cavity

ps_end, /JPEG

pw1 = strcompress(pw+'online_raw_chc_picarro0.ps',/remove_all)
ps_start, filename=pw1, ysize=10, xsize=15

;------ Cavity Temp  -------
ymax = 45.2
ymin = 44.6
yint = 0.2
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, pica[6,*], position=position4, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Cavity Temp [!eo!nC]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, pica[6,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.2; cavity
oplot, time, pica[8,*], color=fsc_color('green'), THICK=1, psym=-cgsymcat(16), symsize=0.2; etalon

;------ Temp Das-------
ymax = 48
ymin = 40
yint = 2
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, pica[7,*], position=position3, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Das Temp [!eo!nC]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, pica[7,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.2; das

;---- Cavity pressure ------
ymax = 140.5
ymin = 139.5
yint = 0.2
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, pica[5,*], position=position2, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Cavity Press [torr]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, pica[5,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.3


;---- Multivalve ------
ymax = 8
ymin = 0
yint = 2
plot, time, pica[9,*], position=position1, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Multivalve', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, pica[9,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.2

;---- Outletvale ------
ymax = 24
ymin = 13
yint = 3
plot, time, pica[17,*]/1000., position=position0, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Outlet Valve', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, pica[17,*]/1000., color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.2

ps_end, /JPEG
endif

if plot_now_meteo eq 1 then begin
;-------------- PLOT -------------------------------------------------------
position0 = [0.05, 0.80, 0.98, 0.99]
position1 = [0.05, 0.60, 0.98, 0.79]
position2 = [0.05, 0.40, 0.98, 0.59]
position3 = [0.05, 0.21, 0.98, 0.39]
position4 = [0.05, 0.030, 0.98, 0.20]

thick = 4
tama = 1.2
pw1 = strcompress(pw+'online_raw_chc_meteo.ps',/remove_all)
ps_start, filename=pw1, ysize=10, xsize=15

;---- Pressure ------
ymax = 550
ymin = 520;539
yint = 5
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, maap[5,*], position=position4, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Pressure [mBars]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, maap[5,*], color=fsc_color('brown'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, nephe[14,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, ozo[8,*], color=fsc_color('green'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, icos[6,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.1

dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=10) 
plot, time, inlet[9,*], position=position4, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Pressure [mBars]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, inlet[9,*], color=fsc_color('black'), THICK=1, psym=-cgsymcat(16), symsize=0.1


;---- Temperature ------
ymax = 30
ymin = -10
yint = 5
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, icos[5,*], position=position3, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Temp [!eo!nC]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, icos[5,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.1

dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=10) 
plot, time, inlet[9,*], position=position3, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Temp [!eo!nC]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, inlet[7,*], color=fsc_color('black'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, inlet[8,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.1


;---- RH ------
ymax = 110
ymin = 10
yint = 20
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, icos[7,*], position=position2, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='RH [%]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, icos[7,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.1

dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=10) 
plot, time, inlet[9,*], position=position2, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='RH [%]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, inlet[5,*], color=fsc_color('black'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, inlet[6,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.1

;---- Corriente FLOW ------
ymax = 10
ymin = -1
yint = 2
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=10) 
plot, time, inlet[11,*], position=position1, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Current [Amp]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, inlet[11,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.5

ymax = 200
ymin = 140
yint = 10
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=10) 
plot, time, inlet[10,*], position=position1, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, yticklen=0.01, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, xtickformat='(A2)', ytickformat='(A2)';, $
oplot, time, inlet[10,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.2


;------ add Wind  -------
ymax = 360
ymin = 0
yint = 60
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, icos[9,*], position=position0, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Wind direction [!eo!n]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $;, XTICKFORMAT='LABEL_DATE', $
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
;oplot, time, icos[9,*], color=fsc_color('blue'), psym = cgsymcat(16), symsize=0.5, THICK=thick
  x = size(icos)
  for l=0, x[2]-1 do begin
    if icos[8,l] ge 0 and icos[8,l] le 4 then begin
       plots, time[l], icos[9,l], psym=-cgsymcat(16), symsize=0.2, color=fsc_color('blue'), THICK=thick+thick+thick
    endif
    if icos[8,l] gt 4 and icos[8,l] le 6 then begin
       plots, time[l], icos[9,l], psym=-cgsymcat(16), symsize=0.4, color=fsc_color('blue'), THICK=thick+thick+thick
    endif
    if icos[8,l] ge 6 and icos[8,l] le 8 then begin
       plots, time[l], icos[9,l], psym=-cgsymcat(16), symsize=0.6, color=fsc_color('blue'), THICK=thick+thick+thick
    endif
    if icos[8,l] gt 8 then begin
       plots, time[l], icos[8,l], psym=-cgsymcat(16), symsize=1.0, color=fsc_color('blue'), THICK=thick+thick+thick
    endif
  endfor
ps_end, /JPEG
endif

;plot_now_aerosoles = 1
if plot_now_aerosoles eq 1 then begin
;-------------- PLOT -------------------------------------------------------
position0 = [0.05, 0.80, 0.98, 0.99]
position1 = [0.05, 0.60, 0.98, 0.79]
position2 = [0.05, 0.40, 0.98, 0.59]
position3 = [0.05, 0.21, 0.98, 0.39]
position4 = [0.05, 0.030, 0.98, 0.20]
pw1 = strcompress(pw+'online_raw_chc.ps',/remove_all)

;----- SMPS -------
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=5) 
thick= 4
tama = 1.2
maxi = 20e3
max_size = 500; nm
data = smps[5:75,*]
title=' '
;fw = 'online_raw_chc2.ps'
;plot_smps_fc_dates, time, dato, maxi, max_size, pw, fw, TITLE=title

mini = 1
xx = size(data)

su = where(data le 0, c)
if c gt 0 then data[su] = 1
data = rotate(data, 4)
data = alog(data)
mcoltab = 39
CTLOAD, mcoltab, /SILENT
maxImage = !D.TABLE_SIZE-9
plotPosition = FLTARR(4)
plotPosition = [0.10, 0.15, 0.95, 0.95]
!P.Position = plotPosition
DEVICE, GET_SCREEN_SIZE = screenSize
drawXSize = 0.78*screenSize[0]
drawYSize = 0.80*drawXSize
imagePosition = plotPosition
imagePosition[[0,2]] = FIX(imagePosition[[0,2]] * FLOAT(drawXSize))
imagePosition[[1,3]] = FIX(imagePosition[[1,3]] * FLOAT(drawYSize))
image = CONGRID(data, (imagePosition[2]-imagePosition[0]), (imagePosition[3]-imagePosition[1]), INTERP=minterp)
su = where(finite(image) eq 0, c)
image = BYTSCL(image, MIN=mini, MAX=alog(maxi), TOP=maxImage-7, /NaN)
if c gt 0 then image[su] = 255
y = [10.000, 10.575, 11.183, 11.825, 12.505, 13.224, 13.984, 14.788, 15.638, 16.536, 17.487, 18.492, 19.555, 20.679, 21.867, $
    23.124, 24.453, 25.859, 27.345, 28.917, 30.579, 32.336, 34.195, 36.160, 38.239, 40.437, 42.761, 45.219, 47.818, 50.566, $
    53.472, 56.546, 59.796, 63.233, 66.867, 70.711, 74.775, 79.073, 83.618, 88.424, 93.506, 98.881, 104.564, 110.574, $
    116.929, 123.650, 130.757, 138.273, 146.220, 154.625, 163.512, 172.910, 182.849, 193.358, 204.472, 216.225, 228.653, $
    241.795, 255.693, 270.389, 285.930, 302.365, 319.744, 338.122, 357.556, 378.107, 399.840, 422.821, 447.124, 472.823, 500.000]
ticks = LogLevels([10,500])
nticks = N_Elements(ticks)
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M'])  
ps_start, filename=pw1, ysize=10, xsize=15
plot, time, y, /NODATA, /NOERASE, xtickinterval=1, /ylog, yrange=[10,500], /ystyle, $
      YTICKS=nticks-1, YTICKV=ticks, yticklen=0, XTICKFORMAT='LABEL_DATE', XTICKUNITS = ['Time'], $;, XTICKFORMAT='(C(CDI,1x,CMoA))', $
      position=position4, ytitle = 'Diameter [nm]', $;TITLE='!7'+title, $;, xtitle = 'Local Time [Days]'
      XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
tvimage, image, /OVERPLOT
;----------------------- Dinuja los thicks ------------------------------------
plot, time, y, /NODATA, /NOERASE, xtickinterval=1, /ylog, yrange=[10.2,500+0.2], /ystyle, $
      position=position4, xgridstyle=2, xticklen=1, xminor=4, $
      XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, $
      charsize = tama, XTICKFORMAT = 'LABEL_DATE', XTICKUNITS = ['Time'];XTICKFORMAT='(C(CDI,1x,CMoA,1x,%Y))'
axis, yaxis = 0, yticks = 1, ytickn = ['10',string(500, format='(I3)')], yminor = 1, $
      XTHICK=thick, YTHICK=thick, CHARTHICK=thick, charsize = tama
;;------------------- Dibuja los contornos----------------
levels = 10
step = ((alog(maxi)+10.68) - mini) / levels
userLevels = IndGen(levels) * step + mini
print, userlevels
SetDecomposedState, 0, CurrentState=state
Contour, data, time, y, /Overplot, /follow, Levels=userLevels, Color=cgColor('black'), /ylog
SetDecomposedState, state

;---- MAAP ------
ymax = 6
ymin = -1
yint = 1
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, maap[9,*], position=position3, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='MAAP   eBC ['+Greek('mu')+'g/'+'m!e3!n'+']', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $; , XTICKFORMAT='LABEL_DATE'
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, maap[9,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, maap[10,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, maap[8,*], color=fsc_color('black'), THICK=1, psym=-cgsymcat(16), symsize=0.1

;---- AE31 ------
ymax = 6
ymin = -1
yint = 1
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=5) 
plot, time, ae31[5,*], position=position2, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='AE31   eBC ['+Greek('mu')+'g/'+'m!e3!n'+']', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $; , XTICKFORMAT='LABEL_DATE'
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, ae31[5,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, ae31[10,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, ae31[12,*], color=fsc_color('black'), THICK=1, psym=-cgsymcat(16), symsize=0.1

;---- Nwphe ------
ymax = 10
ymin = -2
yint = 2
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, nephe[8,*], position=position1, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Back Scattering [1/Mm]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $; , XTICKFORMAT='LABEL_DATE'
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, nephe[8,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, nephe[9,*], color=fsc_color('green'), THICK=1, psym=-cgsymcat(16), symsize=0.1
oplot, time, nephe[10,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.1

;---- Nwphe ------
;ymax = 120
;ymin = 0
;yint = 20
;dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
;time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
;plot, time, nephe[8,*], position=position0, /nodata, /noerase, $
;    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
;    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
;    title = '!7', ytitle='Scattering [1/Mm]', $
;    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $; , XTICKFORMAT='LABEL_DATE'
;    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
;oplot, time, nephe[5,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.1
;oplot, time, nephe[6,*], color=fsc_color('green'), THICK=1, psym=-cgsymcat(16), symsize=0.1
;oplot, time, nephe[7,*], color=fsc_color('red'), THICK=1, psym=-cgsymcat(16), symsize=0.1

;---- Ozo ------
ymax = 50
ymin = 20
yint = 5
dummy = LABEL_DATE(DATE_FORMAT=['%D/%M','%Y']) 
time = timegen(START=j0, FINAL=jf, UNITS='Minutes', STEP_SIZE=1) 
plot, time, nephe[8,*], position=position0, /nodata, /noerase, $
    yrange=[ymin,ymax], ytickinterval=yint, yminor = 1, $ 
    XTICKUNITS = ['Time'], xtickinterval=1, xminor = 12, $
    title = '!7', ytitle='Ozone [ppm]', $
    xgridstyle=2, xticklen=1, yticklen=0.01, xtickformat='(A2)', $; , XTICKFORMAT='LABEL_DATE'
    XTHICK=thick, YTHICK=thick, CHARTHICK=thick, THICK=thick, charsize = tama
oplot, time, ozo[5,*], color=fsc_color('blue'), THICK=1, psym=-cgsymcat(16), symsize=0.1
ps_end, /JPEG


endif



return
end

pro read_raw_maap, pr, j0, jf, dato
;***************************************************************
; YY MM DD hh mm pressure temp flowV  flowS eBC mass
; 0  1  2  3   4   5        6   7     8      9   10
cd, pr

;--- concatena los datos solicitados ---
nd = (jf-j0)+1
file = strarr(nd)
for i=j0, jf do begin
  caldat, i, month, day, year
  if month lt 10 then mes = '0'+string(month) else mes = string(month)
  if day   lt 10 then dia = '0'+string(day)   else dia = string(day) 
  

  ;----------- Elimina los valores NULL del archivo de datos original ----------------------------
  cmd = "tr -cd '\11\12\15\40-\176' < "+strcompress('CHC_MAAP_'+string(year)+mes+dia+'.dat', /remove_all)+" > "+strcompress('CHC_MAAP_'+string(year)+mes+dia+'2.dat', /remove_all)
  spawn, cmd
  cmd = "rm "+strcompress('CHC_MAAP_'+string(year)+mes+dia+'.dat', /remove_all)
  spawn, cmd
  cmd = "mv "+strcompress('CHC_MAAP_'+string(year)+mes+dia+'2.dat', /remove_all)+" "+strcompress('CHC_MAAP_'+string(year)+mes+dia+'.dat', /remove_all)
  spawn, cmd

  ;-- separa los datos de presión ----
  cmd = "sed -i 's/999.995/999.99 5/g' " + strcompress('CHC_MAAP_'+string(year)+mes+dia+'.dat', /remove_all)
  spawn, cmd
  cmd = "sed -i 's/  / /g' " + strcompress('CHC_MAAP_'+string(year)+mes+dia+'.dat', /remove_all)
  spawn, cmd

  file[i-j0] = strcompress('CHC_MAAP_'+string(year)+mes+dia+'.dat', /remove_all)
endfor
cmd = 'cat '+strjoin(file, ' ')
spawn, cmd, dato


;-- obtiene los numeros -----
x = size(dato) & n=x[1]
m = 11
data = fltarr(m,n)
for i=0L, n-1 do begin
  ;print, dato[i]
  div = strsplit(dato[i], ' ')
  time = float(strmid(dato[i], div[1], div[2]-div[0]))
  year = fix(strmid(dato[i], div[2], div[3]-div[2]))
  jul0 = julday(1,1,year)
  jul = jul0+fix(time)
  caldat, jul, month, day, year
  hour = fix((time-fix(time))*24.)
  minu = round((((time-fix(time))*24.)-hour)*60.)
  ;print, year, month, day, hour, minu
  ju1 = julday(month, day, year, hour, minu)-0.1666666 ; from UTC to LT
  caldat, ju1, mes1, dia1, anho1, hora1, minu1
  data[0,i] = anho1
  data[1,i] = mes1
  data[2,i] = dia1
  data[3,i] = hora1
  data[4,i] = minu1
  pres  = strmid(dato[i], div[5], div[6]-div[5])
  temp  = strmid(dato[i], div[6], div[7]-div[6])
  flowv = strmid(dato[i], div[7], div[8]-div[7])
  flows = strmid(dato[i], div[8], div[9]-div[8])
  bc    = strmid(dato[i], div[14], div[15]-div[14])
  mf    = strmid(dato[i], div[15], div[16]-div[15])
  data[5:10,i] = [pres, temp, flowv/60., flows/60., bc, mf]
endfor
;print, data

;-- completa cada 1 minuto ----
n = nd*24*60.
p = 0.
dato = fltarr(m,n)+!values.f_NaN
for i=j0, jf, 0.000694444 do begin; 0.0416667
  caldat, i, month, day, year, hour, minu
  ;print, year, month, day
  ;print, jajaja
  su = where(data[0,*] eq year and data[1,*] eq month and data[2,*] eq day and data[3,*] eq hour and data[4,*] eq minu, c)
  if c gt 0 then dato[*,p] = [year, month, day, hour, minu, data[5:10,su[0]]] else  dato[0:4,p] = [year, month, day, hour, minu]
  p=p+1.
endfor 
su = where(finite(dato[0,*]) ne 0, c)
dato = dato[*,su]
;print, dato[0:5,*]

return
end

pro read_raw_ae31, pr, j0, jf, dato
;***************************************************************
; YY MM DD hh mm eBC 370 470 520 590 660 880 950  flowS
; 0  1  2  3   4      5   6   7   8   9   10  11    12
cd, pr

;--- concatena los datos solicitados ---
nd = (jf-j0)+1
file = strarr(nd)
for i=j0, jf do begin
  caldat, i, month, day, year
  if month lt 10 then mes = '0'+string(month) else mes = string(month)
  if day   lt 10 then dia = '0'+string(day)   else dia = string(day) 
  file[i-j0] = strcompress('CHC_AETH_RAW_'+string(year)+'-'+mes+'-'+dia+'_V1-00.csv', /remove_all)
endfor
cmd = 'cat '+strjoin(file, ' ')
print, cmd
spawn, cmd, data
x = size(data) & n = x[1]


;-------------- Extrae la información del BC a cada wavelenght ---------------
m = 13
dato = fltarr(m,n)
for i=0L, n-1 do begin; n-1
    div = strsplit(data[i], ',') & len = strlen(data[i])
    if len gt 10 then begin
    day = fix(strmid(data[i], div[1]+1, 2)); day
    month1 = strmid(data[i], div[1]+4, 3); month
    case month1 of
       'dec':month=12
       'jan':month=1
       'feb':month=2
       'mar':month=3
       'apr':month=4
       'may':month=5
       'jun':month=6
       'jul':month=7
       'aug':month=8
       'sep':month=9
       'oct':month=10
       'nov':month=11
    endcase
    year = 2000+fix(strmid(data[i], div[1]+8, 2)); year
    hour = fix(strmid(data[i], div[2]+1, 2)); hour
    minu = fix(strmid(data[i], div[2]+4, 2)); min
    ju1 = julday(month, day, year, hour, minu)-0.1666666 ; from UTC to LT
    caldat, ju1, mes1, dia1, anho1, hora1, minu1
    dato[0,i] = anho1
    dato[1,i] = mes1
    dato[2,i] = dia1
    dato[3,i] = hora1
    dato[4,i] = minu1
    for j=5, m-2 do begin; m-1
        dato[j,i] = float(strmid(data[i], div[j-2], div[j-1]-div[j-2]-1))/1000.; ng to ug
    endfor
    dato[12,i] = float(strmid(data[i], div[10], div[11]-div[10]-1)); flow
    endif    
endfor
data = dato

;-- completa cada 5 minuto ----
n = nd*24*60.
p = 0.
dato = fltarr(m,n)+!values.f_NaN
for i=j0, jf, 0.0416667 do begin
  caldat, i, month, day, year, hour
  for minu=0, 55, 5 do begin
    su = where(data[0,*] eq year and data[1,*] eq month and data[2,*] eq day and data[3,*] eq hour and data[4,*] eq minu, c)
    if c gt 0 then dato[*,p] = [year, month, day, hour, minu, data[5:12,su[0]]] else dato[0:4,p] = [year, month, day, hour, minu]
    p=p+1.
  endfor
endfor 
su = where(finite(dato[0,*]) ne 0, c)
dato = dato[*,su]
;print, dato[0:5,*]


return
end

pro read_raw_nephe, pr, j0, jf, dato
;************************************************
; YY MM DD hh mm Scatter 450 525 635 BS 450 525 635  ST  ET  RH  pressure
; 0  1  2  3   4          5   6   7      8   9   10  11  12  13   14
cd, pr

;--- concatena los datos solicitados ---
nd = (jf-j0)+1
file = strarr(nd)
for i=j0, jf do begin
  caldat, i, month, day, year
  if month lt 10 then mes = '0'+string(month) else mes = string(month)
  if day   lt 10 then dia = '0'+string(day)   else dia = string(day) 
  file[i-j0] = strcompress('CHC_NEPH_RAW_'+string(year)+'-'+mes+'-'+dia+'_V1-00.csv', /remove_all)
endfor
cmd = 'cat '+strjoin(file, ' ')
print, cmd
spawn, cmd, data
x = size(data) & n = x[1]

m = 15
dato = fltarr(m,n)+!values.f_NaN
for i=0L, n-1 do begin; n-1
  ;print, data[i]
  div0 = strsplit(data[i], '-')
  year0 = fix(strmid(data[i], div0[0], div0[1]-div0[0]-1))
  if year0 eq 0 then year = year else year = year0
  month = strmid(data[i], div0[1], div0[2]-div0[1]-1)
  day = strmid(data[i], div0[2], 2)
  div1 = strsplit(data[i], ':')
  hour = strmid(data[i], div1[1]-3, 2)
  minu = strmid(data[i], div1[1], 2)
    ju1 = julday(month, day, year, hour, minu)-0.1666666 ; from UTC to LT
    caldat, ju1, mes1, dia1, anho1, hora1, minu1
  div2 = strsplit(data[i], ',')
  dato[0:4,i] = [anho1, mes1, dia1, hora1, minu1]
  for j=1, 10 do begin 
    dato[j+4,i] =  strmid(data[i], div2[j], div2[j+1]-div2[j]-1)
  endfor
endfor
data = dato

;-- completa cada 1 minuto ----
n = nd*24*60.
p = 0.
dato = fltarr(m,n)+!values.f_NaN
for i=j0, jf, 0.000694444 do begin
  caldat, i, month, day, year, hour, minu
  su = where(data[0,*] eq year and data[1,*] eq month and data[2,*] eq day and data[3,*] eq hour and data[4,*] eq minu, c)
  if c gt 0 then dato[*,p] = [year, month, day, hour, minu, data[5:m-1,su[0]]] else  dato[0:4,p] = [year, month, day, hour, minu]
  p=p+1.
endfor 
su = where(finite(dato[0,*]) ne 0, c)
dato = dato[*,su]
;print, dato[0:5,*]


return
end  

pro read_raw_ozono, pr, j0, jf, dato
;***************************************
; YY MM DD hh mm ozono  flowA  flowB  pressure
; 0  1  2  3   4   5       6      7      8
cd, pr

;--- concatena los datos solicitados ---
nd = (jf-j0)+1
file = strarr(nd)
for i=j0, jf do begin
  caldat, i, month, day, year
  if month lt 10 then mes = '0'+string(month) else mes = string(month)
  if day   lt 10 then dia = '0'+string(day)   else dia = string(day) 
  file[i-j0] = strcompress('OZO'+string(year-2000)+mes+dia+'_01M.dat', /remove_all)
endfor
cmd = 'cat '+strjoin(file, ' ')
print, cmd
spawn, cmd, data

su = where(strpos(data, 'AAAA') ne 0, c)
data = data[su]
su = where(strpos(data, 'samp') gt 0, c)
data = data[su]
x = size(data) & n = x[1]

m = 9
dato = fltarr(m,n)
for i=0, n-1 do begin
  year = strmid(data[i], 0, 4)
  month = strmid(data[i], 5, 2)
  day = strmid(data[i], 8, 2)
  hour = strmid(data[i], 11, 2)
  minu = strmid(data[i], 14, 2)
    ju1 = julday(month, day, year, hour, minu)-0.1666666 ; from UTC to LT
    caldat, ju1, mes1, dia1, anho1, hora1, minu1
  dato[0:4,i] = [anho1, mes1, dia1, hora1, minu1]
  div = strsplit(data[i], ' ')
  ozo = strmid(data[i], div[6], div[7]-div[6]-1)
  flowA = strmid(data[i], div[11], div[12]-div[11]-1)
  flowB = strmid(data[i], div[12], div[13]-div[12]-1)
  press = float(strmid(data[i], div[13], strlen(data[i])-div[13]))*1.33322; mmBars
  dato[5:m-1,i] = [ozo, flowA, flowB, press]
endfor  
data = dato

;-- completa cada 1 minuto ----
n = nd*24*60.
p = 0.
dato = fltarr(m,n)+!values.f_NaN
for i=j0, jf, 0.000694444 do begin
  caldat, i, month, day, year, hour, minu
  su = where(data[0,*] eq year and data[1,*] eq month and data[2,*] eq day and data[3,*] eq hour and data[4,*] eq minu, c)
  if c gt 0 then dato[*,p] = [year, month, day, hour, minu, data[5:m-1,su[0]]] else  dato[0:4,p] = [year, month, day, hour, minu]
  p=p+1.
endfor 
su = where(finite(dato[0,*]) ne 0, c)
dato = dato[*,su]
;print, dato[0:5,*]


return
end  

pro read_raw_smps, pr, j0, jf, dato
;***************************************************************
; YY MM DD hh mm  (71 diameters)
; 0  1  2  3   4   5-75
cd, pr

;--- concatena los datos solicitados ---
nd = (jf-j0)+1
file = strarr(nd)
for i=j0, jf do begin
  caldat, i, month, day, year
  if month lt 10 then mes = '0'+string(month) else mes = string(month)
  if day   lt 10 then dia = '0'+string(day)   else dia = string(day) 
  file[i-j0] = strcompress('SMPS_mpss_cha_'+string(year)+mes+dia+'.inv', /remove_all)
endfor
cmd = "grep '' /dev/null "+strjoin(file, ' ')
print, cmd
spawn, cmd, data

;--- just scans ----
su = where(strpos(data, '10.848000') eq -1, c); las diameter, no toma en cuenta las filas de diametros
data = data[su]
x = size(data) & nd=x[1]

; ------ to number ---
md = 76; 71 diametros + 5 date and time 
dato = fltarr(md,nd)
for i=0L, nd-1 do begin; 0L, nd-1
  s = strpos(data[i], ':'); los : viene del grep
  year = strmid(data[i], 14, 4)
  month = strmid(data[i], 18, 2)
  day = strmid(data[i], 20, 2)
  div = strsplit(data[i])
  t = strmid(data[i], s+1, div[1]-s-2)
  hour = fix(t); hour
  minu = round((float(t)-hour)*60.); minu; funciona mejor saca multiplos de 5
    ju1 = julday(month, day, year, hour, minu)-0.1666666 ; from UTC to LT
    caldat, ju1, mes1, dia1, anho1, hora1, minu1
  dato[0:4,i] = [anho1, mes1, dia1, hora1, minu1]
  for j=4, md-3 do begin; diametros
    dato[j+1,i] = strmid(data[i], div[j], div[j+1]-div[j]-1); de 0 a 69 scans
  endfor
  dato[md-1,i] = strmid(data[i], div[74], strlen(data[i])-div[74]); scan 70
endfor
data = dato

;-- completa cada 5 minuto ----
n = nd*24*60.
p = 0.
dato = fltarr(md,n)+!values.f_NaN
for i=j0, jf, 0.0416667 do begin
  caldat, i, month, day, year, hour
  for minu=0, 55, 5 do begin
    su = where(data[0,*] eq year and data[1,*] eq month and data[2,*] eq day and data[3,*] eq hour and data[4,*] eq minu, c)
    if c gt 0 then dato[*,p] = [year, month, day, hour, minu, data[5:md-1,su[0]]] else dato[0:4,p] = [year, month, day, hour, minu]
    p=p+1.
  endfor
endfor 
su = where(finite(dato[0,*]) ne 0, c)
dato = dato[*,su]

return
end

pro read_raw_inlet, pr, j0, jf, data
;***************************************
;YY MM DD hh mm  RH_A RH_i Temp_i Temp_A Pressure Flow Current(A) Flag
; 0  1  2  3  4   5    6     7      8       9      10      11      12
cd, pr

;--- concatena los datos solicitados ---
nd = (jf-j0)+1
file = strarr(nd)
for i=j0, jf do begin
  caldat, i, month, day, year
  if month lt 10 then mes = '0'+string(month) else mes = string(month)
  if day   lt 10 then dia = '0'+string(day)   else dia = string(day) 
  file[i-j0] = strcompress('INLET'+string(year-2000)+mes+dia+'.dat', /remove_all)
endfor
cmd = 'cat '+strjoin(file, ' ')+' > cat_inlet.inlet'
print, cmd
spawn, cmd
cmd = "sed -i 's/:/ /g' cat_inlet.inlet"
spawn, cmd
cmd = 'cat cat_inlet.inlet'
spawn, cmd, data
su = where(strpos(data, 'AAAA') ne 0, c)
data = data[su]
x = size(data) & n = x[1]

;--- get numbers --
m = 13
dato = fltarr(m,n)
for i=0, n-1 do begin
  div = strsplit(data[i], ' ')
  for j=0, m-2 do begin
    dato[j,i] = strmid(data[i], div[j], div[j+1]-div[j]-1)
  endfor
    dato[m-1,i] =  strmid(data[i], div[12], strlen(data[i])-div[12])
endfor 

;-- suma +10 a las horas antes de las 10 e la mañana --
su = where(dato[3,*] le 9, c)
p=0
for i=0L, c-1 do begin; 0, c-1
  for j=0, 9 do begin
    if dato[3,su[i]] eq j then dato[4,su[i]] =  dato[4,su[i]]+p
  endfor
  p=p+10 
  if p gt 59 then p=0
endfor
;print, dato[0:5,*]

;-- to local time --
ju1 = julday(dato[1,*], dato[2,*], dato[0,*], dato[3,*], dato[4,*])-0.1666666 ; from UTC to LT
caldat, ju1, mes1, dia1, anho1, hora1, minu1
dato[0:4,*] = [anho1, mes1, dia1, hora1, minu1]

;-- completa cada 10 minutos y lleva el datos al valor inicial del periodo
nd = (jf-j0+1)*24*6.
data = fltarr(m,nd)+!values.f_NaN
step = 10
p = 0L
for i=j0, jf, 0.0416667 do begin
  caldat, i, month, day, year, hour
  for minu=0, 59, 10 do begin
    su = where(dato[0,*] eq year and dato[1,*] eq month and dato[2,*] eq day and dato[3,*] eq hour  and (dato[4,*] ge minu and dato[4,*] lt step), c)
    if c gt 0 then data[*,p] = [year, month, day, hour, minu, dato[5:12,su[0]]] else data[0:4,p] = [year, month, day, hour, minu]
    step=step+10
    p=p+1
  endfor
  step = 10
endfor  
su = where(finite(data[0,*]) ne 0, c)
data = data[*,su]
;print, data[0:5,*]

return
end

pro read_raw_icos, pr, j0, jf, dato
;***************************************
;YY MM DD hh mm  temp Pressure  RH  WS  WD
; 0  1  2  3  4   5      6      7    8   9
cd, pr

;--- concatena los datos solicitados ---
nd = (jf-j0)+1
file = strarr(nd)
for i=j0, jf do begin
  caldat, i, month, day, year
  if month lt 10 then mes = '0'+string(month) else mes = string(month)
  if day   lt 10 then dia = '0'+string(day)   else dia = string(day) 
  file[i-j0] = strcompress('CHC_471_1_'+string(year)+mes+dia+'.mto', /remove_all)
endfor
cmd = 'cat '+strjoin(file, ' ')
print, cmd
spawn, cmd, data
su = where(strpos(data, 'DATE') ne 0, c)
data = data[su]
x = size(data) & n = x[1]

m = 10
dato = fltarr(m,n)+!values.f_NaN
for i=0, n-1 do begin
  year = strmid(data[i], 0, 4)
  month = strmid(data[i], 5, 2)
  day = strmid(data[i], 8, 2)
  hour = strmid(data[i], 11, 2)
  minu = strmid(data[i], 14, 2)
    ju1 = julday(month, day, year, hour, minu)-0.1666666 ; from UTC to LT
    caldat, ju1, mes1, dia1, anho1, hora1, minu1
  dato[0:4,i] = [anho1, mes1, dia1, hora1, minu1]
  div = strsplit(data[i], ' ')
  for j=2, 5 do begin
    dato[j+3,i] = strmid(data[i], div[j], div[j+1]-div[j]-1)
  endfor
  dato[m-1,i] = strmid(data[i], div[6], strlen(data[i])-div[6]); scan 70
endfor
data = dato

;-- completa cada 1 minuto ----
n = nd*24*60.
p = 0.
dato = fltarr(m,n)+!values.f_NaN
for i=j0, jf, 0.000694444 do begin; 0.0416667
  caldat, i, month, day, year, hour, minu
  ;print, year, month, day
  ;print, jajaja
  su = where(data[0,*] eq year and data[1,*] eq month and data[2,*] eq day and data[3,*] eq hour and data[4,*] eq minu, c)
  if c gt 0 then dato[*,p] = [year, month, day, hour, minu, data[5:m-1,su[0]]] else  dato[0:4,p] = [year, month, day, hour, minu]
  p=p+1.
endfor 
su = where(finite(dato[0,*]) ne 0, c)
dato = dato[*,su]
;print, dato[0:5,*]

return
end

pro read_picarro, pr, j0, jf, dato
;***********************************************
;YY MM DD hh mm  CavityPressure  CavityTemp  DasTemp  EtalonTemp  MPVPosition  CO ppb CO2 ppm CO2_dry ppm  CH4 ppm  CH4_dry ppm  H2O ppb  h2o_reported ppb
; 0  1  2  3  4        5              6         7         8           9          10     11        12         13         14          15          16         
cd, pr

;--- concatena los datos solicitados ---
nd = (jf-j0)+1
file = strarr(nd)
for i=j0, jf do begin
  caldat, i, month, day, year
  if month lt 10 then mes = '0'+string(month) else mes = string(month)
  if day   lt 10 then dia = '0'+string(day)   else dia = string(day) 
  cmd = 'unzip '+strcompress('CHC_474_'+string(year)+mes+dia+'.zip', /remove_all)
  print, cmd
  spawn, cmd
endfor
cmd = 'cat *.dat'
print, cmd
spawn, cmd, data
su = where(strpos(data, 'DATE') ne 0, c)
data = data[su]
x = size(data) & n = x[1]

m = 17
dato = fltarr(m,n)+!values.f_NaN
for i=0L, n-1 do begin
  year = strmid(data[i], 0, 4)
  month = strmid(data[i], 5, 2)
  day = strmid(data[i], 8, 2)
  hour = strmid(data[i], 26, 2)
  minu = strmid(data[i], 29, 2)
    ju1 = julday(month, day, year, hour, minu)-0.1666666 ; from UTC to LT
    caldat, ju1, mes1, dia1, anho1, hora1, minu1
  dato[0:4,i] = [anho1, mes1, dia1, hora1, minu1]
  div = strsplit(data[i], ' ')
  dato[5,i] = float(strmid(data[i], div[8], div[9]-div[8]-1));CavityPressure
  dato[6,i] = float(strmid(data[i], div[9], div[10]-div[9]-1)); CavityTemp
  dato[7,i] = float(strmid(data[i], div[10], div[11]-div[10]-1)); DasTemp
  dato[8,i] = float(strmid(data[i], div[11], div[12]-div[11]-1)); EtalonTemp
  dato[9,i] = fix(strmid(data[i], div[13], div[14]-div[13]-1));MPVPosition
  dato[10,i] = float(strmid(data[i], div[15], div[16]-div[15]-1))*1000.; CO ppb
  dato[11,i] = float(strmid(data[i], div[16], div[17]-div[16]-1)); CO2 ppm
  dato[12,i] = float(strmid(data[i], div[17], div[18]-div[17]-1)); CO2_dry ppm
  dato[13,i] = float(strmid(data[i], div[18], div[19]-div[18]-1)); CH4 ppm
  dato[14,i] = float(strmid(data[i], div[19], div[20]-div[19]-1)); CH4_dry ppm
  dato[15,i] = float(strmid(data[i], div[20], div[21]-div[20]-1))*1000.; H2O ppb
  dato[16,i] = float(strmid(data[i], div[21], div[22]-div[21]-1))*1000.; h2o_reported ppb
endfor
data = dato

;-- completa cada 1 minuto ----
n = nd*24*60.
p = 0L
dato = fltarr(m,n)+!values.f_NaN
for i=j0, jf, 0.000694444 do begin; 0.0416667
  caldat, i, month, day, year, hour, minu
  ;print, year, month, day, hour, minu
  su = where(data[0,*] eq year and data[1,*] eq month and data[2,*] eq day and data[3,*] eq hour and data[4,*] eq minu, c)
  if c gt 0 then begin
    dato[0:4,p] = [year, month, day, hour, minu]
    for j=5, m-1 do begin
      dato[j,p] = mean(data[j,su], /NaN) 
    endfor
    p=p+1L
  endif else begin
    dato[0:4,p] = [year, month, day, hour, minu]
    p=p+1L
  endelse
endfor 
su = where(finite(dato[0,*]) ne 0, c)
dato = dato[*,su]
;print, dato[0:5,*]

cmd = 'rm *.dat'
spawn, cmd

return
end  

pro read_picarro0, pr, j0, jf, dato
;***********************************************
;YY MM DD hh mm  CavityPressure  CavityTemp  DasTemp  EtalonTemp  MPVPosition  CO ppb CO2 ppm CO2_dry ppm  CH4 ppm  CH4_dry ppm  H2O ppb  h2o_reported ppb  Outletvalve
; 0  1  2  3  4        5              6         7         8           9          10     11        12         13         14          15          16              17
cd, pr

;--- busca datos solicitados *.txt ---
nd = (jf-j0)+1
file = strarr(nd)
for j=j0, jf do begin; j0, jf
  caldat, j, month, day, year
  if month lt 10 then mes = '0'+string(month) else mes = string(month)
  if day   lt 10 then dia = '0'+string(day)   else dia = string(day) 
  file = strcompress(+string(year)+mes+dia+'_UTC_minute.txt', /remove_all)
  lfile = file_search(file)
  if strlen(lfile) eq 0 then begin
    cmd = 'unzip '+strcompress('CHC_474_'+string(year)+mes+dia+'.zip', /remove_all) 
    print, cmd
    spawn, cmd
    cmd = 'cat *.dat'
    print, cmd
    spawn, cmd, data
    su = where(strpos(data, 'DATE') ne 0, c)
    data = data[su]
    x = size(data) & n = x[1]
    m = 18
    dato = fltarr(m,n)+!values.f_NaN
    for i=0L, n-1 do begin
      year = strmid(data[i], 0, 4)
      month = strmid(data[i], 5, 2)
      day = strmid(data[i], 8, 2)
      hour = strmid(data[i], 26, 2)
      minu = strmid(data[i], 29, 2)
      dato[0:4,i] = [year, month, day, hour, minu]
      div = strsplit(data[i], ' ')
      dato[5,i] = float(strmid(data[i], div[8], div[9]-div[8]-1));CavityPressure
      dato[6,i] = float(strmid(data[i], div[9], div[10]-div[9]-1)); CavityTemp
      dato[7,i] = float(strmid(data[i], div[10], div[11]-div[10]-1)); DasTemp
      dato[8,i] = float(strmid(data[i], div[11], div[12]-div[11]-1)); EtalonTemp
      dato[9,i] = fix(strmid(data[i], div[13], div[14]-div[13]-1));MPVPosition
      dato[10,i] = float(strmid(data[i], div[15], div[16]-div[15]-1))*1000.; CO ppb
      dato[11,i] = float(strmid(data[i], div[16], div[17]-div[16]-1)); CO2 ppm
      dato[12,i] = float(strmid(data[i], div[17], div[18]-div[17]-1)); CO2_dry ppm
      dato[13,i] = float(strmid(data[i], div[18], div[19]-div[18]-1)); CH4 ppm
      dato[14,i] = float(strmid(data[i], div[19], div[20]-div[19]-1)); CH4_dry ppm
      dato[15,i] = float(strmid(data[i], div[20], div[21]-div[20]-1)); H2O ppm
      dato[16,i] = float(strmid(data[i], div[21], div[22]-div[21]-1)); h2o_reported ppm
      dato[17,i] = float(strmid(data[i], div[14], div[15]-div[14]-1));Outletvalve
    endfor
    ;-- completa cada 1 minuto ----
    openw, uw, file, /get_lun
    printf, uw, 'YY MM DD hh mm  CavityPressure  CavityTemp  DasTemp  EtalonTemp  MPVPosition  COppb  CO2ppm  CO2_dryppm  CH4ppm  CH4_dryppm  H2Oppm  H2O_reportedppm  Outletvalve'
    for ho=0, 23 do begin; 0.0416667
      for mi=0, 59 do begin  
        su = where(dato[3,*] eq ho and dato[4,*] eq mi, c)
        if c gt 0 then begin
          printf, uw, [year, month, day, ho, mi, $
          mean(dato[5,su], /NaN), mean(dato[6,su], /NaN), mean(dato[7,su], /NaN), mean(dato[8,su], /NaN), $
          mean(dato[9,su], /NaN), mean(dato[10,su], /NaN), mean(dato[11,su], /NaN), mean(dato[12,su], /NaN), $
          mean(dato[13,su], /NaN), mean(dato[14,su], /NaN), mean(dato[15,su], /NaN), mean(dato[16,su], /NaN), $
          mean(dato[17,su], /NaN)], format='(5I4, 13F12.3)' 
        endif else begin 
          printf, uw, [year, month, day, ho, mi, !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, $
          !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, $
          !values.f_NaN], format='(5I4, 13F12.3)' 
        endelse
      endfor
    endfor 
    close, uw
    free_lun, uw
    cmd = 'rm *.dat'
    spawn, cmd
  endif
endfor

;--- concatena los datos promediados por minuto ---
cmd = 'cat *.txt'
spawn, cmd, data
su = where(strpos(data, 'YY') ne 0, c)
data = data[su]
x = size(data) & n = x[1]
m = 18
dato = fltarr(m,n)
p=0L
for i=0L, n-1 do begin
  div = strsplit(data[i], ' ')
  xd = size(div)
  for j=0, xd[1]-2 do begin
    dato[j,i] = strmid(data[i], div[j], div[j+1]-div[j]-1)
  endfor
    dato[m-1,i] = strmid(data[i], div[xd[1]-1], strlen(data[i])-div[xd[1]-1])
endfor

;-- to local time --
ju1 = julday(dato[1,*], dato[2,*], dato[0,*], dato[3,*], dato[4,*])-0.1666666 ; from UTC to LT
caldat, ju1, mes1, dia1, anho1, hora1, minu1
dato[0:4,*] = [anho1, mes1, dia1, hora1, minu1]

;-- completa horas al final del día local
caldat, jf, month, day, year
n = 4*60.
d = fltarr(m,n)
p = 0
for ho=20, 23 do begin; 0.0416667
  for mi=0, 59 do begin  
    d[*,p] = [year, month, day, ho, mi, !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, $
          !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, !values.f_NaN, $
          !values.f_NaN] 
    p=p+1
  endfor
endfor

dato = transpose([transpose(dato), transpose(d)])
su = where(julday(dato[1,*], dato[2,*], dato[0,*]) ge j0, c)
dato = dato[*,su]

return
end 